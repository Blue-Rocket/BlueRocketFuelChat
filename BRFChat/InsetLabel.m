//
//  InsetLabel.m
//  BRFChat
//
//  Created by David Foote on 8/4/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
