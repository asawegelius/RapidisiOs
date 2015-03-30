//
//  Routes.m
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 06/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//


#import "Routes.h"
@implementation Routes

@synthesize routeElements;
@synthesize route;

#pragma mark Singleton Methods

+ (id)sharedRoutes {
    static Routes *sharedRoutes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRoutes = [[self alloc] init];
    });
    return sharedRoutes;
}

- (id)init {
    if (self = [super init]) {
        routeElements = nil;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

-(AGSFeatureSet *)getRouteElements{
    return routeElements;
}

-(AGSFeatureSet *)getRoute{
    return route;
}

@end

