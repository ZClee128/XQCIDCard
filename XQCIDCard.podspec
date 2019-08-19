#
# Be sure to run `pod lib lint XQCIDCard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XQCIDCard'
  s.version          = '0.1.0'
  s.summary          = 'A short description of XQCIDCard.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ZClee128/XQCIDCard'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZClee128' => '876231865@qq.com' }
  s.source           = { :git => 'https://github.com/ZClee128/XQCIDCard.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'XQCIDCard/Classes/**/*'
  
   s.resource_bundles = {
     'XQCIDCard' => ['XQCIDCard/Assets/*.png']
   }
   s.resource = 'XQCIDCard/Classes/CardTool/liscanidcard/dicts/zocr0.lib'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.static_framework = true
  s.ios.vendored_libraries = 'XQCIDCard/Classes/CardTool/liscanidcard/libscanidcardios.a','XQCIDCard/Classes/CardTool/liscanidcard/exbankcardcore/libbexbankcard.a'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'ENABLE_BITCODE' => 'NO' ,'ENABLE_TESTABILITY' => 'NO'}
#  s.xcconfig = { 'LD_RUNPATH_SEARCH_PATHS' => 'XQCIDCard/Frameworks',"HEADER_SEARCH_PATHS" => "${PODS_ROOT}/../../CardTool/liscanidcard"}
  # s.dependency 'AFNetworking', '~> 2.3'
end
