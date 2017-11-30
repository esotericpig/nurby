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

require 'nurby/errors/parse_errors'

###
# This class is a bit strange in that it is an instance factory, instead of a
# static factory.
# 
# This is primarily for @next_id because a global (static) one could have
# unexpected conflicts for developers.
###
module Nurby
  class VarFactory
    attr_reader :next_id
    attr_reader :vars
    
    def initialize()
      @next_id = 1
      @vars = {}
    end
    
    def check_vars
      has_range_var = false
      one_range_has_end = false
      
      @vars.each do |id,var|
        if !var.per_var_id.nil? && !@vars.include?(var.per_var_id)
          raise InvalidVarID,"Per var[#{var.per_var_id}] from var[#{id}] does not exist"
        end
        
        if var.is_a?(RangeVar)
          has_range_var = true
          one_range_has_end = true if !var.end_value.nil?
        end
      end
      
      if has_range_var && !one_range_has_end
        raise NoValue,"At least one range var must have an end value to avoid an infinite loop"
      end
    end
    
    def clear()
      @next_id = 1
      @vars.clear()
      
      return self
    end
    
    def delete(id)
      return @vars.delete(id)
    end
    
    def parse(exp_parser)
      return parse!(exp_parser.clone())
    end
    
    def parse!(exp_parser)
      var = nil
      
      begin
        case exp_parser[0]
        when '['
          var = RangeVar.new()
        when '{'
          # Is not a method?
          if exp_parser[-1] != '#'
            var = SetVar.new()
          end
        end
        
        if !var.nil?
          var.parse(exp_parser,true)
          
          if var.id.nil? || var.id.empty?
            var.id = "$#{@next_id}"
            @next_id += 1
          end
          
          raise InvalidVarID,"Var ID[#{var.id}] already exists; duplicate IDs" if @vars.include?(var.id)
          @vars[var.id] = var
        end
      rescue ParseError => pe
        var_id = (var.id.nil?) ? "$#{@next_id}" : var.id
        pe.message = "Var[#{var_id}]: #{pe.message}"
        raise
      end
      
      return var
    end
  end
end
