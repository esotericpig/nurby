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

# vars/:    (x)Var       ( )RangeVar   ( )SetVar        ( )VarFactory
# methods/: ( )Method    ( )RubyMethod ( )MethodFactory
# :         (x)ExpParser (x)ExpStr     ( )parser_errors
#           ( )Parser    ( )Runner

require 'bundler/setup'

require 'nurby/exp_parser'
require 'nurby/exp_str'

require 'nurby/vars/var'

module Nurby
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
  
  # can be a string or int, so need to test if digit
  # if less than, must decrement (step)
  # (x.ord +/- 1).chr for entire string (only a-z, A-Z; else carry/borrow)
  class RangeVar < Var
    attr_accessor :begin_value
    attr_accessor :end_value
    attr_accessor :step
    attr_accessor :zeros
    
    def parse(exp_parser)
      exp_parser = super(exp_parser,']')
      
      # only allow a-z,A-Z,0-9
      
      while exp_parser.next_chr?()
      end
    end
  end
  
  class SetVar < Var
    attr_accessor :index
    attr_accessor :values
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

v = Nurby::Var.new()
v.parse(Nurby::ExpParser.new('l=1-4/u*2]'),']')

puts v.id
puts v.value
puts v.per_var_id
puts v.times

=begin
$anonymous_var_count = 0
VARS = []

class Var
end

class RangeVar
  attr_accessor :id
  attr_accessor :begin_value
  attr_accessor :end_value
  attr_accessor :per_var
  attr_accessor :value
  attr_accessor :zeros
end

def parse_range(range,index)
  range.gsub!(/[[:space:]]+/,'')
  id = nil
  
  if range.include?('=')
    range = range.split('=')
    id = range[0]
    
    if VARS.include?(id)
      raise "Var ID[#{range[0]}] already exists"
    end
    
    range = range[1]
  else
    $anonymous_var_count += 1
    id = "$#{$anonymous_var_count}"
  end
  
  VARS.push(id) # need var class
  
  return "%s"
end

def parse(nurby_url)
  has_prev_slash = false
  parsed_url = ''
  i = -1
  
  while (i += 1) < nurby_url.length
    c = nurby_url[i]
    
    if c == '\\'
      has_prev_slash = !has_prev_slash
    elsif !has_prev_slash
      if c == '['
        i1 = i
        j = -1
        
        while (i1 += 1) < nurby_url.length
          if nurby_url[i1] == ']'
            j = i1
            break
          end
        end
        
        if j == -1
          raise "'[' with no closing ']' @ index[#{i}]"
        end
        
        c = parse_range(nurby_url[i + 1..j - 1],i)
        i = i1
      end
    end
    
    parsed_url += c
  end
  
  puts parsed_url
end

parse(ARGV[0])
=end
