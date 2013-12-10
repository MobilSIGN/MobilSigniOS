//
//  ChatViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "QRCodeViewController.h"
#import "PairedViewController.h"
#import "NSString+SHA1.h"
#import <QuartzCore/QuartzCore.h>

@interface QRCodeViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIAlertView *errorAlert;
@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;

@property (nonatomic) BOOL dismiss;
@property (nonatomic) BOOL visible;

@end

@implementation QRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    
    self.readerView.readerDelegate = self;
    self.readerView.torchMode = 0;
    
    if (![UIDevice systemVersionAtLeast:7.0]) {
        self.readerView.layer.cornerRadius = 7.0;
        self.readerView.layer.masksToBounds = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.visible = YES;
    
    if (self.dismiss) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self connect];
        
        [self.readerView start];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.visible = NO;
    
    [self.readerView stop];
}

- (UIAlertView *)errorAlert
{
    if (!_errorAlert) {
        _errorAlert = [[UIAlertView alloc] initWithTitle:@"Can't connect to server"
                                                 message:@"Please, check server address or try again later."
                                                delegate:nil
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil];
    }
    return _errorAlert;
}

- (void)connect
{
    if (self.address && self.address.length > 0) {
        [self.spinner startAnimating];
        
        [MobilSignClient sharedClient].delegate = self;
        [[MobilSignClient sharedClient] setupConnectionWithAddress:self.address];
    }
}

#pragma mark - MobilSignClientDelegate

- (void)didRecievedMessage:(NSString *)message
{
    
}

- (void)openCompleted
{
    self.title = @"Pairing";
    [self.spinner stopAnimating];
    
    [self.spinner stopAnimating];
    [self.readerView setHidden:NO];
}

- (void)connectionClosed
{
    [self.spinner stopAnimating];
    
    [UIAlertView show:@"Connection to server closed!"];
    
    if (self.visible) {
        self.visible = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.dismiss = YES;
}

- (void)errorOccurred
{
    [self.spinner stopAnimating];
    
    [self.errorAlert show];
    
    if (self.visible) {
        self.visible = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.dismiss = YES;
}

- (void)didPair
{
    PairedViewController *pairedVC = (PairedViewController *)[UIStoryboard viewControllerWithIdentifier:@"PairedViewController"];
    [MobilSignClient sharedClient].delegate = pairedVC;
    
    [self.navigationController pushViewController:pairedVC animated:YES];
}

- (void)readerView:(ZBarReaderView *)view didReadSymbols:(ZBarSymbolSet *)syms fromImage:(UIImage *)img
{
    for(ZBarSymbol *sym in syms) {
        if ([self checkKey:sym.data]) {
            [self.readerView stop];
            
            NSData *modulus = [[NSData alloc] initWithBase64EncodedString:sym.data options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            [CryptoManager saveCommunicationKey:modulus];
  
            [[MobilSignClient sharedClient] pairWithFingerprint:[modulus SHA1]];

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
