//
//  VOACategory.h
//  VOA
//
//  Created by xuzepei on 5/21/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface VOACategory : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * itsdescription;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * pubDate;
@property (nonatomic, retain) NSSet *items;
@end

@interface VOACategory (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
