/*
	HttpRequest.m
	Created by Luc CALARESU on 16/06/09.
 
	This file is part of CocoaPost.

	CocoaPost is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	CocoaPost is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with CocoaPost.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "HttpRequest.h"

@implementation HttpRequest
- (id) init {
	self = [super init];
	if (self != nil) {
	}
	return self;
}


/*
 * Add a parameter 
 * @key: the name of the parameter
 * @value: the value of the parameter
 */
-(void)addParameter:(NSString*)key withValue:(NSString*)value {
	if (parameters != nil) {
		[parameters appendString:@"&"];
	}
	else {
		parameters = [[NSMutableString alloc] init];
	}
	[parameters appendString:[NSString stringWithFormat:@"%@=%@",
							  [self encodeString:key],
							  [self encodeString:value]]];
}


/*
 * Post the datas
 * @path: the URL to send the datas
 * @return: the content of the web page
 */
-(NSString*)postToUrl:(NSString*)path {
	NSString*           res = nil;
	NSHTTPURLResponse*  response;
	NSError*            error;
	
	NSData* postData = [parameters dataUsingEncoding:NSASCIIStringEncoding
								allowLossyConversion:YES];
	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:path]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request 
											   returningResponse:&response 
														   error:&error];
	res =  [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

	return res;
}

- (void) dealloc {
	[parameters release];
	[super dealloc];
}


/*
 * Encode the variable
 * @str: the variable to encode
 */
-(NSString*)encodeString:(NSString*)str {
	CFStringRef originalString = (CFStringRef)str;
	CFStringRef modifiedString = CFURLCreateStringByAddingPercentEscapes(
											kCFAllocatorDefault,
											originalString,
											NULL,
											CFSTR("?=&+"),
											kCFStringEncodingUTF8);
	NSString* encodedString = [(NSString*)modifiedString autorelease];
	
	//NSLog(@"'%@' encoded as '%@'", str, encodedString);
	return encodedString;
}

@end
