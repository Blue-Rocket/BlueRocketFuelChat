//
//  Created by Brian A. Hill on 7/20/15.
//
//  Copyright (c) 2015 Blue Rocket, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AppDelegate+BRChat.h"
#import "ConversationsViewController.h"
#import "ConversationTheirTableViewCell.h"
#import "ConversationsMyTableViewCell.h"
#import "BRDateHelper.h"
#import "ChatMessage.h"

@interface ConversationsViewController ()
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *conversationTextField;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceContraint;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *conversationScrollView;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomConstraint;

@end

@implementation ConversationsViewController

CGFloat kbHeight = 0.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
/*
    // Add a "new messages" button
    UIButton *newMessageButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [newMessageButton addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:newMessageButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
 */   
    [self registerForKeyboardNotifications];
    [self initChat];

    [_conversationTextField becomeFirstResponder];  // Show keyboard

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initChat
{
    [appDelegate.BRChatClient addListener:self];
    [appDelegate.BRChatClient subscribeToChannels:@[_msgChannel] withPresence:NO];
}

#pragma mark - PubNub Event Handlers

- (IBAction)sendMessage:(id)sender {

    [appDelegate.BRChatClient publish:_conversationTextField.text toChannel:_msgChannel withCompletion:^(PNPublishStatus *status){
        // Check whether request successfully completed
        if (!status.isError) {
            // Success
        } else {
            // Failure: handle error.
            // Check category property to find possible issue
            //Request can be resent using [status retry];
        }
    }];
    _conversationTextField.text = @"";
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (message.data.actualChannel) {
        // Message received on channel group stored in
        // message.data.subscribedChannel
    } else {
        // Message received on channel stored in
        // message.data.subscribedChannel
        [self handleMessage:message];
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
        [appDelegate.BRChatClient publish:@"Hello from the PubNub SDK" toChannel:_msgChannel withCompletion:^(PNPublishStatus *status){
            // Check whether request successfully completed
            if (!status.isError) {
                // Success
            } else {
                // Failure: handle error.
                // Check category property to find possible issue
                //Request can be resent using [status retry];
            }
        }];
    } else if (status.category == PNReconnectedCategory) {
        // Event occurs when radio / connectivity is lost then regained
    } else if (status.category == PNDecryptionErrorCategory) {
        // Decryption error.
        // Probably client configured to encrypt messages and
        // on live data feed it received plain text
    }
    
}

- (void)handleMessage:(PNMessageResult *)message
{
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    ChatMessage *chatMsg = [NSEntityDescription
                                insertNewObjectForEntityForName:@"ChatMessage"
                                inManagedObjectContext:context];
    [chatMsg setValue:@"Brian" forKey:@"author"];
    [chatMsg setValue:message.data.message forKey:@"text"];
    [chatMsg setValue:message.data.subscribedChannel forKey:@"channel"];
    [chatMsg setValue:[NSDate dateWithTimeIntervalSince1970:(message.data.timetoken.longValue / 10000000)] forKey:@"timestamp"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

    [_conversation addMessagesObject:chatMsg];

    [self.tableView reloadData];
    
    [self scrollToBottomOfTableView];
}

#pragma mark - UITableVewDataSource delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_conversation.messages count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *sortedArray;
    sortedArray = [_conversation.messages.allObjects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(ChatMessage *)a timestamp];
        NSDate *second = [(ChatMessage *)b timestamp];
        return [first compare:second];
    }];
    
    ChatMessage *message = sortedArray[indexPath.row];
    BOOL mine = [message.channel isEqualToString:@"ID_0"];
    
    if (!mine) {
        static NSString *cellIdentifier = @"theirMessageCellIdentifier";
        

        ConversationTheirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[ConversationTheirTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
        }
        
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:10]; //custom font
        NSString *text = message.text;
        
        cell.messageLabel.backgroundColor = [UIColor grayColor];
        
        cell.messageLabel.text = text;
        cell.messageLabel.font = font;
        cell.messageLabel.numberOfLines = 0;
        cell.messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        cell.messageLabel.adjustsFontSizeToFitWidth = NO;
        cell.messageLabel.clipsToBounds = YES;
        cell.messageLabel.textColor = [UIColor whiteColor];
        cell.messageLabel.textAlignment = NSTextAlignmentCenter;
        [[cell.messageLabel layer] setCornerRadius:4];
        
        cell.timestampLabel.text = [BRDateHelper timeFromNow:message.timestamp];
        [cell.timestampLabel sizeToFit];
        return cell;
    } else {
        static NSString *cellIdentifier = @"myMessageCellIdentifier";
        
        
        ConversationTheirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[ConversationTheirTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
        }
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        NSString *text = message.text;
        
        cell.messageLabel.backgroundColor = [UIColor greenColor];
        
        cell.messageLabel.text = text;
        cell.messageLabel.font = font;
        cell.messageLabel.numberOfLines = 0;
        cell.messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        cell.messageLabel.adjustsFontSizeToFitWidth = NO;
        cell.messageLabel.clipsToBounds = YES;
        cell.messageLabel.textColor = [UIColor whiteColor];
        cell.messageLabel.textAlignment = NSTextAlignmentCenter;
        [[cell.messageLabel layer] setCornerRadius:4];
        
        cell.timestampLabel.text = [BRDateHelper timeFromNow:message.timestamp];
        [cell.timestampLabel sizeToFit];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Go to new message view
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sortedArray;
    sortedArray = [_conversation.messages.allObjects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(ChatMessage *)a timestamp];
        NSDate *second = [(ChatMessage *)b timestamp];
        return [first compare:second];
    }];
    
    ChatMessage *message = sortedArray[indexPath.row];

    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    
    gettingSizeLabel.text = message.text;
    
    CGSize maximumLabelSize = CGSizeMake(175, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    
    if ((expectSize.height + 20) > 44)
        return expectSize.height + 20;
    else return 44;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return NO;
}

