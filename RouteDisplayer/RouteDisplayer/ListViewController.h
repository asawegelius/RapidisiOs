//
//  FirstViewController.h
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 04/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AGSRouteTaskDelegate, AGSGeoprocessorDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *routeNames;
@property (nonatomic, strong) NSMutableArray *routeGraphics;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) AGSGeoprocessor *gpTask;

@end

