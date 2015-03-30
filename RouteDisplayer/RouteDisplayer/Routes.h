//
//  Routes.h
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 06/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>


@interface Routes : NSObject {
    AGSFeatureSet* routeElements;
    AGSFeatureSet* route;
}

@property (nonatomic, retain) AGSFeatureSet* routeElements;
@property (nonatomic, retain) AGSFeatureSet* route;
    
+ (id)sharedRoutes;

-(AGSFeatureSet*) getRouteElements;
-(AGSFeatureSet*) getRoute;

@end
