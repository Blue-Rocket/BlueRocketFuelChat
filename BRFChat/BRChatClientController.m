//
//  BRChatClientController.m
//  BRFChat
//
//  Created by Brian A. Hill on 8/5/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "BRChatClientController.h"
#import "BRChatClient.h"
#import "AppDelegate+BRChat.h"
#import "ChatMessage.h"
#import "Contact.h"

@interface BRChatClientController()

@property (nonatomic,strong) NSMutableArray *channels;  // Current subscribed channels list
@property (nonatomic, strong)BRChatClient *client;
@property (nonatomic,strong)NSMutableArray * conversationList;

@end

@implementation BRChatClientController

- (id)initWithConfiguration:(PNConfiguration *)config
{
     if ( self = [super init] ) {
        _client = [BRChatClient clientWithConfiguration:config];

        [_client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
            // Check whether request successfully completed or not.
            if (!status.isError) {
                // Handle downloaded server time token using: result.data.timetoken
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:(result.data.timetoken.longValue / 10000000)];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.timeStyle = NSDateFormatterShortStyle;
                dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                
                NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [dateFormatter setLocale:usLocale];
                NSString *timestamp = [dateFormatter stringFromDate:date];
                NSLog(@"Server date/time: %@\n", timestamp);
            }
            // Request processing failed.
            else {
                
                // Handle time token download error. Check 'category' property to find
                // out possible issue because of which request did fail.
                //
                // Request can be resent using: [status retry];
            }
        }];
         
        return self;
    }
    return nil;
}


- (void)subscribeToChatChannel:(NSString *)channel
{
    if (![_channels containsObject:channel]) {
        [_client subscribeToChannels:@[channel] withPresence:NO];
        [_channels addObject:channel];
    }
}

#pragma mark - PubNub Event Handlers

- (void)sendMessage:(NSString *)msg onChannel:(NSString *)msgChannel
{
    
    NSString *d = [NSString stringWithFormat: @"{ \"text\" : \"%@\" , \"channel\" :  \"%@\" }",msg, msgChannel];
    
    [_client publish:d toChannel: msgChannel withCompletion:^(PNPublishStatus *status){
        // Check whether request successfully completed
        if (!status.isError) {
            // Add message to conversation
            [self addMessageToConversation:msg onChannel:msgChannel author:@"me"];  //TEMP: Get username from user profile
        } else {
            // Failure: handle error.
            // Check category property to find possible issue
            //Request can be resent using [status retry];
        }
    }];
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (message.data.actualChannel) {
        // Message received on channel group stored in
        [self addMessageToConversation:message];
    } else {
        // Message received on channel stored in
        // message.data.subscribedChannel
        [self addMessageToConversation:message];
    }
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message, message.data.subscribedChannel, message.data.timetoken);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    if (status.category == PNUnexpectedDisconnectCategory){
        // Connectivity lost
    } else if (status.category == PNConnectedCategory)  {
        // Connected event. You can do stuff like publish and know you'll get it
        // Or just use the conneceted event to confirm you are subscribed for
        // UI / internal notifications, etc.
/*        [appDelegate.BRChatClient publish:@"Hello from the PubNub SDK" toChannel:_msgChannel withCompletion:^(PNPublishStatus *status){
            // Check whether request successfully completed
            if (!status.isError) {
                // Success
            } else {
                // Failure: handle error.
                // Check category property to find possible issue
                //Request can be resent using [status retry];
            }
        }];
 */
    } else if (status.category == PNReconnectedCategory) {
        // Event occurs when radio / connectivity is lost then regained
    } else if (status.category == PNDecryptionErrorCategory) {
        // Decryption error.
        // Probably client configured to encrypt messages and
        // on live data feed it received plain text
    }
    
}

// Add incoming message to conversation
- (void)addMessageToConversation:(PNMessageResult *)message
{
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    
    ChatMessage *chatMsg = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ChatMessage"
                            inManagedObjectContext:context];
    
    if ([message.data.message isKindOfClass:[NSString class]]) {
        [chatMsg setValue:message.data.message forKey:@"text"];
        [chatMsg setValue:message.data.subscribedChannel forKey:@"channel"];
        [chatMsg setValue:@"unknown" forKey:@"author"];
    } else if ([message.data.message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = message.data.message;
        [chatMsg setValue:[d objectForKey:@"text"] forKey:@"text"];
        NSString *chan = [d objectForKey:@"channel"];
        [chatMsg setValue:chan forKey:@"channel"];
        [chatMsg setValue:[self userForChatId:chan] forKey:@"author"];
    }
    [chatMsg setValue:[NSDate dateWithTimeIntervalSince1970:(message.data.timetoken.longValue / 10000000)] forKey:@"timestamp"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return;
    }
    
    Conversation * c = [self conversationForChannel:message.data.subscribedChannel];
    [c addMessagesObject:chatMsg];
    [c setValue:[NSDate date] forKey: @"timestamp"];
    NSLog(@"Messages: %lu",[c.messages count]);
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"willReloadData" object:self];
    }
}

// Add outgoing message to conversation
- (void)addMessageToConversation:(NSString *)msg onChannel:(NSString *)channel author:(NSString *)author
{
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    
    ChatMessage *chatMsg = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ChatMessage"
                            inManagedObjectContext:context];
    [chatMsg setValue:USERNAME forKey:@"author"];   // TODO: Get value from user object
    [chatMsg setValue:msg forKey:@"text"];
    [chatMsg setValue:USER_ID forKey:@"channel"];   // TODO: Get value from user object
    [chatMsg setValue:[NSDate date] forKey:@"timestamp"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return;
    }
    Conversation * c = [self conversationForChannel:channel];
    [c addMessagesObject:chatMsg];
    [c setValue:[NSDate date] forKey: @"timestamp"];
    
    NSLog(@"Messages: %lu",[c.messages count]);
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"willReloadData" object:self];
    }
}

// Find the conversation for the given channel
// Create a new conversation if none exists
- (Conversation *)conversationForChannel:(NSString *)channel
{
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Conversation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channel == %@", channel]];
    NSError *error;
    NSArray *cv = [context executeFetchRequest:fetchRequest error:&error];
    
    Conversation *conv;
    if ([cv count] == 0) {    // No conversation on this channel, create one
        conv = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Conversation"
                          inManagedObjectContext:context];
        [conv setValue:[self userForChatId:channel] forKey:@"author"];        //TEMP: Get user name
        [conv setValue:channel forKey:@"channel"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    } else {
        conv = [cv objectAtIndex:0];
    }
    return conv;
}



// TEMP: Get this info from addressbook
- (NSString *)userForChatId:(NSString *)chatId
{
    NSArray *allContacts = [appDelegate.addrBook.contacts allObjects];
    NSArray *filteredContacts = [allContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"chatId == %@", chatId]];
    
    if ([filteredContacts count] > 0){
        Contact *c = [filteredContacts objectAtIndex:0];
        return c.displayName;
    } else
        return  @"";
}

@end
