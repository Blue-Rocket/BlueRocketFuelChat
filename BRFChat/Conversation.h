//
//  Conversation.h
//  
//
//  Created by Brian A. Hill on 8/4/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatMessage;

@interface Conversation : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *messages;
@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(ChatMessage *)value;
- (void)removeMessagesObject:(ChatMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
