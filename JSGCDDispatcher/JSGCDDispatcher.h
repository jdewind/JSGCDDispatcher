#import <Foundation/Foundation.h>

@interface JSGCDDispatcher : NSObject {
  @protected  
  dispatch_queue_t serial_dispatch_queue;
  dispatch_group_t serial_group;
  NSString *_serialQueueID;
}

+ (id)sharedDispatcher; 
+ (id)dispatcherWithSerialQueueID:(NSString *)serialQueueID;

@property (nonatomic, readonly, copy) NSString *serialQueueID;

- (id)initWithSerialQueueID:(NSString *)serialQueueID;

- (void)submitSerialQueueCompletionListener:(void (^)(void))block;
- (void)dispatch:(void (^)(void))block serial:(BOOL)runOnSerialQueue;
- (void)dispatch:(void (^)(void))block priority:(dispatch_queue_priority_t)priority;
- (void)dispatchOnSerialQueue:(void (^)(void))block;
- (void)dispatchOnMainThread:(void (^)(void))block;
@end
