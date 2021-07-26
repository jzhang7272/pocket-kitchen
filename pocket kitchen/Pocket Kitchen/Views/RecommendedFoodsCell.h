//
//  RecommendedFoodsCell.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/26/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendedFoodsCell : UITableViewCell

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(int)row;

@end

NS_ASSUME_NONNULL_END
