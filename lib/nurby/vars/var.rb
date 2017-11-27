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

require 'nurby/errors/parse_errors'

require 'nurby/exp_parser'

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
    
    def parse(exp_parser,opening_tag=nil,closing_tag=nil)
      closing_tag_begin = (closing_tag.nil?) ? nil : closing_tag[0]
      has_closing_tag = closing_tag.nil?
      has_opening_tag = opening_tag.nil?
      
      has_opening_tag = exp_parser.find!(opening_tag) if !has_opening_tag
      raise NoOpeningTag,%Q(Missing opening tag "#{opening_tag}") if !has_opening_tag
      
      exp_parser.start_saver('id') # For possible ID
      exp_parser.start_saver('v') # Value for no '=' specified
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        c = exp_parser[0]
        
        # Don't put this in the switch-statement as closing_tag_begin might be the same as another char
        if c == closing_tag_begin
          if exp_parser.look_ahead?(closing_tag)
            has_closing_tag = true
            break
          end
        end
        
        case c
        when '='
          if !exp_parser.saver?('=')
            @id = exp_parser.saver('id').str.chop() # Chop off '='
            @id = nil if @id.empty?
            
            exp_parser.start_saver('=',true,false)
          end
        when '/'
          exp_parser.start_saver('/',true)
        when '*'
          exp_parser.start_saver('*',true)
        end
      end
      
      raise NoClosingTag,%Q(Missing closing tag "#{closing_tag}") if !has_closing_tag
      
      if exp_parser.saver?('/')
        @per_var_id = exp_parser.saver('/').str.chop()
        raise NoVarID,"Missing per var ID for '/'" if @per_var_id.empty?
      end
      
      if exp_parser.saver?('*')
        @times = exp_parser.saver('*').str.chop()
        raise NoNumber,"Missing number of times for '*'" if @times.empty?
        @times = @times.to_i
        raise InvalidNumber,"Number of times for '*' is less than one [#{@times}]" if @times < 1
      end
      
      if exp_parser.saver?('=')
        @value = exp_parser.saver('=').str.chop()
      else
        @value = exp_parser.saver('v').str.chop()
      end
      
      raise NoValue,"Missing value" if @value.empty?
      
      return ExpParser.new(@value)
    end
  end
end
