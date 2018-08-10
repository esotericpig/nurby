#!/usr/bin/env ruby

###
# This file is part of nurby.
# Copyright (c) 2017-2018 Jonathan Bradley Whited (@esotericpig)
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

require 'bundler/setup'

require 'nurby/exp_parser'
require 'nurby/exp_saver'
require 'nurby/scrap'
require 'nurby/util'
require 'nurby/version'

require 'nurby/errors/errors'
require 'nurby/errors/exit_codes'
require 'nurby/errors/parse_errors'
require 'nurby/errors/var_errors'

require 'nurby/vars/range_var'
require 'nurby/vars/set_var'
require 'nurby/vars/var'
require 'nurby/vars/var_factory'
require 'nurby/vars/var_var'

module Nurby
  class Method
    attr_accessor :eval_str
    attr_accessor :id
    
    # #call() # uses some sandbox
  end
  
  module MethodFactory
    @@methods = {}
    @@next_id = 1
    
    # Method #parse(...)
  end
  
  class RubyMethod < Method
  end
  
  class Parser
    attr_accessor :in_parts
    attr_accessor :out_parts
    
    def next_url()
      # inc all stuff and return nil if done, else string of URL
    end
  end
  
  class Runner
  end
  
  # optionsparser
  class Nurby
  end
end

begin
  exp = (ARGV.length > 0) ? ARGV[0] : 'google.com/[u=1-4*2]{l=2,5,11/u}/end?lesson=@[l]'
  ep = Nurby::ExpParser.new(exp)
  url = []
  vf = Nurby::VarFactory.new()
  v = nil
  
  puts "exp: #{exp}"
  puts "ep:\n#{ep}"
  
  ep.start_saver('url')
  
  while ep.next_chr?()
    v = vf.parse!(ep)
    
    if !v.nil?()
      puts "var[#{v.id}]:\n#{v}"
      s = v.chomp_tag(ep.saver('url').str.strip())
      url << s unless s.empty?()
      url << "<#{v.id}>"
      ep.reset_saver('url')
    end
  end
  
  vf.check_vars()
  url << ep.saver('url').str unless ep.saver('url').str.strip().empty?()
  puts "URL parts: #{url}"
rescue Nurby::NurbyError => ne
  puts "#{(ne.exit_code.nil?) ? nil : ne.exit_code.code}: #{ne.message}"
  puts
  raise
end
