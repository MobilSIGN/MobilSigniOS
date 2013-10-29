//
//  NSString+SHA1.h
//  MobilSign
//
//  Created by Marek Spalek on 22. 10. 13.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SHA1)

/*! Creates sha1 hash for current string. */
- (NSString *)SHA1;

@end
