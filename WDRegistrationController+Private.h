//
//  WDRegistrationController_Private.h
//  Watchdog
//
//  Created by Konstantin Pavlikhin on 6/5/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import "WDRegistrationController.h"

@interface WDRegistrationController ()

// These method prototypes are here for unit testing purposes.

- (NSDictionary*) decomposeQuickApplyLink: (NSString*) link;

- (NSString*) getUrlWithoutProtocol: (NSString*) url;

- (BOOL) isSerial: (NSString*) serial conformsToCustomerData: (NSArray*) customerData error: (NSError**) error;

- (NSString*) signatureReconstructHandler: (NSArray*)customerData;

- (NSString*) urlDecodeString: (NSString*) str;

- (NSDictionary*) parseJson: (NSString*) str;

@end
