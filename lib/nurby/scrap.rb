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

module Nurby
  class Scrap
    attr_accessor :skip_count # -1 means forever
    attr_accessor :str_id_len
    
    def initialize()
      super()
      
      @skip_count = 0
      @str_id_len = 5
    end
    
    def format(id,var,newline=true)
      return (newline ? "\n" : '') << "- %*s #{var}" % [-@str_id_len,id + ':']
    end
    
    def to_s()
      s = ''
      s << format('skip',@skip_count,false)
      return s
    end
  end
end
