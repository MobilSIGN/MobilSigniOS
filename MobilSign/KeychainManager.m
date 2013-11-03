//
//  KeychainManager.m
//  MobilSign
//
//  Created by Marek Spalek on 03. 11. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "KeychainManager.h"
#import "KeychainItemWrapper.h"

#define kPasscodeIdentifier @"passcodeIdentifier"
#define kPasscodeExistsKey @"passcodeExists"
#define kPasscodeHashKey (__bridge id)kSecValueData

@implementation KeychainManager

+ (BOOL)checkValidPasscode:(NSString *)passcode
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPasscodeIdentifier accessGroup:nil];
    
    return [[wrapper objectForKey:kPasscodeHashKey] isEqualToString:[passcode SHA1]];
}

+ (void)createPasscode:(NSString *)passcode
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPasscodeIdentifier accessGroup:nil];
    [wrapper setObject:@"sk.uniza.fri.spalekm.MobilSign" forKey:(__bridge id)kSecAttrService];
    [wrapper setObject:[passcode SHA1] forKey:(__bridge id)kSecValueData];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kPasscodeExistsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)passcodeExist
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kPasscodeExistsKey] boolValue];
}

@end
