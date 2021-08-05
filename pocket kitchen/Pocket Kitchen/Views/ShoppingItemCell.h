//
//  ShoppingItemCell.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/16/21.
//

#import <UIKit/UIKit.h>
#import "FoodItem.h"

@protocol ShoppingItemCellDelegate

- (void)tapBought;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groceryLabel;
@property (weak, nonatomic) IBOutlet UIButton *boughtButton;
@property (nonatomic, strong) FoodItem *groceryItem;
@property (nonatomic, weak) id<ShoppingItemCellDelegate> delegate;
@property (nonatomic) BOOL bought;
@end

NS_ASSUME_NONNULL_END
