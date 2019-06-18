Pod::Spec.new do |spec|
  spec.name = "GNPickerButton"
  spec.version = "0.0.1"
  spec.summary = "A frameworks that let you easy to create picker selection"
  spec.homepage = "https://github.com/tamhuynh5288/GNPickerButton"
  spec.license = "MIT"
  spec.author = { "Tam Huynh" => "tamhuynh5288@gmail.com" }
  spec.platform = :ios, "12.0"
  spec.swift_version = '5.0'
  spec.source = { :git => "https://github.com/tamhuynh5288/GNPickerButton.git", :tag => "#{spec.version}" }
  spec.source_files  = "Source/*.swift"
end
