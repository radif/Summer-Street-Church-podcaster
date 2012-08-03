//
//  AppController.m
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "SSChurchPodcasterAppDelegate.h"



//#import <QuartzCore/QuartzCore.h>
@interface AppController (internal)

@end

@implementation AppController

-(void)awakeFromNib{
	[self restoreFromSettings];
	SSChurchPodcasterAppDelegate *appDelegate=[[NSApplication sharedApplication] delegate];
	[appDelegate setAppController:self];
	//audioFileDropView.acceptableFileTypes=[NSArray arrayWithObjects:@".wav",@".mp3",@".ogg",nil];
	audioFileDropView.acceptableFileTypes=[NSArray arrayWithObjects:@".wav",nil];
	audioFileDropView.fileType=SSChurchFileTypeAudio;
	imageFileDropView.acceptableFileTypes=[NSArray arrayWithObjects:@".jpg",@".jpeg",@".png",@".tga",@".gif",@".bmp",nil];
	imageFileDropView.fileType=SSChurchFileTypeImage;
	[window setDelegate:self];
	
	
	wfc=[[WorkFlowController alloc]initWithDelegate:self];
	
	
		
}



-(void)dealloc{
	[wfc release];
	NSLog(@"%s",__FUNCTION__);
	[window release];
	[titleTextField release];
	[podcastInfoTextField release];
	
	//Credentials:
	[ftpLoginTextField release];
	
	
	[ftpPasswordTextField release];

	[iTunesPingtextFiled release];
	
	
	//Buttons
	[deleteFileCheckMark release];
	[shutdownFileCheckMark release];
	
	[startButton release];
	
	//Progress
	[progressIndicator release];
	[statusLabel release];
	
	
	[todaysDate release];
	[super dealloc];
}

#pragma mark Callbacks
-(IBAction)clearTitlePressed:(id)sender{
	[titleTextField setStringValue:@""];
}
-(IBAction)clearDescPressed:(id)sender{
	[podcastInfoTextField setString:@""];
}
-(IBAction)tutorialPressed:(id)sender{
	system("open http://summerstreetchurch.org/podcasting/stats.php?period=all");
}
-(IBAction)statsPressed:(id)sender{
	system("open http://summerstreetchurch.org/podcasting/stats.php?period=all");

}
-(IBAction)onlineStoragePressed:(id)sender{
system("open -a Filezilla");

}
-(IBAction)localStoragePressed:(id)sender{
	[WorkFlowController openTheLocalStorage];
}
-(IBAction)startPressed:(id)sender{
	
	
	
	
	if (![wfc isWorking]) {
		
		
		//[window setShowsToolbarButton:NO];
		
		[progressIndicator startAnimation:nil];
		[progressIndicator setHidden:NO];
		/*
		 progressIndicator.layer.opacity=0.0;
		 [CATransaction begin]; 
		 [CATransaction setValue:[NSNumber numberWithFloat:0.6f] forKey:kCATransactionAnimationDuration];
		 progressIndicator.layer.opacity=1.0;
		 [CATransaction commit];
		 */
		
		NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
		if (audioFileDropView.fileName) {
			[dict setObject:audioFileDropView.fileName forKey:@"wave_file_name"];	
		}
		if (imageFileDropView.fileName) {
			[dict setObject:imageFileDropView.fileName forKey:@"image_file_name"];
		}
		[dict setObject:[NSString stringWithFormat:@"%i", [deleteFileCheckMark state]] forKey:@"delete_chekmark"];
		[dict setObject:[NSString stringWithFormat:@"%i",[shutdownFileCheckMark state]] forKey:@"shutdown_chekmark"];
		[dict setObject:[ftpLoginTextField stringValue] forKey:@"ftp_login"];
		[dict setObject:[ftpPasswordTextField stringValue] forKey:@"ftp_pwd"];
		[dict setObject:[titleTextField stringValue] forKey:@"title"];
		[dict setObject:[podcastInfoTextField string] forKey:@"description"];
		[dict setObject:[iTunesPingtextFiled stringValue] forKey:@"itunes_ping"];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%a, %e %b %Y %H:%M:%S EDT" allowNaturalLanguage:NO];
		NSString *date=[NSString stringWithString:[formatter stringFromDate:[NSDate date]]];
		[formatter release];
		
		[dict setObject:date forKey:@"pubDate"];
		
		[self saveToSettings];
		
		
		[startButton setTitle:@"Abort"];
		[wfc startWorkFlowWithInformation:dict];
		
	}else {
		
		[wfc abortCurrentWorkFlow];
		
	}
	
	
	
	
	
	
}
#pragma mark Settings

