//
//  NutrientSource.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/23/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface NutrientSource : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int field1; // will rename

@end

NS_ASSUME_NONNULL_END
