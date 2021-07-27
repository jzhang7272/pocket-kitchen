//
//  RecommendedFoodsCell.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/26/21.
//

#import "RecommendedFoodsCell.h"
#import "CollectionRecommendedFoodsCell.h"

@interface RecommendedFoodsCell () < UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation RecommendedFoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
//    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 30;
    layout.estimatedItemSize = CGSizeMake(1.f, 1.f);

}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollectionRecommendedFoodsCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ColelctionRecommendedFoodsCell" forIndexPath:indexPath];
    cell.foodLabel.text = self.recommendedFoods[indexPath.row];
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate forRow:(int)row {
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = row;
    
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


@end
