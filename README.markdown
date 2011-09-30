# JSGCDDispatcher, a small Objective-C wrapper around GCD

JSGCDDipatcher is a small Objective-C wrapper around GCD that provides a simple interface to submit blocks to GCD either on the serial or concurrent queue.

## Global Queue

```objective-c
[[JSGCDDipatcher sharedDispatcher] dispatch:^{
  // Busy Work
}];
```

```objective-c
[[JSGCDDipatcher sharedDispatcher] dispatch:^{
  // Busy Work
} priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
```

## Serial Queue

``` objective-c
[target dispatchOnSerialQueue:^{
  // Busy serial work
}];
```

```objective-c
[[JSGCDDipatcher sharedDispatcher] submitSerialQueueCompletionListener:^{
 // Serial jobs complete
}];
```

## Background Tasks (iOS)

Invoke this method when you have a task that is important and should not be interrupted if the application is suddenly placed in the background. 

```objective-c
[target dispatchBackgroundTask:^(UIBackgroundTaskIdentifier identifier) {
  if(identifier == UIBackgroundTaskInvalid) {
    // Almost out of time to run the task
  } else {
    // Good to go
  }
} priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
```

# TODO

* Better documentation      
* Add OS X Test Target
