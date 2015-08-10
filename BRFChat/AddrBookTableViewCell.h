//
//  AddrBookTableViewCell.h
//  BRFChat
//
//  Created by Brian A. Hill on 8/10/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddrBookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@end
