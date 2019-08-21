//
//  PickerView.swift
//  PickerButton
//
//  Created by Tam Huynh on 9/2/18.
//  Copyright © 2019 th. All rights reserved.
//

import UIKit
import Foundation

open class PickerView: UIView {
    open var picker = UIPickerView()
    open var datasources: [[PickerData]] = []
    open var currentItem: [PickerItem] = []
    
    open var selectedItemHandler: ((PickerView, PickerItem) -> Void)?
    
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
}

// MARK: - Private Methods
private extension PickerView {
    /// Load view
    private func loadView() {
        // Configuration
        backgroundColor = UIColor.white
        
        // Setup picker
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.clear
        addSubview(picker)
        
        // Set autoLayout for view
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([picker.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     picker.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     picker.topAnchor.constraint(equalTo: topAnchor),
                                     picker.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}

// MARK: - Datasource Flow
extension PickerView {
    /// Set datatsource with one component for picker
    ///
    /// - Parameters:
    ///   - datasources: Datasources with one component will load to picker
    open func setDatasource(_ datasource: [PickerData]?) {
        self.datasources = [datasource ?? []]
        currentItem.removeAll()
        picker.reloadAllComponents()
    }
    
    /// Set datatsource with multi component for picker
    ///
    /// - Parameters:
    ///   - datasources: Datasources with multi component will load to picker
    open func setDatasource(_ datasources: [[PickerData]]?) {
        self.datasources = datasources ?? []
        currentItem.removeAll()
        picker.reloadAllComponents()
    }
    
    /// Set datatsource for picker
    ///
    /// - Parameters:
    ///   - pickerDatasource: Any datasource conform PickerDatasource protocol
    open func setDatasource(_ pickerDatasource: PickerDatasource?) {
        setDatasource(pickerDatasource?.datasources)
    }
}

// MARK: - Selected Item Flow
extension PickerView {
    /// Return all selected item in all component. First item has component at index 0.
    open var selectedItem: [PickerItem] {
        return currentItem
    }
    
    /// Return the current selected item in exactly component
    ///
    /// - Parameter inComponent: Component index of item
    /// - Returns: Current selected item
    open func selectedItem(inComponent: Int) -> PickerItem? {
        guard let index = currentItem.firstIndex(where: { $0.component == inComponent }) else { return nil }
        return currentItem[index]
    }
    
    /// Store selected item
    ///
    /// - Parameter item: PickerItem which will be store
    /// - Returns: PickerItem after store into current item list
    @discardableResult
    private func storeSelectedItem(_ item: PickerItem) -> PickerItem {
        return storeSelectedItem(row: item.row, inComponent: item.component, data: item.data)
    }
    
    /// Store selected item
    ///
    /// - Parameters:
    ///   - row: Row of item
    ///   - inComponent: Component of item in datasource
    ///   - data: Data of item
    /// - Returns: PickerItem after store into current item list
    @discardableResult
    private func storeSelectedItem(row: Int, inComponent: Int, data: PickerData) -> PickerItem {
        let pickerItem = PickerItem(component: inComponent, row: row, data: data)
        // Update item data if existed. Otherwise, append new item
        if let index = currentItem.firstIndex(where: { $0.component == inComponent }) {
            currentItem[index] = pickerItem
        } else {
            currentItem.append(pickerItem)
        }
        // Sort current item by component
        currentItem.sort(by: { $0.component < $1.component })
        return pickerItem
    }
}

// MARK: - Select Item Flow
extension PickerView {
    /// Select item at index
    ///
    /// - Parameters:
    ///   - row: Row of item in datasource
    ///   - inComponent: Component of item in datasource
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectRow(_ row: Int, inComponent: Int, animated: Bool = true) -> PickerItem? {
        guard let datasource = datasources[safe: inComponent], let data = datasource[safe: row] else { return nil }
        picker.selectRow(row, inComponent: inComponent, animated: animated)
        let item = PickerItem(component: inComponent, row: row, data: data)
        storeSelectedItem(item)
        return item
    }
    
    /// Select item with value
    ///
    /// - Parameters:
    ///   - value: The value of item
    ///   - inComponent: Component of item in datasource
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectValue(_ value: String?, inComponent: Int, animated: Bool = true) -> PickerItem? {
        guard let value = value,
            let datasource = datasources[safe: inComponent],
            let row = datasource.firstIndex(where: { $0.value == value }) else { return nil }
        
        return selectRow(row, inComponent: inComponent, animated: animated)
    }
    
    /// Select item with title
    ///
    /// - Parameters:
    ///   - title: The title of item
    ///   - inComponent: Component of item in datasource
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectTitle(_ title: String?, inComponent: Int, animated: Bool = true) -> PickerItem? {
        guard let title = title,
            let datasource = datasources[safe: inComponent],
            let row = datasource.firstIndex(where: { $0.title == title }) else { return nil }
        
        return selectRow(row, inComponent: inComponent, animated: animated)
    }
}

// MARK: - UIPickerViewDataSource
extension PickerView: UIPickerViewDataSource {
    open  func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return datasources.count
    }
    
    open  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasources[safe: component]?.count ?? 0
    }
}

// MARK: - UIPickerViewDelegate
extension PickerView: UIPickerViewDelegate {
    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        guard let title = datasources[safe: component]?[safe: row]?.title else { return nil }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let text = NSMutableAttributedString(string: title, attributes: [.paragraphStyle: paragraphStyle])
        return text
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let datasource = datasources[safe: component], let data = datasource[safe: row] else { return }
        let item = PickerItem(component: component, row: row, data: data)
        storeSelectedItem(item)
        selectedItemHandler?(self, item)
    }
}
