//
//  NSString+SHA1.m
//  MobilSign
//
//  Created by Marek Spalek on 22. 10. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "NSString+SHA1.h"
#import "NSData+SHA1.h"

@implementation NSString (SHA1)

- (NSString *)SHA1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    return [data SHA1];
}

@end
