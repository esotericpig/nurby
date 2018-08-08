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

require 'nurby/exp_parser'
require 'nurby/scrap'
require 'nurby/util'

require 'nurby/errors/parse_errors'

module Nurby
  class Var < Scrap
    attr_accessor :id
    attr_accessor :per_var_id
    attr_accessor :time
    attr_accessor :times
    attr_accessor :value
    
    def initialize()
      super()
      clear()
      
      @str_id_len = 8
    end
    
    def clear()
      @id = nil
      @per_var_id = nil
      @time = 0
      @times = nil
      @value = nil
    end
    
    def parse!(exp_parser,begin_tag=nil,end_tag=nil)
      has_begin_tag = begin_tag.nil?()
      has_end_tag = end_tag.nil?()
      
      has_begin_tag = exp_parser.find!(begin_tag) if !has_begin_tag
      raise ParseErrors::NoOpeningTag,%Q^Missing opening tag ("#{begin_tag}") in var^ if !has_begin_tag
      
      exp_parser.clear_savers('id','v','=','/','*')
      exp_parser.start_saver('id')
      exp_parser.start_saver('v',escape: false) # Value for no '=' specified
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        if exp_parser.look_ahead?(end_tag,accept_nil: false)
          has_end_tag = true
          break
        end
        
        case exp_parser[0]
        when '='
          if !exp_parser.saver?('=')
            @id = exp_parser.saver('id').str.chop() # Chop off '='
            @id = nil if @id.empty?
            
            exp_parser.start_saver('=',stop_savers: true,escape: false)
          else
            raise ParseErrors::InvalidSymbol,"Too many '=' symbols in var"
          end
        when '/'
          if !exp_parser.saver?('/')
            exp_parser.start_saver('/',stop_savers: true)
          else
            raise ParseErrors::InvalidSymbol,"Too many '/' symbols in var"
          end
        when '*'
          if !exp_parser.saver?('*')
            exp_parser.start_saver('*',stop_savers: true)
          else
            raise ParseErrors::InvalidSymbol,"Too many '*' symbols in var"
          end
        end
      end
      
      exp_parser.add_saver_chops() if end_tag.nil?()
      
      raise ParseErrors::NoClosingTag,%Q^Missing closing tag ("#{end_tag}") in var^ if !has_end_tag
      
      if exp_parser.saver?('/')
        @per_var_id = exp_parser.saver('/').str.chop()
        raise ParseErrors::NoVarID,"Missing per var ('/') ID in var" if @per_var_id.empty?
      end
      
      if exp_parser.saver?('*')
        @times = Util.gsub_spaces(exp_parser.saver('*').str.chop())
        raise ParseErrors::NoValue,"Missing number of times ('*') value in var" if @times.empty?
        
        if !Util.int?(@times)
          raise ParseErrors::InvalidValue,
            %Q^Number of times ('*') value ("#{@times}") is not an integer ("+/-0-9")^
        end
        
        @times = @times.to_i
        raise ParseErrors::InvalidValue,
          %Q^Number of times ('*') value ("#{@times}") is less than one in var^ if @times < 1
      end
      
      if exp_parser.saver?('=')
        @value = exp_parser.saver('=').str.chop()
      else
        @value = exp_parser.saver('v').str.chop()
      end
      
      raise ParseErrors::NoValue,"Missing value in var" if @value.empty?
      
      return ExpParser.new(@value)
    end
    
    def to_s()
      s = super()
      s << format('id',@id)
      s << format('per_var',@per_var_id)
      s << format('time',@time)
      s << format('times',@times)
      s << format('val',@value)
      return s
    end
  end
end
