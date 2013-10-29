//
//  ViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "ConnectViewController.h"
#import "QRCodeViewController.h"
#import "UIColor+MLPFlatColors.h"
#import "UIFont+FlatUI.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 3.0

@interface ConnectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *serverButtons;

@end

@implementation ConnectViewController

- (IBAction)connect:(UIButton *)sender
{
    [self.addressField resignFirstResponder];
    
    if (self.addressField.text && self.addressField.text.length > 0) {
        
        QRCodeViewController *qrCodeVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"QRCodeViewController"];
        qrCodeVC.address = self.addressField.text;
        
        [self.navigationController pushViewController:qrCodeVC animated:YES];
        [qrCodeVC connect];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor flatWhiteColor];
    
    self.connectLabel.textColor = self.addressField.textColor = [UIColor flatDarkBlackColor];
    self.connectLabel.font = [UIFont flatFontOfSize:[UIFont labelFontSize]];
    
    self.addressField.textColor = [UIColor flatDarkBlackColor];
    self.addressField.font = [UIFont flatFontOfSize:[UIFont labelFontSize]];
    
    self.connectButton.backgroundColor = [UIColor flatDarkBlueColor];
    self.connectButton.titleLabel.font = [UIFont flatFontOfSize:[UIFont buttonFontSize]];
    [self.connectButton setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateNormal];
    self.connectButton.layer.cornerRadius = CORNER_RADIUS;
    
    for (UIButton *button in self.serverButtons) {
        button.backgroundColor = [UIColor flatDarkBlueColor];
        button.titleLabel.font = [UIFont flatFontOfSize:[UIFont buttonFontSize]];
        [button setTitleColor:[UIColor flatWhiteColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = CORNER_RADIUS;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.addressField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        //[textField resignFirstResponder];
        [self connect:nil];
        
        return YES;
    }
    return NO;
}

- (IBAction)addressButtonPressed:(UIButton *)sender
{
    self.addressField.text = sender.titleLabel.text;
}

- (void)viewDidUnload
{
    [self setAddressField:nil];
    [self setConnectButton:nil];
    [self setServerButtons:nil];
    [self setConnectLabel:nil];
    [super viewDidUnload];
}

@end
