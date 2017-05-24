platform :ios, '9.0'

use_frameworks!
inhibit_all_warnings!

def pods
  pod 'Parse', '~> 1.14'
  pod 'ParseFacebookUtilsV4', '~> 1.11'
  pod 'FBSDKCoreKit', '~> 4.10'
  pod 'FBSDKLoginKit', '~> 4.10'
  pod 'XCGLogger', '~> 3.2'
  pod 'Transporter', '~> 2.0'
  pod 'DynamicColor', '~> 2.4'
  pod 'FBSDKShareKit', '~> 4.10'
  pod 'VK-ios-sdk', '~> 1.3'
  pod 'EDSunriseSet', '~> 1.0'
  pod 'SCLAlertView', '0.5.1'
  pod 'TPKeyboardAvoiding', '~> 1.2'
  pod 'CVCalendar', :git => 'https://github.com/Binur/CVCalendar'
  pod 'Whisper', '~> 2.1'
  pod 'ReachabilitySwift', :git => 'https://github.com/ashleymills/Reachability.swift.git', :branch => 'swift-2.3'
  pod 'FXPageControl', '~> 1.4'
  pod 'KMPlaceholderTextView', '1.2.2'
  pod 'EasyTipView', :git => 'https://github.com/Binur/EasyTipView.git'
#  pod 'LiquidLoader', :git => 'https://github.com/yoavlt/LiquidLoader.git', :commit => 'efd1ee4c517ba354b75ff7f2036e087de945edc4'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Reusable', '~> 2.2'
  pod 'Sugar', '1.0'
  pod 'FontBlaster', :git => 'https://github.com/ArtSabintsev/FontBlaster.git', :branch => 'swift2.3'
  pod 'ReactiveCocoa', '~> 4.0'
  pod 'Cartography', '~> 0.7'
  pod 'SVProgressHUD', '2.0'
end

target 'Persimmon' do
    pods
end

target 'PersimmonTests' do
    pods
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    # Configure Pod targets for Xcode 8 compatibility
    config.build_settings['SWIFT_VERSION'] = '2.3'
    config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = 'ABCDEFGHIJ/'
    config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
  end
end
