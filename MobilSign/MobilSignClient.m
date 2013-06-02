//
//  MobilSignClient.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "MobilSignClient.h"

#define SERVER_PORT 2002

@interface MobilSignClient()

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSString *address;

@end

@implementation MobilSignClient

- (id)initWithAddress:(NSString *)address
{
    self = [super init];
    if (self) {
        self.address = address;
    }
    return self;
}

- (void)setupConnection
{
    if (self.address) {
        
        NSLog(@"setup");
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CFReadStreamRef readStream;
            CFWriteStreamRef writeStream;
            CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.address, SERVER_PORT, &readStream, &writeStream);
            
            NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
            NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
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
        
//        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//         [NSNumber numberWithBool:YES], @"kCFStreamSSLAllowsExpiredCertificates",
//         [NSNumber numberWithBool:YES], @"kCFStreamSSLAllowsExpiredRoots",
//         [NSNumber numberWithBool:YES], @"kCFStreamSSLAllowsAnyRoot",
//         [NSNumber numberWithBool:NO], @"kCFStreamSSLValidatesCertificateChain",
//         [NSNull null], @"kCFStreamSSLPeerName",
//         @"kCFStreamSocketSecurityLevelNegotiatedSSL", @"kCFStreamSSLLevel",
//         nil ];
//
//        CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
//        CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
        
            dispatch_async(dispatch_get_main_queue(), ^{
                self.inputStream = inputStream;
                self.outputStream = outputStream;
            });
        //});
    } else {
        NSLog(@"Address was not set!");
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
            
		case NSStreamEventOpenCompleted:
            if (stream == self.inputStream) {
                NSLog(@"Input stream opened");
            } else if (stream == self.outputStream) {
                NSLog(@"Output stream opened");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate openCompleted];
                });
            }
			break;
            
		case NSStreamEventHasBytesAvailable:
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
			NSLog(@"Can not connect to the host!");
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
            //NSLog(@"Has space available");
            break;
		default:
			NSLog(@"Unknown event");
	}
}

- (void)sendMessage:(NSString *)message
{
    message = [NSString stringWithFormat:@"%@\n", message];
    
    if (self.outputStream && [self.outputStream hasSpaceAvailable]) {
        NSLog(@"Send message: %@", message);
        NSData *data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
    }
}

- (void)pairWithFingerprint:(NSString *)fingerprint
{
    [self sendMessage:[NSString stringWithFormat:@"PAIR:%@\n", fingerprint]];
}

- (void)dispatchMessage:(NSString *)message
{
    if (message.length > 5) {
        if ([[message substringToIndex:5] isEqualToString:@"RESP:"]) {
            NSLog(@"Response: %@", [message substringFromIndex:5]);
            return;
        }
        if ([[message substringToIndex:5] isEqualToString:@"SEND:"]) {
            NSLog(@"Recieved message: %@", [message substringFromIndex:5]);
            return;
        }
    }
    NSLog(@"Unknown message: [%@]", message);
}

@end
