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
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *helloLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 100, 20)];
    helloLabel.text = @"Hello!";
    helloLabel.font = [UIFont fontWithName:@"Kohinoor Bangla" size:18];
    helloLabel.textColor = [UIColor lightGrayColor];
    helloLabel.textAlignment = NSTextAlignmentCenter;
    helloLabel.backgroundColor = [UIColor clearColor];

    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 100, 180)];
    titleLabel.text = PFUser.currentUser.username;
    titleLabel.font = [UIFont fontWithName:@"Kohinoor Bangla Semibold" size:32];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
    [logout addTarget:self
               action:@selector(onTapLogOut)
     forControlEvents:UIControlEventTouchUpInside];
    logout.frame = CGRectMake(10, 180, 100.0, 40.0);
    [logout setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [logout setTitle:@"Log Out" forState:UIControlStateNormal];
    
    [self.view addSubview:helloLabel];
    [self.view addSubview:titleLabel];
    [self.view addSubview:logout];
}

- (void)onTapLogOut {
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
