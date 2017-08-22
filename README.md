# KMReceiverCell
Cell for inputing receivers or other keywords, used in E-mail receivers input area.

## Demo

![image](https://raw.githubusercontent.com/Mioke/KMReceiverCell/master/Resources/Receiver_cell_record.gif)

<!-- <img src="https://raw.githubusercontent.com/Mioke/KMReceiverCell/master/Resources/Receiver_cell_record.gif" style="zoom:80%" /> -->

---

## Usage

- Download the zip and drag `KMReceiverCell` folder into your project. 
- Define `shouldReloadCellBlock` when using the cell, use code below:

```swift
	receiverCell.shouldReloadCellBlock = { [weak self] in
	    guard let ss = self else { return }
	    
	    let contentOffset = ss.tableView.contentOffset
	    print("before", contentOffset)
	    
	    UIView.setAnimationsEnabled(false)
	    ss.tableView.beginUpdates()
	    ss.tableView.endUpdates()
	    
	    if ss.receiverCell.isInputing {
	        ss.tableView.contentOffset = contentOffset
	    } else {
	        ss.tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
	    }
	    UIView.setAnimationsEnabled(true)
	    
	    // Uncomment these lines to set tableview's offset when begin editing.
	    /*
	     var new: CGPoint?
	    if ss.receiverCell.isInputing {
	        let contentHeight = ss.receiverCell.pillar.constant
	        let freeHeight = UIScreen.main.bounds.size.width - ss.keyboardRect.size.height - 64
	        
	        if contentHeight > freeHeight {
	            let offset =  contentHeight - freeHeight - 64
	            new = CGPoint(x: 0, y: offset)
	        }
	    }
	    if let new = new {
	        print("new", new)
	        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
	            ss.tableView.setContentOffset(new, animated: true)
	        })
	    }
	    */
	}
```

- ReceiverCell provides several callbacks or handlers for managing actions.
```swift
	// MARK: - Callbacks & delegates
	public var shouldReloadCellBlock: (() -> Void)?
	public var shouldReplaceNameHandler: ((String) -> ReceiverCellModel?)?
	public var errorhandler: ((NSError) -> Void)?
	public var typeAddHandler: ((ReceiverCellModel) -> Void)?
	public var replaceAddHandler: ((ReceiverCellModel) -> Void)?
	public var deleteHandler: ((ReceiverCellModel) -> Void)?
	public var clickAddButton: (() -> Void)?
	public var doubleClickHandler: ((Int, ReceiverCellModel) -> Void)?
```

- All the receiver names or keywords are saved and delivered through class `ReceiverCellModel`.

- You can customize the text field in the cell, but unfortunately I haven't provide methods in the cell. You must __change the source code__ in class `ReceiverCell`. `ReceiverCellTextField` Provide some delegates for changing appearance of different states:
```swift
    var borderColorForState: ((ReceiverTextFieldState) -> UIColor?)?
    var backgroundColorForState: ((ReceiverTextFieldState) -> UIColor?)?
    var textColorForState: ((ReceiverTextFieldState) -> UIColor?)?
```

## More
- Please add an issue or contact me when finding bugs .
- This UI control maynot be updated further.

## Licence
All the source code are under MIT licence. Please see LICENCE file for more informations.
