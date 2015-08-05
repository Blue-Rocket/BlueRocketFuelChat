//
//  Created by Brian A. Hill on 7/20/15.
//
//  Copyright (c) 2015 Blue Rocket, Inc. All rights reserved.
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

#import "AppDelegate+BRChat.h"

@implementation AppDelegate (BRChat)
@dynamic BRChatClient;
@dynamic coreData;
@dynamic addrBook;


-(void)setBRChatClient:(PubNub *)BRChatClient
{
    objc_setAssociatedObject(self, @selector(BRChatClient), BRChatClient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PubNub *)BRChatClient {
    return objc_getAssociatedObject(self, @selector(BRChatClient));
}


-(void)setCoreData:(PersistentStorageController *)coreData
{
    objc_setAssociatedObject(self, @selector(coreData), coreData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PersistentStorageController *)coreData {
    if (!objc_getAssociatedObject(self, @selector(coreData))) {
        self.coreData = [[PersistentStorageController alloc]init];
    } else {
        return objc_getAssociatedObject(self, @selector(coreData));
    }
    return self.coreData;
}

- (void)setAddrBook:(AddressBook *)addrBook
{
    objc_setAssociatedObject(self, @selector(addrBook), addrBook, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AddressBook *)addrBook {
    if (!objc_getAssociatedObject(self, @selector(addrBook))) {
    
        NSManagedObjectContext *context = [self.coreData managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"AddressBook" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        NSMutableArray *addrBk = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
        
        if (!addrBk||[addrBk count] == 0) {
            self.addrBook = [NSEntityDescription insertNewObjectForEntityForName:@"AddressBook" inManagedObjectContext:context];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        } else {
            self.addrBook = [addrBk objectAtIndex:0];   // There should only be one address book
        }
    } else {
        return objc_getAssociatedObject(self, @selector(addrBook));
    }
    return self.addrBook;
}



-(void) configureChat
{
    // PubNub configuration
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" subscribeKey:@"demo"];
    self.BRChatClient = [PubNub clientWithConfiguration:configuration];
    
    [self.BRChatClient timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
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
    
}

@end
