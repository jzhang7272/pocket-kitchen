//
//  RecommendedNutrients.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Nutrient : NSObject

@property double quantity;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *name;

- (instancetype)initNutrient:(double)quantity :(NSString *)unit :(NSString *)code :(NSString *)name;
+ (NSDictionary *)recommendedNutrientAmount:(int)days;
+ (NSDictionary*)nutrientDifference:(NSArray *)groceryItems :(NSMutableDictionary *)recommendedNutrients;

@end

NS_ASSUME_NONNULL_END
