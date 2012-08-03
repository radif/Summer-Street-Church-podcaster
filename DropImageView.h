//
//  DropImageView.h
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef enum{
	SSChurchFileTypeImage=0,
	SSChurchFileTypeAudio=1
}SSChurchFileType;

@interface DropImageView : NSImageView {
	NSString *fileName;
	NSArray *acceptableFileTypes;
	SSChurchFileType fileType;
}
@property (nonatomic, assign) SSChurchFileType fileType;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSArray *acceptableFileTypes;

@end
