
Pod::Spec.new do |s|

  s.name         = "SXGps"
  s.version      = "0.1.0"
  s.summary      = "Easy use GPS get address"

  s.homepage     = "https://github.com/poos/SXGpsHelper"

  s.license      = 'MIT'

  s.author             = { "xiaoR" => "bieshixuan@163.com" }

  s.platform     = :ios, "7.1"

  s.source       = { :git => "https://github.com/poos/SXGpsHelper.git", :tag => s.version.to_s }

  s.source_files  = "SXGps/SXGps.{h,m}"

  s.requires_arc = true

end
