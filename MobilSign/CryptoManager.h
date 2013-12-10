//
//  Crypto.h
//  RSATest
//
//  Created by Marek Spalek on 10/20/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface CryptoManager : NSObject

// Passcode verification
+ (BOOL)checkValidPasscode:(NSString *)passcode;
+ (void)createPasscode:(NSString *)passcode;
+ (BOOL)passcodeExist;

// Mobile key pair
+ (BOOL)keyPairExists;
+ (void)generateKeyPair;
+ (void)deleteKeyPair;

+ (NSData *)encryptWithPublicKey:(NSString *)text;
+ (NSString *)decryptWithPrivateKey:(NSData *)data;

// Communication
+ (void)saveCommunicationKey:(NSData *)modulus;
+ (void)deleteCommunicationKey;

+ (NSData *)encryptWithCommunicationKey:(NSData *)data;
+ (NSData *)decryptWithCommunicationKey:(NSData *)data;

@end
