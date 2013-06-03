//
//  ChatViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "ChatViewController.h"
#import "SIAlertView.h"
#import "UIColor+MLPFlatColors.h"
//#import "ZBarCameraSimulator.h"

@interface ChatViewController ()

@property (strong, nonatomic) MobilSignClient *client;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) BOOL dismiss;
@property (nonatomic, strong) SIAlertView *errorAlert;
//@property (nonatomic, strong) ZBarCameraSimulator *cameraSim;
@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;

@end

@implementation ChatViewController

- (SIAlertView *)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[SIAlertView alloc] initWithTitle:@"MobilSign" andMessage:@"Connection error occured!\nPlease try again later."];
        [_errorAlert addButtonWithTitle:@"Ok" type:SIAlertViewButtonTypeDestructive handler:nil];
    }
    return _errorAlert;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0) return NO;
    
    if (self.client) {
        [self.client sendMessage:textField.text];
        textField.text = @"";
    } else {
        [self showAlert:@"Cant send message!"];
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
    
    [self.textField setHidden:NO];
    //[self.textField becomeFirstResponder];
    
    [self showAlert:@"Connection successfully opened."];
}

- (void)connectionClosed
{
    [self.spinner stopAnimating];
    
    [self showAlert:@"Connection closed."];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)errorOccurred
{
    self.dismiss = YES;
    [self.spinner stopAnimating];
    
    [self.errorAlert show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.readerView.readerDelegate = self;
    
    self.view.backgroundColor = [UIColor flatWhiteColor];
    
    self.textView.backgroundColor = [UIColor flatWhiteColor];
    
    self.spinner.color = [UIColor flatDarkBlueColor];
    
    self.textField.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.dismiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.readerView start];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.readerView stop];
}

- (void)showAlert:(NSString *)alert
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"MobilSign" andMessage:alert];
    [alertView addButtonWithTitle:@"Ok" type:SIAlertViewButtonTypeDefault handler:nil];
    [alertView show];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setTextField:nil];
    [super viewDidUnload];
}

- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{
    for(ZBarSymbol *sym in syms) {
        NSLog(@"QR: %@", sym.data);
        [self didRecievedMessage:[NSString stringWithFormat:@"%@\n", sym.data]];
        //break;
    }
}

@end
