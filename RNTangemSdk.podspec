require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNTangemSdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNTangemSdk
                   DESC
  s.homepage     = package["repository"]["baseUrl"]
  s.license      = package["license"]
  s.author       = package["author"]
  
  s.platforms    = { :ios => "15.1" }
  s.source       = { :git => package["repository"]["url"], :tag => "#{s.version}" }
  
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  
  # some platform settings
  s.platform = :ios
  s.ios.deployment_target = '15.1'
  s.swift_version = '5.0'
  
  # deps
  s.dependency 'TangemSdk', "3.11.0"
  # new archt deps
  install_modules_dependencies(s)
  
end
