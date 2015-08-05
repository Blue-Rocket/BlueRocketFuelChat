//
//  ConversationsMyTableViewCell.m
//  Pods
//
//  Created by Brian A. Hill on 7/27/15.
//
//

#import "ConversationsMyTableViewCell.h"

@implementation ConversationsMyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)displayMessage:(ChatMessage *)msg {
    //TODO:Remove so that the storyboard setting controls
    self.messageLabel.backgroundColor = [UIColor greenColor];
    [super displayMessage:msg];
}

@end
