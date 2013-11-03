//
//  ChatViewController.h
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderView.h"

@interface QRCodeViewController : UITableViewController <MobilSignClientDelegate, ZBarReaderViewDelegate>

@property (strong, nonatomic) NSString *address;

- (void)connect;

@end