#pragma mark - Handle the keyboard
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
 //   [[NSNotificationCenter defaultCenter] addObserver:self
  //                                           selector:@selector(keyboardWillBeHidden:)
  //                                               name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)scrollToBottomOfTableView {
    float bottomOfContent = _tableView.contentSize.height - kbHeight;
    float topOfTextField = _conversationTextField.frame.origin.y - 10;
    CGPoint messagesOffset;
    
    if (_tableView.contentSize.height > _tableView.frame.size.height) {
        bottomOfContent = _tableView.contentSize.height;
        messagesOffset = CGPointMake(0, (bottomOfContent - topOfTextField));
        [_tableView setContentOffset:messagesOffset animated:YES];
    } else {
        bottomOfContent = _tableView.contentSize.height - kbHeight;
        messagesOffset = CGPointMake(0, (topOfTextField - bottomOfContent));
        [_tableView setContentInset:UIEdgeInsetsMake(messagesOffset.y, 0, 0, 0)];
    }
    
    NSLog(@"Content Bottom: %f\tTextField top %f\tOffset %f", bottomOfContent,topOfTextField,messagesOffset.y);
    
    [_tableView layoutIfNeeded];
}

- (void)updateKeyboardConstraint:(CGFloat)height animationDuration:(NSTimeInterval)duration {
    self.bottomSpaceContraint.constant = height;
    self.textFieldBottomConstraint.constant = height + 10;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [_conversationScrollView setContentInset:UIEdgeInsetsMake(0, 0, height, 0)];
        
        CGPoint bottomOffset = CGPointMake(0, _conversationScrollView.contentSize.height - (_conversationScrollView.bounds.size.height - height));
        [_conversationScrollView setContentOffset:bottomOffset animated:YES];
        [_conversationScrollView layoutIfNeeded];
        
        float bottomOfContent = _tableView.contentSize.height - kbHeight;
        float topOfTextField = _conversationTextField.frame.origin.y - 10;
        CGPoint messagesOffset;
        
        if (_tableView.contentSize.height > _tableView.frame.size.height) {
            bottomOfContent = _tableView.contentSize.height;
            messagesOffset = CGPointMake(0, (bottomOfContent - topOfTextField));
            [_tableView setContentOffset:messagesOffset animated:YES];
        } else {
            bottomOfContent = _tableView.contentSize.height - height;
            messagesOffset = CGPointMake(0, (topOfTextField - bottomOfContent));
            [_tableView setContentInset:UIEdgeInsetsMake(messagesOffset.y, 0, 0, 0)];
        }

        NSLog(@"Content Bottom: %f\tTextField top %f\tOffset %f", bottomOfContent,topOfTextField,messagesOffset.y);

        [_tableView layoutIfNeeded];
        
    } completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    kbHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [self updateKeyboardConstraint:kbHeight animationDuration:0.25];
    NSLog(@"HEIGHT: %f", kbHeight);
}


@end
