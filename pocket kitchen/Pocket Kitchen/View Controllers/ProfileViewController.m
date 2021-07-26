//
//  ProfileViewController.m
//  pocket kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "ProfileViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.testLabel.text = @"\u03BC";
}

- (IBAction)onTapLogOut:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"User log out failed: %@", error.localizedDescription);
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LogInViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
            [self presentViewController:loginVC animated:TRUE completion:nil];
        }
    }];
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
