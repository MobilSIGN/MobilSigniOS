//
//  ChatViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (strong, nonatomic) MobilSignClient *client;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) BOOL dismiss;

@end

@implementation ChatViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0) return NO;
    
    if (self.client) {
        [self.client sendMessage:textField.text];
        textField.text = @"";
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MobilSign"
                                                        message:@"Cant send message!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return NO;
}

- (void)connect
{
    if (self.address && self.address.length > 0) {
        [self.spinner startAnimating];
        
        [self.client setupConnection];
    }
}

- (MobilSignClient *)client
{
    if (!_client) {
        _client = [[MobilSignClient alloc] initWithAddress:self.address];
        _client.delegate = self;
    }
    return _client;
}

#pragma mark - MobilSignClientDelegate

- (void)didRecievedMessage:(NSString *)message
{
    self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, message];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length - 1, 0)];
}

- (void)openCompleted
{
    [self.spinner stopAnimating];
    [self.textField becomeFirstResponder];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MobilSign"
                                                    message:@"Connection successfully opened."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionClosed
{
    [self.spinner stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MobilSign"
                                                    message:@"Connection closed."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)errorOccurred
{
    self.dismiss = YES;
    [self.spinner stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MobilSign"
                                                    message:@"Connection error occured!"
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.dismiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setTextField:nil];
    [super viewDidUnload];
}

@end
