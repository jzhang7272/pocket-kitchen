//
//  AddGroceryItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import "AddGroceryItemViewController.h"
#import "InventoryViewController.h"

#import "RecommendedFoodsCell.h"

#import "NutrientApiManager.h"

#import "Nutrient.h"
#import "NutrientSource.h"
#import "FoodItem.h"
#import <Parse/Parse.h>
#import "EGOCache.h"

@interface AddGroceryItemViewController ()
// <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *missingNutrients;

@end

@implementation AddGroceryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
    
    [self analysis];
    [self getRecommendedFoods];
    
    
}
- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) analysis{
    NSDictionary *recommendedNutrients = [Nutrient recommendedNutrientAmount:1];
    NSDictionary *diffNutrients = [Nutrient nutrientDifference:self.groceryItemArray :recommendedNutrients];
    
    self.missingNutrients = [NSMutableArray new];
    for(id nutrient in diffNutrients){
        if ([[diffNutrients valueForKey:nutrient] doubleValue] > 0){
            [self.missingNutrients addObject:nutrient];
        }
    }
    // NSLog(@"%i \n %@", self.missingNutrients.count, diffNutrients);
}

- (void) getRecommendedFoods{
    NSMutableDictionary *recommendedFoods = [NSMutableDictionary new];
    for (NSString *missing in self.missingNutrients){
        [recommendedFoods setObject:[NSMutableArray new] forKey:missing];
    }
    
    // Adding cached foods to recommended
    NSArray *cachedFoods = [[EGOCache globalCache] allKeys];
    for (NSString *food in cachedFoods){
        NSArray *highNutrients = [[EGOCache globalCache] objectForKey:food];
        for (NSString *nutrient in highNutrients){
            if ([self.missingNutrients containsObject:nutrient]){
                NSMutableArray *currFoods = [recommendedFoods valueForKey:nutrient];
                [currFoods addObject:food];
                [recommendedFoods setObject:currFoods forKey:nutrient];
            }
        }
    }

    // Adding random, new foods to recommended
    dispatch_group_t group = dispatch_group_create();
    for (NSString *missing in self.missingNutrients){
        dispatch_group_enter(group);
        
        PFQuery *query = [PFQuery queryWithClassName:@"NutrientSource"];
        [query whereKey:@"nutrient" equalTo:missing];
        [query orderByDescending:@"quantity"];
        query.limit = 150;

        [query findObjectsInBackgroundWithBlock:^(NSArray *sources, NSError *error) {
            if (sources != nil) {
                NSMutableArray *sourcesCopy = [NSMutableArray new];
                [sourcesCopy addObjectsFromArray:sources];
                NSMutableArray *currFoods = [recommendedFoods valueForKey:missing];
                int nmbrNeeded = 10 - currFoods.count;
                for (int i = 0; i < nmbrNeeded; i++){
                    uint32_t rnd = arc4random_uniform([sourcesCopy count]);
                    NutrientSource *source = [sourcesCopy objectAtIndex:rnd];
                    [currFoods addObject:source.food];
                    [sourcesCopy removeObject:source];
                }
                [recommendedFoods setObject:currFoods forKey:missing];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"%@", recommendedFoods);
    });
    
}

//- (void)fetchNutrientSources:(NSString *)nutrient{
//    NSDictionary *DRVs = [Nutrient recommendedNutrientAmount:1];
//    double recommendedValue = ((Nutrient *)[DRVs valueForKey:nutrient]).quantity;
//    PFQuery *query = [PFQuery queryWithClassName:@"NutrientSource"];
//    [query whereKey:@"amount" greaterThanOrEqualTo:@(recommendedValue * PERCENTAGE_HIGH)];
//    [query orderByDescending:@"amount"];
//    query.limit = 100;
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray<NutrientSource *> *items, NSError *error) {
//        if (items != nil) {
//            NSMutableArray *foods = [NSMutableArray new];
//            [foods addObjectsFromArray:items];
//
//            for (int i = 0; i < [foods count]; i++){
//                NutrientSource *source = foods[i];
//                NSLog(@"%@", source.name);
//            }
//        } else {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    RecommendedFoodsCell *newCell = cell;
//    [newCell setCollectionViewDataSourceDelegate:self indexPath:indexPath.row];
//}
//
//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    RecommendedFoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendedFoodsCell"];
//    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath.row];
//    
//    return cell;
//}
//
//- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.missingNutrients.count;
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
