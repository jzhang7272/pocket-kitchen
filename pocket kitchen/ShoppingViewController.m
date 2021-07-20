//
//  ShoppingViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/16/21.
//

#import "ShoppingViewController.h"
#import "InventoryViewController.h"
#import "FoodItem.h"

#import "ShoppingItemCell.h"


@interface ShoppingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *groceryItemField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *groceryItemArray;
@end

@implementation ShoppingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchGroceries];
    
    // Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchGroceries) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (IBAction)onTapAdd:(id)sender {
    if (self.groceryItemField.text.length == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty Field" message:@"Please enter an item to add." preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [FoodItem saveItemAsGrocery:self.groceryItemField.text :@1 :^(FoodItem *groceryItem, NSError *error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
            else {
                NSLog(@"%@",self.groceryItemArray);
                [self.groceryItemArray insertObject:groceryItem atIndex:0];
                [self.tableView reloadData];
            }
          }];

        [self.groceryItemField setText:@""];
    }
}

- (void)fetchGroceries {
    PFQuery *query = [PFQuery queryWithClassName:@"FoodItem"];
    [query whereKey:@"grocery" equalTo:[NSNumber numberWithBool:true]];
    query.limit = QUERIES;

    [query findObjectsInBackgroundWithBlock:^(NSArray<FoodItem *> *items, NSError *error) {
        if (items != nil) {
            self.groceryItemArray = [NSMutableArray new];
            [self.groceryItemArray addObjectsFromArray:items];
//            self.groceryItemArray = [items copy];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ShoppingItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShoppingItemCell"];
    FoodItem *groceryItem = self.groceryItemArray[indexPath.row];
    cell.groceryLabel.text = groceryItem.name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groceryItemArray.count;
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
