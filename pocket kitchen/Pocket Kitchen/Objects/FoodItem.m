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
@dynamic quantityUnit;
@dynamic category;
@dynamic nutrients;
@dynamic nutrientUnit;
@dynamic image;
@dynamic branded;

+ (nonnull NSString *)parseClassName {
    return @"FoodItem";
}

+ (void)saveItem: (NSString *)item :(NSNumber *)quantity :(NSString *)quantityUnit:(NSDate *)expDate :(NSString *)category :(BOOL) branded{
    FoodItem *newItem = [FoodItem new];
    newItem.author = PFUser.currentUser;
    newItem.name = item;
    newItem.expirationDate = expDate;
    newItem.quantity = quantity;
    newItem.quantityUnit = quantityUnit;
    newItem.category = category;
    newItem.branded = branded;
    newItem.grocery = false;
    
    [newItem saveInBackgroundWithBlock: nil];
}

+ (void)saveItemAsGrocery: (NSString *)item :(NSNumber *)quantity :(void(^)(FoodItem *groceryItem, NSError *))completion{
    FoodItem *newItem = [FoodItem new];
    newItem.author = PFUser.currentUser;
    newItem.name = item;
    newItem.quantity = quantity;
    newItem.grocery = true;
    [newItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            completion(newItem, nil);
        }
        else {
            completion(nil, error);
        }
      }];
}

+ (NSDictionary *)initNutrientsWithUnits: (NSDictionary *)dictionary{
    NSMutableDictionary *nutrients = [NSMutableDictionary new];
    for(id nutrient in dictionary){
        NSDictionary *nutrientDetails = dictionary[nutrient];
        NSString *unit = nutrientDetails[@"unit"];
        double quantity = [nutrientDetails[@"quantity"] doubleValue];
        if (quantity < 0.01){
            [nutrients setObject: [NSString stringWithFormat:@"<0.01 %@", unit] forKey:nutrientDetails[@"label"]];
        }
        else{
            [nutrients setObject: [NSString stringWithFormat:@"%.2f %@", quantity, unit] forKey:nutrientDetails[@"label"]];
        }
        
    }
    return nutrients;
}

@end
