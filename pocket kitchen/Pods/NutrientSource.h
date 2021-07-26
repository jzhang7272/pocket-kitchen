//
//  NutrientSource.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/26/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface NutrientSource : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *nutrient;
@property (nonatomic, strong) NSString *food;
@property (nonatomic) double quantity;

@end

NS_ASSUME_NONNULL_END
