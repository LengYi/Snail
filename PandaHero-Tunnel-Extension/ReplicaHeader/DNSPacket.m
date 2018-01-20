//
//  DNSPacket.m
//  Snail
//
//  Created by lemon4ex on 16/6/2.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "DNSPacket.h"

@implementation DNSPacket


- (id)initWithPacketData:(NSData *)arg1 {
    if (self = [self init]) {
        if (arg1.length < 12) {
            return nil;
        }
        
        // TODO
    }
    
    return self;
}


@end