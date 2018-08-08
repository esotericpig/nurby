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

require 'nurby/exp_parser'
require 'nurby/scrap'
require 'nurby/util'

require 'nurby/errors/parse_errors'

# TODO: implement

module Nurby
  class Method
    attr_accessor :code
    attr_accessor :id
    attr_accessor :lang
    attr_accessor :pos
    
    def initialize()
      clear()
    end
    
    def clear()
      @code = nil
      @id = nil
      @lang = nil
      @pos = nil
    end
    
    def parse!(exp_parser,begin_tag=nil,end_tag=nil)
    end
    
    # TODO: put in MethodFactory
    def parse_method!(exp_parser)
      exp_parser.clear_savers('id',':')
      exp_parser.start_saver('id')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when ':'
          if !exp_parser.saver?(':')
            @id = exp_parser.saver('id').str.chop() # Chop off ':'
            @id = nil if @id.empty?()
            
            exp_parser.start_saver(':',stop_savers: true,escape: false)
          end
        end
      end
      
      exp_parser.add_saver_chops()
      
      @id = exp_parser.saver('id').str.chop()
      raise ParseErrors::NoMethodID,'Missing method ID' if @id.empty?()
      
      @code = nil
      @code = exp_parser.saver(':').str.chop() if exp_saver.saver?(':')
      raise ParseErrors::NoValue,'Missing method code' if @code.nil?() || @code.strip().empty?()
      
      return exp_parser
    end
    
    def to_s()
      s = super()
      return s
    end
  end
end
