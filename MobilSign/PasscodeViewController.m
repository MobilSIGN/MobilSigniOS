//
//  PasscodeViewController.m
//  MobilSign
//
//  Created by Marek Spalek on 03. 11. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "PasscodeViewController.h"

@interface PasscodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passcodeField;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;

@end

@implementation PasscodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if ([CryptoManager passcodeExist]) {
        self.confirmLabel.text = @"Confirm";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.passcodeField becomeFirstResponder];
}

#pragma mark - Text field

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length + string.length > 3) self.confirmLabel.enabled = YES;
    else self.confirmLabel.enabled = NO;
    
    if (textField.text.length + string.length > 8) return NO;
    else return YES;
}

- (void)passcodeButtonPressed
{
    if ([CryptoManager passcodeExist]) {
        
        if ([CryptoManager checkValidPasscode:self.passcodeField.text]) {
            NSLog(@"Good passcode");
            
            [self.navigationController pushViewController:[UIStoryboard viewControllerWithIdentifier:@"ConnectViewController"] animated:YES];
        } else {
            NSLog(@"Bad passcode");
            
            [UIAlertView show:@"Wrong passcode, try again."];
        }
    } else {
        NSLog(@"Create passcode");
        
        [CryptoManager createPasscode:self.passcodeField.text];
        
        [self.navigationController pushViewController:[UIStoryboard viewControllerWithIdentifier:@"ConnectViewController"] animated:YES];
    }
    self.passcodeField.text = nil;
    self.confirmLabel.enabled = NO;
}

#pragma  mark - Table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        if (self.passcodeField.text.length > 3) {
            [self passcodeButtonPressed];
        } else {
            [UIAlertView show:@"Too short passcode."];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([CryptoManager passcodeExist]) {
        return @"Please enter you passcode to keychain.";
    } else {
        return @"Please set your passcode to keychain. It will improve your security.";
    }
}

@end
