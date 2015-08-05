//
//  NewMessageViewController.h
//  BRFChat
//
//  Created by Brian A. Hill on 8/3/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PubNub/PubNub.h>

@interface NewMessageViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,PNObjectEventListener>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end
