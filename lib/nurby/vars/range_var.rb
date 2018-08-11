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

require 'nurby/util'

require 'nurby/errors/parse_errors'

require 'nurby/vars/loop_var'

###
# An empty @end_value is allowed, so in order to avoid an infinite loop, all of the vars should be checked.
# See VarFactory.check_vars() for an example.
# 
# @see VarFactory.check_vars()
###
module Nurby
  # (x.ord +/- 1).chr for entire string (only a-z, A-Z; else carry/borrow)
  class RangeVar < LoopVar
    BEGIN_TAG = '[' # @see Util.escape(...)
    END_TAG = ']' # @see Util.escape(...)
    
    attr_accessor :begin_value
    attr_accessor :end_value
    attr_accessor :min_size
    attr_accessor :prefix
    attr_accessor :step
    
    def initialize()
      super()
      
      @str_id_len = 9
      
      @begin_value = nil
      @end_value = nil
      @min_size = nil
      @prefix = nil
      @step = 0
    end
    
    def parse!(exp_parser,parsed_begin_tag=false,parsed_end_tag=false)
      exp_parser = super(exp_parser,parsed_begin_tag,parsed_end_tag)
      
      exp_parser.clear_savers('RangeVar.begin','RangeVar.end','RangeVar.:')
      exp_parser.start_saver('RangeVar.begin')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when '-'
          if !exp_parser.saver?('RangeVar.end')
            # Check if begin value is a negative number
            if Util.gsub_spaces(exp_parser.saver('RangeVar.begin').str) != '-'
              exp_parser.start_saver('RangeVar.end',stop_savers: true)
            end
          # Check if step is not running (which allows negative numbers) and end value is a negative number
          elsif (!exp_parser.saver?('RangeVar.:') || exp_parser.saver('RangeVar.:').stop?()) &&
                (exp_parser.saver('RangeVar.end').stop?() ||
                 Util.gsub_spaces(exp_parser.saver('RangeVar.end').str) != '-')
            raise ParseErrors::InvalidSymbol,"Too many '-' symbols in range var"
          end
        when ':'
          if !exp_parser.saver?('RangeVar.:')
            exp_parser.start_saver('RangeVar.:',stop_savers: true)
          else
            raise ParseErrors::InvalidSymbol,"Too many ':' symbols in range var"
          end
        end
      end
      
      exp_parser.add_saver_chops() # Tags will always be chopped off in super()
      
      @begin_value = exp_parser.saver('RangeVar.begin').str.chop()
      
      if @begin_value.length > 0
        @min_size = Util.index_int_or_letter(@begin_value)
        @min_size = 0 if @min_size.nil?
        @prefix = @begin_value[0] if Util.prefix?(@begin_value[0])
        @begin_value = Util.gsub_spaces!(@begin_value)
        @min_size += @begin_value.length
        value_step = 1
      end
      
      raise ParseErrors::NoValue,'Missing start value in range var' if @begin_value.empty?
      
      is_begin_int = Util.int?(@begin_value)
      is_begin_word = Util.word?(@begin_value)
      
      if is_begin_int
        @begin_value = @begin_value.to_i()
      elsif !is_begin_word
        raise ParseErrors::InvalidValue,
          %Q^Start value ("#{@begin_value}") in range var is not an integer ("+/-0-9") or a word ("a-zA-Z")^
      end
      
      if exp_parser.saver?('RangeVar.end')
        @end_value = exp_parser.saver('RangeVar.end').str.chop()
        
        if @end_value.length > 0
          end_min_size = Util.index_int_or_letter(@end_value)
          end_min_size = 0 if end_min_size.nil?()
          @prefix = @end_value[0] if @prefix.nil?() && Util.prefix?(@end_value[0])
          @end_value = Util.gsub_spaces!(@end_value)
          end_min_size += @end_value.length
          @min_size = end_min_size if end_min_size > @min_size
        end
        
        # Empty @end_value is allowed if at least one var has @end_value w/o @per_var_id.
        # All of the vars must be checked outside of this class.
        # @see VarFactory.check_vars()
        if @end_value.empty?()
          @end_value = nil
        else
          is_end_int = Util.int?(@end_value)
          is_end_word = Util.word?(@end_value)
          
          if !is_end_int && !is_end_word
            raise ParseErrors::InvalidValue,
              %Q^End value ("#{@end_value}") in range var is not an integer ("+/-0-9") or a word ("a-zA-Z")^
          end
          
          # Equivalent to: (is_begin_int && is_end_word) || (is_begin_word && is_end_int)
          if is_begin_int ^ is_end_int
            raise ParseErrors::MismatchValue,
              %Q^Start value ("#{@begin_value}") and end value ("#{@end_value}") types in range var mismatch (both must be integers or words)^
          end
          
          values_equal = false
          
          # Don't compare min size, else: 004 > 10.
          if is_begin_int
            @end_value = @end_value.to_i()
            value_step = -1 if (@end_value - @begin_value) < 0 # (goal - source) is negative?
            values_equal = (@begin_value == @end_value)
          else
            if !Util.reverse_chrs_case_equal?(@begin_value,@end_value)
              raise ParseErrors::MismatchValue,
                %Q^Start value ("#{@begin_value}") and end value ("#{@end_value}") reverse chars' case in range var mismatch ("[aBc-De]" is okay, but not "[aBc-DeF]")^
            end
            
            cmp = @begin_value.casecmp(@end_value)
            
            # casecmp(...) will return true for "'zz'.casecmp('abc') > 0", so test length
            if (@begin_value.length > @end_value.length) ||
                (@begin_value.length == @end_value.length && cmp > 0)
              value_step = -1
            end
            
            values_equal = (cmp == 0)
          end
          
          if values_equal
            raise ParseErrors::InvalidValue,
              %Q^Start value "#{@begin_value}" and end value "#{@end_value}" in range var could create an infinite loop (equal values)^
          end
        end
      end
      
      # Assume decrement for a negative number without @end_value
      value_step = -1 if @end_value.nil?() && @begin_value < 0
      
      if exp_parser.saver?('RangeVar.:')
        @step = Util.gsub_spaces(exp_parser.saver('RangeVar.:').str.chop())
        raise ParseErrors::NoValue,"Missing step (':') value in range var" if @step.empty?
        
        if !Util.int?(@step)
          raise ParseErrors::InvalidValue,%Q^Step (':') value ("#{@step}") in range var is not an integer^
        end
        
        @step = @step.to_i
      else
        @step = value_step
      end
      
      # Based on the values above, value_step was set to either be 1 or -1.
      # If @step is not the same sign [(@step ^ value_step) < 0], then this will be an infinite loop.
      # For example, "[1-4:-1]" would cause an infinite loop as 1 would keep decrementing forever.
      if @step == 0 || (!@end_value.nil?() && (@step ^ value_step) < 0)
        raise ParseErrors::InvalidValue,
          %Q(Step (':') value ("#{@step}") in range var could create an infinite loop)
      end
      
      @value = @begin_value
    end
    
    def to_s()
      s = super()
      s << format('beg_val',@begin_value)
      s << format('end_val',@end_value)
      s << format('min_size',@min_size)
      s << format('prefix',@prefix)
      s << format('step',@step)
      return s
    end
  end
end
