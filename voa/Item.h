//
//  Item.h
//  VOA
//
//  Created by xuzepei on 5/21/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VOACategory;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * isCachedImages;
@property (nonatomic, retain) NSString * pubDate;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * isFavorited;
@property (nonatomic, retain) NSString * itsdescription;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSNumber * isHidden;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *category;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(VOACategory *)value;
- (void)removeCategoryObject:(VOACategory *)value;
- (void)addCategory:(NSSet *)values;
- (void)removeCategory:(NSSet *)values;

@end
