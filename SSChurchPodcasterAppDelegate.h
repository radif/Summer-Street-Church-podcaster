//
//  SSChurchPodcasterAppDelegate.h
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"


@interface SSChurchPodcasterAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	AppController *appController;
}

@property (assign) IBOutlet NSWindow *window;
-(void)setAppController:(AppController *)ac;
@end
