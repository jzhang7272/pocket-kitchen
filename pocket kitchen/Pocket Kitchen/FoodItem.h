//
//  FoodItem.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/13/21.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodItem : PFObject<PFSubclassing>

//@property (nonatomic, strong) NSString *foodID;
@property (nonatomic, strong) PFUser *author;

//@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *quantity;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSMutableDictionary *nutrients;

+ (void)saveItem: (NSString *)item :(NSNumber *)quantity :(NSDate *)expDate :(NSString *)category;

+ (NSDictionary *)initNutrients: (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
