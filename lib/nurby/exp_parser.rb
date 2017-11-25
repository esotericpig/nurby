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

require 'nurby/exp_str'

###
# By design, there is no stop_str() for @exp_str.
###
module Nurby
  class ExpParser
    attr_reader :escape
    attr_reader :escape_chr
    attr_reader :escapes
    attr_reader :exp
    attr_reader :exp_str
    attr_reader :exp_strs
    attr_reader :index
    attr_reader :running_exp_strs # Unnecessary, but maybe makes it faster in the loop?
    
    def initialize(exp,escape_chr='\\')
      @escape = false
      @escape_chr = escape_chr
      @escapes = []
      @exp = exp
      @exp_str = ExpStr.new(nil)
      @exp_strs = {}
      @index = 0
      @running_exp_strs = {}
    end
    
    def [](relative_index)
      # Don't use @index because @exp_str doesn't include @escape_chr and can be reset
      return @exp_str.str[@exp_str.str.length - 1 + relative_index]
    end
    
    def next_chr?()
      if @index >= @exp.length
        return false
      end
      
      @escape = (@exp[@index] == @escape_chr) ? !@escape : false
      @escapes.push(@escape)
      
      # If "\\", then only add '\'; if "\[", then only add '['
      if !@escape
        c = @exp[@index]
        
        @exp_str.concat(c)
        
        @running_exp_strs.each_value do |exp_str|
          exp_str.concat(c)
        end
      end
      
      @index += 1
      
      return true
    end
    
    def reset_all_strs()
      @exp_str.reset()
      reset_strs()
    end
    
    def reset_str(id=nil,stop_strs=true)
      if id.nil?
        self.stop_strs() if stop_strs
        
        return @exp_str.reset()
      end
      
      return start_str(id,stop_strs)
    end
    
    def reset_strs()
      @exp_strs.each do |id,exp_str|
        exp_str.reset()
        @running_exp_strs[id] = exp_str
      end
    end
    
    def start_str(id,stop_strs=true)
      self.stop_strs() if stop_strs
      
      exp_str = @exp_strs[id]
      
      if exp_str.nil?
        exp_str = ExpStr.new(id)
        @exp_strs[id] = exp_str
      else
        exp_str.reset()
      end
      
      @running_exp_strs[id] = exp_str
      
      return exp_str
    end
    
    def stop_strs()
      @exp_strs.each_value do |exp_str|
        exp_str.stop()
      end
      
      @running_exp_strs.clear()
    end
    
    def get_str(id=nil)
      if id.nil?
        return @exp_str.str
      end
      
      exp_str = @exp_strs[id]
      
      return (exp_str.nil?) ? nil : exp_str.str
    end
    
    def escaped?(relative_index=-1)
      # Don't use @index because @escapes could be modified
      return @escapes[@escapes.length - 1 + relative_index]
    end
    
    def has_str?(id)
      return @exp_strs.include?(id)
    end
  end
end
