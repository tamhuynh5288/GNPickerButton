//
//  ViewController.swift
//  Example
//
//  Created by Tam Huynh on 6/17/19.
//  Copyright © 2019 Guney. All rights reserved.
//

import UIKit
import GNPickerButton

class ViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pickerButton: PickerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        pickerButton.enabledBackgroundColor = UIColor.blue
        pickerButton.setDatasource(createNameDatasource())
        
        pickerButton.doneActionOnFirstComponentHandler = { [weak self] (item) in
            guard let self = self else { return }
            self.nameLabel.text = "Selected name is \(item.data.value)"
        }
    }
}

private extension ViewController {
    func createNameDatasource() -> [[PickerData]] {
        return [[PickerData(value: ""),
                PickerData(value: "Alex"),
                PickerData(value: "Tom"),
                PickerData(value: "Jimmy")]]
    }
}

