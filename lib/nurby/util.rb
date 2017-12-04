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

require 'nurby/exp_parser'

require 'nurby/vars/range_var.rb'
require 'nurby/vars/set_var.rb'

module Nurby
  module Util
    def self.reverse_chrs_case_equal?(str1,str2)
      i1 = str1.length
      i2 = str2.length
      
      while (i1 -= 1) >= 0 && (i2 -= 1) >= 0
        c1 = str1[i1]
        c2 = str2[i2]
        
        # Equivalent to: (lower?(c1) && upper?(c2)) || (upper?(c1) && lower?(c2))
        return false if lower?(c1) ^ lower?(c2)
      end
      
      return true
    end
    
    def self.escape(str,escape_chr: ExpParser::DEFAULT_ESCAPE_CHR,var_classes: [],chrs_to_escape: [])
      var_classes.push(RangeVar)
      var_classes.push(SetVar)
      
      var_classes.each do |var_class|
        # concat(...) for array of chrs
        chrs_to_escape.concat(var_class::CLOSING_TAG.chars) if var_class.const_defined?(:CLOSING_TAG)
        chrs_to_escape.concat(var_class::OPENING_TAG.chars) if var_class.const_defined?(:OPENING_TAG)
      end
      
      # escape(...) will create a Set of chrs
      return ExpParser.escape_chrs(str,escape_chr,*chrs_to_escape)
    end
    
    def self.gsub_spaces(str)
      return str.gsub(/[[:space:]]+/,'')
    end
    
    def self.gsub_spaces!(str)
      str.gsub!(/[[:space:]]+/,'') # Don't return this; if no sub, then nil
      return str
    end
    
    def self.index_int_or_letter(str)
      return str.index(/[+\-\da-zA-Z]/)
    end
    
    def self.int?(str)
      return (str =~ /\A([[:space:]]*[+\-]?[[:space:]]*)([[:space:]]*\d+[[:space:]]*)+\z/) ? true : false
    end
    
    def self.int_or_word?(str)
      return int?(str) || word?(str)
    end
    
    def self.lower?(str)
      # Faster than regex in my testing
      return str == str.downcase()
    end
    
    def self.prefix?(chr)
      # Use regex so can allow '\t', etc.
      return (chr =~ /\A(0|[[:space:]])\z/) ? true : false
    end
    
    def self.upper?(str)
      # Faster than regex in my testing
      return str == str.upcase()
    end
    
    def self.whole_num?(str)
      return (str =~ /\A([[:space:]]*+?[[:space:]]*)([[:space:]]*\d+[[:space:]]*)+\z/) ? true : false
    end
    
    def self.whole_num_or_word?(str)
      return whole_num?(str) || word?(str)
    end
    
    def self.word?(str)
      return (str =~ /\A([[:space:]]*[a-zA-Z]+[[:space:]]*)+\z/) ? true : false
    end
  end
end
