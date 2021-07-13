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

- (void)fetchFoodItem: (NSString *)query :(int)page :(void(^)(NSArray *foodItems, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END