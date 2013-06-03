//
//  PairedViewController.h
//  MobilSign
//
//  Created by Marek Špalek on 3. 6. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "MobilSignClient.h"
#import <UIKit/UIKit.h>

@interface PairedViewController : UIViewController <MobilSignClientDelegate>

@property (strong, nonatomic) MobilSignClient *client;

@end
