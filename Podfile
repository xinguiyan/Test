# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Test' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Test
  pod 'Masonry'
  pod 'AFNetworking', '~> 3.0'
  pod 'YYKit'
  pod "JQHttpRequest"
  pod "SVProgressHUD"

end

post_install do |installer|
  # 消除警告
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
    end
  end
  # M1芯片报错修复
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
