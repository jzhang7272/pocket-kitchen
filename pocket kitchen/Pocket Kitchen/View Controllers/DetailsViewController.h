//
//  DetailsViewController.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "FoodItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property (nonatomic, strong) FoodItem *item;

@end

NS_ASSUME_NONNULL_END
