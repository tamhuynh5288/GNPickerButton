//
//  PickerData.swift
//  Picker
//
//  Created by Tam Huynh on 5/8/19.
//  Copyright © 2019 th. All rights reserved.
//

import UIKit

open class PickerButton: UIButton {
    public let titleComponentSeparator = " "
    open var textField = UITextField(frame: .zero)
    open var pickerView = PickerView(frame: CGRect(x: 0, y: 0, width: 216, height: 216))
    open var accessoryView = PickerInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    open var indicatorImageView = UIImageView(image: nil)
    
    open var didBeginEditing: ((String?) -> Void)?
    open var selectedItemHandler: ((PickerItem) -> Void)?
    open var doneActionHandler: ((PickerButton, [PickerItem]) -> Void)?
    
    /// Picker button title will automatic set when item was selected. Default: True
    open var autoDisplayTitle = true
    
    /// Combine title in all component to picker button title. Default: True
    open var autoCombineTitle = true
    
    // ======================================================================
    // MARK: - Inspectable Properties
    // ======================================================================
    
    /// Image of indicator
    @IBInspectable
    open var indicatorImage: UIImage? {
        didSet { layoutTitleHorizontalInsetIfNeed() }
    }
    
    @IBInspectable
    open var titleHorizontalInset: CGFloat = 16 {
        didSet { layoutTitleHorizontalInsetIfNeed() }
    }
    
    @IBInspectable
    open var indicatorHorizontalMargin: ContentHorizontalAlignment = .trailing {
        didSet { setupIndicatorImageView() }
    }
    
    @IBInspectable
    open var indicatorHorizontalInset: CGFloat = 16 {
        didSet { setupIndicatorImageView() }
    }
    
    // ======================================================================
    // MARK: - Enabled/Disabled State
    // ======================================================================
    
    open var enabledBackgroundColor = UIColor.white {
        didSet { setEnabledState(isEnabled) }
    }
    
    open var disabledBackgroundColor = UIColor.lightGray {
        didSet { setEnabledState(isEnabled) }
    }
    
    open var disabledTitleColor = UIColor.darkGray {
        didSet { setEnabledState(isEnabled) }
    }
    
    override open var isEnabled: Bool {
        didSet { setEnabledState(isEnabled) }
    }
    
    /// Show or hide indicator when control is on disabled state. Default is True
    open var showIndicatorOnDisabledState = true {
        didSet { setEnabledState(isEnabled) }
    }
    
    /// Show or hide title when control is on disabled state. Default is True
    open var showTitleOnDisabledState = true {
        didSet { setEnabledState(isEnabled) }
    }
    
    // ======================================================================
    // MARK: - Initialize
    // ======================================================================
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configuration()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    // ======================================================================
    // MARK: - Responder
    // ======================================================================
    
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
        return super.becomeFirstResponder()
    }
    
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: - Configuration Flow
private extension PickerButton {
    /// Configuration
    func configuration() {
        defer {
            setEnabledState(isEnabled)
            layoutTitleHorizontalInsetIfNeed()
            setTitleColor(showTitleOnDisabledState ? disabledTitleColor : .clear, for: .disabled)
        }
        
        // Add subviews
        insertSubview(textField, at: 0)
        insertSubview(indicatorImageView, at: 0)
        
        // Setup picker button
        titleLabel?.lineBreakMode = .byTruncatingTail
        addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
        
        // Setup subviews
        setupInputTextField()
        setupPickerView()
        setupAccessoryView()
        setupIndicatorImageView()
    }
    
    /// Setup input textfield
    func setupInputTextField() {
        textField.isHidden = true
        textField.delegate = self
        textField.inputView = pickerView
        textField.inputAccessoryView = accessoryView
    }
    
    /// Setup picker view
    func setupPickerView() {
        pickerView.selectedItemHandler = { [weak self] (sender, item) in
            self?.selectedItemHandler?(item)
        }
    }
    
    /// Setup accessory view
    func setupAccessoryView() {
        accessoryView.doneActionHandler = { [weak self] (sender) in
            guard let self = self else { return }
            self.resignFirstResponder()
            self.setDefaultDisplay(pickerItems: self.selectedItem)
            self.doneActionHandler?(self, self.selectedItem)
        }
    }
    
    /// Setup indicator view
    func setupIndicatorImageView() {
        // Set autoLayout for view
        indicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        indicatorImageView.removeConstraints(indicatorImageView.constraints)
        let leadingConstraint = indicatorImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: indicatorHorizontalInset)
        let trailingConstraint = indicatorImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: indicatorHorizontalInset)
        NSLayoutConstraint.activate([indicatorImageView.widthAnchor.constraint(equalToConstant: 24),
                                     indicatorImageView.heightAnchor.constraint(equalToConstant: 24),
                                     indicatorImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     indicatorHorizontalMargin == .leading ? leadingConstraint : trailingConstraint])
    }
}

// MARK: - Private Methods
private extension PickerButton {
    /// Layout inset of button title
    func layoutTitleHorizontalInsetIfNeed() {
        guard indicatorImage == nil else {
            let value = (indicatorHorizontalInset * 2) + indicatorImageView.bounds.width
            titleEdgeInsets = UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
            return
        }
        titleEdgeInsets = UIEdgeInsets(top: 0, left: titleHorizontalInset, bottom: 0, right: titleHorizontalInset)
    }
    
