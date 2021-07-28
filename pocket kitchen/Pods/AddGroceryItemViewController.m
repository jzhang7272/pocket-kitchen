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
#import "ScoreCell.h"


#import "NutrientApiManager.h"
#import <SFProgressCircle/SFProgressCircle.h>
#import "Nutrient.h"
#import "NutrientSource.h"
#import "FoodItem.h"
#import <Parse/Parse.h>
#import "EGOCache.h"

#define AnimationDuration 0.7
#define grayColor [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0]
#define lightBlueColor [UIColor colorWithRed:0.86 green:0.96 blue:0.99 alpha:1.0]
#define lightPurpleColor [UIColor colorWithRed:0.87 green:0.74 blue:1.00 alpha:1.0]


@interface AddGroceryItemViewController () <UITableViewDelegate, UITableViewDataSource>
{
    CFTimeInterval startTime;
    NSNumber *fromNumber;
    NSNumber *toNumber;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIView *loadingView;


@property (nonatomic, strong) NSMutableArray *missingNutrients;
@property (nonatomic, strong) NSMutableArray *tooMuchNutrient;
@property (nonatomic, strong) NSMutableArray *recommendedFoods;
@property (nonatomic, strong) NSDictionary *recommendedNutrients;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic) SFCircleGradientView *progressView;
@property (nonatomic) SFCircleGradientView *backgroundProgressView;
@property (nonatomic) UILabel *percentageLabel;


@property (nonatomic) BOOL loaded;
@property (nonatomic) BOOL loadedProgress;

@end

@implementation AddGroceryItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = grayColor;
    [self.tableView setBackgroundView:backgroundView];
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.loadingView)
    {
        self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.loadingView setBackgroundColor:grayColor];

        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.color = [UIColor lightGrayColor];
        [activityIndicator setFrame:CGRectMake((self.loadingView.frame.size.width / 2 - 10), (self.loadingView.frame.size.height / 2 - 10), 20, 20)];

        [self.loadingView addSubview:activityIndicator];

        [activityIndicator startAnimating];
    }
    [self.view addSubview:self.loadingView];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.loaded = false;
    [self analysis];
    [self getRecommendedFoods];
}


- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) analysis{
    self.missingNutrients = [NSMutableArray new];
    self.tooMuchNutrient = [NSMutableArray new];
    self.recommendedNutrients = [Nutrient recommendedNutrientAmount:1];
    NSDictionary *diffNutrients = [Nutrient nutrientDifference:self.groceryItemArray :self.recommendedNutrients];
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
        [self updateUI];
    });
}

#pragma mark - UI

- (void) updateUI {
    self.loaded = true;
    self.loadedProgress = false;
    [self.tableView reloadData];
    [self.loadingView removeFromSuperview];
    
}

- (void)animateTitle:(NSNumber *)from toNumber:(NSNumber *)to {
    fromNumber = from;
    toNumber = to;
    self.percentageLabel.text = [fromNumber stringValue];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateNumber:)];
    startTime = CACurrentMediaTime();
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)animateNumber:(CADisplayLink *)link {
    float dt = ([link timestamp] - startTime) / AnimationDuration;
    if (dt >= 1.0) {
        self.percentageLabel.text = [toNumber stringValue];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    float current = ([toNumber floatValue] - [fromNumber floatValue]) * dt + [fromNumber floatValue];
    self.percentageLabel.text = [NSString stringWithFormat:@"%li", (long)current];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.loaded == true && indexPath.section != 0){
        RecommendedFoodsCell *recCell = cell;
        if (self.tooMuchNutrient.count > 0){
            if (indexPath.section != 1){
                [recCell setCollectionViewDataSourceDelegate:recCell forRow:(int)indexPath.section];
            }
        }
        else{
            [recCell setCollectionViewDataSourceDelegate:recCell forRow:(int)indexPath.section];
        }
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.recommendedFoods.count == 0){
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        return cell;
    }
    else{
        if (indexPath.section == 0){
            ScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell"];
            cell.backgroundColor = grayColor;
            
            _backgroundProgressView = [[SFCircleGradientView alloc] initWithFrame:(CGRect){0, 0, 175, 175}];
            [_backgroundProgressView setCenter:cell.placeholderView.center];
            [_backgroundProgressView setLineWidth:10];
            [_backgroundProgressView setProgress:1];
            [_backgroundProgressView setRoundedCorners:YES];
            [_backgroundProgressView setStartColor:[UIColor systemGray6Color]];
            [_backgroundProgressView setEndColor:[UIColor systemGray6Color]];
            [_backgroundProgressView setStartAngle: M_PI_2];
            [_backgroundProgressView setEndAngle:2 * M_PI + M_PI_2];
            [cell.contentView addSubview:_backgroundProgressView];
            
            _progressView = [[SFCircleGradientView alloc] initWithFrame:(CGRect){0, 0, 175, 175}];
            [_progressView setCenter:cell.placeholderView.center];
            [_progressView setLineWidth:10];
            [_progressView setProgress:0];
            [_progressView setRoundedCorners:YES];
            [cell.contentView addSubview:_progressView];
                
            _percentageLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 100, 30}];
            [_percentageLabel setCenter:cell.placeholderView.center];
            [_percentageLabel setFont:[UIFont fontWithName:@"Kohinoor Bangla Semibold" size:32]];
            [_percentageLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.contentView addSubview:_percentageLabel];
            
            [self.progressView setStartColor:lightBlueColor];
            [self.progressView setEndColor:lightPurpleColor];
            [self.progressView setStartAngle: M_PI_2];
            [self.progressView setEndAngle:2 * M_PI + M_PI_2];
            [self.percentageLabel setTextColor:[UIColor blackColor]];
            
            double percentage = (24 - self.missingNutrients.count - self.tooMuchNutrient.count)/ 24.;
            if(!self.loadedProgress){
                [self.progressView setProgress:percentage animateWithDuration:AnimationDuration];
                [self animateTitle:@(0.f) toNumber:@((int) (percentage * 100))];
                self.loadedProgress = true;
            }
            else{
                [self.progressView setProgress:percentage];
            }
           
            
            return cell;
        }
        if (indexPath.section == 1 && self.tooMuchNutrient.count != 0){
            BadNutrientCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BadNutrientcell"];
            
            NSMutableArray *nutrientNames = [NSMutableArray new];
            for (NSString *nutrient in self.tooMuchNutrient){
                Nutrient *currNutrient = [self.recommendedNutrients valueForKey:nutrient];
                [nutrientNames addObject:currNutrient.name];
            }
            NSString *nutrientString = [[nutrientNames valueForKey:@"description"] componentsJoinedByString:@", "];
            cell.nutrientLabel.text = [NSString stringWithFormat:@"You're going over the recommended values for the following nutrients: %@", nutrientString];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = 20;
            cell.layer.masksToBounds= true;
            return cell;
        }
        else{
            RecommendedFoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendedFoodsCell"];
            int index = (int)(indexPath.section - 1);
            cell.nutrient = self.missingNutrients[index];
            Nutrient *currNutrient = [self.recommendedNutrients valueForKey:cell.nutrient];
            cell.nutrientLabel.text = currNutrient.name;
            cell.recommendedFoods = self.recommendedFoods[index];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = 20;
            cell.layer.masksToBounds= true;

            return cell;
        }
    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return (self.missingNutrients.count + 1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = grayColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    CGFloat height = 10;
    return height;
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


