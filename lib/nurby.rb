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

=begin

Name = "Not cURl w/ ruBY"

"bb.com/[05-] bb [u=1-4][l=1-8/u].pdf"

"eu.com/[n=01-74]" -o "[n] eu [u=1-4][l=1-4/u]#{rb:1:r}[s=1-2/l].pdf"
--output_method "r:i('u','l'); e('{R*2}'); if v('u')%2 == 0 && v('l')%4 == 0 && v('s') == 2"

-o
-w --out-method
-m --in-method

#{rb:1:r}
-1 = at beginning
 0 = current place
 1 = at end
:: = default to 1

{} = set
[] = range
#{ruby: ... }
#{ruby::func}
-x (disable "#{}")

rb = ruby alias
i  = ignore()
e  = evaluate()

[l=1-8/u*2]
{s=one,two/l*2}

\{,\[,\# can all be escaped

=end

# vars/:    (x)Var       (x)RangeVar   (x)SetVar        ( )VarFactory
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

module Nurby
  # TODO: catch ParseError and add var ID ($1)
  module VarFactory
    @@next_id = 1
    @@vars = {}
    
    def self.check_vars
      @@vars.each do |var|
        if !@@vars.include?(var.per_var_id)
          raise "Per var[#{var.per_var_id}] from var[#{var.id}] does not exist"
        end
      end
    end
    
    def self.parse(exp_parser)
      var = nil
      
      # FIXME: clone exp_parser before passing it to classes for savers
      case exp_parser[0]
      when '['
        var = RangeVar.new(exp_parser)
      when '{'
        # Is not a method?
        if exp_parser[-1] != '#'
          var = SetVar.new(exp_parser)
        end
      end
      
      if !var.nil?
        if var.id.nil? || var.id.empty?
          var.id = "$#{@@next_id}"
          @@next_id += 1
        end
        
        if @@vars.include?(@var.id)
          # TODO: raise error
          raise
        end
        
        @@vars[var.id] = var
      end
      
      return var
    end
  end
  
  class Method
    attr_accessor :eval
    attr_accessor :id
    
    # #call() # uses shikashi
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
  v = Nurby::RangeVar.new()
  v.parse(ep)
  
  puts "exp: #{exp}"
  puts "ep:\n#{ep}"
  puts "var:\n#{v}"
rescue Nurby::NurbyError => ne
  puts "#{(ne.exit_code.nil?) ? nil : ne.exit_code.code}: #{ne.message}"
  puts
  raise
end
