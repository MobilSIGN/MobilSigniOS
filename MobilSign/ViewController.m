//
//  ViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

@implementation ViewController

- (IBAction)connect:(UIButton *)sender
{
    [self.addressField resignFirstResponder];
    
    if (self.addressField.text && self.addressField.text.length > 0) {
        
        ChatViewController *chatVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
        chatVC.address = self.addressField.text;
        
        [self presentModalViewController:chatVC animated:YES];
        [chatVC connect];
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

- (void)viewDidUnload
{
    [self setAddressField:nil];
    [self setConnectButton:nil];
    [super viewDidUnload];
}

@end
