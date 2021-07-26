//
//  RecommendedFoodsCell.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/26/21.
//

#import "RecommendedFoodsCell.h"
#import "CollectionRecommendedFoodsCell.h"

@interface RecommendedFoodsCell () <UIPageViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation RecommendedFoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
//    layout.minimumLineSpacing = 5;
//    layout.minimumInteritemSpacing = 5;
//    CGFloat itemWidth = 100;
//    CGFloat itemHeight = itemWidth;
//    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CollectionRecommendedFoodsCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ColelctionRecommendedFoodsCell" forIndexPath:indexPath];
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(int)row {
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = row;
    
    [self.collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
