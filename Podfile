use_frameworks!
inhibit_all_warnings!
install! 'cocoapods',
:disable_input_output_paths => true,
:generate_multiple_pod_projects => true
project 'COVID-19 Track.xcodeproj'
platform :ios, '11.0'

target 'COVID-19 Track' do
  
  use_frameworks!
  
  pod 'RxBluetoothKit'
  pod 'RxCocoa'
#  pod 'Alamofire'

  target 'COVID-19 TrackTests' do
    inherit! :search_paths
    
    pod 'RxTest'
  end

end
