
Pod::Spec.new do |s|

  s.name         = "StateTransition"
  s.version      = "1.1.0"
  s.summary      = "A swift state machine supporting; states, transitions, actions and transition handling"
  s.homepage     = "https://github.com/nicholascross/StateTransition"
  s.license      = 'MIT'
  s.author       = "Nicholas Cross"

  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/nicholascross/StateTransition.git", :tag => "1.1.0" }
  s.source_files  = 'StateTransition/*.swift'
  s.requires_arc = true
  s.swift_version = "4.2"

end