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
@dynamic category;
@dynamic nutrients;
@dynamic image;
@dynamic branded;

+ (nonnull NSString *)parseClassName {
    return @"FoodItem";
}

+ (void)saveItem: (NSString *)item :(NSNumber *)quantity :(NSDate *)expDate :(NSString *)category :(BOOL) branded{
    FoodItem *newItem = [FoodItem new];
    newItem.author = PFUser.currentUser;
    newItem.expirationDate = expDate;
    newItem.name = item;
    newItem.quantity = quantity;
    newItem.category = category;
    newItem.branded = branded;
    
    [newItem saveInBackgroundWithBlock: nil];
}

+ (NSDictionary *)initNutrients: (NSDictionary *)dictionary{
    NSMutableDictionary *nutrients = [NSMutableDictionary new];
    for(id nutrient in dictionary){
        NSDictionary *details = dictionary[nutrient];
        NSString *unit = details[@"unit"];
        double quantity = [details[@"quantity"] doubleValue];
        [nutrients setObject: [NSString stringWithFormat:@"%.2fd %@", quantity, unit] forKey:details[@"label"]];
    }
    return nutrients;
}

@end
