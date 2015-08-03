//
//  ChatMessage.h
//  
//
//  Created by Brian A. Hill on 8/3/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Conversation *conversation;

@end
