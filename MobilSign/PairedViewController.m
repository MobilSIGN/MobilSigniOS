//
//  PairedViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 3. 6. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "PairedViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "SIAlertView.h"

@interface PairedViewController ()

@property (nonatomic, strong) SIAlertView *errorAlert;

@end

@implementation PairedViewController

- (SIAlertView *)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[SIAlertView alloc] initWithTitle:@"MobilSign" andMessage:@"Connection error occured!\nPlease try again later."];
        [_errorAlert addButtonWithTitle:@"Ok" type:SIAlertViewButtonTypeDestructive handler:nil];
    }
    return _errorAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor flatWhiteColor];
}

- (void)didRecievedMessage:(NSString *)message
{
    
}

- (void)openCompleted
{

}

- (void)connectionClosed
{
    [self showAlert:@"Connection to server closed!"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)errorOccurred
{
    [self.errorAlert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPair
{

}

- (void)showAlert:(NSString *)alert
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"MobilSign" andMessage:alert];
    [alertView addButtonWithTitle:@"Ok" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alertView show];
}

@end
