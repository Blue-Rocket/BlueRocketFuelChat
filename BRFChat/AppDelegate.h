//
//  AppDelegate.h
//  BRFChat
//
//  Created by Brian A. Hill on 8/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

