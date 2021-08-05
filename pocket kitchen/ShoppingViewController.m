//
//  ShoppingViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/16/21.
//

#import "ShoppingViewController.h"
#import "InventoryViewController.h"
#import "NutrientAnalysisViewController.h"
#import "FoodItem.h"
#import "Constants.h"

#import "ShoppingItemCell.h"


@interface ShoppingViewController () <ShoppingItemCellDelegate, UITableViewDelegate, UITableViewDataSource>

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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchGroceries) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchGroceries {
    PFQuery *query = [PFQuery queryWithClassName:@"FoodItem"];
    [query whereKey:@"grocery" equalTo:[NSNumber numberWithBool:true]];
    query.limit = NMBR_QUERIES;

    [query findObjectsInBackgroundWithBlock:^(NSArray<FoodItem *> *items, NSError *error) {
        if (items != nil) {
            self.groceryItemArray = [NSMutableArray new];
            [self.groceryItemArray addObjectsFromArray:items];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self.refreshControl endRefreshing];
}

- (void)tapBought{
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ShoppingItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShoppingItemCell"];
    FoodItem *groceryItem = self.groceryItemArray[indexPath.row];
    cell.delegate = self;
    cell.groceryItem = groceryItem;
    if(groceryItem.bought == true){
        [cell.boughtButton setSelected:true];
    }
    else{
        [cell.boughtButton setSelected:false];
    }
    cell.groceryLabel.text = groceryItem.name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groceryItemArray.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FoodItem *groceryItem = [self.groceryItemArray objectAtIndex:indexPath.row];
        [groceryItem deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                NSLog(@"The item was deleted.");
                [self.groceryItemArray removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView reloadData];
            } else {
                NSLog(@"Problem deleting item: %@", error.localizedDescription);
            }
        }];
    }
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
                [self.groceryItemArray insertObject:groceryItem atIndex:0];
                [self.tableView reloadData];
            }
          }];

        [self.groceryItemField setText:@""];
    }
}

- (IBAction)onTapNutrientAnalysis:(id)sender {
    [self performSegueWithIdentifier:@"nutrientAnalysisSegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"nutrientAnalysisSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
            NutrientAnalysisViewController *addController = (NutrientAnalysisViewController*)navigationController.topViewController;
        addController.groceryItemArray = self.groceryItemArray;
    }
}

@end
