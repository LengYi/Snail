//
//  IPv4Packet.m
//  Snail
//
//  Created by lemon4ex on 16/6/5.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "IPv4Packet.h"

@implementation IPv4Packet


- (id)payloadData {
    return [_rawData subdataWithRange:NSMakeRange(_headerLength, _rawData.length - _headerLength)];
}

- (id)initWithPacketData:(NSData *)arg1 {
    if (self = [super init]) {
        if (arg1.length > 0x14) {
            _rawData = arg1;
//            _destinationIP = [arg1 bytes][9];
            // TODO
            // 初始化协议内容
//            v11 = objc_retain(v4, v8, v9);
//            v12 = v7[3];
//            v7[3] = v11;
//            objc_release(v12);
//            v13 = (void *)objc_retainAutorelease(v11);
//            v14 = objc_msgSend(v13, "bytes");
//            *((_BYTE *)v7 + 16) = v14[9];
//            v7[5] = *((_DWORD *)v14 + 3);
//            v7[6] = *((_DWORD *)v14 + 4);
//            v6 = 60;
//            v5 = 28;
//            v7[7] = 4 * *v14 & 0x3C;
//        LABEL_5:
//            v10 = (struct objc_object *)objc_retain(v7, v5, v6);
        }
        else
        {
            return nil;
        }
    }
    
    return self;
}


@end
