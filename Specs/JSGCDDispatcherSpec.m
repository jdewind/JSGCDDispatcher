#define HC_SHORTHAND

#import <OCHamcrest-iPhone/OCHamcrest.h>
#import "Kiwi.h"
#import "JSGCDDispatcher.h"
#import "CaptureAdditions.h"

#ifdef kKW_DEFAULT_PROBE_TIMEOUT
#undef kKW_DEFAULT_PROBE_TIMEOUT
#endif

#define kKW_DEFAULT_PROBE_TIMEOUT 2.0

static NSString* GetQueueLabel(dispatch_queue_t queue)
{
  return [NSString stringWithUTF8String:dispatch_queue_get_label(queue)];
}

SPEC_BEGIN(JSGCDDispatcherSpec)

describe(@"JSGCDDispatcher", ^{
  __block JSGCDDispatcher *target = nil;
  __block NSMutableString *queueLabel = nil;
  
  beforeEach(^{
    target = [JSGCDDispatcher dispatcherWithSerialQueueID:@"com.myqueue"];
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
    __block id application = nil;
    
    beforeEach(^{
      application = [UIApplication mockWithName:@"application"];
      [target setValue:application forKey:@"application"];
    });
    
    it(@"it ends the task if the expiration handler is called", ^{
      KWCaptureSpy *spy = [application capture:@selector(beginBackgroundTaskWithExpirationHandler:) atIndex:0 andReturn:theValue(4353)];
      
      [[[application shouldEventually] receive] endBackgroundTask:UIBackgroundTaskInvalid];
      [[[application shouldEventually] receive] endBackgroundTask:4353];
            
      [target dispatchBackgroundTask:^(UIBackgroundTaskIdentifier identifier) {
        [NSThread sleepForTimeInterval:0.5];
      } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
      
      dispatch_block_t block = spy.argument;
      block();
    });
    
    it(@"it executes the block on the GCD queue and ends the task", ^{      
      [[application stubAndReturn:theValue(19403)] beginBackgroundTaskWithExpirationHandler:(id)anything()];
      [[[application shouldEventually] receive] endBackgroundTask:19403];
      
      [target dispatchBackgroundTask:^(UIBackgroundTaskIdentifier identifier) {
        [queueLabel appendFormat:@"%d", identifier];
      } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];      
      
      [[queueLabel shouldEventually] equal:@"19403"];            
    });
    
    it(@"it ends the task even if the block throws an exception", ^{
      [[application stubAndReturn:theValue(19403)] beginBackgroundTaskWithExpirationHandler:(id)anything()];
      [[[application shouldEventually] receive] endBackgroundTask:19403];
      
      [target dispatchBackgroundTask:^(UIBackgroundTaskIdentifier identifier) {
        @throw [NSException exceptionWithName:@"Exception" reason:@"" userInfo:nil];
      } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];      
    });
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
      
      [[queueLabel shouldEventually] equal:@"com.myqueue"];      
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
});

SPEC_END