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
- (IBAction)onTapBought:(UIButton *)sender {
    if (sender.selected == true){
        [sender setSelected:false];
    }
    else{
        [sender setSelected:true];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
