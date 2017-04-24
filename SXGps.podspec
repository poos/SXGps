
Pod::Spec.new do |s|

  s.name         = "SXGpsHelper"
  s.version      = "0.0.1"
  s.summary      = "you can use the helper easy coding"

  s.homepage     = "https://github.com/poos/SXGpsHelper"

  s.license      = 'MIT'

  s.author             = { "xiaoR" => "bieshixuan@163.com" }

  s.platform     = :ios, "7.1"

  s.source       = { :git => "https://github.com/poos/SXGpsHelper.git", :tag => s.version.to_s }

  s.source_files  = "SXGps.h"

  s.requires_arc = true


s.subspec 'MainClass' do |ss|
ss.source_files = 'Example*.{h,m}'
ss.public_header_files = "*.h"
end

end
