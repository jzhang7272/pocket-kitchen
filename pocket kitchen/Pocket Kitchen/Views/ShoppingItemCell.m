//
//  ShoppingItemCell.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/16/21.
//

#import "ShoppingItemCell.h"


@implementation ShoppingItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)onTapBought:(id)sender {
    if (self.groceryItem.bought){
        self.groceryItem.bought = false;
    }
    else{
        self.groceryItem.bought = true;
    }
    [self.groceryItem saveInBackgroundWithBlock:nil];
    [self.delegate tapBought];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
