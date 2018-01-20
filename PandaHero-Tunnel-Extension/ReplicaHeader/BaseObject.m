//
//  BaseObject.m
//  Snail
//
//  Created by lemon4ex on 16/6/2.
//  Copyright © 2016年 lemon4ex. All rights reserved.
//

#include "BaseObject.h"

@implementation BaseObject


+ (void)load {
//    void *v2; // r0@1
//    void *v3; // r0@1
//    struct Connector *v4; // r1@1
//    struct objc_object *v5; // r3@1
//    unsigned __int16 v6; // [sp+8h] [bp+0h]@0
//    
//    v2 = objc_msgSend(&OBJC_CLASS___NSCountedSet, "alloc");
//    v3 = objc_msgSend(v2, "init");
//    v4 = (struct Connector *)dword_5C3F0;
//    dword_5C3F0 = (int)v3;
//    j__objc_release(v4, v4, (id)&dword_5C3A0, v5, v6);
}

- (id)loggerModuleName {
    return nil;
}

- (unsigned long)instanceId
{
    return 0;
}

- (id)init {
    return self;
}


@end