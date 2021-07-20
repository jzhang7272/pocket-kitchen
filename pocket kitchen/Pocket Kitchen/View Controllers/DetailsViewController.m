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

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nutritionLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *expDateLabel;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *foodView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update labels
    self.foodItemLabel.text = self.item.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"%@ %@", self.item.quantity, self.item.quantityUnit];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    self.expDateLabel.text = [formatter stringFromDate:self.item.expirationDate];
    self.categoryLabel.text = self.item.category;
    
    // Start Activity Indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    
    if (self.item.image != nil){
        NSURL *url = [NSURL URLWithString:self.item.image];
        [self.foodView setImageWithURL:url];
    }

    
    if (self.item.nutrients == nil){
        [self fetchFoodNutrients];
    }
    else{
        self.nutritionLabel.text = [self convertNutrientsToString:self.item.nutrients];
    }
}

- (void)viewDidLayoutSubviews{

    self.scrollView.contentSize = self.contentView.frame.size;
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
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

- (void) fetchFoodNutrients{
    NutrientApiManager *nutrientApi = [NutrientApiManager new];
    [nutrientApi fetchFood:self.item.name :^(NSDictionary *nutrients, BOOL unitGram, NSString *foodImage, NSError *error) {
        // per serving (maybe switch to gram?), vs whole
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            self.item.nutrients = nutrients;
            self.item.image = foodImage;
            NSLog(@"%@", self.item);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *nutrientsString = [self convertNutrientsToString:self.item.nutrients];
                NSString *nutrientsWithGrams = [NSString stringWithFormat:@"(per gram)\n %@", nutrientsString];
                NSString *nutrientsWithWhole = [NSString stringWithFormat:@"(per one item)\n %@", nutrientsString];
                self.nutritionLabel.text = (unitGram) ? nutrientsWithGrams : nutrientsWithWhole;
//                self.nutritionLabel.text = [nutrientsWithWhole stringByAppendingString:nutrientsWithWhole];
                NSURL *url = [NSURL URLWithString:foodImage];
                [self.foodView setImageWithURL:url];
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
- (IBAction)stepperValueChanged:(UIStepper *)sender {
    int quantity = [self.quantityLabel.text integerValue];
    quantity += [sender value];
    self.quantityLabel.text = [NSString stringWithFormat:@"%i %@", quantity, self.item.quantityUnit];
    sender.value = 0;

    self.item.quantity= [NSNumber numberWithInt:quantity];
}
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
