//
//  CategoriesCell.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *expDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *foodView;
@property (weak, nonatomic) IBOutlet UIButton *alertIcon;


@end

NS_ASSUME_NONNULL_END
