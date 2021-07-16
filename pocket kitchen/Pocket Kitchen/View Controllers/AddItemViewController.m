//
//  AddItemViewController.m
//  Pocket Kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "AddItemViewController.h"
#import "FoodItem.h"

@interface AddItemViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *itemField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIDatePicker *expirationDate;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;

@property (nonatomic, strong) NSArray *pickerData;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.expirationDate.minimumDate = [NSDate date];
    
    self.pickerData = @[@"Fridge", @"Freezer", @"Pantry"];
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;
}
- (IBAction)onTapSave:(id)sender {
    NSString *item = self.itemField.text;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *quantity = [formatter numberFromString:self.quantityField.text];
    NSDate *expDate = self.expirationDate.date;
    NSString *category = [self pickerView:self.categoryPicker titleForRow:[self.categoryPicker selectedRowInComponent:0] forComponent:0];
    BOOL branded = (self.typeControl.selectedSegmentIndex == 1) ? true : false;
    
    [FoodItem saveItem:item :quantity :expDate :category :branded];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:true];
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
