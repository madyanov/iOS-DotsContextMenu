**iOS 10+**

Context menu animated from the ellipsis symbol.

## Preview

![Preview](preview.gif)

*Recording causes background glitches.*

## Usage

```swift
// create buttons
let topButton = UIButton(type: .system)
topButton.tintColor = .white
topButton.setImage(#imageLiteral(resourceName: "calendar"), for: .normal)
let middleButton = UIButton(type: .system)
middleButton.tintColor = .white
middleButton.setImage(#imageLiteral(resourceName: "bookmark"), for: .normal)
let bottomButton = UIButton(type: .system)
bottomButton.tintColor = .white
bottomButton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)

// create menu
let dotsMenu = DotsContextMenu(topButton: topButton, middleButton: middleButton, bottomButton: bottomButton)
view.addSubview(dotsMenu)
```

## Properties

```swift
// dimmed background color
var color: UIColor { get set }

// flips menu vertically
var isReversed: Bool { get set }

// width of the menu
var width: CGFloat { get set }

// radius of the ellipsis dots
var dotRadius: CGFloat { get set }

// delay before menu will be automatically closed
var closeAfterDelay: TimeInterval { get set }
```

## Methods

```swift
// manually open menu with animation
func open()

// manually close menu with animation
func close()
```
