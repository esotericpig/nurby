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
require 'nurby/util'

require 'nurby/errors/parse_errors'

require 'nurby/vars/var'

module Nurby
  class LoopVar < Var
    attr_accessor :per_var_id
    attr_accessor :time
    attr_accessor :times
    
    def initialize()
      super()
      
      @str_id_len = 8
      
      @per_var_id = nil
      @time = 0
      @times = nil
    end
    
    def parse!(exp_parser,parsed_begin_tag=false,parsed_end_tag=false)
      exp_parser = super(exp_parser,parsed_begin_tag,parsed_end_tag)
      
      exp_parser.clear_savers('LoopVar.val','LoopVar./','LoopVar.*')
      exp_parser.start_saver('LoopVar.val',escape: false)
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when '/'
          if !exp_parser.saver?('LoopVar./')
            exp_parser.start_saver('LoopVar./',stop_savers: true)
          else
            raise ParseErrors::InvalidSymbol,"Too many '/' symbols in var"
          end
        when '*'
          if !exp_parser.saver?('LoopVar.*')
            exp_parser.start_saver('LoopVar.*',stop_savers: true)
          else
            raise ParseErrors::InvalidSymbol,"Too many '*' symbols in var"
          end
        end
      end
      
      exp_parser.add_saver_chops() # Tags will always be chopped off in super()
      
      if exp_parser.saver?('LoopVar./')
        @per_var_id = exp_parser.saver('LoopVar./').str.chop()
        raise ParseErrors::NoVarID,"Missing per var ('/') ID in var" if @per_var_id.empty?()
      end
      
      if exp_parser.saver?('LoopVar.*')
        @times = Util.gsub_spaces(exp_parser.saver('LoopVar.*').str.chop())
        raise ParseErrors::NoValue,"Missing number of times ('*') value in var" if @times.empty?()
        
        if !Util.int?(@times)
          raise ParseErrors::InvalidValue,
            %Q^Number of times ('*') value ("#{@times}") is not an integer ("+/-0-9")^
        end
        
        @times = @times.to_i()
        raise ParseErrors::InvalidValue,
          %Q^Number of times ('*') value ("#{@times}") is less than one in var^ if @times < 1
      end
      
      @value = exp_parser.saver('LoopVar.val').str.chop()
      raise ParseErrors::NoValue,"Missing value in var" if @value.empty?()
      
      return ExpParser.new(@value)
    end
    
    def to_s()
      s = super()
      s << format('per_var',@per_var_id)
      s << format('time',@time)
      s << format('times',@times)
      return s
    end
  end
end
