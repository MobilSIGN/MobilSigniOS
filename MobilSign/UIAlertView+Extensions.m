//
//  UIAlertView+Extensions.m
//  MobilSign
//
//  Created by Marek Spalek on 03. 11. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "UIAlertView+Extensions.h"

@implementation UIAlertView (Extensions)

+ (void)show:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"MobilSign"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

@end
