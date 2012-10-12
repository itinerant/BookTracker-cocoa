//
//  BookTrackerAppDelegate.m
//  BookTracker
//
//  Created by Jon Doud on 7/1/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import "BookTrackerAppDelegate.h"
#import "Book.h"

@implementation BookTrackerAppDelegate

@synthesize window;
- (id)init 
{
	[super init];
	
	// initialize arrays
	months = [[NSArray alloc] initWithObjects: @"", @"Jan", @"Feb", @"Mar", @"Apr",
			  @"May", @"Jun", @"Jul", @"Aug", @"Sep",
			  @"Oct", @"Nov", @"Dec", nil];
	years = [[NSArray alloc] initWithObjects: @"", @"2012", @"2011", @"2010", @"2009", @"2008", @"2007", @"2006", 
			 @"2005", @"2004", @"2003", nil];
	NSCalendarDate *thisMonth = [NSCalendarDate calendarDate];
	currentMonths = [[NSArray alloc] initWithObjects: 
					 [[NSString alloc] initWithFormat:@"%@ %ld", [months objectAtIndex:[thisMonth monthOfYear]-1], [thisMonth yearOfCommonEra]],
					 [[NSString alloc] initWithFormat:@"%@ %ld", [months objectAtIndex:[thisMonth monthOfYear]], [thisMonth yearOfCommonEra]],
					 nil];
	
	// open database
	db = [[MCPConnection alloc] initToHost:@"localhost" withLogin:@"user" usingPort:3306];
	[db setPassword:@"password"];
	[db connect];
	[db selectDB:@"tracker"];
	
	return self;
}

- (void)dealloc
{
	[db disconnect];
	[months release];
	[years release];
	[currentMonths release];
	[super dealloc];	
}

- (IBAction)filter:(id)sender 
{
	// empty table
	[books removeObjects:[books arrangedObjects]];
	
	// Set default search
	bool filtered = false;
	NSMutableString *query = [[NSMutableString alloc] initWithString:
							  @"select reader, title, author, genre, category, date, pages, audiobook, isbn from books where "];
	
	// reader
	if([readerFilter indexOfSelectedItem] != 0)
	{
		[query appendFormat:@"and reader = '%@' ", [readerFilter titleOfSelectedItem]];
		filtered = true;
	}
	// title
	if(![[titleFilter stringValue] isEqualToString:@""])
	{
		[query appendFormat:@"and title like ucase('%%%@%%') ", [titleFilter stringValue]];
		filtered = true;
	}
	// author
	if(![[authorFilter stringValue] isEqualToString:@""])
	{
		[query appendFormat:@"and author like ucase('%%%@%%') ", [authorFilter stringValue]];
		filtered = true;
	}
	// genre
	if([genreFilter indexOfSelectedItem] != 0)
	{
		[query appendFormat:@"and genre = '%@' ", [genreFilter titleOfSelectedItem]];
		filtered = true;
	}
	// category
	if([categoryFilter indexOfSelectedItem] != 0)
	{
		[query appendFormat:@"and category = '%@' ", [categoryFilter titleOfSelectedItem]];
		filtered = true;
	}
	// month
	if([monthFilter indexOfSelectedItem] != 0)
	{
		[query appendFormat:@"and date like '%%%@%%' ", [monthFilter titleOfSelectedItem]];
		filtered = true;
	}
	// year
	if([yearFilter indexOfSelectedItem] != 0)
	{
		[query appendFormat:@"and date like '%%%@%%' ", [yearFilter titleOfSelectedItem]];
		filtered = true;
	}
	// audiobook
	if([[[audiobookFilter selectedCell] title] isEqualToString:@"Yes"])
	{
		[query appendFormat:@"and audiobook = '1'"];
		filtered = true;
	}
	else if([[[audiobookFilter selectedCell] title] isEqualToString:@"No"])
	{
		[query appendFormat:@"and audiobook = '0'"];
		filtered = true;	
	}
	
	// if not filtered, remove where clause
	if(!filtered)
		[query replaceOccurrencesOfString:@" where" withString:@"" options:NSCaseInsensitiveSearch range:(NSRange){0,[query length]}];
	// otherwise fix where and	
	else
		[query replaceOccurrencesOfString:@"where and" withString:@"where" options:NSCaseInsensitiveSearch range:(NSRange){0,[query length]}];
			
	// get filtered list of books
	NSArray *row;
	result = [db queryString:query];
	while ((row = [result fetchRowAsArray]))
	{
		Book *b = [[Book alloc] init];
		[b setReader:[row objectAtIndex:0]];
		[b setTitle:[row objectAtIndex:1]];
		[b setAuthor:[row objectAtIndex:2]];
		[b setGenre:[row objectAtIndex:3]];
		[b setCategory:[row objectAtIndex:4]];
		[b setDate:[row objectAtIndex:5]];
		[b setPages:[row objectAtIndex:6]];
		if([[row objectAtIndex:7] intValue] == 1)
			[b setAudiobook:@"Yes"];
		else
			[b setAudiobook:@"No"];
    [b setIsbn:[row objectAtIndex:8]];
		[books addObject:b];
		[b release];
	}
	[query release];
	
	// update data display
	[self setStatusFields];
}

