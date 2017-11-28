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

require 'set'

require 'nurby/exp_saver'

###
# By design, there is no stop_saver() for @exp_saver, as it should not be stopped.
# 
# This class cannot process opening and closing tags (unless they are chars).
# It is the job of the outside class to process those with start_saver(...), look_ahead?(...), etc.
###
module Nurby
  class ExpParser
    DEFAULT_ESCAPE_CHR = '\\'
    
    attr_accessor :escape_chr
    attr_reader :escaped
    attr_reader :escaped_chrs
    attr_reader :exp
    attr_reader :exp_saver
    attr_reader :exp_savers
    attr_reader :index
    attr_reader :running_exp_savers
    
    def initialize(exp,escape_chr=DEFAULT_ESCAPE_CHR)
      @escape_chr = escape_chr
      @escaped = false
      @escaped_chrs = []
      @exp = exp
      @exp_saver = ExpSaver.new(nil)
      @exp_savers = {}
      @index = 0
      @running_exp_savers = {}
    end
    
    def [](relative_index)
      # Don't use @index because @exp_saver doesn't include @escape_chr and can be reset
      return @exp_saver[relative_index]
    end
    
    def end_parsing(add_chops=true)
      if add_chops
        @exp_saver.str << ' '
        
        # Only do it for the last ones running
        @running_exp_savers.each_value do |exp_saver|
          exp_saver.str << ' '
        end
      end
    end
    
    def self.escape(str,escape_chr=DEFAULT_ESCAPE_CHR,*chrs_to_escape)
      chrs_to_escape = chrs_to_escape.to_set().add(escape_chr)
      exp_parser = ExpParser.new(str,escape_chr)
      new_str = ''
      
      exp_parser.exp_saver.escape = false
      
      while exp_parser.next_chr?()
        c = exp_parser[0]
        
        e = exp_parser.escaped?()
        i = chrs_to_escape.include?(c)
        
        # e && !i || !e && i
        #   escape('\\hi[hi','\\','[')
        #   1: "\hi" - 'h' should not be escaped and '\' should be
        #   2: "[hi" - '[' should be escaped
        if e ^ i
          new_str << escape_chr
        end
        
        new_str << c
      end
      
      return new_str
    end
    
    def find!(str)
      return true if str.length < 1
      
      i = 0
      s = ''
      
      while next_chr?()
        next if escaped?()
        
        c = self[0]
        
        if c == str[i]
          s << c
          
          break if (i += 1) >= str.length
        elsif i != 0
          # Start over and try again
          i = 0
          s = ''
        end
      end
      
      return s == str
    end
    
    def look_ahead(length)
      return nil if length < 1
      
      exp_parser = ExpParser.new(@exp[@index - 1..-1],@escape_chr)
      
      i = 0
      result = ''
      
      while exp_parser.next_chr?() && i < length
        next if exp_parser.escaped?()
        
        result << exp_parser[0]
        i += 1
      end
      
      return result
    end
    
    def look_ahead?(str)
      return true if str.length < 1
      
      exp_parser = ExpParser.new(@exp[@index - 1..-1],@escape_chr)
      
      i = 0
      s = ''
      
      while exp_parser.next_chr?() && i < str.length
        next if exp_parser.escaped?()
        
        c = exp_parser[0]
        
        break if c != str[i]
        
        s << c
        i += 1
      end
      
      return s == str
    end
    
    def next_chr?()
      if @index >= @exp.length
        return false
      end
      
      @escaped = (@exp[@index] == @escape_chr) ? !@escaped : false
      @escaped_chrs.push(@escaped)
      
      c = @exp[@index]
      
      if @escaped
        @exp_saver.save(c) if !@exp_saver.escape?()
        
        @running_exp_savers.each_value do |exp_saver|
          exp_saver.save(c) if !exp_saver.escape?()
        end
      # If "\\", then only save '\'; if "\[", then only save '['; etc.
      else
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
    
    def reset_saver(id=nil,stop_savers=false)
      if id.nil?
        self.stop_savers() if stop_savers
        
        return @exp_saver.reset()
      end
      
      return start_saver(id,stop_savers,false)
    end
    
    def reset_savers()
      @exp_savers.each do |id,exp_saver|
        exp_saver.reset()
        @running_exp_savers[id] = exp_saver
      end
    end
    
    def start_saver(id,stop_savers=false,only_if_no_saver=true,escape=true)
      return nil if only_if_no_saver && @exp_savers.include?(id)
      self.stop_savers() if stop_savers
      
      exp_saver = @exp_savers[id]
      
      if exp_saver.nil?
        exp_saver = ExpSaver.new(id,escape)
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
    
    def saver(id=nil)
      if id.nil?
        return @exp_saver
      end
      
      exp_saver = @exp_savers[id]
      
      return (exp_saver.nil?) ? nil : exp_saver
    end
    
    def escaped?(relative_index=-1)
      return @escaped || escaped_chr?(relative_index)
    end
    
    def escaped_chr?(relative_index=-1)
      # Don't use @index because @escaped_chrs could be modified
      return @escaped_chrs[@escaped_chrs.length - 1 + relative_index]
    end
    
    def saver?(id)
      return @exp_savers.include?(id)
    end
    
    def to_s()
      s = ''
      
      s << "- exp:      [#{@exp.chars.join(', ')}]\n"
      s << "- esc_chrs: [#{@escaped_chrs.map{|e| (e ? '1' : ' ')}.join(', ')}]\n"
      s << "- ind[%03d]: [#{Array.new(@exp.length).map.with_index{|x,i| (i == @index) ? 'X' : ' '}.join(', ')}]\n" % @index
      s << "- exp_svr:  [#{@exp_saver.str.chars.join(', ')}]\n"
      s << "- exp_svrs: [#{@exp_savers.keys.join(', ')}]\n"
      s << "- run_svrs: [#{@running_exp_savers.keys.join(', ')}]\n"
      
      return s
    end
  end
end
