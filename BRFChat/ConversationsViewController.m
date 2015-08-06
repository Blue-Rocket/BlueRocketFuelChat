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
#import "InsetLabel.h"

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

    [self registerForKeyboardNotifications];
    [self registerForChatNotifications];
    [self initChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initChat
{
    _msgChannel = _conversation.channel;
}

#pragma mark - PubNub Event Handlers

- (IBAction)sendMessage:(id)sender {

    [appDelegate.chatClientController sendMessage:_conversationTextField.text onChannel:_msgChannel];
    _conversationTextField.text = @"";
}


- (void)willReloadData:(NSNotification *)notif
{
    // Retrieve conversations
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Conversation" inManagedObjectContext:context];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"channel == %@", _msgChannel]];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *conversationList = [context executeFetchRequest:fetchRequest error:&error];
    
    _conversation = [conversationList objectAtIndex:0];
    
    [self.tableView reloadData];
    [self scrollToBottomOfTableView];
}

#pragma mark - UITableVewDataSource delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_conversation.messages count];
}

- (ChatMessage *)findMessageAtPath:(NSIndexPath *)indexPath
{
    // TODO: abstract message retrieval into method for reuse
    NSArray *sortedArray;
    sortedArray = [_conversation.messages.allObjects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(ChatMessage *)a timestamp];
        NSDate *second = [(ChatMessage *)b timestamp];
        return [first compare:second];
    }];
    
    ChatMessage *message = sortedArray[indexPath.row];
    
    NSLog(@"MESSAGE: %@",message.text);
    return message;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *message;
    message = [self findMessageAtPath:indexPath];
    NSString *cellIdentifier = @"theirMessageCellIdentifier";
    BOOL mine = [message.channel isEqualToString:@"999"];
    if (mine) {
        cellIdentifier = @"myMessageCellIdentifier";
    }
    ConversationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSAssert(cell != nil, @"Must use a known cell identifier (theirMessageCellIdentifier or myMessageCellIdentifier)");
    [cell displayMessage:message];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *message;
    message = [self findMessageAtPath:indexPath];
    //TODO: get cell from tableview so that we aren't duplicating settings and so that the cell can tell us the height based on My or Theirs as Theirs needs extra height for avatar if message length is short
    
    InsetLabel *gettingSizeLabel = [[InsetLabel alloc] initWithTopInset:5.0 andLeft:10.0 andBottom:5.0 andRight:10.0];
    gettingSizeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)registerForChatNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willReloadData:)
                                                 name:@"willReloadData" object:nil];
    
    
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

- (void)keyboardWillBeHidden:(NSNotification *)notif
{
    kbHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [self updateKeyboardConstraint:10 animationDuration:0.25];
    [_conversationTextField resignFirstResponder];
}

@end
