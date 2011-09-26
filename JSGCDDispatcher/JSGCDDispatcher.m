#import "JSGCDDispatcher.h"

static JSGCDDispatcher *gsharedGCDDispatcher;

@implementation JSGCDDispatcher

@synthesize serialQueueID = _serialQueueID;

#pragma mark -
#pragma mark Class Methods

+ (void)initialize {
  if (self == [JSGCDDispatcher class]) {
    gsharedGCDDispatcher = [[self alloc] initWithSerialQueueID:@"com.jsgcd.dispatch"];    
  }
}

+ (id)sharedDispatcher {
  return gsharedGCDDispatcher;    
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
  }
  
  return self;
}

- (void)dealloc {
  dispatch_release(serial_dispatch_queue);
  dispatch_release(serial_group);  
  [_serialQueueID release];
  [super dealloc];
}

#pragma mark -
#pragma mark Dispatching Methods

- (void)dispatch:(void (^)(void))block priority:(dispatch_queue_priority_t)priority {
  dispatch_async(dispatch_get_global_queue(priority, NULL), block);
}

- (void)dispatch:(void (^)(void))block serial:(BOOL)runOnSerialQueue {
  if (!runOnSerialQueue) {
    dispatch_async(dispatch_get_global_queue(0, NULL), block);
  } else {
    [self dispatchOnSerialQueue:block];
  }

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
@end
