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

require 'nurby/errors/errors'
require 'nurby/errors/exit_codes'

###
# Only for errors related to vars, var factories, etc.
###
module Nurby
  class VarError < NurbyError
    def initialize(message=nil,exit_code=ExitCodes::INTERNAL_ERROR)
      super(message,exit_code)
    end
  end
  
  module VarErrors
    class InvalidVarClass < VarError; end
    class VarClassExists < VarError; end
    class VarClassTagMismatch < VarError; end
  end
end