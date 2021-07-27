//
//  AddGroceryItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import "AddGroceryItemViewController.h"
#import "InventoryViewController.h"

#import "RecommendedFoodsCell.h"
#import "BadNutrientCell.h"
#import "LoadingCell.h"


#import "NutrientApiManager.h"

#import "Nutrient.h"
#import "NutrientSource.h"
#import "FoodItem.h"
#import <Parse/Parse.h>
#import "EGOCache.h"

@interface AddGroceryItemViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *missingNutrients;
@property (nonatomic, strong) NSMutableArray *tooMuchNutrient;
@property (nonatomic, strong) NSMutableArray *recommendedFoods;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL loaded;

@end

@implementation AddGroceryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.loaded = false;
    
    // Start Activity Indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
    [self analysis];
    [self getRecommendedFoods];
    
    
}
- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) analysis{
    self.missingNutrients = [NSMutableArray new];
    self.tooMuchNutrient = [NSMutableArray new];
    NSDictionary *recommendedNutrients = [Nutrient recommendedNutrientAmount:1];
    NSDictionary *diffNutrients = [Nutrient nutrientDifference:self.groceryItemArray :recommendedNutrients];
    NSArray *badNutrients = @[@"SUGAR", @"NA", @"CHOLE", @"FASAT", @"FAT"];
    
    for(id nutrient in diffNutrients){
        if ([badNutrients containsObject:nutrient]){
            if ([[diffNutrients valueForKey:nutrient] doubleValue] < 0){
                [self.tooMuchNutrient addObject:nutrient];
            }
        }
        else{
            if ([[diffNutrients valueForKey:nutrient] doubleValue] > 0){
                [self.missingNutrients addObject:nutrient];
            }
        }
    }

}

- (void) getRecommendedFoods{
    self.recommendedFoods = [NSMutableArray new];
    NSMutableDictionary *recommendedFoods = [NSMutableDictionary new];
    for (NSString *missing in self.missingNutrients){
        [recommendedFoods setObject:[NSMutableArray new] forKey:missing];
    }
    
    // Adding cached foods to be recommended
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

    // Adding random, new foods to be recommended
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
        // Save as 2D array to display in UI
        for (NSString *missing in self.missingNutrients){
            NSArray *foods = [recommendedFoods valueForKey:missing];
            [self.recommendedFoods addObject:foods];
            
        }
        self.loaded = true;
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
    });
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.loaded == true){
        RecommendedFoodsCell *recCell = cell;
        if (self.tooMuchNutrient.count > 0){
            if (indexPath.row != 0){
                [recCell setCollectionViewDataSourceDelegate:recCell forRow:indexPath.row];
            }
        }
        else{
            [recCell setCollectionViewDataSourceDelegate:recCell forRow:indexPath.row];
        }
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.recommendedFoods.count == 0){
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        return cell;
    }
    else{
        if (indexPath.row == 0 && self.tooMuchNutrient.count != 0){
            BadNutrientCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BadNutrientcell"];
            
            NSString *nutrients = [[self.tooMuchNutrient valueForKey:@"description"] componentsJoinedByString:@", "];
            cell.nutrientLabel.text = [NSString stringWithFormat:@"You're going over the recommended values for the following nutrients: %@", nutrients];
            return cell;
        }
        else{
            RecommendedFoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendedFoodsCell"];
            cell.nutrient = self.missingNutrients[indexPath.row - 1];
            cell.nutrientLabel.text = cell.nutrient;
            cell.recommendedFoods = self.recommendedFoods[indexPath.row - 1];

            return cell;
        }
    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.missingNutrients.count + 1);
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


