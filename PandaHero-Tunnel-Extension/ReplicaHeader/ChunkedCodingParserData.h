//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSData;

@interface ChunkedCodingParserData : NSObject
{
    NSData *_data;
    unsigned long _consumed;
}

- (void).cxx_destruct;
- (id)data;
- (id)stringValue;
- (const void *)bytes;
- (void)consume:(unsigned long)arg1;
- (unsigned int)length;
- (id)initWithData:(id)arg1;

@end
