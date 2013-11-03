//
//  KeychainManager.h
//  MobilSign
//
//  Created by Marek Spalek on 03. 11. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject

+ (BOOL)checkValidPasscode:(NSString *)passcode;

+ (void)createPasscode:(NSString *)passcode;

+ (BOOL)passcodeExist;

@end
