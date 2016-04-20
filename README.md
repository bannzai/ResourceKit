# ResourceKit
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
![platform](https://cocoapod-badges.herokuapp.com/p/ResourceKit/badge.png)


Enable autocomplete use resources in swift project.

[まだハードコードで消耗してるの？ ResourceKitで安全コーディング！](http://qiita.com/bannzai/items/e9bf5904940fb1ed5082)

## How does ResourceKit work?
ResouceKit makes your code that uses write for resources:
 - `Becomes clear`, nessary to cast and guessing easy what a method will return.
 - `Checked`, the mistaken character doesn't enter your app code.
 - `Autocompleted`, never have to exist hard code when using resource.

##### Standard use resources.

```swift
// Get ViewController
let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
let viewController = storyboard.instantiateViewControllerWithIdentifier("XXXX") as! ViewController

// PerformSegue
performSegueWithIdentifier("Open", sender: sender)

// Nib
let nib = UINib(nibName: "TableViewCell", bundle: nil)
let cell = nib.instantiateWithOwner(nil, options: nil)[0] as! TableViewCell
```
Please see `ResouceKitDemo` for more information, or [Examples.md](https://github.com/bannzai/ResourceKit/blob/master/Documents/Examples.md)

##### Use ResourceKit.
```swift
// Get ViewController
let viewController = ViewController.instanceFromStoryboard() // <- viewController is ViewController class.

// PerformSegue
performSegueOpen() // <- can write to use autocomplete.

// Nib
let cell = TableViewCell.Xib().view() // <- easy get instance.
```


## Features

After installing ResourceKit into your project, and build it.
ResourceKit will correct any missing/changed/added resources.

ResouceKit supports resource types.
 - [Storyboards](https://github.com/bannzai/ResourceKit/blob/master/Documents/Examples.md#viewcontroller-from-storyboard)
 - [Segues](https://github.com/bannzai/ResourceKit/blob/master/Documents/Examples.md#use-segue-any-uiviewcontroller-sub-class)
 - [Nibs](https://github.com/bannzai/ResourceKit/blob/master/Documents/Examples.md#nib)
 - [Reusables](https://github.com/bannzai/ResourceKit/blob/master/Documents/Examples.md#reusalbes)

 #### TODO:
 - Images
 - LocalizedStrings

## Installation
CocoaPods is the recommended way of installation, as this avoids including any binary files into your project.

### Cocoapods
1. Add `pod 'ResourceKit'` to your Podfile and run pod install.
2. In Xcode: Click on your project in the file list, choose your target under TARGETS, click the Build Phases tab and add a New Run Script Phase by clicking the little plus icon in the top left.
3. Drag the new Run Script phase above the Compile Sources phase and below Check Pods Manifest.lock, expand it and paste the following script: ``"$PODS_ROOT/ResourceKit/ResourceKit"``
4. Build your project, in Finder you will now see a ResourceKit.generated.swift in the $SRCROOT-folder, drag the ResourceKit.generated.swift files into your project and uncheck Copy items if needed

### Manual
1. Download a [ResourceKit](https://github.com/bannzai/ResourceKit/releases/) , unzip it and put it your source root directory.
2. In Xcode: Click on your project in the file list, choose your target under TARGETS, click the Build Phases tab and add a New Run Script Phase by clicking the little plus icon in the top left
3. Drag the new Run Script phase above the Compile Sources phase, expand it and paste the following script: "$SRCROOT/ResourceKit"
4. Build your project, in Finder you will now see a `ResourceKit.generated.swift` in the $SRCROOT-folder, drag the `ResourceKit.generated.swift` files into your project and uncheck Copy items if needed.

## TODO:
 - [x] Cocoapods support.  
 - [ ] Images support.  
 - [ ] LocaliazedString Support.  
 - [ ] Adjust indent.
 - [ ] Collaboration [SegueAddition](https://github.com/bannzai/SegueAddition).
 - [ ] User Chose Generate Resource Support.  

## Help:
##### Q.When want to use a Third party UI Library, how should it be done  
A. You can write `import CustomView` to `ResourceKit.generated.swift`.  
And build again, but It's left `import CustomView`!



## License
[ResourceKit](https://github.com/bannzai/ResourceKit) is released under the MIT license. See LICENSE.txt for details.
