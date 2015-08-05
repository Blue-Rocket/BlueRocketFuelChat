//
//  InsetLabel.h
//  BRFChat
//
//  Created by David Foote on 8/4/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE

@interface InsetLabel : UILabel
@property (nonatomic, assign) IBInspectable CGFloat leftEdge;
@property (nonatomic, assign) IBInspectable CGFloat rightEdge;
@property (nonatomic, assign) IBInspectable CGFloat topEdge;
@property (nonatomic, assign) IBInspectable CGFloat bottomEdge;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
- (id)initWithTopInset:(CGFloat)top andLeft:(CGFloat)left andBottom:(CGFloat)bottom andRight:(CGFloat)right;
@end
