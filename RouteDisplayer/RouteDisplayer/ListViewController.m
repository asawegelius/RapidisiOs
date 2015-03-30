//
//  FirstViewController.m
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 04/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import "ListViewController.h"
#import "Routes.h"


#define kGPTask @"http://logistics-test.rapidis.com:6080/arcgis/rest/services/RlpAppSendStatus/GPServer/RlpAppSendStatus"

@interface ListViewController ()

@end

@implementation ListViewController
NSIndexPath* selectedIndex; //nil until a row is selected

- (void)viewDidLoad {
    [super viewDidLoad];
    //set up the gp task
    self.gpTask = [AGSGeoprocessor geoprocessorWithURL:[NSURL URLWithString:kGPTask]];
    self.gpTask.delegate = self; //required to respond to the gp response.
    selectedIndex = nil;
    self.routeNames = [[NSMutableArray alloc] init];
    self.routeGraphics = [[NSMutableArray alloc] init];
    Routes *routes = [Routes sharedRoutes];
    AGSFeatureSet *fs = [routes getRouteElements];
    if (fs != nil) {
        for(AGSGraphic *graphic in fs.features){
            NSString *name = [[graphic allAttributes] valueForKey:@"Description"];
            NSMutableDictionary *nameAndChecked = [NSMutableDictionary new];
            [nameAndChecked setObject:[NSString stringWithString:name] forKey:@"name"];
            [nameAndChecked setObject:[NSNumber numberWithBool:NO]forKey:@"checked"];
            [self.routeNames addObject:nameAndChecked];
            [self.routeGraphics addObject:graphic];
        }

    }
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    Routes *routes = [Routes sharedRoutes];

    if (self.routeGraphics.count == 0 || (self.routeGraphics.count > 0 &&[self.routeGraphics objectAtIndex:0] != routes.routeElements.features[0])) {
        [self.routeNames removeAllObjects];
        [self.routeGraphics removeAllObjects];
        AGSFeatureSet *fs = [routes getRouteElements];
        if (fs != nil) {
            for(AGSGraphic *graphic in fs.features){
                NSString *name = [[graphic allAttributes] valueForKey:@"Description"];
                NSMutableDictionary *nameAndChecked = [NSMutableDictionary new];
                [nameAndChecked setObject:[NSString stringWithString:name] forKey:@"name"];
                [nameAndChecked setObject:[NSNumber numberWithBool:NO]forKey:@"checked"];
                [self.routeNames addObject:nameAndChecked];
                [self.routeGraphics addObject:graphic];
            }
            
        }
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark handling the table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_routeNames count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSString *name = [[[self.routeGraphics objectAtIndex:indexPath.row] allAttributes] valueForKey:@"Description"];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];

    cell.textLabel.text = name;
    cell.detailTextLabel.text = @"blablabla";
    NSMutableDictionary *selected = (NSMutableDictionary*)[self.routeNames objectAtIndex:indexPath.row] ;
    bool checked = [[selected valueForKey:@"checked"] boolValue];
    UIImage *image = (checked) ? [UIImage   imageNamed:@"checked"] : [UIImage imageNamed:@"upload"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selected = (NSDictionary*)[self.routeNames objectAtIndex:indexPath.row];
    if([[selected valueForKey:@"checked"] boolValue] == NO){
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Send Status"
                                  message:@"Are you sure you want to send status?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             selectedIndex = indexPath;
                             [self sendJob:indexPath];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    }

}



#pragma mark geoprocessor methods

- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op jobDidSucceed:(AGSGPJobInfo *) jobInfo {
    
    //job succeed..query result data
    NSLog(@"job success!");
    NSDictionary *selected = (NSDictionary*)[self.routeNames objectAtIndex:selectedIndex.row];
    bool checked = [[selected valueForKey:@"checked"] boolValue];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:selectedIndex];
    UIButton *button = (UIButton *)cell.accessoryView;
    UIImage *newImage = (checked) ? [UIImage imageNamed:@"upload"] : [UIImage imageNamed:@"checked"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    [selected setValue:[NSNumber numberWithBool:!checked] forKey:@"checked"];
}

//if error encountered while executing gp task
- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op ofType:(AGSGPAsyncOperationType) opType didFailWithError:(NSError *) error forJob:(NSString *) jobId {
    
    //show error message if gp task fails
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult {
    
    
}

- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op jobDidFail:(AGSGPJobInfo *) jobInfo {
    
    for (AGSGPMessage* msg in jobInfo.messages) {
        NSLog(@"%@", msg.description);
    }
    
    //update staus
    //self.statusLbl.text = @"Job Failed!";
}


- (void)sendJob: (NSIndexPath*) indexPath{
    
    AGSGraphic *graphic = (AGSGraphic*)[self.routeGraphics objectAtIndex: indexPath.row];
    AGSGPParameterValue *calcId = [AGSGPParameterValue parameterWithName:@"CalculationID" type:AGSGPParameterTypeLong  value: [graphic attributeForKey:@"CalculationID"]];
    AGSGPParameterValue * vehicleId = [AGSGPParameterValue parameterWithName:@"VehicleID" type:AGSGPParameterTypeLong  value: [graphic attributeForKey:@"VehicleID"]];
    AGSGPParameterValue *sequenceNo = [AGSGPParameterValue parameterWithName:@"SequenceNumber" type:AGSGPParameterTypeLong  value: [graphic attributeForKey:@"SequenceNumber"]];
    AGSGPParameterValue *date = [AGSGPParameterValue parameterWithName:@"ArrivalTime" type:AGSGPParameterTypeDate  value: [NSDate date]];
    NSArray *params = [NSArray arrayWithObjects:calcId, vehicleId, sequenceNo, date, nil];
    
    [self.gpTask submitJobWithParameters:params];
    
}

//this is the delegate method that gets called when job submits successfully
- (void)geoprocessor:(AGSGeoprocessor *)geoprocessor operation:(NSOperation *)op didSubmitJob:(AGSGPJobInfo *)jobInfo {
    
    //update status
    //self.statusLbl.text = @"Geoprocessing Job Submitted!";
    NSLog(@"Geoprocessing Job Submitted!");
    
}



@end
