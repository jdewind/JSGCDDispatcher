@interface JSGCDDispatcher : NSObject {
  @private  
  dispatch_queue_t serial_dispatch_queue;
  dispatch_group_t serial_group;
}

+ (id)sharedDispatcher; 
- (void)submitSerialQueueCompletionListener:(void (^)(void))block;
- (void)dispatchAsync:(void (^)(void))block concurrent:(BOOL)runConcurrently;
- (void)dispatchAsync:(void (^)(void))block;
- (void)dispatchOnMainThread:(void (^)(void))block;
@end
