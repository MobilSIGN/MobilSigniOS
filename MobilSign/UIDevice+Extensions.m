//
//  UIDevice+Extensions.m
//  MobilSign
//
//  Created by Marek Spalek on 21. 08. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "UIDevice+Extensions.h"

@implementation UIDevice (Extensions)

+ (BOOL)systemVersionAtLeast:(double)version
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= version);
}

@end
