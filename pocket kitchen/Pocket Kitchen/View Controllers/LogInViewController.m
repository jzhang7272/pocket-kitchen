//
//  LogInViewController.m
//  pocket kitchen
//
//  Created by Josey Zhang on 7/12/21.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface LogInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *magnetView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundView.image = [UIImage imageNamed:@"whiteFridge"];
    [self.view sendSubviewToBack:self.backgroundView];
    
    self.titleLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titleLabel.layer.shadowOpacity = 0.8;
    self.titleLabel.layer.shadowRadius = 4;
    self.titleLabel.layer.shadowOffset = CGSizeMake(4, 4);
    self.titleLabel.layer.masksToBounds = false;
    
    self.magnetView.layer.cornerRadius = self.magnetView.frame.size.width / 2;
    self.magnetView.layer.masksToBounds = true;
    self.magnetView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.magnetView.layer.shadowOpacity = 0.8;
    self.magnetView.layer.shadowRadius = 1;
    self.magnetView.layer.shadowOffset = CGSizeMake(1.5, 3);
    
    self.loginButton.layer.cornerRadius = SMALL_CORNER_RADIUS;
    self.loginButton.layer.masksToBounds = false;
}


- (IBAction)onTapLogIn:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Username or password incorrect." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            
        }
    }];
}

- (IBAction)onTapSignUp:(id)sender {
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up Failed" message:@"Try a different username and password." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"User created.");
        }
    }];
}

@end
