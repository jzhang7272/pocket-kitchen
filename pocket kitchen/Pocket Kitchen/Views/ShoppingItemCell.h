//
//  ShoppingItemCell.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/16/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShoppingItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groceryLabel;
@property (weak, nonatomic) IBOutlet UIView *boughtButton;

@end

NS_ASSUME_NONNULL_END
