require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNTangemSdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNTangemSdk
                   DESC
  s.homepage     = "https://github.com/XRPL-Labs/tangem-sdk-react-native"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "N3TC4T" => "netcat.av@gmail.com  " }
  s.platforms    = { :ios => "11.0" }
  s.source       = { :git => "https://github.com/XRPL-Labs/tangem-sdk-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true
  s.platform = :ios, '11.0'
  s.ios.deployment_target = '11.0'

  s.swift_version = '5.2'

  s.dependency "React"
  s.dependency 'TangemSdk', "2.2.1"
end