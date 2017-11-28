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

module Util
  def self.gsub_spaces(str)
    return str.gsub(/[[:space:]]+/,'')
  end
  
  def self.gsub_spaces!(str)
    str.gsub!(/[[:space:]]+/,'') # Don't return this; if no sub, then nil
    return str
  end
  
  def self.index_digit_or_letter(str)
    return str.index(/[\da-zA-Z]/)
  end
  
  def self.int?(str)
    return str =~ /\A([[:space:]]*[+\-]?[[:space:]]*)([[:space:]]*\d+[[:space:]]*)+\z/
  end
  
  def self.prefix?(chr)
    return chr == '0' || chr == ' '
  end
  
  def self.whole_num?(str)
    return str =~ /\A([[:space:]]*+?[[:space:]]*)([[:space:]]*\d+[[:space:]]*)+\z/
  end
  
  def self.whole_num_or_word?(str)
    return whole_num?(str) || word?(str)
  end
  
  def self.word?(str)
    return str =~ /\A([[:space:]]*[a-zA-Z]+[[:space:]]*)+\z/
  end
end
