# JSGCDDispatcher, a small Objective-C wrapper around GCD

JSGCDDipatcher is a small Objective-C wrapper around GCD that provides a simple interface to submit blocks to GCD either on serial or concurrent queue.

```objective-c
[[JSGCDDipatcher sharedDispatcher] dispatchAsync:^{
  // Busy Work
} concurrent:YES];
```

```objective-c
[[JSGCDDipatcher sharedDispatcher] submitSerialQueueCompletionListener:^{
 // Serial jobs complete
}];
```



