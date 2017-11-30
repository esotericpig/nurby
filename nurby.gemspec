# encoding: utf-8
# frozen_string_literal: true

###
# This file is part of nurby.
# Copyright (c) 2017 Jonathan Bradley Whited (@esotericpig)
# 
# nurby is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# nurby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with nurby.  If not, see <http://www.gnu.org/licenses/>.
###

lib = File.expand_path('../lib',__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nurby/version'

Gem::Specification.new do |spec|
  spec.name                   = 'nurby'
  spec.version                = Nurby::VERSION
  spec.authors                = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email                  = ['']
  spec.license                = 'LGPL-3.0'
  
  spec.summary                = 'Not cURl w/ ruBY'
  spec.description            = <<~EOD
                                  A curl-like Ruby app that adds missing features and allows Ruby injection
                                  (not meant as a curl replacement).
                                EOD
  spec.homepage               = 'https://github.com/esotericpig/nurby'
  
  spec.files                  = Dir.glob("{bin,lib}/**/*") + %w(
                                    Gemfile
                                    Gemfile.lock
                                    LICENSE
                                    nurby.gemspec
                                    README.md
                                  )
  spec.require_paths          = ['lib']
  spec.bindir                 = 'bin'
  spec.executables            = ['nurby']
  spec.post_install_message   = 'You can now use "nurby" on the command-line.'
  
  # 2.4.0 for Hash.transform_values(...)
  # 2.3.0 for indention heredoc "<<~"
  # 1.9.0 for Hash preserving order
  spec.required_ruby_version  = '>= 2.4.0'
  
  spec.add_runtime_dependency 'shikashi','~> 0.6.0'
  
  spec.add_development_dependency 'bundler','>= 1.15'
end
