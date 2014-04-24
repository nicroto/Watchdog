////////////////////////////////////////////////////////////////////////////////
//  
//  WDSerialEntryController.h
//  
//  Watchdog
//  
//  Created by Konstantin Pavlikhin on 27/01/10.
//  
////////////////////////////////////////////////////////////////////////////////

@protocol WDSerialEntryControllerProtocol

@property(readwrite, assign) NSTextField* customerName;
@property(readwrite, assign) NSView* view;

@end

@interface WDSerialEntryController : NSViewController<WDSerialEntryControllerProtocol>

@property(readwrite, assign) IBOutlet NSTextField* customerName;

@end
