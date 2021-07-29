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
#import "HeaderFilterCell.h"

#import "FoodItem.h"
#import <Parse/Parse.h>
#import "DateTools.h"
#import "UIImageView+AFNetworking.h"
#import <CCDropDownMenus/CCDropDownMenus.h>

const int QUERIES = 20;
const double PERCENTAGE_HIGH = 0.2; // 20% DV or more of a nutrient per serving is considered high
const double PERCENTAGE_LOW = 0.05; // 5% DV or less of a nutrient per serving is considered low

#define grayColor [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0]
#define lightBlueColor [UIColor colorWithRed:0.86 green:0.96 blue:0.99 alpha:1.0]

@interface InventoryViewController () <UITableViewDelegate, UITableViewDataSource, CCDropDownMenuDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *filteredArray;
@property (nonatomic, strong) ManaDropDownMenu *categoryMenu;


@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = grayColor;
    [self.tableView setBackgroundView:backgroundView];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self fetchData];

    
    // Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    // all = [[[NSBundle mainBundle] loadNibNamed:@"Category" owner:self options:nil] objectAtIndex:0];
    // CategoryView *categories = [[CategoryView alloc] init];
    // [categories.categoryButton setTitle:[_categoriesArray objectAtIndex:i] forState:UIControlStateNormal];
    
    // Dropdown
    self.categoryMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectMake(8, 8, 120, 30) title:@"All items"];
    self.categoryMenu.delegate = self;
    self.categoryMenu.numberOfRows = 4;
    self.categoryMenu.textOfRows = @[@"All items", @"Pantry", @"Fridge", @"Freezer"];
    self.categoryMenu.indicator = [UIImage systemImageNamed:@"chevron.down"];
    NSLog(@"%@", self.categoryMenu.indicator);
    [self.headerView addSubview:self.categoryMenu];
    [self.headerView bringSubviewToFront:self.categoryMenu];
}

- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    NSString *category = dropDownMenu.textOfRows[index];
    self.filteredArray = [NSMutableArray new];
    if ([category isEqual:@"All items"]){
        [self.filteredArray addObjectsFromArray:self.itemArray];
    }
    else{
        for (FoodItem *food in self.itemArray){
            if ([food.category isEqual:category]){
                [self.filteredArray addObject:food];
            }
        }
    }
    
    [self.tableView reloadData];
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
            self.filteredArray = [NSMutableArray new];
            self.itemArray = [NSMutableArray new];
            [self.itemArray addObjectsFromArray:items];
            [self.filteredArray addObjectsFromArray:items];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FoodItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodItemCell"];
    FoodItem *item = self.filteredArray[indexPath.section];
    cell.itemLabel.text = item.name;
    cell.quantityLabel.text = [NSString stringWithFormat:@"  %@  ", item.quantity];
    cell.quantityLabel.backgroundColor = lightBlueColor;
    cell.quantityLabel.layer.cornerRadius = 10;
    cell.quantityLabel.clipsToBounds = YES;
    cell.categoryLabel.text = item.category;
    cell.expDateLabel.text = [self getExpirationDate:item.expirationDate];
    
    NSURL *url = [NSURL URLWithString:item.image];
    [cell.foodView setImageWithURL:url];
    cell.foodView.layer.cornerRadius = 15;
    cell.foodView.clipsToBounds = YES;
    
    if ([cell.expDateLabel.text isEqualToString:@"Expired"]){
        cell.alertIcon.tintColor = [UIColor systemRedColor];
    }
    else if([cell.expDateLabel.text isEqualToString:@"Expiring today"]){
        cell.alertIcon.tintColor = [UIColor systemYellowColor];
    }
    else{
        cell.alertIcon.tintColor = [UIColor clearColor];
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.filteredArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = grayColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    CGFloat height = 2;
    return height;
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
    if (daysApart == 0){
        return @"Expiring today";
    }
    else if ([date timeIntervalSinceDate:current] < 0){
        return @"Expired";
    }
    else if (yearsApart > 0){
        if (yearsApart == 1) {
            return [NSString stringWithFormat:@"Expires in %li year", yearsApart];
        }
        else{
            return [NSString stringWithFormat:@"Expires in %li years", yearsApart];
        }
        
    }
    else if (monthsApart > 0){
        if (monthsApart == 1) {
            return [NSString stringWithFormat:@"Expires in %li month", monthsApart];
        }
        else{
            return [NSString stringWithFormat:@"Expires in %li months", monthsApart];
        }
    }
    else{
        if (daysApart == 1) {
            return [NSString stringWithFormat:@"Expires in %li day", daysApart];
        }
        else{
            return [NSString stringWithFormat:@"Expires in %li days", daysApart];
        }
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
        FoodItem *item = self.itemArray[indexPath.section];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.item = item;
    }
}



@end