-(void)restoreFromSettings{
	
	NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"MM-dd-YYYY"];
	todaysDate=[[NSString alloc]initWithString:[formatter stringFromDate:[NSDate date]]];
	[formatter release];
	
	[titleTextField setStringValue:todaysDate];
	
	
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	
	
	
	
	
	
	if ([prefs objectForKey:@"imageFileDropView"]) {
		imageFileDropView.fileName=[prefs objectForKey:@"imageFileDropView"];
		[imageFileDropView setImage:[[[NSImage alloc] initWithContentsOfFile:imageFileDropView.fileName] autorelease]];
	}
	
	if ([prefs objectForKey:@"podcastDescription"]) {
		[podcastInfoTextField setString:[prefs objectForKey:@"podcastDescription"]];
	}
	
	
	//credentials
	if ([prefs objectForKey:@"ftp_login"]) {
		[ftpLoginTextField setStringValue:[prefs objectForKey:@"ftp_login"]];
	}
	
	if ([prefs objectForKey:@"itunes_ping"]) {
		[iTunesPingtextFiled setStringValue:[prefs objectForKey:@"itunes_ping"]];
	}
	
	
	
	
	//passwords
	
	if ([prefs objectForKey:@"ftp_pwd"]) {
		[ftpPasswordTextField setStringValue:[prefs objectForKey:@"ftp_pwd"]];
	}
	
		
	//checkMarks
	if ([prefs objectForKey:@"delete_chekmark"]) {
		[deleteFileCheckMark setState:[prefs integerForKey:@"delete_chekmark"]];
	}
	
	if ([prefs objectForKey:@"shutdown_chekmark"]) {
		[shutdownFileCheckMark setState:[prefs integerForKey:@"shutdown_chekmark"]];
	}
	
	
	
	
}
-(void)saveToSettings{
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];

	[prefs setObject:imageFileDropView.fileName forKey:@"imageFileDropView"];
	
	[prefs setObject:[podcastInfoTextField string] forKey:@"podcastDescription"];
	[prefs setObject:[iTunesPingtextFiled stringValue] forKey:@"itunes_ping"];
	//credentials

	[prefs setObject:[ftpLoginTextField stringValue] forKey:@"ftp_login"];
	
	
	//passwords

	[prefs setObject:[ftpPasswordTextField stringValue] forKey:@"ftp_pwd"];
	
	
	//checkMarks
	[prefs setInteger:[deleteFileCheckMark state] forKey:@"delete_chekmark"];
	[prefs setInteger:[shutdownFileCheckMark state] forKey:@"shutdown_chekmark"];
	
	[prefs synchronize];
}
#pragma mark AlertViewDelegates
- (void) alertDidEnd:(NSAlert *)a returnCode:(NSInteger)rc contextInfo:(void *)ci {
	NSString* context=ci;
	if ([context isEqualToString:@"exit_case"]) {
		switch(rc) {
			case NSAlertFirstButtonReturn:
				// "First" pressed
				break;
			case NSAlertSecondButtonReturn:
				// "Second" pressed
				[self saveToSettings];
				exit(0);
				break;
				// ...
		}
	}
   
}
#pragma mark WorkFlowControllerDelegates
-(void)workFlowController:(WorkFlowController *)controller statusUpdatedWithMessage:(NSString *)message{

	[statusLabel setStringValue:message];
	
}
-(void)workFlowController:(WorkFlowController *)controller workCompletedWithError:(NSString *)errorMessage{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:errorMessage];
	[alert beginSheetModalForWindow:window
					  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
	
	[statusLabel setStringValue:errorMessage];
	[startButton setTitle:@"Start"];
	[progressIndicator stopAnimation:nil];
	[progressIndicator setHidden:YES];
	
	
}
-(void)workFlowControllerWorkCompleted:(WorkFlowController *)controller{
	[startButton setTitle:@"Start"];
	[progressIndicator stopAnimation:nil];
	[progressIndicator setHidden:YES];
}


#pragma mark NSWindowDelegates
- (BOOL)windowShouldClose:(id)sender{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	if ([wfc isWorking]) {
		[alert setMessageText:@"Are you sure you want to quit the podcaster and cancel the job?"];
		[alert addButtonWithTitle:@"Keep Working"];
		
	}else {
		[alert setMessageText:@"Are you sure you want to quit the podcaster?"];
		[alert addButtonWithTitle:@"Don't Quit"];
	}
	[alert addButtonWithTitle:@"Quit"];
	[alert beginSheetModalForWindow:window
					  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:@"exit_case"];
	
	return NO;
	
}

@end
