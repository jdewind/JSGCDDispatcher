#import "JSGCDDispatcher.h"

static JSGCDDispatcher *_sharedGCDDispatcher;

@implementation JSGCDDispatcher

#pragma mark -
#pragma mark Class Methods

+ (void)initialize {
  if (self == [JSGCDDispatcher class]) {
    _sharedGCDDispatcher = [[[self class] alloc] init];    
  }
}

+ (id)sharedDispatcher {
  return _sharedGCDDispatcher;    
}

#pragma mark -
#pragma mark Instance Methods

- (id)init {
  if ((self = [super init])) {
    serial_dispatch_queue = dispatch_queue_create("com.jsgcd.dispatch", NULL);
    serial_group = dispatch_group_create();
  }
  
  return self;
}

- (void)dealloc {
  dispatch_release(serial_dispatch_queue);
  dispatch_release(serial_group);
  [super dealloc];
}

#pragma mark -
#pragma mark Dispatching Methods

- (void)dispatchAsync:(void (^)(void))block concurrent:(BOOL)runConcurrently {
  if (runConcurrently) {
    dispatch_async(dispatch_get_global_queue(0, 0), block);
  } else {
    [self dispatchAsync:block];
  }

}

- (void)dispatchAsync:(void (^)(void))block {
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
