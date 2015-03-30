//
//  Styles.m
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 18/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import "Styles.h"



@implementation Styles
- (instancetype)init
{
    self = [super init];
    if (self) {        

    }
    return self;
}

+(UIColor*)BLUE{
    return [UIColor colorWithRed:0 green:0.788 blue:0.863 alpha:1.0];
}

+(UIColor *)GREEN{
    return [UIColor colorWithRed:0.627 green:0.808 blue:0.306 alpha:1.0];
}

+(UIColor *)ORANGE{
    return [UIColor colorWithRed:1.00 green:0.471 blue:0.0 alpha:1.0];
}
@end