- (IBAction)addBook:(id)sender
{
	// required fields
	if([readerAdd indexOfSelectedItem] == 0 || [[titleAdd stringValue] isEqualToString:@""] ||
	   [[authorAdd stringValue] isEqualToString:@""] || [[genreAdd stringValue] isEqualToString:@""] ||
	   ([[pagesAdd stringValue] isEqualToString:@""] && [audiobookAdd state] == 0))
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Missing required fields!\n\nThe following fields are required:\nReader\nTitle\nAuthor\nGenre\n\nand one of\nPages or Audiobook"];
		[alert runModal];
		return;
	}
	
	// build insert string
	NSString *reader = [readerAdd titleOfSelectedItem];
	NSMutableString *title = [NSMutableString stringWithString:[titleAdd stringValue]];
	[title replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:(NSRange){0,[title length]}];
	NSMutableString *author = [NSMutableString stringWithString:[authorAdd stringValue]];
	[author replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:(NSRange){0,[author length]}];
	NSMutableString *genre = [NSMutableString stringWithString:[genreAdd stringValue]];
	[genre replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:(NSRange){0,[genre length]}];
	NSMutableString *category = [NSMutableString stringWithString:[categoryAdd stringValue]];
	[category replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:(NSRange){0,[category length]}];
	NSString *date = [dateAdd titleOfSelectedItem];
	int pages = [pagesAdd intValue];
	int audiobook = [audiobookAdd state];
  NSMutableString *isbn = [NSMutableString stringWithString:[isbnAdd stringValue]]; 
  [isbn replaceOccurrencesOfString:@"'" withString:@"''" options:NSCaseInsensitiveSearch range:(NSRange){0,[isbn length]}];
	
	NSMutableString *query = [[NSMutableString alloc] initWithFormat:
							  @"insert into books (reader, title, author, genre, category, date, pages, audiobook, isbn) values ('%@', '%@', '%@', '%@', '%@', '%@', %d, %d, '%@')",
							  reader, title, author, genre, category, date, pages, audiobook, isbn];
	NSLog(@"%@", query);
	[db queryString:query];
	[query release];
	
	// reset fields
	[self setControlData];
	
	// clear fields
	[titleAdd setStringValue:@""];
	[authorAdd setStringValue:@""];
	[genreAdd setStringValue:@""];
	[categoryAdd setStringValue:@""];
	[pagesAdd setStringValue:@""];
	[audiobookAdd setState:0];
    [isbnAdd setStringValue:@""];
	
}

