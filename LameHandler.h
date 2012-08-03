/*
 *  lameHandler2.h
 *  lameEncoder
 *
 *  Created by Radif Sharafullin on 8/20/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
@class LameHandler;

@protocol LameHandlerDelegate
@optional
-(void)lameHandlerStarted:(LameHandler *)lh;
//-(void)lameHandler:(LameHandler *)lh workProgressPercentage:(int)percent;
-(void)lameHandlerFinished:(LameHandler *)lh;
-(void)lameHandlerTagWritten:(LameHandler *)lh;
@end

@interface LameHandler : NSObject
{
	id<LameHandlerDelegate, NSObject> delegate;
	NSString *comments;
	NSString *title;
	NSString *newMp3FileName;
	NSString *imageFileName;
	
}
@property (nonatomic, retain) NSString *newMp3FileName;
@property (nonatomic, retain) NSString *imageFileName;
@property (nonatomic, assign) id<LameHandlerDelegate, NSObject> delegate;
@property (nonatomic, retain) NSString *comments;
@property (nonatomic, retain) NSString *title;

-(id)initWithTitle:(NSString *)ttl comments:(NSString *)cmnts image:(NSString *)img delegate:(id<LameHandlerDelegate, NSObject>)del;
-(int)encodeWavFile:(NSString *)wavFileName toMP3FileName:(NSString *)mp3Filename;
-(void)writeTag;
@end

