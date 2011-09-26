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

* Add Kiwi Specs
* Better documentation
* Add podspec

