//
//  ConversationTableViewCell.m
//  BRFChat
//
//  Created by David Foote on 8/4/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "ConversationTableViewCell.h"
#import "BRDateHelper.h"

@implementation ConversationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)displayMessage:(ChatMessage *)msg {
    self.messageLabel.text = msg.text;
    self.timestampLabel.text = [BRDateHelper timeFromNow:msg.timestamp];

    [[self.messageLabel layer] setCornerRadius:4];
    [self.messageLabel sizeToFit];
    [self.timestampLabel sizeToFit];
}
@end
