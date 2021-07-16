//
//  ShoppingItem.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/16/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingItem : PFObject

@property (nonatomic, strong) PFUser *author;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *quantity;

+ (void)saveItem: (NSString *)item :(NSNumber *)quantity :(NSDate *)expDate :(NSString *)category :(BOOL) branded;

@end

NS_ASSUME_NONNULL_END
