//
//  AppController.h
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DropImageView.h"
#import "WorkFlowController.h"


@interface AppController : NSObject <WorkFlowControllerDelegate, NSWindowDelegate> {
	IBOutlet NSWindow *window;
	
	
	//Images
	
	IBOutlet DropImageView *audioFileDropView;
	IBOutlet DropImageView *imageFileDropView;
	
	//Info
	IBOutlet NSTextField *titleTextField;
	IBOutlet NSTextView *podcastInfoTextField;
	
	//Credentials:
	IBOutlet NSTextField *ftpLoginTextField;
		
	IBOutlet NSTextField *ftpPasswordTextField;
	IBOutlet NSTextField *iTunesPingtextFiled;	
	
	//Buttons
	IBOutlet NSButton *deleteFileCheckMark;
	IBOutlet NSButton *shutdownFileCheckMark;
	
	
	
	IBOutlet NSButton *startButton;
	
	
	
	//Progress
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *statusLabel;
	
	
	
	NSString *todaysDate;
	
	WorkFlowController *wfc;
	
}

-(IBAction)clearTitlePressed:(id)sender;
-(IBAction)clearDescPressed:(id)sender;

-(IBAction)tutorialPressed:(id)sender;
-(IBAction)startPressed:(id)sender;
-(IBAction)localStoragePressed:(id)sender;
-(IBAction)statsPressed:(id)sender;
-(IBAction)onlineStoragePressed:(id)sender;
-(void)restoreFromSettings;
-(void)saveToSettings;	
@end
