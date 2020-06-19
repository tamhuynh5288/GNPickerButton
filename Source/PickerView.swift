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
    /// Picker
    open private(set) var picker = UIPickerView()
    
    /// Datasource of picker
    open private(set) var datasources = [[PickerData]]()
    
    /// Return all selected item in all component. Sorted  list by ascending components
    open private(set) var selectedItems = [PickerItem]()
    
    /// Handler when selected item completed
    open var selectedItemHandler: ((PickerView, PickerItem) -> Void)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
}

// MARK: - PRIVATE METHODS
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

// MARK: - DATASOURCES
extension PickerView {
    /// Set datatsource with one component for picker
    /// - Parameter datasource: Datasources with one component will load to picker
    open func setDatasource(_ datasource: [PickerData]?) {
        self.datasources = [datasource ?? []]
        selectedItems.removeAll()
        picker.reloadAllComponents()
    }
    
    /// Set datatsource with multi component for picker
    /// - Parameter datasources: Datasources with multi component will load to picker
    open func setDatasource(_ datasources: [[PickerData]]?) {
        self.datasources = datasources ?? []
        selectedItems.removeAll()
        picker.reloadAllComponents()
    }

    /// Set datatsource for picker
    /// - Parameter pickerDatasource: Any datasource conform PickerDatasource protocol
    open func setDatasource(_ pickerDatasource: PickerDatasource?) {
        setDatasource(pickerDatasource?.datasources)
    }
}

// MARK: - SELECTED ITEM
extension PickerView {
    /// Return the current selected item in exactly component
    /// - Parameter inComponent: Index of component
    /// - Returns: PickerItem which has selected
    open func selectedItem(inComponent: Int = 0) -> PickerItem? {
        guard let index = selectedItems.firstIndex(where: { $0.component == inComponent }) else { return nil }
        return selectedItems[index]
    }
    
    /// Store selected item
    /// - Parameter item: PickerItem which will be store
    /// - Returns: PickerItem after store into current item list
    @discardableResult
    private func storeSelectedItem(_ item: PickerItem) -> PickerItem {
        return storeSelectedItem(row: item.row, inComponent: item.component, data: item.data)
    }
    
    /// Store selected item
    /// - Parameters:
    ///   - row: Row of item
    ///   - component: Component of item
    ///   - data: Data of item
    /// - Returns: PickerItem after store into selectedItems list
    @discardableResult
    private func storeSelectedItem(row: Int, inComponent component: Int, data: PickerData) -> PickerItem {
        let item = PickerItem(component: component, row: row, data: data)
        // Update item data if existed. Otherwise, append new item
        if let index = selectedItems.firstIndex(where: { $0.component == component }) {
            selectedItems[index] = item
        } else {
            selectedItems.append(item)
        }
        // Sort current item by ascending components
        selectedItems.sort(by: { $0.component < $1.component })
        return item
    }
}

// MARK: - SET SELECT ITEM
extension PickerView {
    /// Select item at index
    /// - Parameters:
    ///   - row: Row of item
    ///   - component: Component of item
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectRow(_ row: Int, inComponent component: Int = 0, animated: Bool = true) -> PickerItem? {
        guard let datasource = datasources[safe: component], let data = datasource[safe: row] else { return nil }
        picker.selectRow(row, inComponent: component, animated: animated)
        let item = PickerItem(component: component, row: row, data: data)
        storeSelectedItem(item)
        return item
    }
    
    /// Select item with value
    /// - Parameters:
    ///   - value: The value of item
    ///   - component: Component of item
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectValue(_ value: String?, inComponent component: Int = 0, animated: Bool = true) -> PickerItem? {
        guard let value = value, let datasource = datasources[safe: component],
            let row = datasource.firstIndex(where: { $0.value == value }) else { return nil }
        
        return selectRow(row, inComponent: component, animated: animated)
    }
    
    /// Select item with title
    /// - Parameters:
    ///   - title: The title of item
    ///   - component: Component of item
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectTitle(_ title: String?, inComponent component: Int = 0, animated: Bool = true) -> PickerItem? {
        guard let title = title, let datasource = datasources[safe: component],
            let row = datasource.firstIndex(where: { $0.title == title }) else { return nil }
        
        return selectRow(row, inComponent: component, animated: animated)
    }
}

// MARK: - PICKERVIEW DATASOURCE
extension PickerView: UIPickerViewDataSource {
    open  func numberOfComponents(in pickerView: UIPickerView) -> Int {
        datasources.count
    }
    
    open  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        datasources[safe: component]?.count ?? 0
    }
}

// MARK: - PICKERVIEW DELEGATE
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
