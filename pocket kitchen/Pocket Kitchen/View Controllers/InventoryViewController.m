//
//  FoodViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "InventoryViewController.h"
#import "AddItemViewController.h"
#import "DetailsViewController.h"
#import "NutrientApiManager.h"

#import "FoodItemCell.h"
#import "CategoryView.h"

#import "FoodItem.h"
#import <Parse/Parse.h>
#import "DateTools.h"

const int QUERIES = 20;

@interface InventoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIStackView *horizontalScrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *categoriesArray;


@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    _categoriesArray = @[@"Food", @"Fridge", @"Pantry"];
    for (int i = 0; i <= 10; i++){
        CategoryView *categories = [[CategoryView alloc] init];
        [categories.categoryButton setTitle:@"title" forState:UIControlStateNormal];
//    all = [[[NSBundle mainBundle] loadNibNamed:@"Category" owner:self options:nil] objectAtIndex:0];
        [self.horizontalScrollView addArrangedSubview:categories];
    }
    
    
    [self fetchData];

    
    // Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)fetchData{
    PFQuery *query = [PFQuery queryWithClassName:@"FoodItem"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:PFUser.currentUser];
    [query whereKey:@"grocery" equalTo:[NSNumber numberWithBool:false]];
    [query orderByDescending:@"name"];
    query.limit = QUERIES;

    [query findObjectsInBackgroundWithBlock:^(NSArray<FoodItem *> *items, NSError *error) {
        if (items != nil) {
            self.itemArray = [NSMutableArray new];
            [self.itemArray addObjectsFromArray:items];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FoodItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodItemCell"];
    FoodItem *item = self.itemArray[indexPath.row];
    // NSLog(@"%@", item);
    cell.itemLabel.text = item.name;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%@", item.quantity];
    cell.categoryLabel.text = item.category;
    cell.expDateLabel.text = [self getExpirationDate:item.expirationDate];
   // cell.expDateLabel.text = ([[self getExpirationDate:item.expirationDate] integerValue] < 0) ? @"Expired" : [self getExpirationDate:item.expirationDate];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FoodItem *foodItem = [self.itemArray objectAtIndex:indexPath.row];
        [foodItem deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                NSLog(@"The item was deleted.");
                [self.itemArray removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [tableView reloadData];
            } else {
                NSLog(@"Problem deleting item: %@", error.localizedDescription);
            }
        }];
    }
}

// Helper Functions
- (NSString *)getExpirationDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *current = [NSDate date];
    NSInteger yearsApart = [date yearsFrom:current];
    NSInteger monthsApart = [date monthsFrom:current];
    NSInteger daysApart = [date daysFrom:current];
    if ([[NSCalendar currentCalendar] isDate:date inSameDayAsDate:current]){
        return @"Expiring today!";
    }
    else if ([date timeIntervalSinceDate:current] < 0){
        return @"Expired";
    }
    else if (yearsApart > 0){
        return [NSString stringWithFormat:@"%li year(s)", yearsApart];
    }
    else if (monthsApart > 0){
        return [NSString stringWithFormat:@"%li month(s)", monthsApart];
    }
    else{
        return [NSString stringWithFormat:@"%li day(s)", daysApart];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"addItemSeque"]) {
        UINavigationController *navigationController = [segue destinationViewController];
            AddItemViewController *addController = (AddItemViewController*)navigationController.topViewController;
//            addController.delegate = self;
    }
    if([[segue identifier] isEqualToString:@"detailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        FoodItem *item = self.itemArray[indexPath.row];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.item = item;
    }
}



@end
