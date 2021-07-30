//
//  DetailsViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/14/21.
//

#import "DetailsViewController.h"
#import "NutrientApiManager.h"

#import <Parse/Parse.h>
#import "UIImageView+AFNetworking.h"
#import "PKYStepper.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nutritionLabel;
@property (weak, nonatomic) IBOutlet UILabel *nutritionDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UIDatePicker *expDatePicker;
@property (weak, nonatomic) IBOutlet PKYStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet UIImageView *foodView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update labels
    self.foodItemLabel.text = self.item.name;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    self.categoryLabel.text = self.item.category;
    self.expDatePicker.date = self.item.expirationDate;
    self.expDatePicker.minimumDate = self.item.expirationDate;
    
    self.quantityStepper.value = [self.item.quantity intValue];
    self.quantityStepper.stepInterval = 1;
    self.quantityStepper.buttonWidth = 33;
    [self.quantityStepper setLabelTextColor:[UIColor systemBlueColor]];
    [self.quantityStepper setBorderColor:[UIColor systemBlueColor]];
    [self.quantityStepper setButtonTextColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.quantityStepper.valueChangedCallback =
    ^(PKYStepper *stepper, float count) {
        self.item.quantity = @((int) count);
        self.quantityStepper.countLabel.text = [NSString stringWithFormat:@"%@", @((int)count)];
    };
    [self.quantityStepper setup];
    
    NSURL *url = [NSURL URLWithString:self.item.image];
    [self.foodView setImageWithURL:url];
    self.foodView.layer.cornerRadius = 15;
    self.foodView.clipsToBounds = YES;
    
    self.backgroundView.layer.cornerRadius = 20;
    self.backgroundView.clipsToBounds = YES;
    [self.contentView sendSubviewToBack:self.backgroundView];

    
    if (self.item.nutrients == nil){
        
        // Start Activity Indicator
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        self.activityIndicator.center = self.view.center;
        [self.view addSubview:self.activityIndicator];
        [self.activityIndicator startAnimating];
        
        [self fetchFoodDetails];
    }
    else{
        self.nutritionDetailsLabel.text = self.item.nutrients;
        self.nutritionLabel.text = [NSString stringWithFormat:@"Nutrition Facts (per %@)", self.item.nutrientUnit];
    }
}

- (void)viewDidLayoutSubviews{

    self.scrollView.contentSize = self.contentView.frame.size;
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        self.item.expirationDate = self.expDatePicker.date;
        [self.item saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                NSLog(@"The item was saved.");
            } else {
                NSLog(@"Problem saving item: %@", error.localizedDescription);
            }
        }];
    }
    [super viewWillDisappear:animated];
}

- (void) fetchFoodDetails{
    NutrientApiManager *nutrientApi = [NutrientApiManager new];
    [nutrientApi fetchInventoryNutrients:self.item.name :@"totalNutrients":^(NSDictionary *dictionary, BOOL unitCup, NSString *foodImage, NSError *error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            NSMutableDictionary *nutrients = [NSMutableDictionary new];
            [nutrients addEntriesFromDictionary: [FoodItem initNutrientsWithUnits:dictionary]];
            self.item.image = foodImage;
            self.item.nutrientUnit = (unitCup) ? @"cup" : @"serving";
            dispatch_async(dispatch_get_main_queue(), ^{
                self.item.nutrients = [self convertNutrientsToString:nutrients];
                self.nutritionDetailsLabel.text = self.item.nutrients;
                self.nutritionLabel.text = [NSString stringWithFormat:@"Nutrition Facts (per %@)", self.item.nutrientUnit];
                NSURL *url = [NSURL URLWithString:foodImage];
                [self.item saveInBackgroundWithBlock:nil];
            });
        }
    }];
}

- (NSString *)convertNutrientsToString:(NSDictionary *)dictionary{
    NSMutableString *ret = [NSMutableString new];
    for(id key in dictionary){
        [ret appendString:[NSString stringWithFormat:@"%@: %@\n", key, [dictionary objectForKey:key]]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
    return ret;
}
//- (IBAction)stepperValueChanged:(UIStepper *)sender {
//    int quantity = [self.quantityLabel.text integerValue];
//    quantity += [sender value];
//    self.quantityLabel.text = [NSString stringWithFormat:@"%i %@", quantity, self.item.quantityUnit];
//    sender.value = 0;
//
//    self.item.quantity= [NSNumber numberWithInt:quantity];
//}
- (IBAction)onTapDelete:(id)sender {
    [self.item deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"The item was deleted.");
        } else {
            NSLog(@"Problem deleting item: %@", error.localizedDescription);
        }
    }];
    [[self navigationController] popViewControllerAnimated:YES];
    
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
