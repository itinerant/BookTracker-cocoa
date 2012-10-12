//
//  Book.h
//  BookTracker
//
//  Created by Jon Doud on 7/1/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Book : NSObject {
	NSString *reader;
	NSString *title;
	NSString *author;
	NSString *genre;
	NSString *category;
	NSString *date;
	NSString *pages;
	NSString *audiobook;
  NSString *isbn;
}

@property (retain) NSString *reader;
@property (retain) NSString *title;
@property (retain) NSString *author;
@property (retain) NSString *genre;
@property (retain) NSString *category;
@property (retain) NSString *date;
@property (retain) NSString *pages;
@property (retain) NSString *audiobook;
@property (retain) NSString *isbn;

@end
