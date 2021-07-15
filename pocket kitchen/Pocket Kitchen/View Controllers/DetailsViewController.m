//
//  DetailsViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/14/21.
//

#import "DetailsViewController.h"
#import "NutrientApiManager.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nutritionLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *expDateLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.foodItemLabel.text = self.item.name;
    self.quantityLabel.text = [NSString stringWithFormat:@"%@", self.item.quantity];
    
    if (self.item.nutrients == nil){
        
        // Start Activity Indicator
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        self.activityIndicator.center = self.view.center;
        [self.view addSubview:self.activityIndicator];
         [self.activityIndicator startAnimating];
        [self fetchFoodNutrients];
    }
    else{
        self.nutritionLabel.text = [self convertNutrientsToString:self.item.nutrients];
    }
}

- (void) fetchFoodNutrients{
    NutrientApiManager *nutrientApi = [NutrientApiManager new];
    [nutrientApi fetchFood:self.item.name :^(NSDictionary *nutrients, NSError *error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            self.item.nutrients = nutrients;
            self.nutritionLabel.text = [self convertNutrientsToString:self.item.nutrients];
//            NSLog(@"%@", nutrients);
        }
    }];
}

- (NSString *)convertNutrientsToString:(NSDictionary *)dictionary{
    NSMutableString *ret = [NSMutableString new];
    for(id key in dictionary){
        [ret appendString:[NSString stringWithFormat:@"%@: %@\n", key, [dictionary objectForKey:key]]];
    }
    NSLog(@"%@", ret);
    [self.activityIndicator stopAnimating];
    return ret;
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
