////////////////////////////////////////////////////////////////////////////////
//  
//  RegistrationWindowController.m
//  
//  Watchdog
//  
//  Created by Konstantin Pavlikhin on 27/01/10.
//  
////////////////////////////////////////////////////////////////////////////////

#import "WDRegistrationWindowController.h"

#import "WDRegistrationController.h"

#import "WDSerialEntryController.h"

#import "WDRegistrationStatusController.h"

#import "WDResources.h"

#import <QuartzCore/CoreAnimation.h>

@implementation WDRegistrationWindowController
{
  id<WDSerialEntryControllerProtocol> serialEntryController;
  
  WDRegistrationStatusController* registrationStatusController;
}

- (id) init
{
  NSString* path = [[WDResources resourcesBundle] pathForResource: @"WDRegistrationWindow" ofType: @"nib"];
  
  self = [super initWithWindowNibPath: path owner: self];
  
  if(!self) return nil;
  
  // Immediately starting to observe WDRegistrationController's applicationState property.
  [[WDRegistrationController sharedRegistrationController] addObserver: self forKeyPath: ApplicationStateKeyPath options: NSKeyValueObservingOptionInitial context: NULL];
  
  return self;
}

- (void) dealloc
{
  // Terminating the observation.
  [[WDRegistrationController sharedRegistrationController] removeObserver: self forKeyPath: ApplicationStateKeyPath];
}

- (void) observeValueForKeyPath: (NSString*) keyPath ofObject: (id) object change: (NSDictionary*) change context: (void*) context
{
  WDRegistrationController* SRC = [WDRegistrationController sharedRegistrationController];
  
  if(object == SRC && [keyPath isEqualToString: ApplicationStateKeyPath])
  {
    SRC.applicationState == WDRegisteredApplicationState? [self switchToRegistrationStatusSubview] : [self switchToSerialEntrySubview];
  }
}

- (void) windowDidLoad
{
  // Adjusting subview change animation.
  CATransition* fadeTransition = [CATransition animation];
  
  [fadeTransition setType: kCATransitionFade];
  
  [fadeTransition setDuration: 0.3];
  
  NSDictionary* animations = [NSDictionary dictionaryWithObject: fadeTransition forKey: @"subviews"];
  
  [[self.window contentView] setAnimations: animations];
  
  [[self.window contentView] setWantsLayer: YES];
}

- (IBAction) showWindow: (id) sender
{
  // If the window is closed — showing it at the visual center of the screen.
  if(![[self window] isVisible]) [[self window] center];
  
  [super showWindow: sender];
}

// Lazy WDSerialEntryController constructor.
- (WDSerialEntryController*) serialEntryController
{
  if(!serialEntryController)
  {
    WDRegistrationController* SRC = [WDRegistrationController sharedRegistrationController];
    if (SRC.customSerialEntryController) {
      serialEntryController = SRC.customSerialEntryController;
    } else {
      serialEntryController = [WDSerialEntryController new];
    }
  }

  return serialEntryController;
}

// Lazy WDRegistrationStatusController constructor.
- (WDRegistrationStatusController*) registrationStatusController
{
  if(!registrationStatusController)
  {
    registrationStatusController = [WDRegistrationStatusController new];
  }

  return registrationStatusController;
}

- (void) onAddedView: (NSView*) newView{
  NSView* parentView = self.window.contentView;
  NSRect parentFrame = [self.window frame];
  CGSize newSize = [newView frame].size;
  int titlebarHeight = 22; // TODO: how to get this automatically?

  // resize the window to fit the added view
  newSize.height += titlebarHeight;
  parentFrame.origin.y += parentFrame.size.height; // remove the old height
  parentFrame.origin.y -= newSize.height; // add the new height
  parentFrame.size = newSize;

  // center the added view
  [newView setFrameOrigin:NSMakePoint(
    (NSWidth([parentView bounds]) - NSWidth([newView frame])) / 2,
    (NSHeight([parentView bounds]) - NSHeight([newView frame])) / 2
  )];
  [newView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];

  // render changed view
  [self.window setFrame: parentFrame display: YES animate: NO];
}

// Fade-in/fade-out subview switcher.
- (void) switchToRegistrationStatusSubview
{
  NSView* contentView = self.window.contentView;
  NSView* newView = [[self registrationStatusController] view];

  if([[contentView subviews] containsObject: [serialEntryController view]])
  {
    [[contentView animator] replaceSubview: [serialEntryController view] with: newView];
  }
  else
  {
    [contentView addSubview: newView];
  }

  [self onAddedView: newView];

  [self.window makeFirstResponder: registrationStatusController.dismissButton];
}

// Fade-in/fade-out subview switcher.
- (void) switchToSerialEntrySubview
{
  NSView* contentView = self.window.contentView;
  NSView* newView = [[self serialEntryController] view];

  if([[contentView subviews] containsObject: [registrationStatusController view]])
  {
    [[contentView animator] replaceSubview: [registrationStatusController view] with: newView];
  }
  else
  {
    [[[self window] contentView] addSubview: newView];
  }

  [self onAddedView:newView];
  
  [self.window makeFirstResponder: serialEntryController.firstResponderTextField];
}

@end
