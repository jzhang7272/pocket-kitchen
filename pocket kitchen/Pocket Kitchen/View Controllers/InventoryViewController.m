//
//  FoodViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "InventoryViewController.h"
#import "AddItemViewController.h"

#import "FoodItemCell.h"

#import "FoodItem.h"
#import <Parse/Parse.h>
#import "DateTools.h"

const int QUERIES = 20;

@interface InventoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *itemArray;



@end

@implementation InventoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchData];
    
    // Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

}

- (void)fetchData{
    PFQuery *query = [PFQuery queryWithClassName:@"FoodItem"];
    [query orderByDescending:@"name"];
    query.limit = QUERIES;

    [query findObjectsInBackgroundWithBlock:^(NSArray<FoodItem *> *items, NSError *error) {
        if (items != nil) {
            self.itemArray = [items copy];
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
    NSLog(@"%@", item);
    cell.itemLabel.text = item.name;
    cell.quantityLabel.text = [NSString stringWithFormat:@"%@", item.quantity];
    cell.categoryLabel.text = item.category;
    cell.expDateLabel.text = [self getExpirationDate:item.expirationDate];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemArray.count;
}

- (NSString *)getExpirationDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *current = [NSDate date];
    NSInteger yearsApart = [date yearsFrom:current];
    NSInteger monthsApart = [date monthsFrom:current];
    NSInteger daysApart = [date daysFrom:current];
    if (yearsApart > 0){
        return [NSString stringWithFormat:@"%li year(s)", yearsApart+1];
    }
    else if (monthsApart > 0){
        return [NSString stringWithFormat:@"%li month(s)", monthsApart+1];
    }
    else{
        return [NSString stringWithFormat:@"%li day(s)", daysApart+1];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"addItemSeque"]) {
        UINavigationController *navigationController = [segue destinationViewController];
            AddItemViewController *addController = (AddItemViewController*)navigationController.topViewController;
//            addController.delegate = self;
    }
}



@end
