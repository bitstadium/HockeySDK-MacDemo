/*
 * Copyright (c) 2012-2014 HockeyApp, Bit Stadium GmbH. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "HockeySDKMacDemoAppDelegate.h"
#import <HockeySDK/HockeySDK.h>


@interface HockeySDKMacDemoAppDelegate() <BITHockeyManagerDelegate>

@property (nonatomic, unsafe_unretained) IBOutlet NSWindow *window;
@property (nonatomic, unsafe_unretained) IBOutlet SUUpdater *sparkle;

@end


@implementation HockeySDKMacDemoAppDelegate


#pragma mark - Application

- (void)applicationDidFinishLaunching:(NSNotification *)note {
  // Launch the crash reporter task
  
  [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"<enter your app identifier in here>"];
  [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled:YES];
  [[BITHockeyManager sharedHockeyManager].crashManager setAskUserDetails:NO];
  [[BITHockeyManager sharedHockeyManager].feedbackManager setRequireUserName:BITFeedbackUserDataElementRequired];
  [[BITHockeyManager sharedHockeyManager].feedbackManager setRequireUserEmail:BITFeedbackUserDataElementOptional];
  [[BITHockeyManager sharedHockeyManager] startManager];
  
  self.sparkle.delegate = self;
  self.sparkle.feedURL = [NSURL URLWithString:@"https://rink.hockeyapp.net/api/2/apps/<enter your app identifier in here>"];
  self.sparkle.sendsSystemProfile = YES;
  [self.sparkle checkForUpdatesInBackground];

  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self selector:@selector(startUsage) name:NSApplicationDidBecomeActiveNotification object:nil];
  [dnc addObserver:self selector:@selector(stopUsage) name:NSApplicationWillTerminateNotification object:nil];
  [dnc addObserver:self selector:@selector(stopUsage) name:NSApplicationWillResignActiveNotification object:nil];

  // Note: Make sure to uncheck "Visible At Launch" for the main window in its xib!
  // Otherwise it would should up alongside the auth window and the user can
  // use the app without authenticating
  [self setupApplication];
}


#pragma mark - Main App Window

/**
 Setup the apps windows
 
 This should only be called in the BITAuthenticator delegates implementations.
 If both are implemented, and the user getsidentified AND validated, then both delegates are invoked!
 */
- (void)setupApplication {
  // If the user is not identified, don't continue to the app
  // In case you want the user to always be validated, check for `isValidated` property instead.
//  if (![[BITHockeyManager sharedHockeyManager].authenticator isIdentified]) return;

  // Note: also make sure the main window isn't set to automatically show
  [self.window makeFirstResponder: nil];
  [self.window makeKeyAndOrderFront:nil];
}



/**
 Implement this to make sure window restoration is only done if the user is identifed/validated
 
 Additionally in this example we also check if the app did not crash in the previous session
 */
- (BOOL)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
  // if the user is not validated, don't allow restoration
//  if (![[BITHockeyManager sharedHockeyManager].authenticator isIdentified]) return NO;

  // Don't restore if we had a crash in the previous app session
  if ([[BITHockeyManager sharedHockeyManager].crashManager didCrashInLastSession]) return NO;
  
  // we could restore any window now and return YES
  
  return NO;
}


#pragma mark - Crashers

/**
 Trigger a signal based crash
 */
- (void)bam {
	__builtin_trap();
}

/**
 Trigger an exception
 
 This normally is silent on OS X, but using HockeySDK it will crash the app and allows it to send a report to HockeyApp
 */
- (void)exceptionBam {
  NSArray *array = [NSArray array];
  [array objectAtIndex:23];
}


#pragma mark - Actions

/**
 Show the feedback window
 
 @param sender Sender
 */
- (IBAction)showFeedbackView:(id)sender {
  [[BITHockeyManager sharedHockeyManager].feedbackManager showFeedbackWindow];
}

/**
 Trigger a signal based crash
 
 @param sender Sender
 */
- (IBAction)doCrash:(id)sender {
  [self bam];
}

/**
 Trigger an exception
 
 @param sender Sender
 */
- (IBAction)doExceptionCrash:(id)sender {
  [self exceptionBam];
}


#pragma mark - Usage Time Tracking

/**
 The app is started or comes into foreground
 */
- (void)startUsage {
  [[BITSystemProfile sharedSystemProfile] startUsage];
}

/**
 The app is going to background or terminated
 */
- (void)stopUsage {
  [[BITSystemProfile sharedSystemProfile] stopUsage];
}


#pragma mark - Sparkle Delegate

/**
 Attach system usage data to the Sparkle Update Check Request
 
 @param updater        Sparkle updater
 @param sendingProfile BOOL
 
 @return Array with data that should be attached to the request
 */
- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater
                 sendingSystemProfile:(BOOL)sendingProfile {
  return [[BITSystemProfile sharedSystemProfile] systemUsageData];
}


#pragma mark - BITCrashManagerDelegate

/**
 Delegate to attach a text (e.g. log) to a crash report
 
 @param crashManager BITCrashManager instance calling this delegate
 
 @return NSString object that should be attached to the crash report
 */
- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager {
  return @"Example log attachment";
}
@end