- (IBAction)setCurrentSelection:(id)sender
{
	int row = [table selectedRow];
	[readerAdd setObjectValue:@""];
	[titleAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:1 row:row] stringValue]]];
	[authorAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:2 row:row] stringValue]]];
	[genreAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:3 row:row] stringValue]]];
	[categoryAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:4 row:row] stringValue]]];
	[pagesAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:6 row:row] stringValue]]];
	if([[[table preparedCellAtColumn:7 row:row] stringValue] compare:@"Yes"] == NSOrderedSame)
		[audiobookAdd setState:1];
	else 
		[audiobookAdd setState:0];
  [isbnAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:8 row:row] stringValue]]];
}

- (IBAction)clearFilters:(id)sender
{
	[readerFilter setObjectValue:@""];
	[titleFilter setObjectValue:@""];
	[authorFilter setObjectValue:@""];
	[genreFilter setObjectValue:@""];
	[categoryFilter setObjectValue:@""];
	[monthFilter setObjectValue:@""];
	[yearFilter setObjectValue:@""];
	[audiobookFilter selectCellAtRow:0 column:2];
	
	[self filter:nil];
	
}

- (void)setControlData
{
	// Start progress animation
	[progress startAnimation:nil];
	
	// clear data before resetting it
	[authors removeObjects:[authors arrangedObjects]];
	[genres removeObjects:[genres arrangedObjects]];
	[categories removeObjects:[categories arrangedObjects]];
	[books removeObjects:[books arrangedObjects]];
	
	NSArray *row;
	// get Authors
	[authors addObject:@""];
	result = [db queryString:@"select distinct author from books order by upper(author)"];
	while ((row = [result fetchRowAsArray]))
		[authors addObject:[row objectAtIndex:0]];
		
	// get Genres
	[genres addObject:@""];
	result = [db queryString:@"select distinct genre from books order by upper(genre)"];
	while ((row = [result fetchRowAsArray]))
		[genres addObject:[row objectAtIndex:0]];
	
	// get Categories
	result = [db queryString:@"select distinct category from books order by upper(category)"];
	while ((row = [result fetchRowAsArray]))
		[categories addObject:[row objectAtIndex:0]];
	
	// Load books
	[self filter:nil];
	
	// scroll to end of list
	if([table numberOfRows] > 0)
		[table scrollRowToVisible:[table numberOfRows]-1];
	
	// update status fields
	[self setStatusFields];
	
	// Stop progress animation
	[progress stopAnimation:nil];	
}

- (void)setStatusFields
{
	int count = [table numberOfRows];
	int pages = 0;
	int audiobooks = 0;
	for(int i=0; i<count; i++)
	{
		pages += [[table preparedCellAtColumn:6 row:i] intValue];
		if([[[table preparedCellAtColumn:7 row:i] stringValue] compare:@"Yes"] == NSOrderedSame)
			audiobooks++;
	}
	[audiobookTotal setStringValue:[[NSString alloc] initWithFormat:@"Audiobooks: %d", audiobooks]];
	if(pages > 1000)
		[pageTotal setStringValue:[[NSString alloc] initWithFormat:@"%d,%d", pages / 1000, pages % 1000]];
	else
		[pageTotal setStringValue:[[NSString alloc] initWithFormat:@"%d pages", pages]];
	[bookTotal setStringValue:[[NSString alloc] initWithFormat:@"Showing %d of %d books", count, count]];	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	// set author and genre values
	[genreFilter removeAllItems];
	[categoryFilter removeAllItems];
	
	// set month and year values
	[dateAdd removeAllItems];
	[dateAdd addItemsWithTitles:currentMonths];
	[dateAdd selectItemAtIndex:1];
	[monthFilter removeAllItems];
	[monthFilter addItemsWithTitles:months];
	[yearFilter removeAllItems];
	[yearFilter addItemsWithTitles:years];
	
	[self setControlData];
}

- (void)windowWillClose:(NSNotification *)aNotification 
{
	[NSApp terminate:self];
}

@end
