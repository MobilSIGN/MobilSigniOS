//
//  ChatViewController.h
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "MobilSignClient.h"
#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <UITextFieldDelegate, MobilSignClientDelegate>

@property (strong, nonatomic) NSString *address;

- (void)connect;

@end
