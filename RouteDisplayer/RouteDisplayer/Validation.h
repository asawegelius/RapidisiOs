//
//  Validation.h
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 17/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Validation : NSObject

+(BOOL)isValidPassword:(NSString*) string;
+(BOOL)isValidName:(NSString*) string;
+(BOOL)isNumeric:(NSString*) string;

@end
