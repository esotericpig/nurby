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

require 'nurby/vars/var'

# TODO: implement

module Nurby
  class VarVar < Var
    BEGIN_TAG = '#[' # @see Util.escape(...)
    END_TAG = ']' # @see Util.escape(...)
    
    attr_accessor :index
    attr_accessor :value
    
    def initialize()
      super()
      clear()
    end
    
    def clear()
      super()
      
      @index = 0
      @value = nil
    end
    
    def parse!(exp_parser,parsed_begin_tag=false,parsed_end_tag=false)
      exp_parser = super(exp_parser,parsed_begin_tag ? nil : BEGIN_TAG,parsed_end_tag ? nil : END_TAG)
      
      exp_parser.clear_savers('v')
      exp_parser.start_saver('v')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
      end
      
      exp_parser.add_saver_chops() # Tags will always be chopped off in super()
      @value = exp_parser.saver('v').str.chop() if exp_parser.saver?('v')
    end
    
    def to_s()
      s = super()
      s << format('index',@index)
      s << format('val',@value)
      return s
    end
  end
end
