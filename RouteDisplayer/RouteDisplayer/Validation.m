//
//  Validation.m
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 17/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import "Validation.h"

@implementation Validation

UIColor *errorBg;

-(instancetype)init{
    errorBg = [UIColor colorWithRed:0.957 green:0.467 blue:0.129 alpha:1.0];
    return self;
}


+(BOOL)isValidPassword:(NSString*) string {
    //NSString *passwordRegexp = @"/(\\p{L}|[0-9]){2,15}/i";
    //
    //NSPredicate* nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegexp];
    
    return [string length] > 0;
}

+(BOOL)isValidName:(NSString*) string {
    //NSString* nameRegex = @"/\\p{L}{2,15}/i";
    //NSPredicate* nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    
    return [string length] > 0;
   
}

+(BOOL) isNumeric:(NSString*) string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    return  [scanner scanInteger:NULL] && [scanner isAtEnd];
}




@end
