#import <Foundation/Foundation.h>

NSString *const JSDefaultSerialQueueName;

@interface JSGCDDispatcher : NSObject {
  @protected  
  dispatch_queue_t serial_dispatch_queue;
  dispatch_group_t serial_group;
  NSString *_serialQueueID;
#if TARGET_OS_IPHONE
  @private
  BOOL _backgroundTimeAvailable;
  UIApplication *_application;
#endif
}

+ (id)sharedDispatcher; 
+ (id)dispatcherWithSerialQueueID:(NSString *)serialQueueID;

@property (nonatomic, readonly, copy) NSString *serialQueueID;

- (id)initWithSerialQueueID:(NSString *)serialQueueID;

- (void)submitSerialQueueCompletionListener:(void (^)(void))block;
- (void)dispatch:(void (^)(void))block;
- (void)dispatch:(void (^)(void))block priority:(dispatch_queue_priority_t)priority;
#if TARGET_OS_IPHONE
- (void)dispatchBackgroundTask:(void (^)(UIBackgroundTaskIdentifier identifier))block priority:(dispatch_queue_priority_t)priority;
#endif
- (void)dispatchOnSerialQueue:(void (^)(void))block;
- (void)dispatchOnMainThread:(void (^)(void))block;
@end
