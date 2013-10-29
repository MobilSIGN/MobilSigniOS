//
//  ChatViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "QRCodeViewController.h"
#import "SIAlertView.h"
#import "UIColor+MLPFlatColors.h"
#import "UIFont+FlatUI.h"
#import "PairedViewController.h"
#import "NSString+SHA1.h"
//#import "ZBarCameraSimulator.h"

@interface QRCodeViewController ()

@property (strong, nonatomic) MobilSignClient *client;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) BOOL dismiss;
@property (nonatomic, strong) SIAlertView *errorAlert;
@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;
@property (weak, nonatomic) IBOutlet UITextView *scanTextView;

@end

@implementation QRCodeViewController

- (SIAlertView *)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[SIAlertView alloc] initWithTitle:@"MobilSign" andMessage:@"Connection error occured!\nPlease try again later."];
        [_errorAlert addButtonWithTitle:@"Ok" type:SIAlertViewButtonTypeDestructive handler:nil];
    }
    return _errorAlert;
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
    
}

- (void)openCompleted
{
    [self.spinner stopAnimating];
    [self.connectingLabel setHidden:YES];
    [self.scanTextView setHidden:NO];
    [self.readerView setHidden:NO];
    
    [self performSelector:@selector(sendTestMessage) withObject:nil afterDelay:1.0];
}

- (void)sendTestMessage
{
    NSLog(@"Test message.");
    [self.client sendMessage:@"message\n"];
}


- (void)connectionClosed
{
    self.dismiss = YES;
    [self.spinner stopAnimating];
    
    [self showAlert:@"Connection to server closed!"];
    
    NSLog(@"NC: %@", self.navigationController);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)errorOccurred
{
    self.dismiss = YES;
    [self.spinner stopAnimating];
    
    [self.errorAlert show];
    
    NSLog(@"NC: %@", self.navigationController);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didPair
{
    PairedViewController *pairedVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PairedViewController"];
    pairedVC.client = self.client;
    pairedVC.client.delegate = pairedVC;
    
    [self.navigationController pushViewController:pairedVC animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.readerView.readerDelegate = self;
    self.readerView.torchMode = 0;
    
    self.view.backgroundColor = [UIColor flatWhiteColor];

    self.spinner.color = [UIColor flatDarkBlueColor];

    self.connectingLabel.font = [UIFont boldFlatFontOfSize:[UIFont labelFontSize]];
    self.connectingLabel.textColor = [UIColor flatDarkBlueColor];
    
    self.scanTextView.font = [UIFont boldFlatFontOfSize:[UIFont labelFontSize]];
    self.scanTextView.textColor = [UIColor flatDarkBlueColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.dismiss) {
        NSLog(@"NC: %@", self.navigationController);
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    [alertView addButtonWithTitle:@"Ok" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alertView show];
}

- (void)readerView:(ZBarReaderView *)view didReadSymbols:(ZBarSymbolSet *)syms fromImage:(UIImage *)img
{
    for(ZBarSymbol *sym in syms) {
        if ([self checkKey:sym.data]) {
            long long key = [sym.data longLongValue];
            NSLog(@"Long long value: %lld", key);
            NSString *fingerprint = [sym.data SHA1];
            [self.readerView stop];
            [self.client pairWithFingerprint:fingerprint];
            [self showAlert:[NSString stringWithFormat:@"Pairing with key fingerprint:\n%@", fingerprint]];
            break;
        }
    }
}

- (BOOL)checkKey:(NSString *)key
{
    NSLog(@"Key scanned: %@", key);
    return YES;
}

@end
