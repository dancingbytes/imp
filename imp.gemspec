# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "imp/version"

Gem::Specification.new do |s|

  s.name          = 'imp'
  s.version       = Imp::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Tyralion']
  s.email         = ['info@dancingbytes.ru']
  s.homepage      = 'https://github.com/dancingbytes/imp'
  s.summary       = 'Small daemons` manager for ruby'
  s.description   = 'Small daemons` manager for ruby'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ['README.md']
  s.require_paths = ['lib']

  s.licenses      = ['BSD']

end