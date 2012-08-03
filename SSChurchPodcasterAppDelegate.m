//
//  SSChurchPodcasterAppDelegate.m
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SSChurchPodcasterAppDelegate.h"

@implementation SSChurchPodcasterAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[NSApp setApplicationIconImage: [NSImage imageNamed: @"icon.icns"]];
}

-(void)applicationWillTerminate:(NSNotification *)notification{

	[appController saveToSettings];
}
-(void)setAppController:(AppController *)ac{
	appController=ac;
}

@end
