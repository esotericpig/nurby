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

require 'nurby/errors/parse_errors'
require 'nurby/errors/var_errors'

require 'nurby/vars/loop_var'
require 'nurby/vars/range_var'
require 'nurby/vars/set_var'
require 'nurby/vars/var_var'

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
    attr_reader :var_classes
    attr_reader :vars
    
    def initialize()
      @next_id = 1
      @var_classes = {}
      @vars = {}
      
      add_in_var_classes()
    end
    
    def add_in_var_classes()
      add_var_class(RangeVar)
      add_var_class(SetVar)
      add_var_class(VarVar)
    end
    
    # Basically a tree/graph
    def add_var_class(var_class,allow_override=false)
      raise VarErrors::InvalidVarClass,
        "No BEGIN_TAG for var_class[#{var_class}]" if !var_class.const_defined?(:BEGIN_TAG)
      if var_class::BEGIN_TAG.nil?() || var_class::BEGIN_TAG.strip().empty?()
        raise VarErrors::InvalidVarClass,"BEGIN_TAG is empty for var_class[#{var_class}]"
      end
      
      curr_hash = @var_classes
      
      var_class::BEGIN_TAG.each_char() do |c|
        curr_hash[c] = {} unless curr_hash.key?(c)
        curr_hash = curr_hash[c]
        
        if !allow_override and curr_hash.key?(:value)
          conflict = curr_hash[:value]
          
          raise VarErrors::VarClassConflict,%Q^var_class[#{var_class}].begin_tag"#{var_class::BEGIN_TAG}"^ <<
            %Q^ conflicts with another var_class[#{conflict}].begin_tag"#{conflict::BEGIN_TAG}"; to allow^ <<
            %Q^ overriding, set param[allow_override] to true for method[add_var_class(...)]^
        end
      end
      
      curr_hash[:value] = var_class
    end
    
    def check_vars()
      has_range = false
      has_set = false
      has_safe_range = false
      has_safe_set = false
      
      @vars.each() do |id,var|
        if var.is_a?(LoopVar)
          if !var.per_var_id.nil?()
            if !@vars.include?(var.per_var_id)
              raise ParseErrors::InvalidVarID,"per_var[#{var.per_var_id}] from var[#{id}] does not exist"
            end
            if id == var.per_var_id
              raise ParseErrors::InvalidVarID,"per_var[#{var.per_var_id}] from var[#{id}] cannot be the same ID"
            end
          end
        end
        
        if var.is_a?(RangeVar)
          has_range = true
          #range_has_end = true if !var.end_value.nil?() && var.per_var_id.nil?()
        elsif var.is_a?(SetVar)
          has_set = true
        elsif var.is_a?(VarVar)
          if !@vars.include?(var.var_id)
            raise ParseErrors::InvalidVarID,"var[#{var.var_id}] from var_var[#{id}] does not exist"
          end
          if id == var.var_id
            raise ParseErrors::InvalidVarID,"var[#{var.var_id}] from var_var[#{id}] cannot be the same ID"
          end
        end
      end
      
      # bob.com/[u=1-   ]{l=1,2,3}
      # bob.com/[u=1-4/l]{l=1,2,3}
      # bob.com/{u=1,2,3}[l=1-   ]
      
      # FIXME: Should be okay also if have per_var if the per_var is on a set_var or range_var with end
      #if has_range && !range_has_end
      #  raise ParseErrors::NoValue,
      #    "At least one range_var must have an end value without a per_var to avoid an infinite loop"
      #end
    end
    
    def delete(id)
      return @vars.delete(id)
    end
    
    def parse(exp_parser)
      return parse!(exp_parser.clone())
    end
    
    def parse!(exp_parser)
      return nil if exp_parser.escaped?()
      
      var = nil
      var_class = @var_classes[exp_parser[0]]
      
      if !var_class.nil?()
        # Search the tree/graph
        if var_class.length > 2 || !var_class.key?(:value)
          look_ahead = exp_parser.clone()
          values = [var_class[:value]]
          
          loop do
            break unless look_ahead.next_chr?()
            break if look_ahead.escaped?()
            break unless var_class.key?(look_ahead[0])
            
            var_class = var_class[look_ahead[0]]
            values << var_class[:value] if var_class.key?(:value)
            
            break unless var_class.length > 2 || !var_class.key?(:value)
          end
          
          var_class = values.pop()
          
          # Parse all of the BEGIN_TAG
          if !var_class.nil?()
            var_class::BEGIN_TAG[1..-1].each_char() do |c|
              break unless exp_parser.next_chr?()
              if exp_parser[0] != c
                raise VarErrors::VarClassTagMismatch,
                  "var_class[#{var_class}] and BEGIN_TAG[#{var_class::BEGIN_TAG}] mismatch"
              end
            end
          end
        else
          var_class = var_class[:value]
        end
        
        var = var_class.new() unless var_class.nil?()
      end
      
      if !var.nil?()
        exp_parser.stop_savers()
        
        begin
          var.parse!(exp_parser,true)
        rescue ParseError => pe
          var_id = (var.id.nil?()) ? "$#{@next_id}" : var.id
          pe.message = "var[#{var_id}]: #{pe.message}"
          raise
        end
        
        exp_parser.start_savers()
        
        if var.id.nil?() || var.id.empty?()
          var.id = "$#{@next_id}"
          @next_id += 1
        end
        
        raise ParseErrors::InvalidVarID,
          "var.id[#{var.id}] already exists; duplicate IDs" if @vars.key?(var.id)
        @vars[var.id] = var
      end
      
      return var
    end
  end
end
