//
//  FTPHandler.m
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FTPHandler.h"


@implementation FTPHandler
@synthesize userName, password,  delegate;

-(id)initWithUserName:(NSString *)usName password:(NSString *)pwd andDelegate:(id<FTPHandlerDelegate, NSObject>)del{

	self=[super init];
	self.delegate=del;
	self.userName=usName;
	self.password=pwd;
	
	return self;
	
}

+(NSArray *)episodes{
	NSError *err=nil;
	NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://summerstreetchurch.org/podcasting/episodes.php"]];
	NSXMLDocument *xmlDoc=[[NSXMLDocument alloc] initWithData:data options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
	NSMutableArray *episodes=[NSMutableArray array];
	NSArray *arry=[[[xmlDoc children] objectAtIndex:0]children];
	for (NSXMLNode *node in arry) {
		[episodes addObject:[[node children]objectAtIndex:0]];
	}
	return episodes;
}
-(void)uploadFile:(NSString *)filePath{
	if (ftpRequest) {
		[ftpRequest release];
		ftpRequest=nil;
	}
	ftpRequest = [[S7FTPRequest alloc] initWithURL:
								[NSURL URLWithString:@"ftp://ftp.summerstreetchurch.org/podcasting/episodes/"]
													toUploadFile:filePath];
	
	ftpRequest.username = self.userName;
	ftpRequest.password = self.password;

	ftpRequest.delegate = self;
	ftpRequest.didFinishSelector = @selector(uploadFinished:);
	ftpRequest.didFailSelector = @selector(uploadFailed:);
	ftpRequest.willStartSelector = @selector(uploadWillStart:);
	ftpRequest.didChangeStatusSelector = @selector(requestStatusChanged:);
	ftpRequest.bytesWrittenSelector = @selector(uploadBytesWritten:);
	
	[ftpRequest startRequest];
}

- (void)uploadFinished:(S7FTPRequest *)request {
	NSLog(@"finish");
	if (delegate) {
		if ([delegate respondsToSelector:@selector(ftpHandlerFinishedUploadingFile:)]) {
			[delegate ftpHandlerFinishedUploadingFile:self];
		}
	}
}

- (void)uploadFailed:(S7FTPRequest *)request {
	NSLog(@"failed");
	if (delegate) {
		if ([delegate respondsToSelector:@selector(ftpHandlerNetworkErrorOccured:)]) {
			[delegate ftpHandlerNetworkErrorOccured:self];
		}
	}
}

- (void)uploadWillStart:(S7FTPRequest *)request {
	
	NSLog(@"Will transfer %d bytes.", request.fileSize);
}

- (void)uploadBytesWritten:(S7FTPRequest *)request {
	
	NSLog(@"Transferred: %d", request.bytesWritten);
}

- (void)requestStatusChanged:(S7FTPRequest *)request {
	
	switch (request.status) {
		case S7FTPRequestStatusOpenNetworkConnection:
			NSLog(@"Opened connection.");
			break;
		case S7FTPRequestStatusReadingFromStream:
			NSLog(@"Reading from stream...");
			break;
		case S7FTPRequestStatusWritingToStream:
			NSLog(@"Writing to stream...");
			break;
		case S7FTPRequestStatusClosedNetworkConnection:
			NSLog(@"Closed connection.");
			break;
		case S7FTPRequestStatusError:
			NSLog(@"Error occurred.");
			break;
	}
}
-(void)dealloc{
	self.userName=nil;
	self.password=nil;
	if (ftpRequest) {
		ftpRequest.delegate=nil;
		[ftpRequest cancel];
		[ftpRequest release];
		ftpRequest=nil;
	}
	[super dealloc];
}
@end
