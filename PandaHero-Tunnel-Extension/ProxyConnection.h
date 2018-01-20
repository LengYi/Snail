//
//  ProxyConnection.h
//  PandaHero
//
//  Created by lemon4ex on 2017/10/18.
//  Copyright © 2017年 lemon4ex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPMessage.h"

@class GCDAsyncSocket;

@protocol ProxyConnectionDelegate;

@interface ProxyConnection : NSObject
@property (nonatomic, weak) id<ProxyConnectionDelegate> delegate;

- (instancetype)initWithLocalSocket:(GCDAsyncSocket *)localSocket;
- (void)readHTTPMessage;
- (void)writeHTTPMessage:(HTTPMessage *)message;
@end


@protocol ProxyConnectionDelegate <NSObject>
- (void)didReadHTTPMessage:(ProxyConnection *)connection message:(HTTPMessage *)message;
- (void)connectionDidDisconnect:(ProxyConnection *)connection withError:(NSError *)err;
@end
