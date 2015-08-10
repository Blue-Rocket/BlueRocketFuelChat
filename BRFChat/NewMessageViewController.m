//
//  NewMessageViewController.m
//  BRFChat
//
//  Created by Brian A. Hill on 8/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "NewMessageViewController.h"
#import "AppDelegate+BRChat.h"
#import "Contact.h"
#import "BRChatClient.h"
#import "ConversationsViewController.h"

@interface NewMessageViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *messageAddressTextField;
@property (weak, nonatomic) IBOutlet UITableView *addrTable;
- (IBAction)sendMessage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation NewMessageViewController

NSInteger tableRows = 0;
NSMutableArray *contactNames;
NSString *msgChannel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForNotifications];
    contactNames = [[NSMutableArray alloc] initWithCapacity:0];
    _addrTable.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _messageAddressTextField.text = @"";
    _messageTextView.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Handle the keyboard
// Call this method somewhere in your view controller setup code.
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(addressTextDidChange:)
                                            name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)updateKeyboardConstraint:(CGFloat)height animationDuration:(NSTimeInterval)duration {
    self.bottomConstraint.constant = height;
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    CGFloat kbHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height + 20;
    [self updateKeyboardConstraint:kbHeight animationDuration:0.25];
    NSLog(@"HEIGHT: %f", kbHeight);
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
}

- (void)addressTextDidChange:(NSNotification *)notif
{
    NSString *text = [(UITextField *)notif.object text];
    
    [self lookUpInAddressBook:text];
}

- (void)lookUpInAddressBook:(NSString *)text
{
    
    NSArray *allContacts = [appDelegate.addrBook.contacts allObjects];
    
    NSArray *filteredContacts = [allContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName BEGINSWITH [cd] %@", text]];

    NSArray *sortedArray;
    sortedArray = [filteredContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Contact *)a displayName];
        NSString *second =  [(Contact *)b displayName];
        return [first compare:second];
    }];
    
    [contactNames removeAllObjects];
    tableRows = [sortedArray count];

    for (Contact *c in sortedArray) {
        [contactNames addObject:c];
    }
    _addrTable.hidden = NO;
    [_addrTable reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"newMessageAddrCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
    }
    Contact *c = [contactNames objectAtIndex:indexPath.row];
    cell.textLabel.text = c.displayName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableRows;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *c = [contactNames objectAtIndex:indexPath.row];
    _messageAddressTextField.text = c.displayName;
    _addrTable.hidden = YES;
//    [_messageTextView becomeFirstResponder];
    
    // TODO: Add delete recipient button -------------
    
    // Get ChatId from contact
    msgChannel = c.chatId;

}


- (IBAction)sendMessage:(id)sender {
    
    [appDelegate.chatClientController sendMessage: _messageTextView.text onChannel:msgChannel];
    
    // If the ConversationsViewController is on the view stack, pop to it.
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ConversationsViewController class]]) {
            ConversationsViewController *cvc = (ConversationsViewController *)vc;
            cvc.msgChannel = msgChannel;
            cvc.conversation = [appDelegate.chatClientController conversationForChannel:msgChannel];
            [self.navigationController popToViewController:cvc animated:YES];
            return;
        }
    }
    // If not, push it.
    ConversationsViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"convVC"];
    cvc.msgChannel = msgChannel;
    cvc.conversation = [appDelegate.chatClientController conversationForChannel:msgChannel];
    [self.navigationController pushViewController:cvc animated:YES];
}


@end
