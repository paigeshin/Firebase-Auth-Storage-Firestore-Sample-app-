# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FungiFinder' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FungiFinder

# add the Firebase pod for Google Analytics
pod 'Firebase/Analytics'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Firestore'

# Optionally, include the Swift extensions if you're using Swift.
pod 'FirebaseFirestoreSwift'

# add pods for any other desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.2'
    end
  end
end
