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

require 'nurby/util'

require 'nurby/errors/parse_errors'

require 'nurby/vars/var'

module Nurby
  # can be a string or int, so need to test if digit
  # if less than, must decrement (step)
  # (x.ord +/- 1).chr for entire string (only a-z, A-Z; else carry/borrow)
  class RangeVar < Var
    CLOSING_TAG = ']' # @see Util.escape(...)
    OPENING_TAG = '[' # @see Util.escape(...)
    
    attr_accessor :begin_value
    attr_accessor :end_value
    attr_accessor :min_size
    attr_accessor :prefix
    attr_accessor :step
    
    def initialize
      super()
      clear()
    end
    
    def clear()
      super()
      
      @begin_value = nil
      @end_value = nil
      @min_size = nil
      @prefix = nil
      @step = 0
    end
    
    def parse(exp_parser,parsed_opening_tag=false,parsed_closing_tag=false)
      exp_parser = super(exp_parser,parsed_opening_tag ? nil : OPENING_TAG,
        parsed_closing_tag ? nil : CLOSING_TAG)
      
      exp_parser.start_saver('b')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when '-'
          # Check if 'b' is '-', as it could be a negative number ("[-4-0]").
          # If 'e' is a negative number, start_saver(...) already checks if it exists.
          exp_parser.start_saver('e',true) if Util.gsub_spaces(exp_parser.saver('b').str) != '-'
        when ':'
          exp_parser.start_saver(':',true)
        end
      end
      
      exp_parser.end_parsing() # Tags will always be chopped off in super()
      
      @begin_value = exp_parser.saver('b').str.chop()
      
      if @begin_value.length > 0
        @min_size = Util.index_int_or_letter(@begin_value)
        @min_size = 0 if @min_size.nil?
        @prefix = @begin_value[0] if Util.prefix?(@begin_value[0])
        @begin_value = Util.gsub_spaces!(@begin_value)
        @min_size += @begin_value.length
        value_step = 1
      end
      
      raise NoValue,'Missing start value in range var' if @begin_value.empty?
      
      is_begin_int = Util.int?(@begin_value)
      is_begin_word = Util.word?(@begin_value)
      
      if is_begin_int
        @begin_value = @begin_value.to_i()
      elsif !is_begin_word
        raise InvalidValue,%Q^Start value ("#{@begin_value}") in range var is not an integer ("+/-0-9") ^ <<
          %Q^or a word ("a-zA-Z")^
      end
      
      if exp_parser.saver?('e')
        @end_value = exp_parser.saver('e').str.chop()
        
        if @end_value.length > 0
          end_min_size = Util.index_int_or_letter(@end_value)
          end_min_size = 0 if end_min_size.nil?
          @prefix = @end_value[0] if @prefix.nil? && Util.prefix?(@end_value[0])
          @end_value = Util.gsub_spaces!(@end_value)
          end_min_size += @end_value.length
          @min_size = end_min_size if end_min_size > @min_size
        end
        
        # Empty @end_value is allowed if at least one var has @end_value.
        # All of the vars must be checked outside of this class.
        # @see VarFactory.check_vars()
        if @end_value.empty?
          @end_value = nil
        else
          is_end_int = Util.int?(@end_value)
          is_end_word = Util.word?(@end_value)
          
          if !is_end_int && !is_end_word
            raise InvalidValue,%Q^End value ("#{@end_value}") in range var is not an integer ("+/-0-9") ^ <<
              %Q^or a word ("a-zA-Z")^
          end
          
          # Equivalent to: (is_begin_int && is_end_word) || (is_begin_word && is_end_int)
          if is_begin_int ^ is_end_int
            raise MismatchValue,%Q^Start value ("#{@begin_value}") and end value ("#{@end_value}") types ^ <<
              %Q^in range var mismatch (both must be integers or words)^
          end
          
          values_equal = false
          
          # Don't compare min size, else: 004 > 10.
          if is_begin_int
            @end_value = @end_value.to_i()
            value_step = -1 if (@end_value - @begin_value) < 0 # (goal - source) is negative?
            values_equal = (@begin_value == @end_value)
          else
            if !Util.reverse_chrs_case_equal?(@begin_value,@end_value)
              raise MismatchValue,%Q^Start value ("#{@begin_value}") and end value ("#{@end_value}") ^ <<
                %Q^reverse chars' case in range var mismatch ("[aBc-De]" is okay, but not "[aBc-DeF]")^
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
            raise InvalidValue,%Q^Start value "#{@begin_value}" and end value "#{@end_value}" in range ^ <<
              %Q^var could create an infinite loop (equal values)^
          end
        end
      end
      
      # Assume decrement for a negative number only
      value_step = -1 if @end_value.nil? && @begin_value < 0
      
      if exp_parser.saver?(':')
        @step = Util.gsub_spaces(exp_parser.saver(':').str.chop())
        raise NoValue,"Missing step (':') value in range var" if @step.empty?
        
        if !Util.int?(@step)
          raise InvalidValue,%Q^Step (':') value ("#{@step}") in range var is not an integer^
        end
        
        @step = @step.to_i
      else
        @step = value_step
      end
      
      # Based on the values above, value_step was set to either be 1 or -1.
      # If @step is not the same sign [(@step ^ value_step) < 0], then this will be an infinite loop.
      # For example, "[1-4:-1]" would cause an infinite loop as 1 would keep decrementing forever.
      if @step == 0 || (!@end_value.nil? && (@step ^ value_step) < 0)
        raise InvalidValue,%Q(Step (':') value ("#{@step}") in range var could create an infinite loop)
      end
    end
    
    def to_s()
      s = super()
      
      s << "- beg_val:  #{@begin_value}\n"
      s << "- end_val:  #{@end_value}\n"
      s << "- min_size: #{@min_size}\n"
      s << "- prefix:   #{@prefix}\n"
      s << "- step:     #{@step}\n"
      
      return s
    end
  end
end
