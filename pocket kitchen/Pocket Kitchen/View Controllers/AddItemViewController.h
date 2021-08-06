//
//  AddItemViewController.h
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddItemViewDelegate

- (void)refreshData;

@end

@interface AddItemViewController : UIViewController

@property (nonatomic, weak) id<AddItemViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
