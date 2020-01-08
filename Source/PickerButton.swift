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
    public let indicatorImageSize = CGSize(width: 24, height: 24)
    
    open var textField = UITextField(frame: .zero)
    open var pickerView = PickerView(frame: CGRect(x: 0, y: 0, width: 216, height: 216))
    open var accessoryView = PickerInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    open var indicatorButton = UIButton()
    
    /// List of stored constraints of indicatorButton
    private var indicatorButtonConstraints = [NSLayoutConstraint]()
    
    // Handler closures
    open var beginEditingHandler: ((String?) -> Void)?
    open var selectedRowHandler: ((PickerItem) -> Void)?
    open var doneActionHandler: (([PickerItem]) -> Void)?
    open var doneActionOnFirstComponentHandler: ((PickerItem) -> Void)?
    
    /// Picker button title will automatic set when item was selected. Default: True
    open var autoDisplayTitle = true
    
    /// Combine title in all component to picker button title. Default: True
    open var autoCombineTitle = true
    
    // ======================================================================
    // MARK: - Layout Properties
    // ======================================================================
    
    /// Image of indicator
    @IBInspectable
    open var indicatorImage: UIImage? = #imageLiteral(resourceName: "list_pull") {
        didSet {
            indicatorButton.setImage(indicatorImage, for: .normal)
            layoutTitleHorizontalInsetIfNeed()
        }
    }
    
    @IBInspectable
    open var titleHorizontalInset: CGFloat = 16 {
        didSet { layoutTitleHorizontalInsetIfNeed() }
    }
    
    @IBInspectable
    open var indicatorHorizontalInset: CGFloat = 16 {
        didSet {
            layoutIndicatorButtonIfNeeded()
            layoutTitleHorizontalInsetIfNeed()
        }
    }
    
    open var indicatorHorizontalMargin: ContentHorizontalAlignment = .trailing {
        didSet {
            layoutIndicatorButtonIfNeeded()
            layoutTitleHorizontalInsetIfNeed()
        }
    }
    
    // ======================================================================
    // MARK: - Enabled/Disabled State
    // ======================================================================
    
    @IBInspectable
    open var enabledBackgroundColor: UIColor = .white {
        didSet { setEnabledState(isEnabled) }
    }
    
    @IBInspectable
    open var disabledBackgroundColor: UIColor = .lightGray {
        didSet { setEnabledState(isEnabled) }
    }
    
    @IBInspectable
    open var disabledTitleColor: UIColor = .darkGray {
        didSet { setEnabledState(isEnabled) }
    }
    
    override open var isEnabled: Bool {
        didSet { setEnabledState(isEnabled) }
    }
    
    /// Use indicator image or not. Default is True
    open var useIndicatorImage = true {
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
        }
        
        // Add subviews
        insertSubview(textField, at: 0)
        insertSubview(indicatorButton, at: 0)
        
        // Setup picker button
        titleLabel?.lineBreakMode = .byTruncatingTail
        addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
        
        // Setup indicator button
        indicatorButton.setImage(indicatorImage, for: .normal)
        indicatorButton.addTarget(self, action: #selector(actionIndicatorImage), for: .touchUpInside)
        
        // Setup subviews
        setupInputTextField()
        setupPickerView()
        setupAccessoryView()
        setupIndicatorButton()
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
            self?.selectedRowHandler?(item)
        }
    }
    
    /// Setup accessory view
    func setupAccessoryView() {
        accessoryView.doneActionHandler = { [weak self] (sender) in
            guard let self = self else { return }
            self.resignFirstResponder()
            self.setDefaultDisplay(pickerItems: self.selectedItems)
            self.doneActionHandler?(self.selectedItems)
            if let selectedItem = self.selectedItems.first {
                self.doneActionOnFirstComponentHandler?(selectedItem)
            }            
        }
    }
    
    /// Setup accessory view
    func setupIndicatorButton() {
        // Set autoLayout for view
        indicatorButton.translatesAutoresizingMaskIntoConstraints = false
        // Create list of constraints
        let constraints = [indicatorButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -indicatorHorizontalInset),
                           indicatorButton.widthAnchor.constraint(equalToConstant: indicatorImageSize.width),
                           indicatorButton.heightAnchor.constraint(equalToConstant: indicatorImageSize.height),
                           indicatorButton.centerYAnchor.constraint(equalTo: centerYAnchor)]
        // Active all constraints
        indicatorButtonConstraints = constraints
        NSLayoutConstraint.activate(indicatorButtonConstraints)
    }
    
    @objc func actionIndicatorImage() {
        sendActions(for: .touchUpInside)
    }
}

// MARK: - Private Methods
private extension PickerButton {
    /// Layout inset of button title
    func layoutTitleHorizontalInsetIfNeed() {
        titleEdgeInsets = UIEdgeInsets(top: 0, left: titleHorizontalInset, bottom: 0, right: titleHorizontalInset)
    }
    
    /// Setup indicator view
    func layoutIndicatorButtonIfNeeded() {
        // Checking if indicatorButton is currently hidden. Dont create constraint for it
        guard !indicatorButton.isHidden && !indicatorButtonConstraints.isEmpty else { return }
        
        // Checking horizontal constraints is Leading or Trailing, and add correct constraint to indicatorButton
        if indicatorHorizontalMargin == .leading {
            indicatorButtonConstraints[0].constant = -(bounds.width - indicatorHorizontalInset - indicatorImageSize.width)
        } else {
            indicatorButtonConstraints[0].constant = -indicatorHorizontalInset
        }
        layoutIfNeeded()
    }
    
    /// Set enabled/disabled state of picker button
    ///
    /// - Parameter isEnabled: True will enable picker button and process any thing related
    func setEnabledState(_ isEnabled: Bool) {
        indicatorButton.isHidden = !useIndicatorImage ? true : (showIndicatorOnDisabledState ? false : !isEnabled)
        layoutIndicatorButtonIfNeeded()
        layoutTitleHorizontalInsetIfNeed()
        setTitleColor(showTitleOnDisabledState ? disabledTitleColor : .clear, for: .disabled)
        if backgroundImage(for: .normal) != nil { return }
        backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
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
    open var selectedItems: [PickerItem] {
        return pickerView.selectedItems
    }
    
    /// Return the current selected item in exactly component
    ///
    /// - Parameter inComponent: Component of datasources
    /// - Returns: Current selected item
    open func selectedItem(inComponent: Int = 0) -> PickerItem? {
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
    open func selectRow(_ row: Int, inComponent: Int = 0, animated: Bool = true) -> PickerItem? {
        if let item = pickerView.selectRow(row, inComponent: inComponent, animated: animated) {
            setDefaultDisplay(pickerItems: selectedItems)
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
    open func selectValue(_ value: String?, inComponent: Int = 0, animated: Bool = true) -> PickerItem? {
        if let item = pickerView.selectValue(value, inComponent: inComponent, animated: animated) {
            setDefaultDisplay(pickerItems: selectedItems)
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
    open func selectTitle(_ title: String?, inComponent: Int = 0, animated: Bool = true) -> PickerItem? {
        if let item = pickerView.selectTitle(title, inComponent: inComponent, animated: animated) {
            setDefaultDisplay(pickerItems: selectedItems)
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
    open func setDisplayTitle(_ title: String?, inComponent: Int = 0, shouldSelectItem: Bool = false, animated: Bool = true) {
        // Auto select picker item in correct component
        if shouldSelectItem || selectedItems.isEmpty {
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
            if shouldSelectItem || selectedItems.isEmpty {
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
        beginEditingHandler?(displayTitle)
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
