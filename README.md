# ShotBlocker

Detecting iOS screenshots ala Snapchat and Facebook Poke.

Current technique is to poll the user's camera roll and check for new screenshot-esque images; if you would like to add another technique, definitely submit a pull-request!

## Usage

```objective-c
#import "ShotBlocker.h"

[[ShotBlocker sharedManager] detectScreenshotWithImageBlock:^(UIImage *screenshot) {
    NSLog(@"Screenshot: %@", screenshot);
}];

// Later on...

[[ShotBlocker sharedManager] stopDetectingScreenshots];
```

Also available are:

- `detectScreenshotWithBlock:^()`
- `detectScreenshotWithBlock:^() andErrorBlock:^(NSError * error){}`
- `detectScreenshotWithImageBlock:^(UIImage *screenshot) andErrorBlock:^(NSError * error){}`

The `NSError` will occur if the user denies your app access to their photos.

## Installation

### [CocoaPods](http://cocoapods.org/)

[Coming soon!](https://github.com/CocoaPods/Specs/pull/941)

### Xcode

1. Add ShotBlocker as a [git submodule](http://schacon.github.com/git/user-manual.html#submodules). Here's how to add it as a submodule:

    $ cd rootOfYourGitRepo
    $ git submodule add https://github.com/clayallsopp/ShotBlocker.git Vendor/ShotBlocker
    $ git submodule update --init --recursive 

2. Add `ShotBlocker/ShotBlocker.h` and `ShotBlocker/ShotBlocker.m` to your project, but don't copy the files (so the location is relative).

3. Add `AssetsLibrary.framework` to your project
