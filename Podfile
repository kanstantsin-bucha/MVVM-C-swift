source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

workspace 'example.xcworkspace'

abstract_target 'examplePods' do
    #pod 'FeathersjsClientSwift', '~> 0.8'
    pod 'FeathersjsClientSwift', :path => '~/repos/,github/FeathersjsClientSwift'
    pod 'SVProgressHUD', '~> 2.0'
    pod 'SDWebImage', '~>3.7'
    pod 'CDBKit'
    pod 'GoogleMaps'
    pod 'CDBPlacedUI', '~> 0.0'
    pod 'INTULocationManager', '~> 4.2'
    #pod 'Fabric'
    #pod 'Crashlytics'
    
    target :'example' do
        xcodeproj 'example.xcodeproj'
    end
    target :'exampleTests' do
        xcodeproj 'example.xcodeproj'
    end
    
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end


