## ViewController from Storyboard

#### initialViewController

_Standard_
```swift
let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
let viewController = storyboard.initialViewController() as! ViewController
```

_Use ResourceKit_
```swift
let viewController = ViewController.initialViewController()
```

#### instance from storyboard
_Standard_
```swift
let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
let viewController = storyboard.instantiateViewControllerWithIdentifier("XXXX") as! ViewController
```

_Use ResourceKit_
```swift
let viewController = ViewController.instanceFromStoryboard()
```

#### if same class in instance from storyboard  
_standard_
```swift
let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
let viewController1 = storyboard.instantiateViewControllerWithIdentifier("XXXX") as! ViewController
let viewController2 = storyboard.instantiateViewControllerWithIdentifier("YYYY") as! ViewController
```

_Use ResourceKit_
```swift
let viewController1 = ViewController.instanceFromStoryboardXXXX()
let viewController2 = ViewController.instanceFromStoryboardYYYY()
```

## Use segue any UIViewController sub class

_standard_
```swift
...
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Open" {
        // something...
    }
}
...

performSegueWithIdentifier("Open", sender: sender)
```

_Use ResourceKit_
```swift
// In CustomViewController class.
...
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == CustomViewController.Segue.open {
        // something...
    }
}
...

performSegueOpen() // or performSegueOpen(sender: AnyObject?)
```

## Nib
#### create instance from .xib
_standard_
```swift
let nib = UINib(nibName: "TableViewCell", bundle: nil)
let cell nib.instantiateWithOwner(nil, options: nil)[0] as! TableViewCell
```

_Use ResourceKit_
```swift
let customView = CustomView.Xib().fromNib()
```
#### for tableview or collectionview
_standard_
```swift
let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
collectionView?.registerNib(nib, forCellWithReuseIdentifier: "ReusableIdentifier")

let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ReusableIdentifier", forIndexPath: indexPath) as! CollectionViewCell

```

_Use ResourceKit_
```swift
collectionView?.registerNib(CollectionViewCell.Xib())

let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.Xib().name, forIndexPath: indexPath) as! CollectionViewCell
```

## Reusalbes
#### use storyboard
_standard_
```swift
let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ReusableIdentifier", forIndexPath: indexPath) as! CollectionViewCell
```

_Use ResourceKit_
```swift

let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.Reusable.ReuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
```
