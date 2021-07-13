//
//  FoodItem.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/13/21.
//

#import "FoodItem.h"

@implementation FoodItem

@dynamic author;
@dynamic expirationDate;
@dynamic name;
@dynamic quantity;

+ (nonnull NSString *)parseClassName {
    return @"FoodItem";
}

+ (void)saveItem: (NSString *)item :(NSNumber *)quantity :(NSDate *)expDate :(NSString *)category{
    FoodItem *newItem = [FoodItem new];
    newItem.author = PFUser.currentUser;
    newItem.expirationDate = expDate;
    newItem.name = item;
    newItem.quantity = quantity;
    newItem.category = category;
    
    [newItem saveInBackgroundWithBlock: nil];
}

@end
