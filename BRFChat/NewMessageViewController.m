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

@interface NewMessageViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *messageAddressTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation NewMessageViewController

UITableView *addrTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForNotifications];
//    [_messageAddressTextField becomeFirstResponder];
    
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
    CGFloat kbHeight = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
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
    
    _messageTextView.text = [self lookUpInAddressBook:text];
}

- (NSString *)lookUpInAddressBook:(NSString *)text
{
    
    NSArray *allContacts = [appDelegate.addrBook.contacts allObjects];
    
    NSArray *filteredContacts = [allContacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"displayName BEGINSWITH [cd] %@", text]];

    NSArray *sortedArray;
    sortedArray = [filteredContacts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Contact *)a displayName];
        NSString *second =  [(Contact *)b displayName];
        return [first compare:second];
    }];
    
    NSMutableString *contactsText = [NSMutableString stringWithCapacity:0];
    for (Contact *c in sortedArray) {
        [contactsText appendString:c.displayName];
        [contactsText appendString:@"\n"];
    }
    return contactsText;
}


@end
