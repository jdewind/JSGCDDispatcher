//
//  AppDelegate.m
//  DispatcherExample
//
//  Created by Justin DeWind on 10/13/11.
//  Copyright (c) 2011 Atomic Object. All rights reserved.
//

#import "AppDelegate.h"
#import "JSGCDDispatcher.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize controller = _controller;

- (void)dealloc
{
  [_window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.window.backgroundColor = [UIColor whiteColor];
  self.controller = [[[UINavigationController alloc] initWithRootViewController:[[[UITableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease]] autorelease];
  [self.window addSubview:self.controller.view];
  [self.window makeKeyAndVisible];
  
  // An important task that should request background time if it can't finish in the foregound  
  [[JSGCDDispatcher sharedDispatcher] dispatchBackgroundTask:^(UIBackgroundTaskIdentifier identifier) {
    if (identifier == UIBackgroundTaskInvalid) {
      NSLog(@"Background Task is Not Valid!");
    } else {
      [NSThread sleepForTimeInterval:4];
      NSLog(@"Background Task is Complete");
    }
  } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
  
  // Push block on to a shared serial queue
  [[JSGCDDispatcher sharedDispatcher] dispatchOnSerialQueue:^{
    NSLog(@"Block Executed On %s", dispatch_queue_get_label(dispatch_get_current_queue()));
  }];
  
  // Push block on global concurrent queue  
  [[JSGCDDispatcher sharedDispatcher] dispatch:^{
    NSLog(@"Block Executed On %s", dispatch_queue_get_label(dispatch_get_current_queue()));
    [[JSGCDDispatcher sharedDispatcher] dispatchOnMainThread:^{
      NSLog(@"Block Executed On %s", dispatch_queue_get_label(dispatch_get_current_queue()));
    }];
  } priority:DISPATCH_QUEUE_PRIORITY_HIGH];
  
  // Execute the submitted block after all blocks have been executed on the serial queue
  [[JSGCDDispatcher sharedDispatcher] submitSerialQueueCompletionListener:^{
    NSLog(@"Serial Queue Complete!");
  }];
  
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  [[JSGCDDispatcher sharedDispatcher] dispatchBackgroundTask:^(UIBackgroundTaskIdentifier identifier) {
    if (identifier == UIBackgroundTaskInvalid) {
      NSLog(@"Background Task is Not Valid!");
    } else {
      [NSThread sleepForTimeInterval:4];
      NSLog(@"Background Task is Complete");
    }
  } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
}

@end
