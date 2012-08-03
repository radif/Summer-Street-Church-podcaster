//
//  FTPHandler.h
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "S7FTPRequest.h"

@class FTPHandler;
@protocol FTPHandlerDelegate
@optional
-(void)ftpHandlerNetworkErrorOccured:(FTPHandler *)f;
-(void)ftpHandlerFinishedUploadingFile:(FTPHandler *)f;

@end


@interface FTPHandler : NSObject {
	NSString *userName;
	NSString *password;
	id<FTPHandlerDelegate, NSObject> delegate;
	S7FTPRequest *ftpRequest;
}
@property (nonatomic, assign) id<FTPHandlerDelegate, NSObject> delegate;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *password;


-(id)initWithUserName:(NSString *)usName password:(NSString *)pwd andDelegate:(id<FTPHandlerDelegate, NSObject>)del;
-(void)uploadFile:(NSString *)filePath;
+(NSArray *)episodes;
@end
