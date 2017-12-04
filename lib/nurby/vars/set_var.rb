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

require 'nurby/vars/var'

module Nurby
  class SetVar < Var
    CLOSING_TAG = '}' # @see Util.escape(...)
    OPENING_TAG = '{' # @see Util.escape(...)
    
    attr_accessor :index
    attr_accessor :values
    
    def initialize()
      super()
      clear()
    end
    
    def clear()
      super()
      
      @index = 0
      @values = []
    end
    
    def parse!(exp_parser,parsed_opening_tag=false,parsed_closing_tag=false)
      exp_parser = super(exp_parser,parsed_opening_tag ? nil : OPENING_TAG,
        parsed_closing_tag ? nil : CLOSING_TAG)
      
      exp_parser.start_saver!('v')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when ','
          @values.push(exp_parser.saver('v').str.chop())
          exp_parser.reset_saver('v')
        end
      end
      
      exp_parser.end_parsing()
      
      @values.push(exp_parser.saver('v').str.chop()) if exp_parser.saver?('v')
      
      # Don't validate any of the values; let it fly; even allow empty string '' or no values
      
      @value = @values.first()
    end
    
    def to_s()
      s = super()
      
      s << "- index:    #{@index}\n"
      s << "- vals:     [#{@values.join(', ')}]\n"
      
      return s
    end
  end
end
