/*
 * Author: Andreas Linde <mail@andreaslinde.de>
 *         Kent Sutherland
 *
 * Copyright (c) 2011 Andreas Linde & Kent Sutherland. All rights reserved.
 * All rights reserved.
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

@implementation HockeySDKMacDemoAppDelegate

#pragma mark - BITCrashReportManagerDelegate

-(NSString *)crashReportApplicationLog {
  return @"test";
}

// set the main nibs window to hidden on startup
// this delegate method is required to be implemented!
- (void) showMainApplicationWindow {
  [window makeFirstResponder: nil];
  [window makeKeyAndOrderFront:nil];
}

#pragma mark - Application

- (void)applicationDidFinishLaunching:(NSNotification *)note {
  // Launch the crash reporter task
  
  [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"<enter your app identifier in here>" companyName:@"My company" crashReportManagerDelegate:self];
  [[BITHockeyManager sharedHockeyManager] setLoggingEnabled:YES];
  [[BITHockeyManager sharedHockeyManager] setExceptionInterceptionEnabled:YES];
  [[BITHockeyManager sharedHockeyManager] setAskUserDetails:YES];
  [[BITHockeyManager sharedHockeyManager] startManager];

  NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
  [dnc addObserver:self selector:@selector(startUsage) name:NSApplicationDidBecomeActiveNotification object:nil];
  [dnc addObserver:self selector:@selector(stopUsage) name:NSApplicationWillTerminateNotification object:nil];
  [dnc addObserver:self selector:@selector(stopUsage) name:NSApplicationWillResignActiveNotification object:nil];
}


#pragma mark - Crash

- (void)bam {
	/* Trigger a crash */
  signal(SIGBUS, SIG_DFL);
  
  *(long*)0 = 0xDEADBEEF;
}

- (void)exceptionBam {
	/* Trigger a crash */
  NSArray *array = [NSArray array];
  [array objectAtIndex:23];
//  [NSException raise:NSInvalidArgumentException format:@"Foo must not be nil"];  
}


- (IBAction)doCrash:(id)sender {
  [self bam];
}

- (IBAction)doExceptionCrash:(id)sender {
  [self exceptionBam];
}

#pragma mark - Usage Time Tracking
- (void)startUsage {
  NSLog(@"start");
  return [[BITSystemProfile sharedSystemProfile] startUsage];
}

- (void)stopUsage {
  NSLog(@"stop");
  return [[BITSystemProfile sharedSystemProfile] stopUsage];
}

@end
