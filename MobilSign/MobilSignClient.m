//
//  MobilSignClient.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "MobilSignClient.h"

#define SERVER_PORT 2002

#define kRequestSend     @"SEND:"
#define kRequestPair     @"PAIR:"
#define kRequestEncrypt  @"ENCR:"
#define kRequestDecrypt  @"DECR:"

#define kResponse        @"RESP:"

@interface MobilSignClient()

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation MobilSignClient

+ (MobilSignClient *)sharedClient
{
    static dispatch_once_t once;
    static id sharedManager;
    dispatch_once(&once, ^{
        sharedManager = [[MobilSignClient alloc] init];
    });
    return sharedManager;
}

- (void)setupConnectionWithAddress:(NSString *)address
{
    if (address) {
        
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)address, SERVER_PORT, &readStream, &writeStream);
        
        NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
        NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        self.inputStream = inputStream;
        self.outputStream = outputStream;
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
        // SSL
//        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                  [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
//                                  [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredRoots,
//                                  [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
//                                  [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
//                                  [NSNull null], kCFStreamSSLPeerName,
//                                  kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
//                                  nil ];
//        
//        CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
//        CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
        
    } else {
        NSLog(@"Address was not set!");
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"Handle event: %d for stream: %@", eventCode, stream);
    switch (eventCode) {
            
		case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened.");
            if (stream == self.inputStream) {
                NSLog(@"Input stream opened");
            } else if (stream == self.outputStream) {
                NSLog(@"Output stream opened");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Open completed.");
                    [self.delegate openCompleted];
                });
            }
			break;
            
		case NSStreamEventHasBytesAvailable:
            NSLog(@"Bytes available.");
            if (stream == self.inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                        
                        if (output && output.length > 0) {
                            //NSLog(@"Server said: %@", output);
                            [self dispatchMessage:output];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate didRecievedMessage:output];
                            });
                            
                        }
                    }
                }
            }
			break;
            
		case NSStreamEventErrorOccurred:
        {
			NSLog(@"Error: Can not connect to the host!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate errorOccurred];
            });
        }
			break;
            
		case NSStreamEventEndEncountered:
        {
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            NSLog(@"Stream closed");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate connectionClosed];
            });
        }
			break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Has space available");
            break;
		default:
			NSLog(@"Unknown event");
	}
}

- (void)sendMessage:(NSString *)message
{
    [self sendRequest:[NSString stringWithFormat:@"%@%@", kRequestSend, message]];
}

- (void)sendRequest:(NSString *)request
{
    request = [NSString stringWithFormat:@"%@\n", request];
    
    if (self.outputStream && [self.outputStream hasSpaceAvailable]) {
        NSLog(@"Send request: %@", request);
        NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSUTF8StringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
    } else {
        if (!self.outputStream) {
            NSLog(@"Output stream not existing!");
        } else if (![self.outputStream hasSpaceAvailable]) {
            NSLog(@"Output stream hasn't space available!");
        }
    }
}

- (void)pairWithFingerprint:(NSString *)fingerprint
{
    NSLog(@"Pairing with key fingerprint: %@", fingerprint);
    [self sendRequest:[NSString stringWithFormat:@"%@%@", kRequestPair, fingerprint]];
}

- (void)dispatchMessage:(NSString *)message
{
    if (message.length > 5) {
        if ([[message substringToIndex:5] isEqualToString:kResponse]) {
            NSString *response = [message substringFromIndex:5];
            NSLog(@"Response: %@", response);
            
            if ([[response substringToIndex:6] isEqualToString:@"paired"]) {
                [self.delegate didPair];
            }
            
            return;
        }
        if ([[message substringToIndex:5] isEqualToString:kRequestSend]) {
            NSLog(@"Recieved message: %@", [message substringFromIndex:5]);
            return;
        }
        if ([[message substringToIndex:5] isEqualToString:kRequestEncrypt]) {
            NSString *toEncrypt = [message substringFromIndex:5];
            NSLog(@"Encrypt message: %@", toEncrypt);
            [Crypto encryptWithCommunicationKey:toEncrypt];
            return;
        }
        if ([[message substringToIndex:5] isEqualToString:kRequestDecrypt]) {
            NSString *toDecrypt = [message substringFromIndex:5];
            NSLog(@"Encrypt message: %@", toDecrypt);
            NSString *decrypted = [Crypto decryptWithCommunicationKey:[NSData dataFromBase64String:message]];
            NSLog(@"Decrypted: %@", decrypted);
            [self.delegate didRecievedMessage:decrypted];
            return;
        }
    }
    NSLog(@"Unknown message: [%@]", message);
}

- (void)close
{
    [self.inputStream close];
    [self.outputStream close];
}

@end
