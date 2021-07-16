//
//  CategoryView.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/15/21.
//

#import "CategoryView.h"

@implementation CategoryView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        [self customInit];
    }
    
    return self;
}

- (void)customInit{
    [[NSBundle mainBundle] loadNibNamed:@"Category" owner:self options: nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}
@end
