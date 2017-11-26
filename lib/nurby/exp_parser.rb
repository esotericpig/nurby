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

require 'nurby/exp_saver'

###
# By design, there is no stop_saver() for @exp_saver.
###
module Nurby
  class ExpParser
    attr_reader :escapables
    attr_reader :escape_chr
    attr_reader :exp
    attr_reader :exp_saver
    attr_reader :exp_savers
    attr_reader :index
    attr_reader :is_escaped
    attr_reader :running_exp_savers
    
    def initialize(exp,escape_chr='\\')
      @escapables = []
      @escape_chr = escape_chr
      @exp = exp
      @exp_saver = ExpSaver.new(nil)
      @exp_savers = {}
      @index = 0
      @is_escaped = false
      @running_exp_savers = {} # Unnecessary, but maybe makes it faster in the loop?
    end
    
    def [](relative_index)
      # Don't use @index because @exp_saver doesn't include @escape_chr and can be reset
      return @exp_saver.str[@exp_saver.str.length - 1 + relative_index]
    end
    
    def next_chr?()
      if @index >= @exp.length
        return false
      end
      
      @is_escaped = (@exp[@index] == @escape_chr) ? !@is_escaped : false
      @escapables.push(@is_escaped)
      
      # If "\\", then only add '\'; if "\[", then only add '['; etc.
      if !@is_escaped
        c = @exp[@index]
        
        @exp_saver.save(c)
        
        @running_exp_savers.each_value do |exp_saver|
          exp_saver.save(c)
        end
      end
      
      @index += 1
      
      return true
    end
    
    def reset_all_savers()
      @exp_saver.reset()
      reset_savers()
    end
    
    def reset_saver(id=nil,stop_savers=true)
      if id.nil?
        self.stop_savers() if stop_savers
        
        return @exp_saver.reset()
      end
      
      return start_saver(id,stop_savers)
    end
    
    def reset_savers()
      @exp_savers.each do |id,exp_saver|
        exp_saver.reset()
        @running_exp_savers[id] = exp_saver
      end
    end
    
    def start_saver(id,stop_savers=true)
      self.stop_savers() if stop_savers
      
      exp_saver = @exp_savers[id]
      
      if exp_saver.nil?
        exp_saver = ExpSaver.new(id)
        @exp_savers[id] = exp_saver
      else
        exp_saver.reset()
      end
      
      @running_exp_savers[id] = exp_saver
      
      return exp_saver
    end
    
    def stop_savers()
      @exp_savers.each_value do |exp_saver|
        exp_saver.stop()
      end
      
      @running_exp_savers.clear()
    end
    
    def get_saver(id=nil)
      if id.nil?
        return @exp_saver
      end
      
      exp_saver = @exp_savers[id]
      
      return (exp_saver.nil?) ? nil : exp_saver
    end
    
    def escaped?(relative_index=-1)
      # Don't use @index because @escapables could be modified
      return @is_escaped || @escapables[@escapables.length - 1 + relative_index]
    end
    
    def has_saver?(id)
      return @exp_savers.include?(id)
    end
    
    def to_s()
      s = ''
      s << "[#{@exp.chars.join(', ')}]\n"
      s << "[#{@escapables.map{|e| (e ? '1' : '0')}.join(', ')}]\n"
      
      return s
    end
  end
end
