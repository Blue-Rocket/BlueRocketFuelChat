//
//  AppDelegate.h
//  BRFChat
//
//  Created by Brian A. Hill on 8/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])


// TODO: TEMP - get info from user object
#define USER_ID @"999"
#define USERNAME @"Me"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;



@end

