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

require 'nurby/exp_parser'

# TODO: throw custom-errors; possibly catch in VarFactory so can use id or generated-id ($1)

module Nurby
  class Var
    attr_reader :id
    attr_accessor :per_var_id
    attr_accessor :times
    attr_accessor :value
    
    def initialize()
      clear()
    end
    
    def clear()
      @id = nil
      @per_var_id = nil
      @times = nil
      @value = nil
    end
    
    def parse(exp_parser,closing_chr=nil)
      has_closing_chr = (closing_chr.nil?) ? true : false
      
      exp_parser.start_str('v') # For no ID specified
      
      while exp_parser.next_chr?()
        if exp_parser.escaped?()
          next
        end
        
        case exp_parser[0]
        when '='
          if !exp_parser.has_str?('=')
            @id = exp_parser.get_str().chop() # Chop off '='
            @id = nil if @id.empty?
            
            exp_parser.start_str('=')
          end
        when '/'
          exp_parser.start_str('/') if !exp_parser.has_str?('/')
        when '*'
          exp_parser.start_str('*') if !exp_parser.has_str?('*')
        when closing_chr
          has_closing_chr = true
          break
        end
      end
      
      if !has_closing_chr
        raise "Missing closing char: #{closing_chr}"
      end
      
      if exp_parser.has_str?('/')
        @per_var_id = exp_parser.get_str('/').chop()
        raise "No per var ID specified for '/'" if @per_var_id.nil? || @per_var_id.empty?
      end
      
      if exp_parser.has_str?('*')
        @times = exp_parser.get_str('*').chop()
        raise "No times number specified for '*'" if @times.nil? || @times.empty?
        @times = @times.to_i
        raise "Times number for '*' is less than one: #{@times}" if @times < 1
      end
      
      if exp_parser.has_str?('=')
        @value = exp_parser.get_str('=').chop()
      else
        @value = exp_parser.get_str('v').chop()
      end
      
      raise "No value specified for var" if @value.nil? || @value.empty?
      
      return ExpParser.new(@value)
    end
  end
end
