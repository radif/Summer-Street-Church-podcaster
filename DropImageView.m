//
//  DropImageView.m
//  SSChurchPodcaster
//
//  Created by Radif Sharafullin on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DropImageView.h"
#import "NSImageUtils.h"

@implementation DropImageView
@synthesize fileName, acceptableFileTypes, fileType;

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self registerForDraggedTypes:[NSArray arrayWithObjects:
									   NSFilenamesPboardType, nil]];
		self.fileName = nil;
    }
    return self;
}


- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	
		int centerX = rect.size.width / 2;
		
		NSRect textRect = NSMakeRect(0, 0, 0, 30);
		if (fileName != nil) {
			NSString *text=[fileName lastPathComponent];
			textRect = [text boundingRectWithSize:NSMakeSize(rect.size.width - 25, 30) options:NSStringDrawingUsesFontLeading attributes:nil];
			textRect.origin.x = centerX - textRect.size.width / 2;
			textRect.origin.y = 0;
			[text drawInRect:textRect withAttributes:nil];
		}
	
	
	
	
}


- (void)addLinkToFiles:(NSArray *)files {
	self.fileName = [files objectAtIndex:0];
	if (self.fileType==SSChurchFileTypeAudio) {
		[self setImage:[NSImage imageNamed:@"audio.png"]];
		[self setNeedsDisplay:YES];
	}
}

// I'm DND Destination
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
       
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
		NSString *file=[files objectAtIndex:0];
		
		for (NSString *s in self.acceptableFileTypes){
		if([file hasSuffix:s]) return NSDragOperationCopy;
		}
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        if (sourceDragMask & NSDragOperationLink) {
            [self addLinkToFiles:files];
        } else {
            [self addLinkToFiles:files];
        }
    }
    return YES;
}

-(void)dealloc{
	self.fileName=nil;
	self.acceptableFileTypes=nil;
	[super dealloc];
}
@end
