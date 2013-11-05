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
+ (NSData *)encryptWithPublicKey;
+ (void)decryptWithPrivateKey:(NSData *)dataToDecrypt;

@end
