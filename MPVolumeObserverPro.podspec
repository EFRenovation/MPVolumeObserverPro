Pod::Spec.new do |s|
  s.name             = 'MPVolumeObserverPro'
  s.version          = '0.1.2'
  s.summary          = 'MPVolumeObserverPro project.'

  s.description      = <<-DESC
Use MPVolumeObserverPro in pod.
                       DESC

  s.homepage         = 'https://github.com/EFRenovation/MPVolumeObserverPro'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EyreFree' => 'eyrefree@eyrefree.org' }
  s.source           = { :git => 'https://github.com/EFRenovation/MPVolumeObserverPro.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/EyreFree777'

  s.ios.deployment_target = '11.0'

  s.requires_arc = true
  s.source_files = 'MPVolumePro/Class/*.{h,m}'
  
  s.frameworks = 'UIKit', 'AudioToolbox', 'MediaPlayer', 'AVFoundation'
end