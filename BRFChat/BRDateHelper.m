//
//  BRDateHelper.m
//  Pods
//
//  Created by Brian A. Hill on 7/28/15.
//
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

