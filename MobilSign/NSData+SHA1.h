//
//  NSData+SHA1.h
//  TrashOut
//
//  Created by Marek Spalek on 8/9/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

/*! Category on NSData for creating sha1 hash. */
@interface NSData (SHA1)

/*! Creates sha1 hash for current data. */
- (NSString *)SHA1;

@end
