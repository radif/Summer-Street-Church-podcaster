/*
	 HttpRequest.h
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

#import <Cocoa/Cocoa.h>


@interface HttpRequest : NSObject {
	NSMutableString* parameters;
}
-(void)addParameter:(NSString*)key withValue:(NSString*)value;
-(NSString*)postToUrl:(NSString*)path;
-(NSString*)encodeString:(NSString*)str;

@end
