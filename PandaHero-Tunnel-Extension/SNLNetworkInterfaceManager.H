//
//  KDNetworkInterfaceManager.h
//  Netpas
//
//  Created by Blankwonder on 4/23/15.
//  Copyright (c) 2015 Blankwonder. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SNLNetworkInterfaceManagerInterfaceDidChange;

@interface SNLNetworkInterfaceManager : NSObject

@property (readonly) BOOL WWANValid;
@property (readonly) BOOL WiFiValid;

+ (instancetype)sharedInstance;

- (void)updateInterfaceInfo;

- (void)monitorInterfaceChange;

@property (nonatomic, readonly) BOOL monitoring;

@end
