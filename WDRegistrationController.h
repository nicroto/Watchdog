////////////////////////////////////////////////////////////////////////////////
//  
//  WDRegistrationController.h
//  
//  Watchdog
//  
//  Created by Konstantin Pavlikhin on 27/01/10.
//  
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "WDSerialEntryControllerProtocol.h"
#import "WDRegistrationStatusControllerProtocol.h"

@class WDRegistrationWindowController;

enum WDApplicationState
{
  // Application state before any checks are made.
  WDUnknownApplicationState = 0,
  
  // Application state when no [valid] serial is found.
  WDUnregisteredApplicationState,
  
  // Application state when all checks are succeeded.
  WDRegisteredApplicationState
};

enum WDSerialVerdict
{
  // When a supplied serial is perfectly legal.
  WDValidSerialVerdict,
  
  // When a supplied serial doesn't conform to the customer name.
  WDCorruptedSerialVerdict,
  
  // Response on serial that was added to the blacklist.
  WDBlacklistedSerialVerdict,
  
  // Response on serial that was not generated by the developer.
  WDPiratedSerialVerdict
};

@interface WDRegistrationController : NSObject

// Returnes a singleton of the WDRegistrationController.
+ (WDRegistrationController*) sharedRegistrationController;

// Returns current registration state of the application.
@property(readonly, atomic) enum WDApplicationState applicationState;

// Must be set to the application DSA/ECDSA public key in PEM format.
@property(readwrite, strong, atomic) NSString* publicKeyPEM;

// Should be set to the array of the blacklisted serials.
@property(readwrite, strong, atomic) NSArray* serialsStaticBlacklist;

// Should be set with custom Serial Entry controller if your app requires one
@property(readwrite, strong, atomic) id<WDSerialEntryControllerProtocol> customSerialEntryController;

// Should be set with custom Registration Status controller if your app requires one
@property(readwrite, strong, atomic) id<WDRegistrationStatusControllerProtocol> customRegistrationStatusController;

// Should be set with custom Serial Entry controller if your app requires one
@property(readwrite, strong, atomic) NSString* (^customSignatureReconstructHandler)(NSArray*);

typedef void (^SerialCheckHandler)(enum WDSerialVerdict verdict);

// Accepts a Quick-Apply link string in form of "appname-wd://GFUENLVNDLPOJHJB:GAWWERTYUIOPEDCNJIKLKJHGFDXCVBNM". Runs asynchronously. Shows either alerts or registration window.
- (void) registerWithQuickApplyLink: (NSString*) link handler: (SerialCheckHandler) handler;

// Tries to register app with the supplied customer name & serial pair then calls handler with the appropriate flag. Runs asynchronously.
- (void) registerWithCustomerData: (NSArray*) customerData serial: (NSString*) serial handler: (SerialCheckHandler) handler;

// Opens application registration window. Should be called from the main thread.
- (IBAction) showRegistrationWindow: (id) sender;

// Returns the name of the successfully accepted customer. Thread safe.
- (NSString*) registeredCustomerName;

// Removes registration data from UserDefaults and puts app in unregistered state. Should be called from the main thread only!
- (void) deauthorizeAccount;

// Launches an asynchronous check of the installed serial. Shows alerts on invalid serials.
- (void) checkForStoredSerialAndValidateIt;

@end

// Use this const string instead of manual typing of the "applicationState" property name in KVO addition/removal of observers.
extern NSString* const ApplicationStateKeyPath;

// May be useful if someone wants to migrate user license data to a new place.
extern NSString* const WDCustomerNameKey;

extern NSString* const WDSerialKey;
