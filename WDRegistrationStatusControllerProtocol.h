//
//  WDRegistrationStatusControllerProtocol.h
//  Watchdog
//
//  Created by Nikolay Tsenkov on 4/29/14.
//  Copyright (c) 2014 Konstantin Pavlikhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDRegistrationStatusControllerProtocol <NSObject>

@property(readwrite, assign) NSButton* dismissButton;
@property(readwrite, assign) NSView* view;

@end
