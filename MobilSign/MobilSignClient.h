//
//  MobilSignClient.h
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MobilSignClientDelegate

- (void)didRecievedMessage:(NSString *)message;
- (void)openCompleted;
- (void)connectionClosed;
- (void)errorOccurred;

@end

@interface MobilSignClient : NSObject <NSStreamDelegate>

@property (nonatomic, retain) id <MobilSignClientDelegate> delegate;

- (id)initWithAddress:(NSString *)address;
- (void)setupConnection;
- (void)sendMessage:(NSString *)message;

@end
