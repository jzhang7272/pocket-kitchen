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


@end
