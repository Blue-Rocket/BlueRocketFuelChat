//
//  BRDateHelper.m
//  Pods
//
//  Created by Brian A. Hill on 7/28/15.
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

#import "BRDateHelper.h"

@implementation BRDateHelper

+ (NSString *)timeFromNow:(NSDate *)then
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSCalendarUnit unit = kCFCalendarUnitYear | kCFCalendarUnitDay | kCFCalendarUnitMonth | kCFCalendarUnitHour | kCFCalendarUnitMinute;

    NSDateComponents *comps = [calendar components:unit fromDate:then toDate:[NSDate date] options:0];

    long years = [comps year];
    long months = [comps month];
    long days = [comps day];
    long hours = [comps hour];
    long minutes = [comps minute];

    NSString *result;

    if ((years > 1)||(months > 1)||(days > 2)) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            dateFormatter.dateStyle = NSDateFormatterShortStyle;

            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:usLocale];
            result = [dateFormatter stringFromDate:then];


    } else if (days == 1)
        result = @"yesterday";
    else if (hours > 1)
        result = [NSString stringWithFormat:@"%ldhrs ago",hours];
    else if (hours == 1)
        result = @"1hr ago";
    else
        result = [NSString stringWithFormat:@"%ldm ago",minutes];


    return result;
}

@end
