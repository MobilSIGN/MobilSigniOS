//
//  NSData+AES256.h
//  RSATest
//
//  Created by Marek Spalek on 11/7/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
