//
//  GetRouteViewController.m
//  RouteDisplayer
///
//  Created by Åsa Susanna Wegelius on 04/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import "GetRouteViewController.h"
#import "Routes.h"

#define kGPTask @"http://logistics-test.rapidis.com:6080/arcgis/rest/services/RlpAppGetRoute/GPServer/RlpAppGetRoute"
#define kGPTaskSecure @"http://logistics-test.rapidis.com:6080/arcgis/rest/services/SecureRlpAppGetRoute/GPServer/RlpAppGetRoute"

@interface GetRouteViewController ()

@end

@implementation GetRouteViewController{
    NSString * route_id;
}
@synthesize activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nameTxtField.delegate = self;
    self.nameTxtField.tag = 1;
    self.nameTxtField.returnKeyType = UIReturnKeyDone;
    self.passWordTxtField.delegate = self;
    self.passWordTxtField.tag = 2;
    self.passWordTxtField.returnKeyType = UIReturnKeyDone;
    self.vehicleIdTxtField.delegate = self;
    self.vehicleIdTxtField.tag = 3;
    self.vehicleIdTxtField.returnKeyType = UIReturnKeyDone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark handling the form methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self resetErrors];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSInteger tag = textField.tag;
    switch (tag) {
        case 1:
            [self.nameImg setImage:[UIImage imageNamed:@"person"]];
            if ([self.statusLbl.text  isEqual: @"Name is required"]) {
                self.statusLbl.text = @"";
            }
            break;
        case 2:
            [self.passwordImg setImage:[UIImage imageNamed:@"password"]];
            if ([self.statusLbl.text  isEqual: @"Password is required"]) {
                self.statusLbl.text = @"";
            }
            break;
        case 3:
            [self.idImg setImage:[UIImage imageNamed:@"id"]];
            if ([self.statusLbl.text  isEqual: @"Input must be a number"]) {
                self.statusLbl.text = @"";
            }
        default:
            break;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([self validateAllFields]){
        [self submit:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self validateAllFields];
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)validateAllFields{
    // test name
    if (![Validation isValidName:self.nameTxtField.text]) {
        self.statusLbl.textColor = [Styles ORANGE];
        self.statusLbl.text = @"Name is required";
        [self.nameImg setImage:[UIImage imageNamed:@"person_err"]];
        return NO;
    }
    else {
        [self.nameImg setImage:[UIImage imageNamed:@"person_ok"]];
    }
    if (![Validation isValidPassword:self.passWordTxtField.text]) {
        self.statusLbl.textColor = [Styles ORANGE];
        self.statusLbl.text = @"password is required";
        [self.passwordImg setImage:[UIImage imageNamed:@"password_err"]];
        return NO;
    }
    else{
        [self.passwordImg setImage:[UIImage imageNamed:@"password_ok"]];
    }
    // test vehicle id
    if (![Validation isNumeric:self.vehicleIdTxtField.text]) {
        //show error message if gp task fails
        self.statusLbl.textColor = [Styles ORANGE];
        self.statusLbl.text = @"Input must be a number";
        [self.idImg setImage:[UIImage imageNamed:@"id_err"]];
        return NO;
    }
    else{
        [self.idImg setImage:[UIImage imageNamed:@"id_ok"]];
    }
    return YES;
}

-(void)resetErrors{
    self.statusLbl.text = @"";
    if ([Validation isValidName:self.nameTxtField.text]) {
        [self.nameImg setImage:[UIImage imageNamed:@"person_ok"]];
    }
    else{
        [self.nameImg setImage:[UIImage imageNamed:@"person"]];
    }
    if ([Validation isValidPassword:self.passWordTxtField.text]){
        [self.passwordImg setImage:[UIImage imageNamed:@"password_ok"]];
    }
    else{
        [self.passwordImg setImage:[UIImage imageNamed:@"password"]];
    }
    if ([Validation isNumeric: self.vehicleIdTxtField.text]) {
        [self.idImg setImage:[UIImage imageNamed:@"id_ok"]];
    }
    else{
        [self.idImg setImage:[UIImage imageNamed:@"id"]];
    }
}

-(void)resetForm{
    [self.nameImg setImage:[UIImage imageNamed:@"person"]];
    [self.passwordImg setImage:[UIImage imageNamed:@"password"]];
    [self.idImg setImage:[UIImage imageNamed:@"id"]];
    self.nameTxtField.text = @"";
    self.passWordTxtField.text = @"";
    self.vehicleIdTxtField.text = @"";
}

- (IBAction)submit:(id)sender {
    if ([self validateAllFields]) {
        route_id = self.vehicleIdTxtField.text;
        //create the credential
        AGSCredential* cred = [[AGSCredential alloc] initWithUser:self.nameTxtField.text password:self.passWordTxtField.text];
        //set up the gp task
        self.gpTask = [AGSGeoprocessor geoprocessorWithURL:[NSURL URLWithString:kGPTaskSecure] credential:cred];
        self.gpTask.delegate = self; //required to respond to the gp response.

        NSNumber* input = [[[NSNumberFormatter alloc]init] numberFromString:self.vehicleIdTxtField.text];
        long inputValue = [input longValue];
        
        AGSGPParameterValue *driversId =[AGSGPParameterValue parameterWithName: @"VehicleID" type: AGSGPParameterTypeLong  value: [NSNumber numberWithLong:inputValue]];
        AGSGPParameterValue *calculationId = [AGSGPParameterValue parameterWithName:@"CalculationID" type:AGSGPParameterTypeLong  value: [NSNumber numberWithLong:0]];
        NSArray *params = [NSArray arrayWithObjects:driversId, calculationId, nil];
        [self.gpTask submitJobWithParameters:params];
        [self.activityIndicator startAnimating];
    }

}

#pragma mark geoprocessor methods


//this is the delegate method that gets called when job submits successfully
- (void)geoprocessor:(AGSGeoprocessor *)geoprocessor operation:(NSOperation *)op didSubmitJob:(AGSGPJobInfo *)jobInfo {
    NSString *message = [NSString stringWithFormat:@"Fetching the route %@!", route_id];
    //update status
    self.statusLbl.textColor = [UIColor darkGrayColor];
    self.statusLbl.text = message;

}



//if error encountered while executing gp task
- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op ofType:(AGSGPAsyncOperationType) opType didFailWithError:(NSError *) error forJob:(NSString *) jobId {
    
    //show error message if gp task fails
    self.statusLbl.textColor = [Styles ORANGE];
    self.statusLbl.text =[error localizedDescription];
    
    [self.activityIndicator stopAnimating];
}



- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op jobDidFail:(AGSGPJobInfo *) jobInfo {
    
    for (AGSGPMessage* msg in jobInfo.messages) {
        NSLog(@"%@", msg.description);
    }
    
    //update staus
    self.statusLbl.textColor = [Styles ORANGE];
    self.statusLbl.text = @"Job Failed!";
    
    [self.activityIndicator stopAnimating];
}

- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op didQueryWithResult:(AGSGPParameterValue *) result forJob:(NSString *) jobId {    //get the result
    AGSFeatureSet *fs = result.value;
    Routes *sharedRoute = [Routes sharedRoutes];
    if ([result.name  isEqual: @"RouteElements"]) {
        [sharedRoute setRouteElements:fs];
    }
    else if([result.name isEqual:@"Route"]){
        [sharedRoute setRoute:fs];
    }
    
    //showing status
    if (sharedRoute.getRouteElements != nil && sharedRoute.getRoute != nil) {
        if (sharedRoute.getRouteElements.features.count < 1) {
            self.statusLbl.textColor = [Styles ORANGE];
            self.statusLbl.text = @"No route for that id";
        }
        else {
            self.statusLbl.textColor = [UIColor darkGrayColor];
            self.statusLbl.text = @"Added the route!";
            [self resetForm];
        }
        [self.activityIndicator stopAnimating];
        
    }
    
}


- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult {
    
    
}

- (void)geoprocessor:(AGSGeoprocessor *) geoprocessor operation:(NSOperation *) op jobDidSucceed:(AGSGPJobInfo *) jobInfo {
    
    //job succeed..query result data
    [geoprocessor queryResultData:jobInfo.jobId paramName:@"RouteElements"];
    [geoprocessor queryResultData:jobInfo.jobId paramName:@"Route"];
}


@end
