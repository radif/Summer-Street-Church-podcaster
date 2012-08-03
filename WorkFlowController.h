//
//  WorkFlowController.h
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LameHandler.h"
#import "FTPHandler.h"
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
@class WorkFlowController;

@protocol WorkFlowControllerDelegate
-(void)workFlowController:(WorkFlowController *)controller statusUpdatedWithMessage:(NSString *)message;
-(void)workFlowController:(WorkFlowController *)controller workCompletedWithError:(NSString *)errorMessage;
-(void)workFlowControllerWorkCompleted:(WorkFlowController *)controller;

@end

@interface WorkFlowController : NSObject <LameHandlerDelegate, FTPHandlerDelegate>{

	id<WorkFlowControllerDelegate> delegate;
	LameHandler *lh;
	FTPHandler *ftph;
	NSMutableDictionary *userInfo;
	BOOL isWorking;
}
@property (nonatomic, readonly) BOOL isWorking;
@property (nonatomic, retain) NSMutableDictionary *userInfo;
@property (nonatomic, assign) id<WorkFlowControllerDelegate> delegate;
-(id)initWithDelegate:(id)del;
-(void)startWorkFlowWithInformation:(NSMutableDictionary *)uI;
-(void)abortCurrentWorkFlow;	
-(BOOL)evaluateInputData;
-(void)copyTheDocs;
+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories;
-(void)sendMP3File;
+(void)openTheLocalStorage;
+(BOOL)addEpisodeToDataBase:(NSString *)fileName title:(NSString *)title description:(NSString *)desc date:(NSString *)date;
-(void)shutDownIfNecessary;
+(BOOL)pingURL:(NSString *)urlString;
@end

static OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend);
