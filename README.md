# ResourceKit

Enable autocomplete use resources like in swift project.

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
let cell nib.instantiateWithOwner(nil, options: nil)[0] as! TableViewCell
```

##### Use ResourceKit.
```swift
// Get ViewController
let viewController = ViewController.instanceFromStoryboard() // <- viewController is ViewController class.

// PerformSegue
performSegueOpen() // <- performSegue become instance method.

// Nib
let cell = TableViewCell.fromNib() // <- Get easy instance.
```


## Features

After installing ResourceKit into your project, and build it.
ResourceKit will correct any missing/changed/added resources.

ResouceKit supports resource types.

 - Storyboards
 - Segues
 - Nibs
 - Reusables

 #### TODO:
 - Images
 - LocalizedStrings

## Installation

### Manual

1. Download a [ResourceKit](https://github.com/bannzai/ResourceKit) , unzip it and put it your source root directory.
2. In Xcode: Click on your project in the file list, choose your target under TARGETS, click the Build Phases tab and add a New Run Script Phase by clicking the little plus icon in the top left
3. Drag the new Run Script phase above the Compile Sources phase, expand it and paste the following script: "$SRCROOT/ResourceKit" "$SRCROOT"
4. Build your project, in Finder you will now see a `ResourceKit.generated.swift` in the $SRCROOT-folder, drag the `ResourceKit.generated.swift` files into your project and uncheck Copy items if needed.

## TODO:
 - [ ] Cocoapods support.  
 - [ ] Images support.  
 - [ ] LocaliazedString Support.  
 - [ ] User Chose Generate Resource Support.  

## License

[ResourceKit](https://github.com/bannzai/ResourceKit) is released under the MIT license. See LICENSE.txt for details.
