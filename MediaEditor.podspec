Pod::Spec.new do |s|
  s.name          = 'MediaEditor'
  s.version       = '1.2.1'

  s.summary       = 'An extensible Media Editor for iOS.'
  s.description   = <<-DESC
                    An extensible Media Editor for iOS that allows editing single or multiple images.
                  DESC

  s.homepage      = 'https://github.com/wordpress-mobile/MediaEditor-iOS'
  s.license       = { :type => 'GPLv2', :file => 'LICENSE' }
  s.author        = { 'The WordPress Mobile Team' => 'mobile@wordpress.org' }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source        = { :git => 'https://github.com/wordpress-mobile/MediaEditor-iOS.git', :tag => s.version.to_s }
  s.module_name = "MediaEditor"
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.resources = 'Sources/**/*.{storyboard}'
  s.resource_bundles = {
    'MediaEditor' => 'Sources/**/*.{xcassets}'
  }

  s.dependency 'CropViewController', '~> 2.5.3'
end
