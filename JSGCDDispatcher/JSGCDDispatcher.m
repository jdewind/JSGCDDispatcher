#import "JSGCDDispatcher.h"

NSString *const JSDefaultSerialQueueName = @"com.jsgcd.dispatch";

static JSGCDDispatcher *gSharedGCDDispatcher;

#if TARGET_OS_IPHONE
@interface JSGCDDispatcher()
@property (assign, getter = isBackgroundTimeAvailable) BOOL backgroundTimeAvailable;
@property (nonatomic, retain) UIApplication *application;
@end
#endif

@implementation JSGCDDispatcher
@synthesize serialQueueID = _serialQueueID;
#if TARGET_OS_IPHONE
@synthesize backgroundTimeAvailable = _backgroundTimeAvailable;
@synthesize application = _application;
#endif

#pragma mark -
#pragma mark Class Methods

+ (void)initialize {
  if (self == [JSGCDDispatcher class]) {
    gSharedGCDDispatcher = [[self alloc] initWithSerialQueueID:JSDefaultSerialQueueName];    
  }
}

+ (id)sharedDispatcher {
  return gSharedGCDDispatcher;    
}

+ (id)dispatcherWithSerialQueueID:(NSString *)serialQueueID {
  return [[[self alloc] initWithSerialQueueID:serialQueueID] autorelease];
}

#pragma mark -
#pragma mark Instance Methods

- (id)initWithSerialQueueID:(NSString *)serialQueueID {
  if ((self = [super init])) {
    _serialQueueID = [serialQueueID copy];
    serial_dispatch_queue = dispatch_queue_create([self.serialQueueID UTF8String], NULL);
    serial_group = dispatch_group_create();
#if TARGET_OS_IPHONE
    self.backgroundTimeAvailable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
#endif
  }
  
  return self;
}

- (UIApplication *)application {
  if (!_application) {
    _application = [UIApplication sharedApplication];
  }
  return [[_application retain] autorelease];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  dispatch_release(serial_dispatch_queue);
  dispatch_release(serial_group);  
  [_serialQueueID release];
  [super dealloc];
}

#pragma mark -
#pragma mark Dispatching Methods

- (void)dispatch:(void (^)(void))block priority:(dispatch_queue_priority_t)priority {
  dispatch_async(dispatch_get_global_queue(priority, 0), block);
}

- (void)dispatch:(void (^)(void))block {
  [self dispatch:block priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
}

- (void)dispatchOnSerialQueue:(void (^)(void))block {
  dispatch_group_async(serial_group, serial_dispatch_queue, block);
}

- (void)dispatchOnMainThread:(void (^)(void))block {
  // If a block is submitted to the queue that is already on the main run loop, 
  // the thread will block forever waiting for the completion of the block -- which will never happen.
  if ([NSThread currentThread] == [NSThread mainThread]) {
    block();    
  } else {
    dispatch_sync(dispatch_get_main_queue(), block);    
  }
}

- (void)submitSerialQueueCompletionListener:(void (^)(void))block {
  dispatch_group_notify(serial_group, serial_dispatch_queue, block);
}

#if TARGET_OS_IPHONE

#pragma mark - iOS Background Queuing

- (void)dispatch:(void (^)(void))block priority:(dispatch_queue_priority_t)priority requestBackgroundTime:(BOOL)canRunInBackground {
  if (canRunInBackground) {
    __block UIBackgroundTaskIdentifier bgTask = [self.application beginBackgroundTaskWithExpirationHandler:^{
      [self.application endBackgroundTask:bgTask];
      @synchronized(self) { bgTask = UIBackgroundTaskInvalid; };
    }];

    block = ^{
      @synchronized(self) {
        if (bgTask != UIBackgroundTaskInvalid) {
          block();
          [self.application endBackgroundTask:bgTask];
        }        
      }
    };
  }
  [self dispatch:block priority:priority];
}
#endif

#pragma mark - Private

@end
