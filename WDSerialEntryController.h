////////////////////////////////////////////////////////////////////////////////
//  
//  WDSerialEntryController.h
//  
//  Watchdog
//  
//  Created by Konstantin Pavlikhin on 27/01/10.
//  
////////////////////////////////////////////////////////////////////////////////
#import "WDSerialEntryControllerProtocol.h"

@interface WDSerialEntryController : NSViewController<WDSerialEntryControllerProtocol>

@property(readwrite, assign) IBOutlet NSTextField* firstResponderTextField;

@end
