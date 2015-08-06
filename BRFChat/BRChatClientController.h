//
//  BRChatClientController.h
//  BRFChat
//
//  Created by Brian A. Hill on 8/5/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PubNub/PubNub.h>
#import "Conversation.h"

@interface BRChatClientController : NSObject <PNObjectEventListener>

- (id)initWithConfiguration:(PNConfiguration *)config;
- (void)sendMessage:(NSString *)msg onChannel:(NSString *)msgChannel;
- (void)subscribeToChatChannel:(NSString *)channel;
- (Conversation *)conversationForChannel:(NSString *)channel;

@end
