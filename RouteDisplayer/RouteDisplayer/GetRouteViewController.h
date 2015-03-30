//
//  GetRouteViewController.h
//  RouteDisplayer
//
//  Created by Åsa Susanna Wegelius on 04/02/15.
//  Copyright (c) 2015 Åsa Susanna Wegelius. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "Validation.h"
#import "Styles.h"

@interface GetRouteViewController : UIViewController <AGSRouteTaskDelegate, AGSGeoprocessorDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *statusLbl;
@property (strong, nonatomic) IBOutlet UITextField *nameTxtField;
@property (strong, nonatomic) IBOutlet UITextField *passWordTxtField;

@property (strong, nonatomic) IBOutlet UITextField *vehicleIdTxtField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) AGSGeoprocessor *gpTask;


- (IBAction)submit:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *nameImg;

@property (strong, nonatomic) IBOutlet UIImageView *passwordImg;

@property (strong, nonatomic) IBOutlet UIImageView *idImg;

@end
