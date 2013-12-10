//
//  PairedViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 3. 6. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "PairedViewController.h"

@interface PairedViewController ()

@property (nonatomic, strong) UIAlertView *errorAlert;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PairedViewController

- (UIAlertView *)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[UIAlertView alloc] initWithTitle:@"Can't connect to server"
                                                 message:@"Please, chceck server address or try again later."
                                                delegate:nil
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    }
    return _errorAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Paired";
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Exit"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(exit)];
    
    [self.textField becomeFirstResponder];
}

- (void)didRecievedMessage:(NSString *)message
{
    NSLog(@"Recieved message: %@", message);
    self.textLabel.text = message;
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

- (void)exit
{
    [[MobilSignClient sharedClient] close];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        NSLog(@"Send: %@", textField.text);
        [[MobilSignClient sharedClient] sendMessage:textField.text];
        textField.text = @"";
    }
    
    return NO;
}

@end
