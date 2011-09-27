#import "Kiwi.h"
#import "JSGCDDispatcher.h"

static NSString* GetQueueLabel(dispatch_queue_t queue)
{
  return [NSString stringWithUTF8String:dispatch_queue_get_label(queue)];
}

SPEC_BEGIN(JSGCDDispatcherSpec)

describe(@"JSGCDDispatcher", ^{
  __block JSGCDDispatcher *target = nil;
  __block NSMutableString *queueLabel = nil;
  
  beforeEach(^{
    target = [JSGCDDispatcher sharedDispatcher];
    queueLabel = [NSMutableString string];
  });
  
  describe(@"#dispatch:", ^{
    it(@"executes the block on the global default priority queue", ^{
      [target dispatch:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];
      }];
      
      [[queueLabel shouldEventually] equal:@"com.apple.root.default-priority"];
    });
  });

#if TARGET_OS_IPHONE
  describe(@"dispatch:priority:requestBackgroundTime:", ^{
    pending(@"it does not execute the block if the application is not granted background time", ^{});
    pending(@"it does not execute the block if the available time to execute expires", ^{});
    pending(@"it executes the block and ends the task", ^{});
  });
#endif
  
  describe(@"#dispatch:priority:", ^{
    it(@"executes on the default priority queue", ^{
      [target dispatch:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];
      } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
      
      [[queueLabel shouldEventually] equal:@"com.apple.root.default-priority"];            
    });
    
    it(@"executes on the high priority queue", ^{
      [target dispatch:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];
      } priority:DISPATCH_QUEUE_PRIORITY_HIGH];
      
      [[queueLabel shouldEventually] equal:@"com.apple.root.high-priority"];            
    });
    
    it(@"executes on the low priority queue", ^{
      [target dispatch:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];
      } priority:DISPATCH_QUEUE_PRIORITY_LOW];
      
      [[queueLabel shouldEventually] equal:@"com.apple.root.low-priority"];            
    });  
    
    it(@"executes on the background priority queue", ^{
      [target dispatch:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];
      } priority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
      
      [[queueLabel shouldEventually] equal:@"com.apple.root.background-priority"];            
    });  
  });
  
  describe(@"@dispatchOnSerialQueue:", ^{
    it(@"executes the block on the default serial queue", ^{
      [target dispatchOnSerialQueue:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];        
      }];
      
      [[queueLabel shouldEventually] equal:JSDefaultSerialQueueName];      
    });    
  });
  
  describe(@"#dispatchOnMainThread:", ^{
    it(@"doesn't hang if it is executed on the main thread", ^{
      [target dispatchOnMainThread:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];                
      }];
      [[queueLabel shouldEventually] equal:@"com.apple.main-thread"];            
    });
    
    it(@"executes the block on the main thread", ^{
      [target dispatchOnSerialQueue:^{
        [target dispatchOnMainThread:^{
          [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];                
        }];
      }];
      [[queueLabel shouldEventually] equal:@"com.apple.main-thread"];            
    });
  });
  
  describe(@"#submitSerialQueueCompletionListener:", ^{
    it(@"invokes the queue completion listener once the serial queue has finished" , ^{
      NSMutableString *status = [NSMutableString string];
      
      [target dispatchOnSerialQueue:^{
        [status appendString:@"Block 1"];
      }];
      
      [target dispatchOnSerialQueue:^{
        [status appendString:@" Block 2"];
      }];
      
      [target submitSerialQueueCompletionListener:^{
        [status appendString:@" Complete"];
      }];      
      
      [[status shouldEventually] equal:@"Block 1 Block 2 Complete"];            
    });
  });
  
  describe(@".dispatcherWithSerialQueueID:", ^{
    beforeEach(^{
      target = [JSGCDDispatcher dispatcherWithSerialQueueID:@"com.dewind"];
    });
    
    it(@"creates a dispatcher with the given serial queue id", ^{
      [target dispatchOnSerialQueue:^{
        [queueLabel appendString:GetQueueLabel(dispatch_get_current_queue())];        
      }];
      
      [[queueLabel shouldEventually] equal:@"com.dewind"];      
    });
  });
});

SPEC_END