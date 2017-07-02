#
# Be sure to run `pod lib lint URLSessionMetrics.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'URLSessionMetrics'
  s.version          = '0.1.0'
  s.summary          = 'URLSessionMetrics Browser and Detail Viewer'

  s.description      = <<-DESC
  Logger and Viewer for URLSessionMetrics added back in iOS 10.
  Designed to be easy to drop in and go with the easiest setup possible.
                       DESC

  s.homepage         = 'https://github.com/dmiedema/URLSessionMetrics'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dmiedema' => 'danielmiedema+github@me.com' }
  s.source           = { :git => 'https://github.com/dmiedema/URLSessionMetrics.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/no_good_ones'

  s.ios.deployment_target = '10.0'

  s.source_files = 'URLSessionMetrics/Classes/**/*'

  s.frameworks = 'UIKit'
end
