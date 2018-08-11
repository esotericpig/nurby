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

require 'nurby/errors/parse_errors'

module Nurby
  class Var < Scrap
    attr_accessor :id
    attr_accessor :value
    
    def initialize()
      super()
      
      @id = nil
      @value = nil
    end
    
    def parse!(exp_parser,parsed_begin_tag=false,parsed_end_tag=false)
      begin_tag = parsed_begin_tag ? nil : self.class::BEGIN_TAG
      end_tag = parsed_end_tag ? nil : self.class::END_TAG
      
      has_begin_tag = begin_tag.nil?()
      has_end_tag = end_tag.nil?()
      
      has_begin_tag = exp_parser.find!(begin_tag) if !has_begin_tag
      raise ParseErrors::NoOpeningTag,%Q^Missing opening tag ("#{begin_tag}") in var^ if !has_begin_tag
      
      exp_parser.clear_savers('Var.id','Var.=','Var.val')
      exp_parser.start_saver('Var.id')
      exp_parser.start_saver('Var.val',escape: false) # Value for no '=' specified
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        if !has_end_tag && exp_parser.look_ahead?(end_tag,accept_nil: false)
          has_end_tag = true
          break
        end
        
        case exp_parser[0]
        when '='
          if !exp_parser.saver?('Var.=')
            @id = exp_parser.saver('Var.id').str.chop() # Chop off '='
            @id = nil if @id.empty?
            
            exp_parser.start_saver('Var.=',stop_savers: true,escape: false)
          else
            raise ParseErrors::InvalidSymbol,"Too many '=' symbols in var"
          end
        end
      end
      
      exp_parser.add_saver_chops() if end_tag.nil?()
      
      raise ParseErrors::NoClosingTag,%Q^Missing closing tag ("#{end_tag}") in var^ if !has_end_tag
      
      if exp_parser.saver?('Var.=')
        @value = exp_parser.saver('Var.=')
      else
        @value = exp_parser.saver('Var.val')
      end
      @value = @value.str.chop()
      
      raise ParseErrors::NoValue,"Missing value in var" if @value.empty?()
      
      return ExpParser.new(@value)
    end
    
    def to_s()
      s = super()
      s << format('id',@id)
      s << format('val',@value)
      return s
    end
  end
end
