# JSGCDDispatcher, a small Objective-C wrapper around GCD

JSGCDDipatcher is a small Objective-C wrapper around GCD that provides a simple interface to submit blocks to GCD either on the serial or concurrent queue.

```objective-c
[[JSGCDDipatcher sharedDispatcher] dispatch:^{
  // Busy Work
} serial:NO];
```

```objective-c
[[JSGCDDipatcher sharedDispatcher] submitSerialQueueCompletionListener:^{
 // Serial jobs complete
}];
```

# TODO

* Better documentation      
* Add OS X Test Target
* Wrap other GCD APIs
