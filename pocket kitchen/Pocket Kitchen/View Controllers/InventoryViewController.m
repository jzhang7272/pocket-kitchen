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
#import "CategoryCell.h"

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
#define lighterBlueColor [UIColor colorWithRed:0.96 green:0.96 blue:0.99 alpha:1.0]
#define darkerLightBlueColor [UIColor colorWithRed:0.76 green:0.86 blue:0.89 alpha:1.0]

@interface InventoryViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *filteredArray;
@property (nonatomic, strong) NSArray *categoryArray;


@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize
    self.categoryArray = @[@"All items", @"Pantry", @"Fridge", @"Freezer"];
    self.headerView.backgroundColor = [UIColor systemGray6Color];

    // Delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // Collection View
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.estimatedItemSize = CGSizeMake(1.f, 1.f);
    self.collectionView.allowsMultipleSelection = false;
    self.collectionView.backgroundColor = [UIColor systemGray6Color];
    
    // Table View
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = grayColor;
    [self.tableView setBackgroundView:backgroundView];
    self.tableView.tableFooterView = [UIView new];
    
    // Get data
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

#pragma mark - Collection View
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    cell.categoryLabel.text = self.categoryArray[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds= true;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoryArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = lightBlueColor;
    
    NSString *category = self.categoryArray[indexPath.row];
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

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}

#pragma mark - Table View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

        FoodItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodItemCell"];
        FoodItem *item = self.filteredArray[indexPath.section];
        cell.itemLabel.text = item.name;
        cell.quantityLabel.text = [NSString stringWithFormat:@"  %@  ", item.quantity];
        cell.quantityLabel.backgroundColor = grayColor;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FoodItem *foodItem = [self.filteredArray objectAtIndex:indexPath.section];
        [foodItem deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                [self.itemArray removeObject:foodItem];
                [self.filteredArray removeObjectAtIndex:indexPath.section];
                [tableView beginUpdates];
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                                     withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
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
        FoodItem *item = self.filteredArray[indexPath.section];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.item = item;
    }
}



@end
