//
//  BRChatClient.m
//  BRChat
//
//  Created by Brian A. Hill on 7/21/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
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

#import "BRChatClient.h"

@implementation BRChatClient : PubNub


- (id)initWithConfiguration:(PNConfiguration *)config
{
    BRChatClient *brc = [BRChatClient clientWithConfiguration:config];
    
    [brc timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
        // Check whether request successfully completed or not.
        if (!status.isError) {
            // Handle downloaded server time token using: result.data.timetoken
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:(result.data.timetoken.longValue / 10000000)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
            
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            NSString *timestamp = [dateFormatter stringFromDate:date];
            NSLog(@"Server date/time: %@\n", timestamp);
        }
        // Request processing failed.
        else {
            
            // Handle time token download error. Check 'category' property to find
            // out possible issue because of which request did fail.
            //
            // Request can be resent using: [status retry];
        }
    }];

    return brc;
}


@end
