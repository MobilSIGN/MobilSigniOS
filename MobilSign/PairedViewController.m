//
//  PairedViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 3. 6. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "PairedViewController.h"
#import "UIColor+MLPFlatColors.h"

@interface PairedViewController ()

@property (nonatomic, strong) UIAlertView *errorAlert;

//@property (nonatomic) BOOL visible;
//@property (nonatomic) BOOL dismiss;

@end

@implementation PairedViewController

- (UIAlertView *)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[UIAlertView alloc] initWithTitle:@"MobilSign"
                                                 message:@"Connection error occured!\nPlease try again later."
                                                delegate:nil
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    }
    return _errorAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
//    self.visible = YES;
}

- (void)didRecievedMessage:(NSString *)message
{
    
}

- (void)openCompleted
{

}

- (void)connectionClosed
{
    [UIAlertView show:@"Connection to server closed!"];
    
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

@end
