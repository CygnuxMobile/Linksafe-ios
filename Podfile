platform :ios, '15.0'

# Enable modular headers globally
use_modular_headers!

target 'LinkSafe' do
  pod 'BEMCheckBox'
  # pod 'Switch'
  # pod 'HSDatePickerViewController', '~> 1.0'
  pod 'SDWebImage', '~>3.8'
  
  # Firebase dependencies with modular headers
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'

  pod 'EMCCountryPickerController'
  # pod 'TestFairy'
end

post_install do |installer|
  targets = installer.pods_project.targets
  if installer.respond_to?(:generated_projects)
    installer.generated_projects.each do |project|
      targets += project.targets
    end
  end
  targets.uniq.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
    end
  end
end

