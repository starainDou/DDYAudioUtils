Pod::Spec.new do |s|
  # 名称，pod search 搜索的关键词,注意这里一定要和.podspec的名称一样,否则报错
  s.name         = "DDYSoundTouch"
  # 版本号/库原代码的版本
  s.version      = "1.0.2"
  # 简介
  s.summary      = "天橙语音工具[录制、转码MP3]"
  # 项目主页地址
  s.homepage     = "https://staging.intviu.cn"
  # 许可证/所采用的授权版本
  s.license      = 'MIT'
  # 库的作者
  s.author       = { "DDYSoundTouch" => "doudianyu@orangelab.cn" }
  # 项目的地址
  s.source       = { :git => "", :tag => s.version }
  # 支持的平台及版本
  s.platform     = :ios, "10.0"

  # 使用了第三方静态库
  # s.ios.vendored_library = ''
  #s.ios.vendored_libraries = ''
  

  # “弱引用”所需的framework，多个用逗号隔开
  # s.ios.weak_frameworks = 'UserNotifications'

  # 所需的library，多个用逗号隔开
  # s.ios.libraries = 'z','sqlite3.0','c++','resolv'

  # 是否使用ARC，如果指定具体文件，则具体的问题使用ARC
  s.requires_arc = true

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
  s.user_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.libraries = "c++"
  s.source_files = 'DDYSoundTouch/*{h,mm,cpp}'
  # s.ios.frameworks = 'UIKit', 'AVFoundation'
  s.xcconfig = {
   'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
   'CLANG_CXX_LIBRARY' => 'libc++'
  }

end
