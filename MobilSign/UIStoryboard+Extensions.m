//
//  UIStoryboard+Extensions.m
//  Bioveta
//
//  Created by Marek Spalek on 27. 10. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "UIStoryboard+Extensions.h"

@implementation UIStoryboard (Extensions)

+ (UIViewController *)viewControllerWithIdentifier:(NSString *)identifier
{
    @try {
        return [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    }
    @catch (NSException *exception) {
            return nil;
    }
}

@end
