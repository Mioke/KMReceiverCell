//
//  ViewController.swift
//  KMReceiverCellDemo
//
//  Created by jiangkelan on 22/08/2017.
//  Copyright © 2017 Klein Mioke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var receiverCell: ReceiverCell!
    var keyboardRect: CGRect = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Keywords input"
        self.setupData()
        
        tableView.register(UINib.init(nibName: "ReceiverCell", bundle: nil),
                           forCellReuseIdentifier: "ReceiverCell")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell") as? ReceiverCell {
            receiverCell = cell
        }
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        
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
    }
    
    private func setupData() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    func keyboardWillShow(notification: Notification) -> Void {
        if let rect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            self.keyboardRect = rect
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - UITableView's delegate & datasource
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Header
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    // MARK: Cell
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return receiverCell
    }
    
    // MARK: Action
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
