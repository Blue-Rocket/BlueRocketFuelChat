//
//  AddressBookViewController.m
//  BRFChat
//
//  Created by Brian A. Hill on 8/10/15.
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

#import "AddressBookViewController.h"
#import "AddrBookTableViewCell.h"

@interface AddressBookViewController ()

@property (nonatomic,strong) NSMutableDictionary *contactsDict;
@property (nonatomic,strong) NSArray *sectionTitles;
@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _contactsDict = [[NSMutableDictionary alloc]initWithCapacity:0];

    for (Contact *c in appDelegate.addrBook.contacts) {
        NSString *indexLetter = [[c.displayName substringWithRange:(NSRange){0,1}]capitalizedString];

        if ([[_contactsDict allKeys] containsObject:indexLetter]) {
            NSMutableArray *cArray = [_contactsDict objectForKey:indexLetter];
            [cArray addObject:c];
        } else {
            NSMutableArray *cArray = [[NSMutableArray alloc]initWithObjects:c, nil];
            [_contactsDict setObject:cArray forKey:indexLetter];
        }
    }
    _sectionTitles = [[_contactsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *sectionTitle = [_sectionTitles objectAtIndex:section];
    NSArray *contacts = [_contactsDict objectForKey:sectionTitle];
    return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddrBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressBookCellIdentifier" forIndexPath:indexPath];

    NSString *sectionTitle = [_sectionTitles objectAtIndex:indexPath.section];

    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    NSArray *contacts = [[_contactsDict objectForKey:sectionTitle] sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    Contact *c = [contacts objectAtIndex:indexPath.row];
    cell.title.text = c.displayName;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_sectionTitles objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sectionTitles;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [_sectionTitles indexOfObject:title];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
