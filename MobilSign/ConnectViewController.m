//
//  ViewController.m
//  MobilSign
//
//  Created by Marek Špalek on 4. 5. 2013.
//  Copyright (c) 2013 Marek Spalek. All rights reserved.
//

#import "ConnectViewController.h"
#import "QRCodeViewController.h"
#import <QuartzCore/QuartzCore.h>


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


#define CORNER_RADIUS 3.0

@interface ConnectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *connectLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressField;

@end

@implementation ConnectViewController

- (void)connect
{
    [self.addressField resignFirstResponder];
    
    if (self.addressField.text && self.addressField.text.length > 0) {
        
        QRCodeViewController *qrCodeVC = (QRCodeViewController *)[UIStoryboard viewControllerWithIdentifier:@"QRCodeViewController"];
        qrCodeVC.address = self.addressField.text;
        
        [self.navigationController pushViewController:qrCodeVC animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *ipAddress = [self getIPAddress:YES];
    ipAddress = [ipAddress substringToIndex:[ipAddress rangeOfString:@"." options:NSBackwardsSearch].location];
    
    if (ipAddress.length > 0) {
        self.addressField.text = [NSString stringWithFormat:@"%@.", ipAddress];
    }
    
    [[MobilSignClient sharedClient] close];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.addressField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self connect];
        
        return YES;
    }
    return NO;
}

- (IBAction)addressButtonPressed:(UIButton *)sender
{
    self.addressField.text = sender.titleLabel.text;
}

- (void)viewDidUnload
{
    [self setAddressField:nil];
    [self setConnectLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        [self connect];
    }
}

#pragma mark - IP address

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
