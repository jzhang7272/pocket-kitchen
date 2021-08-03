//
//  AddGroceryItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/21/21.
//

#import "NutrientAnalysisViewController.h"
#import "InventoryViewController.h"
#import "NutrientApiManager.h"

#import "RecommendedFoodsCell.h"
#import "BadNutrientCell.h"
#import "LoadingCell.h"
#import "ScoreCell.h"

#import <SFProgressCircle/SFProgressCircle.h>
#import <PopupKit/PopupView.h>
#import "Nutrient.h"
#import "NutrientSource.h"
#import "FoodItem.h"
#import <Parse/Parse.h>
#import "EGOCache.h"
#import "Constants.h"

const int TOTAL_FOODS = 10;
const double TOTAL_NUTRIENTS = 24.;
const double ANIMATION_DURATION = 0.7;
const int NMBR_DAYS = 7;

#define grayColor [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0]
#define lightBlueColor [UIColor colorWithRed:0.86 green:0.96 blue:0.99 alpha:1.0]
#define lightPurpleColor [UIColor colorWithRed:0.87 green:0.74 blue:1.00 alpha:1.0]


@interface NutrientAnalysisViewController () <UITableViewDelegate, UITableViewDataSource> {
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
@property (nonatomic) CGPoint cellCenter;


@property (nonatomic) BOOL loaded;
@property (nonatomic) BOOL loadedProgress;

@end

@implementation NutrientAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = grayColor;
    [self.tableView setBackgroundView:backgroundView];
    
