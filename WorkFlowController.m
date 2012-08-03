//
//  WorkFlowController.m
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorkFlowController.h"
#import "HttpRequest.h"
OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};
	
    OSStatus error = noErr;
	
    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, 
						 sizeof(kPSNOfSystemProcess), &targetDesc);
	
    if (error != noErr)
    {
        return(error);
    }
	
    error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc, 
							   kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
	
    AEDisposeDesc(&targetDesc);
    if (error != noErr)
    {
        return(error);
    }
	
    error = AESend(&appleEventToSend, &eventReply, kAENoReply, 
				   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
	
    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
    {
        return(error);
    }
	
    AEDisposeDesc(&eventReply);
	
    return(error); 
}
@implementation WorkFlowController
@synthesize delegate, userInfo, isWorking;


-(id)initWithDelegate:(id)del{
	self=[super init];
	self.delegate=del;
	isWorking=NO;
	[self copyTheDocs];
	
	
	
	
	
	return self;
}

-(void)startWorkFlowWithInformation:(NSMutableDictionary *)uI{
	self.userInfo=uI;
//check
	if (![self evaluateInputData]) return;
	isWorking=YES;
	[delegate workFlowController:self statusUpdatedWithMessage:@"Initializing..."];
	
	//encode mp3
	NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"MM-dd-YYYY-hh-mm-ss-a"];
	NSString *fileName=[NSString stringWithFormat:@"%@.mp3",[formatter stringFromDate:[NSDate date]]];
	
	[formatter release];
	
	[self.userInfo setObject:[[WorkFlowController getDocumentPath:@"SSCPodcasting/episodes" createItIfDoesntExist:YES] stringByAppendingPathComponent:fileName] forKey:@"mp3_file_name"];
	
	if (lh) {
		[lh release];
	}
	lh=[[LameHandler alloc] initWithTitle:[self.userInfo objectForKey:@"title"]
								 comments:[self.userInfo objectForKey:@"description"]
									image:[self.userInfo objectForKey:@"image_file_name"]
								 delegate:self];
	
	[lh encodeWavFile:[self.userInfo objectForKey:@"wave_file_name"] toMP3FileName:[self.userInfo objectForKey:@"mp3_file_name"]];
	

//tag mp3
	
//upload mp3
	if (ftph) {
		[ftph release];
	}
	ftph=[[FTPHandler alloc]initWithUserName:[userInfo objectForKey:@"ftp_login"] password:[userInfo objectForKey:@"ftp_pwd"] andDelegate:self];
//get the list of online files
//generate xml
//upload xml
//ping itunes


}
-(void)abortCurrentWorkFlow{
//code
	
	[delegate workFlowController:self workCompletedWithError:@"Aborted by user"];
	isWorking=NO;
}
-(void)workFlowCompleted{

	
	[delegate workFlowControllerWorkCompleted:self];
	isWorking=NO;
	
}


-(void) dealloc{

	self.userInfo=nil;
	[lh release];
	[ftph release];
	[super dealloc];
}
#pragma mark LameHandler delegates
-(void)lameHandlerStarted:(LameHandler *)lh{
	[delegate workFlowController:self statusUpdatedWithMessage:@"Encoding to mp3..."];
}


-(void)lameHandlerFinished:(LameHandler *)l{
	[delegate workFlowController:self statusUpdatedWithMessage:@"Writing mp3 Tag..."];
	
}
-(void)lameHandlerTagWritten:(LameHandler *)lh{
	
	[self sendMP3File];
}

#pragma mark Network
-(void)sendMP3File{
	[delegate workFlowController:self statusUpdatedWithMessage:@"Uploading mp3 file..."];
	[ftph uploadFile:[self.userInfo objectForKey:@"mp3_file_name"]];
	
}

-(void)ftpHandlerNetworkErrorOccured:(FTPHandler *)f{
	[delegate workFlowController:self workCompletedWithError:@"Upload to the web failed..."];
	isWorking=NO;
}
-(void)ftpHandlerFinishedUploadingFile:(FTPHandler *)f{
	[delegate workFlowController:self statusUpdatedWithMessage:@"File Uploaded, updating feed..."];
	
	
	bool result=[WorkFlowController addEpisodeToDataBase:[[userInfo objectForKey:@"mp3_file_name"] lastPathComponent]
									   title:[userInfo objectForKey:@"title"]
								 description:[userInfo objectForKey:@"description"]
										date:[userInfo objectForKey:@"pubDate"]];
	
	if (result) {
		[delegate workFlowController:self statusUpdatedWithMessage:@"Feed updated, will ping itunes server..."];
	}else {
		[delegate workFlowController:self statusUpdatedWithMessage:@"Error updating feed..."];
	}
	
	if([[self class] pingURL:[userInfo objectForKey:@"itunes_ping"]]){
		[delegate workFlowController:self statusUpdatedWithMessage:@"iTunes ping completed..."];
	}else {
		[delegate workFlowController:self statusUpdatedWithMessage:@"Cannot ping iTunes..."];
	}

	
	[self shutDownIfNecessary];
	[self workFlowCompleted];
	if ([[userInfo objectForKey:@"delete_chekmark"] boolValue]){
		[[NSFileManager defaultManager] removeItemAtPath:[self.userInfo objectForKey:@"wave_file_name"] error:nil];
	}

}


