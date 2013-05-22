# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'microtimestamps/version'

Gem::Specification.new do |s|
  s.name        = 'microtimestamps'
  s.version     = '0.0.1'
  s.date        = '2013-05-21'
  s.summary     = "Microsecond Timestamps for ActiveRecord"
  s.description = "Replaces ActiveRecord's magic timestamp attributes with microseconds since epoch"
  s.authors     = ["Will Mitchell"]
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency "activesupport" , "~> 3.2.13"
  s.add_dependency "activerecord" , "~> 3.2.13"
  s.add_dependency "rails" , "~> 3.2.13"
end