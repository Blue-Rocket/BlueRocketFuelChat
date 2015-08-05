//
//  ConversationTableViewCell.h
//  BRFChat
//
//  Created by David Foote on 8/4/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"

@interface ConversationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

- (void)displayMessage:(ChatMessage *)msg;

@end
