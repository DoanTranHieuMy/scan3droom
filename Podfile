# Uncomment the next line to define a global platform for your project
 platform :ios, '15.2'

target 'RoomScan3D' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod "ESTabBarController-swift"
  pod 'pop', '~> 1.0'
  pod 'R.swift'

  # Pods for RoomScan3D

  target 'RoomScan3DTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RoomScan3DUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      # Required to avoid "Too many symbol files" error when uploading to the app store (https://stackoverflow.com/questions/25755240/too-many-symbol-files-after-successfully-submitting-my-apps)
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
  end
end

