//
//  MainMenuViewController.m
//  CatchMe
//
//  Created by Jonathon Simister on 10/17/12.
//  Copyright (c) 2012 Same Level Software. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (IBAction)activateAccelerometer {
    
    NSString* ison;
    
    ison = [db getSetting:@"on"];
    
    if([ison isEqualToString:@"on"]) {
        [swOn setOn:true];
        
        NSLog(@"on loaded");
        //retrieve accelerometer data
        motionManager = [[CMMotionManager alloc]init];
        
        //if ([motionManager isAccelerometerAvailable]){
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [motionManager
         startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
             NSLog(@"X = %.04f, Y = %.04f, Z = %.04f", accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
         }];
        /*}else{
         NSLog(@"Accelerometer did not work.");
         }*/
    } else {
        [swOn setOn:false];
        NSLog(@"off loaded");
    }
    /*
    // retrieve accelerometer data
    motionManager = [[CMMotionManager alloc]init];
    
    if ([motionManager isAccelerometerAvailable]){
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [motionManager
         startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
             
             double x_accel = accelerometerData.acceleration.x;
             double y_accel = accelerometerData.acceleration.y;
             double z_accel = accelerometerData.acceleration.z;
             
             NSLog(@"X = %.06f, Y = %.06f, Z = %.06f", x_accel, y_accel, z_accel);
             
             //double vector_sum = sqrt(x_accel * x_accel + y_accel * y_accel + z_accel * z_accel);
             //NSLog(@"Vector Sum = %.06f", vector_sum);
         }];
    }
    else{
        NSLog(@"Accelerometer did not work.");
    }
    */
}

- (void)viewWillAppear:(BOOL)animated {
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 0.05; // 20 Hz
    
    [motionManager startDeviceMotionUpdates];
     NSLog(@"Pitch = %.02f, Roll = %.02f, Yaw = %.02f", motionManager.deviceMotion.attitude.pitch, motionManager.deviceMotion.attitude.roll, motionManager.deviceMotion.attitude.yaw);
    

}

- (void)viewDidDisappear:(BOOL)animated {
    if (swOn.on) {
        [db setSetting:@"on" value:@"yes"];
    } else {
        [db setSetting:@"on" value:@"no"];
    }
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever the user moves it updates
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; //accuracy
    [locationManager startUpdatingLocation];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [db closeDB];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal *3600 - minutes *60;
    NSLog(@"%d° %d' %1.4f\"",degrees, minutes, seconds);
    
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal *60;
    seconds = decimal *3600 - minutes *60;
    NSLog(@"%d° %d' %1.4f\"",degrees, minutes, seconds);
}

@end
