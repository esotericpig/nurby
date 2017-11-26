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

module Nurby
  class ExpSaver
    attr_reader :id
    attr_accessor :str
    
    def initialize(id)
      @id = id
      reset()
    end
    
    def reset()
      @is_stopped = false
      @str = ''
      
      return self
    end
    
    def save(str)
      @str.concat(str) if !@is_stopped
      
      return self
    end
    
    def stop()
      @is_stopped = true
      
      return self
    end
    
    def stop?()
      return @is_stopped
    end
  end
end
