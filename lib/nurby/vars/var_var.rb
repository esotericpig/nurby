#!/usr/bin/env ruby

###
# This file is part of nurby.
# Copyright (c) 2018 Jonathan Bradley Whited (@esotericpig)
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

require 'nurby/util'

require 'nurby/errors/parse_errors'

require 'nurby/vars/var'

module Nurby
  class VarVar < Var
    BEGIN_TAG = '@[' # @see Util.escape(...)
    END_TAG = ']' # @see Util.escape(...)
    
    attr_accessor :var_id
    attr_accessor :when_to_init # 0 = before; 1 = after
    
    def initialize()
      super()
      
      @str_id_len = 7
      
      @var_id = nil
      @when_to_init = 1 # Sane default
    end
    
    def parse!(exp_parser,parsed_begin_tag=false,parsed_end_tag=false)
      exp_parser = super(exp_parser,parsed_begin_tag,parsed_end_tag)
      
      exp_parser.clear_savers('VarVar.id','VarVar.:')
      exp_parser.start_saver('VarVar.id')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when ':'
          if !exp_parser.saver?('VarVar.:')
            exp_parser.start_saver('VarVar.:',stop_savers: true)
          else
            raise ParseErrors::InvalidSymbol,"Too many ':' symbols in var var"
          end
        end
      end
      
      exp_parser.add_saver_chops()
      
      @var_id = exp_parser.saver('VarVar.id').str.chop() if exp_parser.saver?('VarVar.id')
      
      if @var_id.nil?() || @var_id.empty?()
        raise ParseErrors::NoValue,'Missing var ID in var var'
      end
      
      if exp_parser.saver?('VarVar.:')
        @when_to_init = Util.gsub_spaces(exp_parser.saver('VarVar.:').str.chop())
        raise ParseErrors::NoValue,"Missing when-to-init (':') value in var var" if @when_to_init.empty?()
        
        if !Util.int?(@when_to_init)
          raise ParseErrors::InvalidValue,
            %Q^When-to-init (':') value ("#{@when_to_init}") in var var is not an integer^
        end
        
        @when_to_init = @when_to_init.to_i
        
        if @when_to_init != 0 && @when_to_init != 1
          raise ParseErrors::InvalidValue,
            %Q^When-to-init (':') value ("#{@when_to_init}") must be 0 (before) or 1 (after)^
        end
      end
    end
    
    def to_s()
      s = super()
      s << format('var_id',@var_id)
      s << format('when?',@when_to_init)
      return s
    end
  end
end
