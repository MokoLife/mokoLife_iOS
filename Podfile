post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end

platform :ios,'9.0'
inhibit_all_warnings!

target 'MKSmartPlug' do

pod 'Masonry'
pod 'FMDB'
pod 'Toast'
pod 'MBProgressHUD'
pod 'MJRefresh'
pod 'HJTabViewController',     :git => 'https://github.com/panghaijiao/HJTabViewController.git'
pod 'YYKit'
pod 'MLInputDodger'
pod 'FLAnimatedImage'
pod 'AFNetworking'
pod 'CircleProgressBar'
pod 'MKSocketSDK', '~> 0.0.2'
pod 'MKMqttServerSDK'

end
