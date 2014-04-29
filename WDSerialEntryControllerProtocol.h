//
//  WDSerialEntryControllerProtocol.h
//  Watchdog
//
//  Created by Nikolay Tsenkov on 4/25/14.
//  Copyright (c) 2014 Konstantin Pavlikhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDSerialEntryControllerProtocol<NSObject>

@property(readwrite, assign) id firstResponderTextField;
@property(readwrite, assign) NSView* view;

@end