    /// Set enabled/disabled state of picker button
    ///
    /// - Parameter isEnabled: True will enable picker button and process any thing related
    func setEnabledState(_ isEnabled: Bool) {
        if backgroundImage(for: .normal) != nil { return }
        backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
        indicatorImageView.isHidden = showIndicatorOnDisabledState ? false : !isEnabled
        setTitleColor(showTitleOnDisabledState ? disabledTitleColor : .clear, for: .disabled)
    }
}

// MARK: - Datasource Flow
extension PickerButton {
    /// Set datatsource with one component for picker
    ///
    /// - Parameters:
    ///   - datasources: Datasources with one component will load to picker
    open func setDatasource(_ datasource: [PickerData]?) {
        pickerView.setDatasource(datasource)
    }
    
    /// Set datatsource for picker
    ///
    /// - Parameters:
    ///   - datasources: Datasources will load to picker
    open func setDatasource(_ datasources: [[PickerData]]?) {
        pickerView.setDatasource(datasources)
    }
    
    /// Set datatsource for picker
    ///
    /// - Parameters:
    ///   - pickerDatasource: Any datasource conform PickerDatasource protocol
    open func setDatasource(_ pickerDatasource: PickerDatasource?) {
        pickerView.setDatasource(pickerDatasource)
    }
}

// MARK: - Get Selected Item Flow
extension PickerButton {
    /// Return all selected item in all component
    open var selectedItem: [PickerItem] {
        return pickerView.selectedItem
    }
    
    /// Return the current selected item in exactly component
    ///
    /// - Parameter inComponent: Component of datasources
    /// - Returns: Current selected item
    open func selectedItem(inComponent: Int) -> PickerItem? {
        return pickerView.selectedItem(inComponent: inComponent)
    }
}

// MARK: - Select Item Flow
extension PickerButton {
    /// Select item at index
    ///
    /// - Parameters:
    ///   - row: Row of item in datasource
    ///   - inComponent: Component of item in datasource
    ///   - animated: True will animated selection action
    /// - Returns: PickerItem which has selected
    @discardableResult
    open func selectRow(_ row: Int, inComponent: Int, animated: Bool = true) -> PickerItem? {
        if let item = pickerView.selectRow(row, inComponent: inComponent, animated: animated) {
            setDefaultDisplay(pickerItems: selectedItem)
            return item
        }
        return nil
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
        if let item = pickerView.selectValue(value, inComponent: inComponent, animated: animated) {
            setDefaultDisplay(pickerItems: selectedItem)
            return item
        }
        return nil
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
        if let item = pickerView.selectTitle(title, inComponent: inComponent, animated: animated) {
            setDefaultDisplay(pickerItems: selectedItem)
            return item
        }
        return nil
    }
}

// MARK: - Set Title Flow
extension PickerButton {
    /// Check and set default picker button title and auto select picker item
    ///
    /// - Parameters:
    ///   - items: PickerItems will be set title
    ///   - shouldSelectItem: True will auto select item corresponding. Default is false
    ///   - animated: True will animated select action
    open func setDefaultDisplay(pickerItems items: [PickerItem], shouldSelectItem: Bool = false, animated: Bool = true) {
        guard autoDisplayTitle else { return }
        if autoCombineTitle {
            setDisplayTitles(pickerItems: items, shouldSelectItem: shouldSelectItem, animated: animated)
        } else if let item = items.first {
            setDisplayTitle(item.data.title, inComponent: item.component, shouldSelectItem: shouldSelectItem, animated: animated)
        }
    }
    
    /// Set picker button title and auto select picker item
    ///
    /// - Parameters:
    ///   - title: Title will show on button
    ///   - inComponent: Component contain picker item
    ///   - shouldSelectItem: True will auto select item corresponding. Default is false
    ///   - animated: True will animated select action
    open func setDisplayTitle(_ title: String?, inComponent: Int, shouldSelectItem: Bool = false, animated: Bool = true) {
        // Auto select picker item in correct component
        if shouldSelectItem {
            pickerView.selectTitle(title, inComponent: inComponent, animated: animated)
        }
        // Set title for picker button
        setTitle(title, for: .normal)
    }
    
    /// Set picker button title and auto select picker item
    ///
    /// - Parameters:
    ///   - items: PickerItems will be set title
    ///   - shouldSelectItem: True will auto select item corresponding. Default is false
    ///   - animated: True will animated select action
    open func setDisplayTitles(pickerItems items: [PickerItem], shouldSelectItem: Bool = false, animated: Bool = true) {
        var completedTitle = ""
        for item in items {
            // Process to get completed title for picker button
            let title = item.data.title
            completedTitle += completedTitle.isEmpty ? title : (titleComponentSeparator + title)
            // Auto select picker item in correct component
            if shouldSelectItem {
                pickerView.selectTitle(title, inComponent: item.component, animated: animated)
            }
        }
        // Set completed title for picker button
        setTitle(completedTitle, for: .normal)
    }
}

// MARK: - UITextFieldDelegate
extension PickerButton: UITextFieldDelegate {
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        let displayTitle = title(for: .normal) ?? ""
        didBeginEditing?(displayTitle)
        // Auto reSelect pickerItem match with title if need
        guard autoDisplayTitle else { return }
        if autoCombineTitle {
            var pickerItems = [PickerItem]()
            for (index, title) in displayTitle.components(separatedBy: titleComponentSeparator).enumerated() {
                // Set row == 0 because we dont need row here
                pickerItems.append(PickerItem(component: index, row: 0, data: PickerData(title: title)))
            }
            setDefaultDisplay(pickerItems: pickerItems, shouldSelectItem: true)
        }
    }
}
