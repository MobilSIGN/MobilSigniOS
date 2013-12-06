//
//  Crypto.h
//  RSATest
//
//  Created by Marek Spalek on 10/20/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface Crypto : NSObject

+ (BOOL)keyPairExists;
+ (void)generateKeyPair;
+ (void)deleteKeyPair;

+ (NSData *)encryptWithPublicKey:(NSString *)text;
+ (NSString *)decryptWithPrivateKey:(NSData *)data;

+ (void)saveCommunicationKey:(NSData *)modulus;
+ (void)deleteCommunicationKey;

+ (NSData *)encryptWithCommunicationKey:(NSData *)data;
+ (NSData *)decryptWithCommunicationKey:(NSData *)data;

@end
