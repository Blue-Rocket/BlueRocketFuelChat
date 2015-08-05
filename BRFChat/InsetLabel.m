//
//  InsetLabel.m
//  BRFChat
//
//  Created by David Foote on 8/4/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "InsetLabel.h"

@implementation InsetLabel


- (id)initWithTopInset:(CGFloat)top andLeft:(CGFloat)left andBottom:(CGFloat)bottom andRight:(CGFloat)right
{
    self = [super init];
    
    if(self)
    {
        self.topEdge = top;
        self.leftEdge = left;
        self.bottomEdge = bottom;
        self.rightEdge = right;
        // We were not loaded from a NIB
        [self labelDidLoad:NO];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        // We were not loaded from a NIB
        [self labelDidLoad:NO];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // We were loaded from a NIB
    [self labelDidLoad:YES];
}

- (void)labelDidLoad:(BOOL)loadedFromNib
{
    self.edgeInsets = UIEdgeInsetsMake(self.topEdge, self.leftEdge, self.bottomEdge, self.rightEdge);
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect newRect = UIEdgeInsetsInsetRect(rect, self.edgeInsets);
    [super drawTextInRect:newRect];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

@end
