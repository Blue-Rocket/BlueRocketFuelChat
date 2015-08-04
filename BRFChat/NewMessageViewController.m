//
//  NewMessageViewController.m
//  BRFChat
//
//  Created by Brian A. Hill on 8/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "NewMessageViewController.h"

@interface NewMessageViewController ()

@end

@implementation NewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
    
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
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //   [[NSNotificationCenter defaultCenter] addObserver:self
    //                                           selector:@selector(keyboardWillBeHidden:)
    //                                               name:UIKeyboardWillHideNotification object:nil];
    
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




@end
