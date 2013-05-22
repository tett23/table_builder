# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iwashi/version'

Gem::Specification.new do |gem|
  gem.name          = "iwashi"
  gem.version       = Iwashi::VERSION
  gem.authors       = ["tett23"]
  gem.email         = ["tett23@gmail.com"]
  gem.description   = %q{テーブルだ！！}
  gem.summary       = %q{テーブルタグかきたくない}
  gem.homepage      = "http://donuthole.org"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport'
  gem.add_dependency 'erubis'
end
