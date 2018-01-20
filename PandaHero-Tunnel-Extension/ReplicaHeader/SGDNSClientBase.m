//
//  SGDNSClientBase.m
//  Snail
//
//  Created by lemon4ex on 16/6/5.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#import "SGDNSClientBase.h"
#import "BaseObject.h"

@implementation SGDNSClientBase


- (void)udpSocketDidClose:(id)arg1 withError:(id)arg2 {
	
}

- (void)udpSocket:(id)arg1 didNotSendDataWithTag:(long)arg2 dueToError:(id)arg3 {
	
}

- (void)udpSocket:(id)arg1 didSendDataWithTag:(long)arg2 {
	
}

- (void)udpSocket:(id)arg1 didNotConnect:(id)arg2 {
	
}

- (void)closeSocketsForContext:(id)arg1 {
	
}

- (void)createUpstreamSocketsForContext:(id)arg1 {
	
}

- (id)init {
    if (self = [super init]) {
        _dispatchQueue = dispatch_queue_create([[self loggerModuleName] NSUTF8StringEncoding], 0);
    }
    
    return self;
}


@end