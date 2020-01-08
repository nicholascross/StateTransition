
Pod::Spec.new do |s|

  s.name         = "StateTransition"
  s.version      = "5.0.1"
  s.summary      = "A swift state machine supporting; states, transitions, actions and transition handling"
  s.homepage     = "https://github.com/nicholascross/StateTransition"
  s.license      = 'MIT'
  s.author       = "Nicholas Cross"

  s.osx.deployment_target = "10.15"
  s.ios.deployment_target = "13.0"
  s.tvos.deployment_target = "13.0"
  s.watchos.deployment_target = "6.0"

  s.source       = { :git => "https://github.com/nicholascross/StateTransition.git", :tag => "5.0.1" }
  s.source_files  = 'StateTransition/*.swift'
  s.requires_arc = true
  s.swift_version = "5.1"

end
