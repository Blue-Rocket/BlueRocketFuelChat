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

#import "MessagesViewController.h"
#import "MessagesTableViewCell.h"
#import "ChatMessage.h"
#import "Conversation.h"
#import "ConversationsViewController.h"
#import "BRDateHelper.h"
#import "AppDelegate+BRChat.h"
#import "Contact.h"
#import "AddressBook.h"

@interface MessagesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController

@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self fakeSomeData];        //TODO: Temporary
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"BRNewChatMessageNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    
    for (Conversation *c in _conversationList) {
        NSLog(@"Conversation Messages: %lu", [c.messages count]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([[segue identifier] isEqualToString:@"conversationSegue"]) {
         ConversationsViewController* viewController = [segue destinationViewController];
         viewController.conversation = [_conversationList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
         viewController.msgChannel = @"my_channel";      //TEMP: We'll get this from the message that we clicked on to open the conversations view
     }
 }


#pragma mark - TEMPORARY!!! Fake some messages and conversations
- (ChatMessage *)fakeSomeMessageFrom:(NSString *)author onChannel:(NSString *)channel text:(NSString *)text
{
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    ChatMessage *chatMsg = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"ChatMessage"
                                       inManagedObjectContext:context];
    [chatMsg setValue:author forKey:@"author"];
    [chatMsg setValue:text forKey:@"text"];
    [chatMsg setValue:channel forKey:@"channel"];
    [chatMsg setValue:[NSDate date] forKey:@"timestamp"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return chatMsg;
}

- (Conversation *)fakeSomeConversation:(Contact *)contact
{
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    Conversation *conv = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Conversation"
                            inManagedObjectContext:context];
    [conv setValue:contact.displayName forKey:@"author"];
    [conv setValue:contact.chatId forKey:@"channel"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return conv;
}

- (Contact *)fakeSomeContactForName:(NSString *)name withChatId:(NSString *)chatId
{
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    Contact *contact = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Contact"
                            inManagedObjectContext:context];
    [contact setValue:name forKey:@"displayName"];
    [contact setValue:chatId forKey:@"chatId"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return contact;
}


- (void)fakeSomeData
{
    //TODO - temporary
    // Populate the address book just once
    if ([[appDelegate.addrBook.contacts allObjects] count] < 19) {
        Contact *c = [self fakeSomeContactForName:@"Albert" withChatId:[NSString stringWithFormat:@"1000"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Alice" withChatId:[NSString stringWithFormat:@"1001"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Herbert" withChatId:[NSString stringWithFormat:@"1002"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Lawrence" withChatId:[NSString stringWithFormat:@"1003"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Judy" withChatId:[NSString stringWithFormat:@"1004"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Maria" withChatId:[NSString stringWithFormat:@"1005"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Donna" withChatId:[NSString stringWithFormat:@"1006"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"David" withChatId:[NSString stringWithFormat:@"1007"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Zak" withChatId:[NSString stringWithFormat:@"1008"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Shawn" withChatId:[NSString stringWithFormat:@"1009"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Jess" withChatId:[NSString stringWithFormat:@"1010"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Estevan" withChatId:[NSString stringWithFormat:@"1011"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Brian" withChatId:[NSString stringWithFormat:@"1012"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Xavier" withChatId:[NSString stringWithFormat:@"1013"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Victor" withChatId:[NSString stringWithFormat:@"1014"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Cathy" withChatId:[NSString stringWithFormat:@"1015"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Kevin" withChatId:[NSString stringWithFormat:@"1016"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Kyle" withChatId:[NSString stringWithFormat:@"1017"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Randall" withChatId:[NSString stringWithFormat:@"1018"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Betsy" withChatId:[NSString stringWithFormat:@"1019"]];
        [appDelegate.addrBook addContactsObject:c];
        c = [self fakeSomeContactForName:@"Jeff" withChatId:[NSString stringWithFormat:@"1020"]];
        [appDelegate.addrBook addContactsObject:c];
    }
    
    /* TEMP: Add some test messages  ***********************
     NSMutableArray *conversations = [NSMutableArray arrayWithCapacity:0];
    
    for (int j=0;j<10;j++) {
        int r = rand() % 19;
        Contact *c = [[appDelegate.addrBook.contacts allObjects] objectAtIndex:r];
        Conversation *cv = [self fakeSomeConversation:c];
        for (int i=0;i<r;i++) {
            
            NSString *msgText = [NSString stringWithFormat:@"This is the extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra, extra long text of message %d.", i];
            ChatMessage *cm;
            if ((i % 2) == 0) {
                cm = [self fakeSomeMessageFrom:c.displayName onChannel:c.chatId text:msgText];
            } else {
                cm = [self fakeSomeMessageFrom:USERNAME onChannel:USER_ID text:msgText];
            }
            
            [cv addMessagesObject:cm];
            [cv setValue:[NSDate date] forKey: @"timestamp"];   // Update the timestamp to be that of the latest message
        }
        [conversations addObject:cv];
    }
    **********************************/
}

- (void)loadData
{
    // Retrieve conversations
    NSManagedObjectContext *context = [appDelegate.coreData managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Conversation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    _conversationList = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    if ([_conversationList count] == 0) // Go to new messages view
        [self performSegueWithIdentifier:@"newMessagesViewSegue" sender:self];
    else
        [_tableView reloadData];
}


#pragma mark - UITableVewDataSource delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_conversationList count];
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MessagesTableViewCellIdentifier";
    
    MessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MessagesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellIdentifier];
    }
    
    NSArray *sortedArray;
    sortedArray = [_conversationList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(ChatMessage *)a timestamp];
        NSDate *second = [(ChatMessage *)b timestamp];
        return [first compare:second];
    }];
    
    NSInteger index = indexPath.row;
    Conversation *cv = [sortedArray objectAtIndex:index];

    sortedArray = [[cv messages].allObjects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(ChatMessage *)a timestamp];
        NSDate *second = [(ChatMessage *)b timestamp];
        return [first compare:second];
    }];
    
    ChatMessage *msg = [sortedArray lastObject];
    cell.nameLabel.text = cv.author;
    
    cell.messageLabel.text = msg.text;
    
    cell.timestampLabel.text = [BRDateHelper timeFromNow:msg.timestamp];
    [cell.timestampLabel sizeToFit];
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"conversationSegue" sender:self];
}


@end
