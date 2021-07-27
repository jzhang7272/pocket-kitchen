//
//  RecommendedFoodsCell.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendedFoodsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nutrientLabel;

@property (nonatomic, strong) NSArray *recommendedFoods;
@property (nonatomic, strong) NSString *nutrient;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate forRow:(int)row;

@end

NS_ASSUME_NONNULL_END
