/*
 *  lameHandler2.cpp
 *  lameEncoder
 *
 *  Created by Radif Sharafullin on 8/20/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#include <stdio.h>
#include <lame/lame.h>
#include "lameHandler.h"
#import <TagAPI.h>
#import <AppKit/NSBitmapImageRep.h>

@implementation LameHandler
@synthesize delegate, title, comments, imageFileName, newMp3FileName;
-(id)initWithTitle:(NSString *)ttl comments:(NSString *)cmnts image:(NSString *)img delegate:(id<LameHandlerDelegate, NSObject>)del{
	self=[super init];
	self.title=ttl;
	self.imageFileName=img;
	self.comments=cmnts;
	self.delegate=del;
	return self;
}
-(int)encodeWavFile:(NSString *)wavFileName toMP3FileName:(NSString *)mp3Filename{
	self.newMp3FileName=mp3Filename;
	if(![[NSFileManager defaultManager] fileExistsAtPath:wavFileName]) return 1;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:mp3Filename]){
		[[NSFileManager defaultManager] removeItemAtPath:mp3Filename error:nil];
	}
	
	NSDictionary *dict=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:wavFileName,mp3Filename,nil]
												   forKeys:[NSArray arrayWithObjects:@"wavFileName",@"mp3Filename",nil]
						];
	[self performSelectorInBackground:@selector(bg_EncodeWavWork:) withObject:dict];
	return 0;
}
-(void)writeTag{
	TagAPI * tag = [[TagAPI alloc] initWithGenreList:nil];
	[tag examineFile:self.newMp3FileName];
	NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
	[formatter setDateFormat:@"YYYY"];
	int yrearInt=[[formatter stringFromDate:[NSDate date]]intValue];
	[formatter release];
	
	[tag setTitle:self.title];
	[tag setComments:self.comments];
	[tag setArtist:@"Summer Street Church"];
	[tag setYear:yrearInt];
	[tag setEncodedBy:@"(c) Radif Sharafullin SSChurch podcast producer custom software"];
	
	[tag setAlbum:@"Summer Street Church Podcasting"];
	
	NSBitmapImageRep *img= [[NSBitmapImageRep alloc] initWithData:[NSData dataWithContentsOfFile:self.imageFileName]];
	NSDictionary *dic = [NSDictionary
						 dictionaryWithObjectsAndKeys:img, @"Image",
						 @"jpeg", @"Mime Type",
						 @"Other", @"Picture Type",
						 @"", @"Description", nil];
	[tag setImages:[NSMutableArray arrayWithObject:dic]];
	[tag updateFile];
	[img release];
	[tag release];
	if ([delegate respondsToSelector:@selector(lameHandlerTagWritten:)]) {
		[delegate lameHandlerTagWritten:self];	
	}
	
}

-(void)dealloc{

	self.imageFileName=nil;
	self.newMp3FileName=nil;
	self.title=nil;
	self.comments=nil;
	[super dealloc];
}

#pragma mark Background Work
-(void)bg_EncodeWavWork:(NSDictionary *)dict{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	if ([delegate respondsToSelector:@selector(lameHandlerStarted:)]) {
		[delegate lameHandlerStarted:self];	
	}
	
	
	char *wavfilename=(char *)[[dict objectForKey:@"wavFileName"] cStringUsingEncoding:NSUTF8StringEncoding];
	char *mp3filename=(char *)[[dict objectForKey:@"mp3Filename"] cStringUsingEncoding:NSUTF8StringEncoding];
	
	lame_global_struct *gf1;
	short int wavbuf[2304*2];
	unsigned char mp3buf[10000];
	FILE *hr;
	FILE *hw;
	int rres;
	int encr;
	
	encr=0;rres=0;
	hr=fopen(wavfilename,"rb");
	hw=fopen(mp3filename,"wb+");
	fseek(hr,44,0);//skip wave header
	gf1=lame_init();//init
	
	lame_set_VBR(gf1,vbr_default);//set default VBR method
	lame_set_bWriteVbrTag(gf1,1);//enable writing VBR tag
	
	//settings:
	lame_set_VBR_q(gf1, 4);
	
	//lame_set_VBR_min_bitrate_kbps(gf1, 8);
	lame_set_VBR_max_bitrate_kbps(gf1, 40);
	lame_set_mode(gf1, MONO);//mono
	
	
	//suppose that other parameters are set by default:
	//max bitrate=320,min bitrate=32,VBR quality=4;input,output freq=44100.
	lame_init_params(gf1);
	
	//start the encoding loop
	
	
	while ((rres=fread(wavbuf,2,2304,hr))>0)
	{

		/*
		if ([delegate respondsToSelector:@selector(lameHandler:workProgressPercentage:)]) {
			//TODO rethink percentage or remove this method
			[delegate lameHandler:self workProgressPercentage:100];
		}
		 */
		

        encr=lame_encode_buffer_interleaved(gf1,wavbuf,rres/2,mp3buf,10000);
        fwrite(mp3buf,1,encr,hw);       
	}
	encr=lame_encode_flush(gf1,mp3buf,10000);
	fwrite(mp3buf,1,encr,hw);
	fclose(hr);
	fclose(hw);
	
	
	hw=fopen(mp3filename,"rb+");
	lame_mp3_tags_fid(gf1,hw);//write VBR tag
	fclose(hw);
	
	lame_close(gf1);
	if ([delegate respondsToSelector:@selector(lameHandlerFinished:)]) {
		[delegate lameHandlerFinished:self];	
	}
	[self performSelectorOnMainThread:@selector(writeTag) withObject:nil waitUntilDone:YES];
	[pool release];
}
@end


