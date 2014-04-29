////////////////////////////////////////////////////////////////////////////////
//  
//  WDRegistrationStatusController.h
//  
//  Watchdog
//  
//  Created by Konstantin Pavlikhin on 27/01/10.
//  
////////////////////////////////////////////////////////////////////////////////

#import "WDRegistrationStatusControllerProtocol.h"

@interface WDRegistrationStatusController : NSViewController<WDRegistrationStatusControllerProtocol>

@property(readwrite, assign) IBOutlet NSButton* dismissButton;

@end
