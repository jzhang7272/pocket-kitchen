//
//  AddGroceryItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import "AddGroceryItemViewController.h"

#import "NutrientApiManager.h"

#import "Nutrient.h"
#import "FoodItem.h"
#import <Parse/Parse.h>

@interface AddGroceryItemViewController ()

@end

@implementation AddGroceryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)onTapAnalyze:(id)sender {
    NSDictionary *recommendedNutrients = [Nutrient recommendedNutrientAmount:7];
    NSDictionary *diffNutrients = [Nutrient nutrientDifference:self.groceryItemArray :recommendedNutrients];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
