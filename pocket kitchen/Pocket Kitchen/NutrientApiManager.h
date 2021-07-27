//
//  NutrientApiManager.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/13/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NutrientApiManager : NSObject

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *servingURL;

- (void)fetchFoodItem: (NSString *)query :(int)page :(void(^)(NSArray *foodItems, NSError *error))completion;
- (void)fetchInventoryNutrients:(NSString *)item :(NSString *)nutrientType :(void(^)(NSDictionary *, BOOL, NSString *, NSError *))completion;
- (void)fetchGroceryNutrients:(NSString *)foodItem :(void(^)(NSDictionary *, double nmbrServings, NSError *))completion;
- (void) fetchNutrientHelper:(NSString *)foodID :(NSString *)unitURL :(NSString *)alternateUnitURL :(NSString *)nutrientType :(void(^)(NSDictionary *, BOOL, double, NSError *))completion;

@end

NS_ASSUME_NONNULL_END
