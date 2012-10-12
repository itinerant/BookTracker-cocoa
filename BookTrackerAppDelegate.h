//
//  BookTrackerAppDelegate.h
//  BookTracker
//
//  Created by Jon Doud on 7/1/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MCPKit/MCPKit.h>

@interface BookTrackerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	
	// add controls
	IBOutlet NSPopUpButton *readerAdd;
	IBOutlet NSTextField *titleAdd;
	IBOutlet NSComboBox *authorAdd;
	IBOutlet NSComboBox *genreAdd;
	IBOutlet NSComboBox *categoryAdd;
	IBOutlet NSPopUpButton *dateAdd;
	IBOutlet NSButton *audiobookAdd;
	IBOutlet NSTextField *pagesAdd;
  IBOutlet NSTextField *isbnAdd;
	IBOutlet NSProgressIndicator *progress;
	
	// filter controls
	IBOutlet NSPopUpButton *readerFilter;
	IBOutlet NSSearchField *titleFilter;
	IBOutlet NSSearchField *authorFilter;
	IBOutlet NSPopUpButton *genreFilter;
	IBOutlet NSPopUpButton *categoryFilter;
	IBOutlet NSPopUpButton *monthFilter;
	IBOutlet NSPopUpButton *yearFilter;
	IBOutlet NSMatrix *audiobookFilter;
	
	// totals labels
	IBOutlet NSTextField *audiobookTotal;
	IBOutlet NSTextField *bookTotal;
	IBOutlet NSTextField *pageTotal;
	
	// table
	IBOutlet NSTableView *table;
	
	// elements
	NSArray *months;
	NSArray *years;
	NSArray *currentMonths;
	NSArray *itemNodes;
	
	// sort descriptors
	IBOutlet NSArrayController *authors;
	IBOutlet NSArrayController *genres;
	IBOutlet NSArrayController *categories;
	IBOutlet NSArrayController *books;
	
	// database items
	MCPConnection *db;
	MCPResult *result;
}

@property (assign) IBOutlet NSWindow *window;

- (void)windowWillClose:(NSNotification *)aNotification;
- (IBAction)filter:(id)sender;
- (IBAction)addBook:(id)sender;
- (IBAction)setCurrentSelection:(id)sender;
- (IBAction)clearFilters:(id)sender;
- (void)setControlData;
- (void)setStatusFields;

@end