#pragma mark Custom
-(void)shutDownIfNecessary{
	OSStatus error = noErr;
	if ([[userInfo objectForKey:@"shutdown_chekmark"]boolValue]) {
		error = SendAppleEventToSystemProcess(kAEShutDown);
		if (error == noErr)
		{[delegate workFlowController:self statusUpdatedWithMessage:@"Computer is shutting down..."];}
		else
		{[delegate workFlowController:self statusUpdatedWithMessage:@"Computer cannot shutdown..."];}
	}else {
		[delegate workFlowController:self statusUpdatedWithMessage:@"All jobs completed, staying on..."];
	}


}
+(BOOL)pingURL:(NSString *)urlString{
	NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
	if ([data length]) {
		return YES;
	}
	return NO;

}
+(BOOL)addEpisodeToDataBase:(NSString *)fileName title:(NSString *)title description:(NSString *)desc date:(NSString *)date{
	HttpRequest* postRequest = [[HttpRequest alloc] init];
	[postRequest addParameter:@"file" 
					withValue:fileName];
	[postRequest addParameter:@"title" 
					withValue:title];
	[postRequest addParameter:@"desc" 
					withValue:desc];
	[postRequest addParameter:@"date" 
					withValue:date];
	
	NSString* res = [postRequest postToUrl:@"http://summerstreetchurch.org/podcasting/addepisode.php"];
	[res release];
	[postRequest release];
	return ([res rangeOfString:@"OK"].location != NSNotFound);
}

-(void)copyTheDocs{
	NSString *toPath=[[self class] getDocumentPath:@"SSCPodcasting" createItIfDoesntExist:YES];
	NSString *fromPath=[[NSBundle mainBundle] pathForResource:@"podcasting" ofType:nil];
	
	NSFileManager *fm=[NSFileManager defaultManager];
	NSArray *files=[fm contentsOfDirectoryAtPath:fromPath error:nil];

	
	for (NSString *file in files) {
		if (![fm fileExistsAtPath:[toPath stringByAppendingPathComponent:file]]) {
			[fm copyItemAtPath:[fromPath stringByAppendingPathComponent:file] toPath:[toPath stringByAppendingPathComponent:file] error:nil];
		}
	}
}


+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories
{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:tmpString])
		[[NSFileManager defaultManager] createDirectoryAtPath:tmpString withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}

-(BOOL)evaluateInputData{
	
	if (![userInfo objectForKey:@"wave_file_name"]) {
		[delegate workFlowController:self workCompletedWithError:@"No input audio file provided!"];
		return NO;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:[userInfo objectForKey:@"wave_file_name"]]) {
		[delegate workFlowController:self workCompletedWithError:@"No input audio file exist at path provided!"];
		return NO;
	}
	
	if (![userInfo objectForKey:@"image_file_name"]) {
		[delegate workFlowController:self workCompletedWithError:@"No input image file provided!"];
		return NO;
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:[userInfo objectForKey:@"image_file_name"]]) {
		[delegate workFlowController:self workCompletedWithError:@"No input mage file exist at path provided!"];
		return NO;
	}
	if (![[userInfo objectForKey:@"ftp_login"] length]) {
		[delegate workFlowController:self workCompletedWithError:@"No FTP username provided!"];
		return NO;
	}
	if (![[userInfo objectForKey:@"ftp_pwd"] length]) {
		[delegate workFlowController:self workCompletedWithError:@"No FTP password provided!"];
		return NO;
	}
	
	if (![[userInfo objectForKey:@"title"] length]) {
		[delegate workFlowController:self workCompletedWithError:@"No Title provided!"];
		return NO;
	}

	if (![[userInfo objectForKey:@"description"] length]) {
		[delegate workFlowController:self workCompletedWithError:@"No Description provided!"];
		return NO;
	}
	
	if (![[userInfo objectForKey:@"itunes_ping"] length]) {
		[delegate workFlowController:self workCompletedWithError:@"No iTunes Ping address provided!"];
		return NO;
	}
	if (![[userInfo objectForKey:@"pubDate"] length]) {
		[delegate workFlowController:self workCompletedWithError:@"No date determined!"];
		return NO;
	}
	
	
	
	return YES;

}
+(void)openTheLocalStorage{
	NSString *prompt=[NSString stringWithFormat:@"open %@", [WorkFlowController getDocumentPath:@"SSCPodcasting/episodes" createItIfDoesntExist:YES]];
	system([prompt cStringUsingEncoding:NSUTF8StringEncoding]);
}
@end
