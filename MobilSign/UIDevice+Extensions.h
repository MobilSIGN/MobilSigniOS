//
//  UIDevice+Extensions.h
//  MobilSign
//
//  Created by Marek Spalek on 21. 08. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Extensions)

+ (BOOL)systemVersionAtLeast:(double)version;

@end
