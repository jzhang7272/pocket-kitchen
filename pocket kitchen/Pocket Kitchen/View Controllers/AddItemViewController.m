//
//  AddItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "AddItemViewController.h"
#import "FoodItem.h"
#import "NutrientApiManager.h"

#import "EGOCache.h"

@import MLImage;
@import MLKit;


@interface AddItemViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UITextField *quantityUnitField;
@property (weak, nonatomic) IBOutlet UIDatePicker *expirationDate;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeView;

@property (nonatomic, strong) NSArray *pickerData;

@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) MLKBarcodeScanner *barcodeScanner;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.expirationDate.minimumDate = [NSDate date];
    
    self.pickerData = @[@"Fridge", @"Freezer", @"Pantry"];
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;
    
    self.imagePickerVC = [UIImagePickerController new];
    self.imagePickerVC.delegate = self;
    self.imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera not available so we will use photo library instead");
        self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // User taps on photo to upload photo
    UITapGestureRecognizer *photoTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(uploadTakePhoto:)];
    [self.barcodeView addGestureRecognizer:photoTapGestureRecognizer];
    [self.barcodeView setUserInteractionEnabled:YES];
    
    self.barcodeScanner = [MLKBarcodeScanner barcodeScanner];
}

- (void)uploadTakePhoto:(UITapGestureRecognizer *)sender{
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    self.barcodeView.image = (editedImage != nil) ? editedImage : originalImage;
    
    [self getBarcode:self.barcodeView.image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) getBarcode:(UIImage *)image {
    MLKBarcodeScannerOptions *options = [[MLKBarcodeScannerOptions alloc] initWithFormats:MLKBarcodeFormatUPCA];
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:image];
    visionImage.orientation = image.imageOrientation;
    
    [self.barcodeScanner processImage:visionImage completion:^(NSArray<MLKBarcode *> *_Nullable barcodes, NSError *_Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        else {
          for (MLKBarcode *barcode in barcodes) {
              NSString *displayValue = barcode.displayValue;
              NSString *rawValue = barcode.rawValue;
          }
        }
        
    }];
}

- (IBAction)onTapSave:(id)sender {
    NSString *item = [self.itemField.text capitalizedString];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *quantity = [formatter numberFromString:self.quantityField.text];
    NSDate *expDate = self.expirationDate.date;
    NSString *quantityUnit = self.quantityUnitField.text;
    NSString *category = [self pickerView:self.categoryPicker titleForRow:[self.categoryPicker selectedRowInComponent:0] forComponent:0];

    [self cacheUserFoods:item :quantity :quantityUnit :expDate :category];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
}

- (void)cacheUserFoods:(NSString *)foodItem :(NSNumber *)quantity :(NSString *)quantityUnit:(NSDate *)expDate :(NSString *)category {
    NutrientApiManager *nutrientApi = [NutrientApiManager new];
    [nutrientApi fetchInventoryNutrients:foodItem :@"totalDaily" :^(NSDictionary *dictionary, BOOL unitGram, NSString *foodImage, NSError *error) {
        
        if(error){
            NSLog(@"%@", error.localizedDescription);
        }
        else{
            NSMutableArray *highNutrients = [NSMutableArray new];
            for(id nutrient in dictionary){
                NSDictionary *nutrientDetails = dictionary[nutrient];
                if ([nutrientDetails[@"quantity"] doubleValue] >= 20){
                    [highNutrients addObject:nutrient];
                }
            }
            if ([highNutrients count] != 0){
                [[EGOCache globalCache] setObject:highNutrients forKey:[foodItem lowercaseString] withTimeoutInterval:60*60*24*7];
            }
            [FoodItem saveItem:foodItem :quantity :quantityUnit :expDate :category :foodImage];
        }
    }];
}

// PickerView Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
     return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
     return self.pickerData[row];
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
