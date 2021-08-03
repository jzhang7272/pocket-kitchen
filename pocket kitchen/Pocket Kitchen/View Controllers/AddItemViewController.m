//
//  AddItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "AddItemViewController.h"
#import "NutrientApiManager.h"
#import "FoodItem.h"
#import "Nutrient.h"
#import "Constants.h"

#import "EGOCache.h"
#import "UIImageView+AFNetworking.h"

const int ONE_DAY = 1;

@import MLImage;
@import MLKit;

@interface AddItemViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UITextField *quantityUnitField;
@property (weak, nonatomic) IBOutlet UIDatePicker *expirationDate;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) NSMutableDictionary *nutrients;
@property (nonatomic, strong) NSString *nutrientUnit;
@property (nonatomic, strong) NSString *foodImage;

@property (strong, nonatomic) UIImagePickerController *barcodePickerVC;
@property (strong, nonatomic) MLKBarcodeScanner *barcodeScanner;
@property (strong, nonatomic) UIView *loadingView;

@end

@implementation AddItemViewController

#pragma mark - UI

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.expirationDate.minimumDate = [NSDate date];
    self.barcodeScanner = [MLKBarcodeScanner barcodeScanner];
    
    self.pickerData = @[@"Fridge", @"Freezer", @"Pantry"];
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;
    
    self.barcodePickerVC = [UIImagePickerController new];
    self.barcodePickerVC.delegate = self;
    self.barcodePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.barcodePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera not available so we will use photo library instead");
        self.barcodePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(uploadBarcodeImage:)];
    [self.barcodeView addGestureRecognizer:photoTapGestureRecognizer];
    [self.barcodeView setUserInteractionEnabled:YES];
    
    self.barcodeView.layer.cornerRadius = SMALL_CORNER_RADIUS;
    self.barcodeView.clipsToBounds = true;
    self.saveButton.layer.cornerRadius = LARGE_CORNER_RADIUS;
    self.saveButton.clipsToBounds = true;
}


// BarcodePickerView Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *barcodeImage = (editedImage != nil) ? editedImage : originalImage;
    
    [self showLoadingScreen];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self getBarcode:barcodeImage];
}


// CategoryPickerView Delegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
     return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerData.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
        if (!tView){
            tView = [[UILabel alloc] init];
            [tView setFont:[UIFont fontWithName:@"Kohinoor Bangla" size:18]];
            tView.text = self.pickerData[row];
            tView.textAlignment = NSTextAlignmentCenter;
        }
        return tView;
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
     return self.pickerData[row];
}

#pragma mark - UI Helper Functions

- (void)uploadBarcodeImage:(UITapGestureRecognizer *)sender{
    [self presentViewController:self.barcodePickerVC animated:YES completion:nil];
}

- (void) showLoadingScreen {
    self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.loadingView setBackgroundColor:[UIColor systemGray5Color]];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor lightGrayColor];
    [activityIndicator setFrame:CGRectMake((self.loadingView.frame.size.width / 2 - 10), (self.loadingView.frame.size.height / 2 - 10), 20, 20)];

    [self.loadingView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [self.view addSubview:self.loadingView];
}

