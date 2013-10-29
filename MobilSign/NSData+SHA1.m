//
//  NSData+SHA1.m
//  TrashOut
//
//  Created by Marek Spalek on 8/9/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import "NSData+SHA1.h"

@implementation NSData (SHA1)

- (NSString *)SHA1
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];

    if (CC_SHA1([self bytes], [self length], digest)) {
        NSMutableString *tmp = [NSMutableString string];
        for (NSUInteger i=0; i < sizeof(digest); i++)
            [tmp appendFormat:@"%02x", digest[i]];
        return [NSString stringWithString:tmp];
    }
    return nil;
}

@end