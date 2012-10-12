//
//  Book.m
//  BookTracker
//
//  Created by Jon Doud on 7/1/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import "Book.h"


@implementation Book

@synthesize reader;
@synthesize title;
@synthesize author;
@synthesize category;
@synthesize genre;
@synthesize date;
@synthesize pages;
@synthesize audiobook;
@synthesize isbn;

-(id)init
{
	return self;
}

@end
