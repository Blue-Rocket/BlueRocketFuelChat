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

@interface MessagesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessagesViewController

@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    
    /* TEMP: Add some test messages  *************************/
    NSMutableArray *conversations = [NSMutableArray arrayWithCapacity:0];
    
    for (int j=0;j<10;j++) {
        int r = rand() % 25;
        Conversation *cv = [self fakeSomeConversation];
        for (int i=0;i<r;i++) {
            
            NSString *msgText = [NSString stringWithFormat:@"This is the text of message %d.", i];
            NSString *channel;
            if ((i % 2) == 0)
                channel = [NSString stringWithFormat:@"ID_%d",r];
            else
                channel = [NSString stringWithFormat:@"ID_0"];
            
            ChatMessage *cm = [self fakeSomeMessageFrom:@"Brian" onChannel:channel text:msgText];
            
            [cv addMessagesObject:cm];
            [cv setValue:[NSDate date] forKey: @"timestamp"];   // Update the timestamp to be that of the latest message
        }
        [conversations addObject:cv];
    }
    /***********************************/
    
    // Retrieve conversations
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Conversation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    _conversationList = [NSMutableArray arrayWithArray:[context executeFetchRequest:fetchRequest error:&error]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (ChatMessage *)fakeSomeMessageFrom:(NSString *)author onChannel:(NSString *)channel text:(NSString *)text
{
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
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

- (Conversation *)fakeSomeConversation
{
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    Conversation *conv = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Conversation"
                            inManagedObjectContext:context];
    [conv setValue:@"Brian" forKey:@"author"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return conv;
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
    cell.nameLabel.text = msg.author;
    
    cell.messageLabel.text = msg.text;
    
    cell.timestampLabel.text = [BRDateHelper timeFromNow:msg.timestamp];
    [cell.timestampLabel sizeToFit];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"conversationSegue"]) {
        ConversationsViewController* viewController = [segue destinationViewController];
        viewController.conversation = [_conversationList objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        viewController.msgChannel = @"my_channel";      //TEMP: We'll get this from the message that we clicked on to open the conversations view
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"conversationSegue" sender:self];
}


@end
