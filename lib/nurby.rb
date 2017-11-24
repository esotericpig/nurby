#!/usr/bin/env ruby

###
# This file is part of nurby.
# Copyright (c) 2017 Jonathan Bradley Whited (@esotericpig)
# 
# nurby is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# nurby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with nurby.  If not, see <http://www.gnu.org/licenses/>.
###

# TODO: break out into classes, just testing for now...

=begin

Name = "Not cURl w/ ruBY"

"bb.com/[05-] bb [u=1-4][l=1-8/u].pdf"

"eu.com/[n=01-74]" -o "[n] eu [u=1-4][l=1-4/u]#{rb::r}[s=1-2/l].pdf"
--output_method "r:f(); i('u','l'); e('{R*2}'); if v('u')%2 == 0 && v('l')%4 == 0 && v('s') == 2"

{} = set
[] = range
#{ruby: ... }
#{ruby::func}
-x (disable "#{}")

rb = ruby alias
i  = ignore()
e  = evaluate()
f  = finish() # so can do before or after

[l=1-8/u*2]
{s=one,two/l*2}

\{,\[,\# can all be escaped

=end

module Nurby
  class Var
    attr_accessor :id
    attr_accessor :per_var_id
    attr_accessor :times
    attr_accessor :value
    
    def parse(exp_parser,closing_tag=nil)
      # TODO: clear variables?
      
      closing_tag_end = closing_tag[-1]
      has_closing_tag = false
      
      exp_parser.start_str('v') # For no ID specified
      
      while exp_parser.next_chr?()
        if exp_parser.has_escape?()
          next
        end
        
        case exp_parser[0]
        when '='
          if !exp_parser.has_str?('=')
            @id = exp_parser.get_str().chop() # Chop off '='
            @id = nil if @id.empty?
            
            exp_parser.stop_strs()
            exp_parser.start_str('=')
          end
        when '/'
          if !exp_parser.has_str?('/')
            exp_parser.stop_strs()
            exp_parser.start_str('/')
          end
        when '*'
          if !exp_parser.has_str?('*')
            exp_parser.stop_strs()
            exp_parser.start_str('*')
          end
        when closing_tag_end
          s = exp_parser.get_str()
          s = s[s.length - closing_tag.length..-1]
          
          if s == closing_tag
            has_closing_tag = true
            break
          end
        end
      end
      
      if !has_closing_tag
        # TODO: raise good error
        raise "Missing closing tag"
      end
      
      if exp_parser.has_str?('/')
        @per_var_id = exp_parser.get_str('/').chop()
        # TODO: raise good error
        raise "No per var" if @per_var_id.nil? || @per_var_id.empty?
      end
      if exp_parser.has_str?('*')
        @times = exp_parser.get_str('*').chop()
        # TODO: raise good error
        raise "No times" if @times.nil? || @times.empty?
        # TODO: catch and raise if not int
        @times = @times.to_i
      end
      
      if exp_parser.has_str?('=')
        @value = exp_parser.get_str('=').chop()
      else
        @value = exp_parser.get_str('v').chop()
      end
      if @value.nil? || @value.empty?
        # TODO: raise good error
        raise "No value"
      end
      
      return ExpParser.new(@value)
    end
  end
  
  module VarFactory
    @@next_id = 1
    @@vars = {}
    
    def self.check_vars
      @@vars.each do |var|
        if !@@vars.include?(var.per_var_id)
          raise "PerVar[#{var.per_var_id}] from Var[#{var.id}] does not exist"
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
  
  class ExpStr
    attr_accessor :id
    attr_accessor :is_stop
    attr_accessor :str
    
    def initialize(id)
      @id = id
      
      reset()
    end
    
    def concat(str)
      return @is_stop ? @str : @str.concat(str)
    end
    
    def reset()
      @is_stop = false
      @str = ''
    end
    
    def stop()
      @is_stop = true
    end
    
    def stop?()
      return @is_stop
    end
  end
  
  class ExpParser
    attr_accessor :exp
    attr_accessor :exp_str
    attr_accessor :exp_strs
    attr_accessor :has_escape
    attr_accessor :index
    
    def initialize(exp)
      @exp = exp
      @exp_str = ExpStr.new(nil)
      @exp_strs = {}
      @has_escape = false
      @index = 0
    end
    
    def [](relative_index)
      return @exp_str.str[@exp_str.str.length - 1 + relative_index]
    end
    
    def next_chr?()
      if @index >= @exp.length
        return false
      end
      if @exp[@index] == '\\'
        @has_escape = !@has_escape
      end
      
      c = @exp[@index]
      
      # FIXME: need to only concat if !has_escape, also fix Var loop
      @exp_str.concat(c)
      
      @exp_strs.each_value do |exp_str|
        exp_str.concat(c)
      end
      
      @index += 1
      
      return true
    end
    
    def start_str(id)
      exp_str = @exp_strs[id]
      
      if exp_str.nil?
        exp_str = ExpStr.new(id)
        @exp_strs[id] = exp_str
      else
        exp_str.reset()
      end
      
      return exp_str
    end
    
    def stop_strs()
      @exp_strs.each_value do |exp_str|
        exp_str.stop()
      end
    end
    
    def get_str(id=nil)
      if id.nil?
        return @exp_str.str
      end
      
      exp_str = @exp_strs[id]
      
      return exp_str.nil? ? nil : exp_str.str
    end
    
    def has_escape?()
      return @has_escape
    end
    
    def has_str?(id)
      return @exp_strs.include?(id)
    end
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
