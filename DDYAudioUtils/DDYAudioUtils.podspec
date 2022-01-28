Pod::Spec.new do |s|
  # 名称，pod search 搜索的关键词,注意这里一定要和.podspec的名称一样,否则报错
  s.name         = "DDYAudioUtils"
  # 版本号/库原代码的版本
  s.version      = "2.1.2"
  # 简介
  s.summary      = "天橙语音工具[录制、转码MP3]"
  # 项目主页地址
  s.homepage     = "https://staging.intviu.cn"
  # 许可证/所采用的授权版本
  s.license      = 'MIT'
  # 库的作者
  s.author       = { "DDYAudioUtils" => "doudianyu@orangelab.cn" }
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

  s.subspec 'Core' do |ss|
    ss.source_files = 'DDYAudioUtils/core/*{h,m}'
    ss.ios.frameworks = 'UIKit', 'AVFoundation'
  end

  s.subspec 'Mp3' do |ss|
    ss.vendored_frameworks = 'DDYAudioUtils/mp3/lame.framework'
    ss.source_files = 'DDYAudioUtils/mp3/*{h,m}'
  end

  s.subspec 'Amr' do |ss|
    ss.vendored_libraries = 'DDYAudioUtils/amr/lib/*.a'
    ss.source_files = 'DDYAudioUtils/amr/*{h,m,mm}', 'DDYAudioUtils/amr/include/*/*.h', 'DDYAudioUtils/amr/amrwapper/*{h,mm}'
  end

end
