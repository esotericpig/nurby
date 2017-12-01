#!/usr/bin/env ruby

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

# TODO: break out into classes, just testing for now...

# TODO: while parsing, break out into parts in array
#       ['bb.com/',Var('[05-]'),' bb ',Var('[u=1-4]'),...]
#       this is the job of the Parser class

# vars/:    (x)Var       (x)RangeVar   (x)SetVar        (x)VarFactory
# methods/: ( )Method    ( )RubyMethod ( )MethodFactory
# :         (x)ExpParser (x)ExpStr     (x)parser_errors
#           ( )Parser    ( )Runner

require 'bundler/setup'

require 'nurby/exp_parser'
require 'nurby/exp_saver'
require 'nurby/util'
require 'nurby/version'

require 'nurby/errors/errors'
require 'nurby/errors/exit_codes'
require 'nurby/errors/parse_errors'

require 'nurby/vars/range_var'
require 'nurby/vars/set_var'
require 'nurby/vars/var'
require 'nurby/vars/var_factory'

module Nurby
  class Method
    attr_accessor :eval
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
  end
  
  class Runner
  end
  
  # optionsparser
  class Nurby
  end
end

begin
  exp = (ARGV.length > 0) ? ARGV[0] : '[l=1-4/u*2]'
  ep = Nurby::ExpParser.new(exp)
  vf = Nurby::VarFactory.new()
  v = nil
  
  while ep.next_chr?()
    pv = vf.parse!(ep)
    v = pv if !pv.nil?
  end
  
  vf.check_vars()
  
  puts "exp: #{exp}"
  puts "ep:\n#{ep}"
  puts "var:\n#{v}"
rescue Nurby::NurbyError => ne
  puts "#{(ne.exit_code.nil?) ? nil : ne.exit_code.code}: #{ne.message}"
  puts
  raise
end
