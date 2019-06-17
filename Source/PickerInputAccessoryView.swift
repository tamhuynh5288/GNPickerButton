//
//  PickerInputAccessoryView.swift
//  QMA
//
//  Created by Tam Huynh on 9/2/18.
//  Copyright © 2019 th. All rights reserved.
//

import UIKit

open class PickerInputAccessoryView: UIView {
    open var doneActionHandler: ((PickerInputAccessoryView) -> Void)?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    public init() {
        super.init(frame: .zero)
        loadView()
    }
    
    func loadView() {
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.black, for: .normal)
        doneButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        let view = UIView()
        view.addSubview(doneButton)
        addSubview(view)
        
        // Configuration
        backgroundColor = UIColor.white
        
        // Set autoLayout for Done button
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([doneButton.widthAnchor.constraint(equalToConstant: 70),
                                     doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     doneButton.topAnchor.constraint(equalTo: view.topAnchor),
                                     doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        // Set autoLayout for view
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     view.topAnchor.constraint(equalTo: topAnchor),
                                     view.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    @objc func doneAction() {
        doneActionHandler?(self)
    }
}
