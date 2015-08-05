//
//  Contact.h
//  
//
//  Created by Brian A. Hill on 8/4/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * chatId;
@property (nonatomic, retain) NSManagedObject *addressbook;

@end
