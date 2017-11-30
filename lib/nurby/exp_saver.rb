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
    attr_accessor :escape
    attr_reader :id
    attr_reader :stop
    attr_accessor :str
    
    alias_method :escape?,:escape
    alias_method :stop?,:stop
    
    def initialize(id,escape=true)
      @escape = escape
      @id = id
      
      reset()
    end
    
    def initialize_copy(original)
      super(original)
      
      @escape = @escape.clone()
      @id = @id.clone()
      @stop = @stop.clone()
      @str = @str.clone()
    end
    
    def [](relative_index)
      return @str[@str.length - 1 + relative_index]
    end
    
    def reset()
      @stop = false
      @str = ''
      
      return self
    end
    
    def save(str)
      @str.concat(str) if !@stop
      
      return self
    end
    
    def stop()
      @stop = true
      
      return self
    end
  end
end