- (void) showError:(NSString *)title :(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Button Actions

- (IBAction)onTapSave:(id)sender {
    NSString *item = [self.itemField.text capitalizedString];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *quantity = [formatter numberFromString:self.quantityField.text];
    NSDate *expDate = self.expirationDate.date;
    NSString *quantityUnit = self.quantityUnitField.text;
    NSString *category = [self pickerView:self.categoryPicker titleForRow:[self.categoryPicker selectedRowInComponent:0] forComponent:0];
    
    if (self.nutrients != nil){
        [self cacheBarcodeFoods:item :quantity :quantityUnit :expDate :category];
        [self dismissViewControllerAnimated:true completion:nil];
    }
    else{
        [self cacheUserFoods:item :quantity :quantityUnit :expDate :category];
    }
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)onClear:(id)sender {
    self.nutrients = nil;
    self.nutrientUnit = nil;
    [self.barcodeView setImage:[UIImage systemImageNamed:@"photo"]];
    self.itemField.text = @"";
    self.foodImage = nil;
}

#pragma mark - Helper Functions

- (void) getBarcode:(UIImage *)image {
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    [self.barcodeScanner processImage:visionImage completion:^(NSArray<MLKBarcode *> *_Nullable barcodes, NSError *_Nullable error) {
        if (error || barcodes.count == 0) {
            NSLog(@"%@", error.localizedDescription);
            [self.loadingView removeFromSuperview];
            [self showError:@"Couldn't read barcode" :@"No barcode found."];
        }
        else {
          for (MLKBarcode *barcode in barcodes) {
              NSString *rawValue = barcode.rawValue;
              NSLog(@"Raw: %@", rawValue);
              [self getFoodFromBarcode:rawValue];
          }
        }
    }];
}

- (void) getFoodFromBarcode:(NSString *)barcode {
    NutrientApiManager *nutrientApi = [NutrientApiManager new];
    [nutrientApi fetchBarcodeNutrients:barcode :^(NSString *name, NSDictionary *dictionary, NSString *image, NSString *unit, NSString *amtPerUnit, BOOL error) {
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView removeFromSuperview];
                [self showError:@"Unknown Barcode" :@"Couldn't find food with UPC code."];
            });
        }
        else{
            self.nutrients = [NSMutableDictionary new];
            [self.nutrients addEntriesFromDictionary:dictionary];
            self.nutrientUnit = unit;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.itemField.text = name;
                self.foodImage = image;
                NSURL *url = [NSURL URLWithString:image];
                [self.barcodeView setImageWithURL:url];
                [self.loadingView removeFromSuperview];
            });
        }
    }];
}

- (void)cacheUserFoods:(NSString *)foodItem :(NSNumber *)quantity :(NSString *)quantityUnit:(NSDate *)expDate :(NSString *)category {
    NutrientApiManager *nutrientApi = [NutrientApiManager new];
    [nutrientApi fetchInventoryNutrients:foodItem :@"totalDaily" :^(NSDictionary *dictionary, BOOL unitGram, NSString *foodImage, NSError *error) {
        if(dictionary == nil){
            NSLog(@"%@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Item not Found" message:@"The food item you entered was not found in the databse. Would you still like to add this item to your inventory?" preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {[self dismissViewControllerAnimated:true completion:nil];}];
                [alert addAction:cancelAction];

                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                    [FoodItem saveItem:foodItem :quantity :quantityUnit :expDate :category :foodImage];
                    [self dismissViewControllerAnimated:true completion:nil];
                }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else{
            NSMutableArray *highNutrients = [NSMutableArray new];
            for(id nutrient in dictionary){
                NSDictionary *nutrientDetails = dictionary[nutrient];
                if ([nutrientDetails[@"quantity"] doubleValue] >= THRESHOLD_HIGH_DRV){
                    [highNutrients addObject:nutrient];
                }
            }
            if ([highNutrients count] != 0){
                [[EGOCache globalCache] setObject:highNutrients forKey:[foodItem capitalizedString] withTimeoutInterval:CACHE_TIME];
            }
            [FoodItem saveItem:foodItem :quantity :quantityUnit :expDate :category :foodImage];
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

- (void)cacheBarcodeFoods:(NSString *)foodItem :(NSNumber *)quantity :(NSString *)quantityUnit :(NSDate *)expDate :(NSString *)category {
    NSMutableArray *highNutrients = [NSMutableArray new];
    NSDictionary *recommendedNutrients = [Nutrient recommendedNutrientAmount:ONE_DAY];
    for(id nutrient in recommendedNutrients){
        double recommendedAmt = ((Nutrient *)[recommendedNutrients valueForKey:nutrient]).quantity;
        double foodAmt = [self.nutrients[nutrient] doubleValue];
        if (foodAmt >= (THRESHOLD_HIGH_DECIMAL_DRV * recommendedAmt)){
            [highNutrients addObject:nutrient];
        }
    }
    if ([highNutrients count] != 0){
        [[EGOCache globalCache] setObject:highNutrients forKey:[foodItem lowercaseString] withTimeoutInterval:CACHE_TIME];
    }
    [FoodItem saveItem:foodItem :quantity :quantityUnit :expDate :category :self.foodImage];
}


@end
