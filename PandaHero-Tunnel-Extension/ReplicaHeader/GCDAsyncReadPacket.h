//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import <Foundation/Foundation.h>

@class NSData, NSMutableData;

@interface GCDAsyncReadPacket : NSObject
{
    NSMutableData *buffer;
    unsigned int startOffset;
    unsigned int bytesDone;
    unsigned int maxLength;
    double timeout;
    unsigned int readLength;
    NSData *term;
    BOOL bufferOwner;
    unsigned int originalBufferLength;
    long tag;
}

- (int)searchForTermAfterPreBuffering:(long)arg1;
- (unsigned int)readLengthForTermWithPreBuffer:(id)arg1 found:(char *)arg2;
- (unsigned int)readLengthForTermWithHint:(unsigned int)arg1 shouldPreBuffer:(char *)arg2;
- (unsigned int)readLengthForNonTermWithHint:(unsigned int)arg1;
- (unsigned int)optimalReadLengthWithDefault:(unsigned int)arg1 shouldPreBuffer:(char *)arg2;
- (void)ensureCapacityForAdditionalDataOfLength:(unsigned int)arg1;
- (id)initWithData:(id)arg1 startOffset:(unsigned int)arg2 maxLength:(unsigned int)arg3 timeout:(double)arg4 readLength:(unsigned int)arg5 terminator:(id)arg6 tag:(long)arg7;

@end

