//
//  AddressBook.h
//  
//
//  Created by Brian A. Hill on 8/4/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface AddressBook : NSManagedObject

@property (nonatomic, retain) NSSet *contacts;
@end

@interface AddressBook (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