    self.tableView.tableFooterView = [UIView new];
    
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

#pragma mark - Helper Functions

- (void) analysis{
    self.missingNutrients = [NSMutableArray new];
    self.tooMuchNutrient = [NSMutableArray new];
    self.recommendedNutrients = [Nutrient recommendedNutrientAmount:NMBR_DAYS];
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
        query.limit = NMBR_QUERIES;

        [query findObjectsInBackgroundWithBlock:^(NSArray *sources, NSError *error) {
            if (sources != nil) {
                NSMutableArray *sourcesCopy = [NSMutableArray new];
                [sourcesCopy addObjectsFromArray:sources];
                NSMutableArray *currFoods = [recommendedFoods valueForKey:missing];
                int nmbrNeeded = TOTAL_FOODS - (int)currFoods.count;
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
    
    // Save as 2D array to display in UI
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        for (NSString *missing in self.missingNutrients){
            NSArray *foods = [recommendedFoods valueForKey:missing];
            [self.recommendedFoods addObject:foods];
            
        }
        [self updateUI];
    });
}

#pragma mark - UI

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)onTapInfo:(id)sender {
    UIView* contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.frame = CGRectMake(0.0, 0.0, 300, 390);
    contentView.layer.cornerRadius = SMALL_CORNER_RADIUS;
    
    UIView *titleBackground = [[UIView alloc] init];
    titleBackground.backgroundColor = lightBlueColor;
    titleBackground.frame = CGRectMake(0, 0, 300, 40);
    titleBackground.layer.cornerRadius = SMALL_CORNER_RADIUS;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 280, 20)];
    titleLabel.text = @"How does this work?";
    titleLabel.font = [UIFont fontWithName:@"Kohinoor Bangla Semibold" size:18];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.clipsToBounds = true;
    
    UILabel *bodyLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 280, 340)];
    bodyLabel.text = @"\tOf the many nutrients that can be found in our diet, the Nutrient Analysis considers 24 main nutrients in foods. In order for individuals to be healthy, they must meet the average daily recommended values (DRV) for intake of nutrients (DRV provided by The Food and Nutrition Board of the National Academies of Sciences Engineering, and Medicine). \n\tThe Nutrient Analysis then calculates the health score (out of 100) for a user's grocery list based on weekly recommended values of nutrients. To reach a score of 100, food items in the shopping list must reach the RV for nutrients beneficial to the body and not exceed RV for nutrients that are detrimental to the body in large amounts. Nutrients that have not met recommended values are represented with a green plus sign with recommended foods that are high in that nutrient. \n\tNotes: Unrecognized foods are not included in calculations. If no quantity of food item is provided, the default is 1. Quantity is measured by one item, or one serving if item information cannot be found.";
    bodyLabel.font = [UIFont fontWithName:@"Kohinoor Bangla" size:11];
    bodyLabel.numberOfLines = 0;
    bodyLabel.backgroundColor = [UIColor whiteColor];
    bodyLabel.textColor = [UIColor blackColor];
    bodyLabel.textAlignment = NSTextAlignmentLeft;
    bodyLabel.clipsToBounds = true;
    
    [contentView addSubview:titleBackground];
    [contentView addSubview:titleLabel];
    [contentView addSubview:bodyLabel];


    PopupView* popup = [PopupView popupViewWithContentView:contentView];
    popup.showType = PopupViewShowTypeBounceIn;
    popup.dismissType = PopupViewDismissTypeBounceOut;
    popup.shouldDismissOnBackgroundTouch = true;
    popup.backgroundColor = [UIColor clearColor];
    [popup show];
}


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
    float dt = ([link timestamp] - startTime) / ANIMATION_DURATION;
    if (dt >= 1.0) {
        self.percentageLabel.text = [toNumber stringValue];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    float current = ([toNumber floatValue] - [fromNumber floatValue]) * dt + [fromNumber floatValue];
    self.percentageLabel.text = [NSString stringWithFormat:@"%li", (long)current];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.loaded == true && indexPath.section != 0 && self.missingNutrients.count != 0){
        RecommendedFoodsCell *recCell = (RecommendedFoodsCell *)cell;
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
    if (self.loaded == false){
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
        return cell;
    }
    else{
        if (indexPath.section == 0){
            ScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell"];
            cell.backgroundColor = grayColor;
            
            if (!self.loadedProgress){
                self.cellCenter = cell.placeholderView.center;
            }
            
            _backgroundProgressView = [[SFCircleGradientView alloc] initWithFrame:(CGRect){0, 0, 175, 175}];
            [_backgroundProgressView setCenter:self.cellCenter];
            [_backgroundProgressView setLineWidth:10];
            [_backgroundProgressView setProgress:1];
            [_backgroundProgressView setRoundedCorners:YES];
            [_backgroundProgressView setStartColor:[UIColor systemGray6Color]];
            [_backgroundProgressView setEndColor:[UIColor systemGray6Color]];
            [_backgroundProgressView setStartAngle: M_PI_2];
            [_backgroundProgressView setEndAngle:2 * M_PI + M_PI_2];
            [cell.contentView addSubview:_backgroundProgressView];
            
            _progressView = [[SFCircleGradientView alloc] initWithFrame:(CGRect){0, 0, 175, 175}];
            [_progressView setCenter:self.cellCenter];
            [_progressView setLineWidth:10];
            [_progressView setProgress:0];
            [_progressView setRoundedCorners:YES];
            [cell.contentView addSubview:_progressView];
                
            _percentageLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 100, 30}];
            [_percentageLabel setCenter:self.cellCenter];
            [_percentageLabel setFont:[UIFont fontWithName:@"Kohinoor Bangla Semibold" size:32]];
            [_percentageLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.contentView addSubview:_percentageLabel];
            
            [self.progressView setStartColor:lightBlueColor];
            [self.progressView setEndColor:lightPurpleColor];
            [self.progressView setStartAngle: M_PI_2];
            [self.progressView setEndAngle:2 * M_PI + M_PI_2];
            [self.percentageLabel setTextColor:[UIColor blackColor]];
            
            double percentage = (TOTAL_NUTRIENTS - self.missingNutrients.count - self.tooMuchNutrient.count)/ TOTAL_NUTRIENTS;
            if(!self.loadedProgress){
                [self.progressView setProgress:percentage animateWithDuration:ANIMATION_DURATION];
                [self animateTitle:@(0.f) toNumber:@((int) (percentage * 100))];
                self.loadedProgress = true;
            }
            else{
                [self.progressView setProgress:percentage];
            }
           
            
            return cell;
        }
        else if (indexPath.section == 1 && self.tooMuchNutrient.count != 0){
            BadNutrientCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BadNutrientcell"];

            NSMutableArray *nutrientNames = [NSMutableArray new];
            for (NSString *nutrient in self.tooMuchNutrient){
                Nutrient *currNutrient = [self.recommendedNutrients valueForKey:nutrient];
                [nutrientNames addObject:currNutrient.name];
            }
            NSString *nutrientString = [[nutrientNames valueForKey:@"description"] componentsJoinedByString:@", "];
            cell.nutrientLabel.text = [NSString stringWithFormat:@"You're going over the recommended values for the following nutrients: %@", nutrientString];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = LARGE_CORNER_RADIUS;
            cell.layer.masksToBounds= true;
            return cell;
        }
        else{
            RecommendedFoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendedFoodsCell"];
            
            if (self.missingNutrients.count == 0){
                [cell.nutrientLabel setFont:[UIFont fontWithName:@"Kohinoor Bangla" size:18]];
                cell.nutrientLabel.text = @"Recommended values for healthy nutrients reached!";
                [cell.iconButton setSelected:true];
            }
            else{
                int index = (self.tooMuchNutrient.count > 0) ? (int)(indexPath.section - 2) : (int)(indexPath.section - 1);
                cell.nutrient = self.missingNutrients[index];
                Nutrient *currNutrient = [self.recommendedNutrients valueForKey:cell.nutrient];
                cell.nutrientLabel.text = currNutrient.name;
                cell.recommendedFoods = self.recommendedFoods[index];
                [cell.iconButton setSelected:false];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = LARGE_CORNER_RADIUS;
            cell.layer.masksToBounds= true;
            return cell;
        }
    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int badNutrientCount = (self.tooMuchNutrient.count == 0) ? 0 : 1;
    
    // If there are no missing nutrients, one section still used to display information
    return (self.missingNutrients.count == 0) ? (2 + badNutrientCount) : self.missingNutrients.count + badNutrientCount + 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = grayColor;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return (CGFloat) 10;
}

@end


