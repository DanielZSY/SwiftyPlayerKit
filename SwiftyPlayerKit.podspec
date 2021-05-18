#
# Be sure to run `pod lib lint SwiftyPlayerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# 1. new code update github
# 2. local not code : pod repo add SwiftyPlayerKit  https://github.com/DanielZSY/SwiftyPlayerKit.git
#    local uodate code: cd ~/.cocoapods/repos/SwiftyPlayerKit. Then execute: pod repo update SwiftyPlayerKit
# 3. pod repo push SwiftyPlayerKit SwiftyPlayerKit.podspec --allow-warnings --sources='https://github.com/CocoaPods/Specs.git'
# 4. pod trunk push SwiftyPlayerKit.podspec --allow-warnings
# 5. pod install or pod update on you project execute

Pod::Spec.new do |s|
  s.name             = 'SwiftyPlayerKit'
  s.version          = '0.0.1'
  s.summary          = 'SwiftyPlayerKit'
  s.module_name      = 'SwiftyPlayerKit'
  
  s.homepage         = 'https://github.com/DanielZSY/SwiftyPlayerKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DanielZSY' => 'danielzsy@163.com' }
  s.source           = { :git => 'https://github.com/DanielZSY/SwiftyPlayerKit.git', :tag => s.version.to_s }
  
  s.platform              = :ios, '10.0'
  s.swift_versions        = "5"
  s.ios.deployment_target = '10.0'
  s.pod_target_xcconfig   = { 'SWIFT_VERSION' => '5.0' }
  
  s.frameworks    = 'UIKit'
  s.libraries     = 'z', 'c++'
  s.source_files  = 'SwiftyPlayerKit/**/*.{swift,h,m}'
  s.ios.resource_bundle = {
      'SwiftyPlayerKit' => 'SwiftyPlayerKit/Assets/BMPlayer.xcassets',
      'SwiftyAudioKit' => 'SwiftyPlayerKit/Assets/Audio.bundle',
      'KKMuteSwitchListener' => 'SwiftyPlayerKit/Assets/KKMuteSwitchListener.bundle'
  }
  s.dependency 'CryptoSwift'
  s.dependency 'BFKit-Swift'
  s.dependency 'SnapKit', '~> 5.0.0'
  s.dependency 'NVActivityIndicatorView', '~> 4.7.0'
end
