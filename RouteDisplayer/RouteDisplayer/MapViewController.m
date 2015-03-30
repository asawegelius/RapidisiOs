//
//  SecondViewController.m
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 04/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import "MapViewController.h"
#import "Routes.h"
@import MapKit;

@interface MapViewController ()

@end

@implementation MapViewController{
    CLLocation *currentLocation;
    NSURL* url;
    AGSEnvelope *envelope;
}



-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    envelope = [[AGSEnvelope alloc] init];
    self.calloutTemplate = [[AGSCalloutTemplate alloc]init];
    self.calloutTemplate.titleTemplate = @"${Description}";
    
    self.mapView.layerDelegate = self;
    self.mapView.callout.delegate = self;
    url = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Tiled Layer"];
    self.mapView.layerDelegate = self;
    
    self.mapView.locationDisplay.autoPanMode = AGSLocationDisplayAutoPanModeNavigation ;
    self.mapView.locationDisplay.navigationPointHeightFactor  = 0.25; //25% along the center line from the bottom edge to the top edge
    
    self.myGraphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.myGraphicsLayer withName:@"Graphics Layer"];
    [self displayDirections];

}

-(void) mapViewDidLoad:(AGSMapView*)mapView {
    [self.mapView.locationDisplay startDataSource];
}



- (void)viewDidUnload {
    //Stop the GPS, undo the map rotation (if any)
    if(self.mapView.locationDisplay.dataSourceStarted){
        [self.mapView.locationDisplay stopDataSource];
        self.mapView.rotationAngle = 0;
    }
    self.mapView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayDirections {
    [self.myGraphicsLayer removeAllGraphics];
    Routes *routes = [Routes sharedRoutes];
    AGSFeatureSet *route = [routes getRoute];
    AGSFeatureSet *routeElements = [routes getRouteElements];
    for(AGSGraphic *graphic in route.features){
        if (graphic.geometry.spatialReference == self.mapView.spatialReference) {
            [self drawPolyline:(AGSPolyline*)graphic.geometry fromFeature:graphic];
            envelope = graphic.geometry.envelope;
        }
        else {
            AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
            AGSGeometry *newGeometry = [geometryEngine projectGeometry:graphic.geometry toSpatialReference:self.mapView.spatialReference];
            [self drawPolyline:(AGSPolyline*)newGeometry fromFeature:graphic];
            //envelope = newGeometry.envelope;
            envelope = [[AGSEnvelope alloc] initWithXmin:newGeometry.envelope.xmin - 0.004
                                                    ymin:newGeometry.envelope.ymin - 0.004
                                                    xmax:newGeometry.envelope.xmax + 0.004
                                                    ymax:newGeometry.envelope.ymax + 0.004
                                        spatialReference:self.mapView.spatialReference];
            
        }
    }
    
    //for (AGSGraphic* graphic in routeElements.features) {
    for (int i = (int)routeElements.features.count - 1; i >= 0; i--) {
        AGSGraphic* graphic = routeElements.features[i];
        if (graphic.geometry.spatialReference != self.mapView.spatialReference) {
            AGSGeometryEngine *geometryEngine = [AGSGeometryEngine defaultGeometryEngine];
            AGSGeometry *newGeometry = [geometryEngine projectGeometry:graphic.geometry toSpatialReference:self.mapView.spatialReference];
            [self drawPoint:(AGSPoint*)newGeometry fromFeature:graphic];
            }
        else {
            [self drawPoint:(AGSPoint*)graphic.geometry fromFeature:graphic];
        }
    }
    self.mapView.rotationAngle = 0;
    [self.mapView zoomToEnvelope: envelope animated:YES];
}

-(void)drawPoint:(AGSPoint*) point fromFeature: (AGSGraphic*) feature{
    AGSPictureMarkerSymbol* pushpin = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"marker"];
    pushpin.offset = CGPointMake(0,25);
    pushpin.leaderPoint = CGPointMake(0, -25);
    NSDictionary *allAttr = [feature allAttributes];
    AGSTextSymbol *textSymbol=[[AGSTextSymbol alloc]initWithText:[NSString stringWithFormat:@"%@", [allAttr valueForKey:@"SequenceNumber"]] color:[Styles ORANGE]];
    textSymbol.offset =CGPointMake(0,33);
    textSymbol.bold = YES;
    AGSCompositeSymbol *symb = [[AGSCompositeSymbol alloc] init];
    [symb addSymbol: pushpin];
    [symb addSymbol:textSymbol];
    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:point symbol:symb attributes:[feature allAttributes]];
    [self.myGraphicsLayer addGraphic:graphic];
}

-(void)drawPolyline:(AGSPolyline*)polyline fromFeature: (AGSGraphic*) feature{
    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:polyline symbol:[self lineSymbol] attributes:[feature allAttributes]];
    [self.myGraphicsLayer addGraphic:graphic];

}

-(AGSSimpleMarkerSymbol*)markerSymbol{
    AGSSimpleMarkerSymbol *circle = [[AGSSimpleMarkerSymbol alloc] initWithColor:[Styles ORANGE] ];
    circle.style = AGSSimpleMarkerSymbolStyleCircle ;
    circle.color =[UIColor colorWithRed:0.957 green:0.467 blue:0.129 alpha:1.0];
    return circle;
}

-(AGSSimpleLineSymbol*)lineSymbol {
 
    AGSSimpleLineSymbol *lineSymbol = [[AGSSimpleLineSymbol alloc] init];
    
    lineSymbol.style = AGSSimpleLineSymbolStyleSolid;
    lineSymbol.color = [Styles ORANGE];
    
    
    lineSymbol.width = 4;
    return lineSymbol;
    
}

-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint*)mapPoint{
    //Specify the callout's contents
    NSDictionary *allAttr = [feature allAttributes];
    _mapView.callout.title = (NSString*)[allAttr valueForKey:@"Description"];
    _mapView.callout.detail =(NSString*)[allAttr valueForKey:@"StopType"];
    return YES;
}

- (void) didClickAccessoryButtonForCallout:(AGSCallout *)callout {
    AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;
    if([graphic.geometry isKindOfClass:[AGSPoint class] ]){
        AGSPoint *point = (AGSPoint*)graphic.geometry;
        [self openMapsWithDestination:point andName:[[graphic allAttributes] valueForKey:@"Description"]];
    }
    
}



-(void) openMapsWithDestination: (AGSPoint*) stop  andName: (NSString*) name{
    CLLocationCoordinate2D destLocation = CLLocationCoordinate2DMake(stop.y , stop.x);
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: destLocation addressDictionary: nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = name;
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}

@end



