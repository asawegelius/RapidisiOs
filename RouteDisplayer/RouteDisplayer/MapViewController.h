//
//  SecondViewController.h
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 04/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import <CoreLocation/CoreLocation.h>
#import "Styles.h"


@interface MapViewController : UIViewController <AGSMapViewLayerDelegate, CLLocationManagerDelegate, AGSCalloutDelegate>

@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLPlacemark *placemark;
@property (strong, nonatomic) AGSGraphicsLayer* myGraphicsLayer;
@property (strong ,nonatomic) AGSCalloutTemplate* calloutTemplate;


@end

