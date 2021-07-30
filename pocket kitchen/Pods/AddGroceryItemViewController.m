//
//  AddGroceryItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import "AddGroceryItemViewController.h"
#import "InventoryViewController.h"

#import "NutrientApiManager.h"

#import "Nutrient.h"
#import "NutrientSource.h"
#import "FoodItem.h"
#import <Parse/Parse.h>
#import "EGOCache.h"

@interface AddGroceryItemViewController ()

@end

@implementation AddGroceryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchNutrientSources:@"VITC"];
    
}

- (IBAction)onTapAnalyze:(id)sender {
    NSDictionary *recommendedNutrients = [Nutrient recommendedNutrientAmount:7];
    NSDictionary *diffNutrients = [Nutrient nutrientDifference:self.groceryItemArray :recommendedNutrients];
    NSLog(@"DIFFERENCE: %@", diffNutrients);
    NSArray *cachedFoods = [[EGOCache globalCache] allKeys];
    // NSString *getSavedObject = [[EGOCache globalCache] objectForKey:cachedFoods[0]];
}

- (void)fetchNutrientSources:(NSString *)nutrient{
    NSDictionary *DRVs = [Nutrient recommendedNutrientAmount:1];
    double recommendedValue = ((Nutrient *)[DRVs valueForKey:nutrient]).quantity;
    PFQuery *query = [PFQuery queryWithClassName:@"NutrientSource"];
    [query whereKey:@"amount" greaterThanOrEqualTo:@(recommendedValue * PERCENTAGE_HIGH)];
    [query orderByDescending:@"amount"];
    query.limit = 100;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<NutrientSource *> *items, NSError *error) {
        if (items != nil) {
            NSMutableArray *foods = [NSMutableArray new];
            [foods addObjectsFromArray:items];
            
            for (int i = 0; i < [foods count]; i++){
                NutrientSource *source = foods[i];
                NSLog(@"%@", source.name);
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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
