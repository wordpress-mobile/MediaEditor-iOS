Pod::Spec.new do |s|
  s.name             = 'MediaEditor'
  s.version          = '0.1.0'
  s.summary          = 'An extensible Media Editor for iOS.'

  s.description      = <<-DESC
                       An extensible Media Editor for iOS that allows editing single or multiple images.
                       DESC

  s.homepage         = 'https://github.com/wordpress-mobile/MediaEditor-iOS.git'
  s.license          = { :type => 'GPLv2', :file => 'LICENSE' }
  s.author           = { 'Automattic' => 'mobile@automattic.com' }
  s.social_media_url = "http://twitter.com/WordPressiOS"
  s.source           = { :git => 'https://github.com/wordpress-mobile/MediaEditor-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.module_name = "MediaEditor"
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.resources = 'Sources/**/*.{storyboard}'
  s.resource_bundles = {
    'MediaEditor' => 'Sources/**/*.{xcassets}'
  }

  s.dependency 'TOCropViewController', '~> 2.5.2'
end
