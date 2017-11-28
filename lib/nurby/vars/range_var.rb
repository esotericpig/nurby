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
    attr_accessor :begin_value
    attr_accessor :end_value
    attr_accessor :min_size
    attr_accessor :prefix
    attr_accessor :step
    
    def initialize
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
      exp_parser = super(exp_parser,parsed_opening_tag ? nil : '[',parsed_closing_tag ? nil : ']')
      
      exp_parser.start_saver('b')
      
      while exp_parser.next_chr?()
        next if exp_parser.escaped?()
        
        case exp_parser[0]
        when '-'
          exp_parser.start_saver('e',true)
        when ':'
          exp_parser.start_saver(':',true)
        end
      end
      
      exp_parser.end_parsing() # Tags will always be chopped off in super()
      
      @begin_value = exp_parser.saver('b').str.chop()
      value_step = 0
      
      if @begin_value.length > 0
        @min_size = Util.index_digit_or_letter(@begin_value)
        @min_size = 0 if @min_size.nil?
        @prefix = @begin_value[0] if Util.prefix?(@begin_value[0])
        @begin_value = Util.gsub_spaces(@begin_value)
        @min_size += @begin_value.length
        value_step = 1
      end
      
      raise NoValue,'Missing start value for range' if @begin_value.empty?
      
      if !Util.whole_num_or_word?(@begin_value)
        raise InvalidValue,%Q(Start value "#{@begin_value}" for range is not a whole number "0-9" or a word "a-zA-Z")
      end
      
      is_begin_num = Util.whole_num?(@begin_value)
      @begin_value = @begin_value.to_i() if is_begin_num
      
      if exp_parser.saver?('e')
        @end_value = exp_parser.saver('e').str.chop()
        
        if @end_value.length > 0
          end_value_min_size = Util.index_digit_or_letter(@end_value)
          end_value_min_size = 0 if end_value_min_size.nil?
          @prefix = @end_value[0] if @prefix.nil? && Util.prefix?(@end_value[0])
          @end_value = Util.gsub_spaces(@end_value)
          end_value_min_size += @end_value.length
          @min_size = end_value_min_size if end_value_min_size > @min_size
        end
        
        # Empty @end_value is allowed if at least one var has @end_value
        # All of the vars must be checked outside of this class
        if @end_value.empty?
          @end_value = nil
        else
          if !Util.whole_num_or_word?(@end_value)
            raise InvalidValue,%Q(End value "#{@end_value}" for range is not a whole number "0-9" or a word "a-zA-Z")
          end
          
          if (is_begin_num && Util.word?(@end_value)) ||
              (Util.word?(@begin_value) && Util.whole_num?(@end_value))
            raise MismatchValue,%Q^Start value "#{@begin_value}" and end value "#{@end_value}" for range mismatch (both must be whole numbers or words)^
          end
          
          values_equal = false
          
          # Don't compare min size, else: 004 > 10
          if is_begin_num
            @end_value = @end_value.to_i()
            values_equal = @begin_value == @end_value
            value_step = -1 if @end_value < @begin_value
          else
            cmp = @end_value.casecmp(@begin_value)
            values_equal = (cmp == 0)
            value_step = -1 if cmp < 0
          end
          
          if values_equal
            raise InvalidValue,%Q(Start value "#{@begin_value}" and end value "#{@end_value}" for range could create an infinite loop)
          end
        end
      end
      
      if exp_parser.saver?(':')
        @step = Util.gsub_spaces(exp_parser.saver(':').str.chop())
        raise NoValue,"Missing step value for ':' in range" if @step.empty?
        raise InvalidValue,%Q(Step value "#{@step}" for ':' in range is not an integer) if !Util.int?(@step)
        @step = @step.to_i
      else
        @step = value_step
      end
      
      if @step == 0 || (@step * value_step) != @step
        raise InvalidValue,%Q(Step value "#{@step}" for ':' in range could create an infinite loop)
      end
    end
    
    def to_s()
      s = super()
      
      s << "- beg_val:  #{@begin_value}\n"
      s << "- end_val:  #{@end_value}\n"
      s << "- min_size: #{@min_size}\n"
      s << "- pre:      #{@prefix}\n"
      s << "- stp:      #{@step}\n"
      
      return s
    end
  end
end
