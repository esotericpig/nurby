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

require 'nurby/errors/errors'
require 'nurby/errors/exit_codes'

###
# Only for errors related to parsing.
###
module Nurby
  class ParseError < NurbyError
    def initialize(message=nil,exit_code=ExitCodes::MALFORMED_URL)
      super(message,exit_code)
    end
  end
  
  class InvalidMethodID < ParseError; end
  class InvalidSymbol < ParseError; end
  class InvalidValue < ParseError; end
  class InvalidVarID < ParseError; end
  class MismatchValue < ParseError; end
  class NoClosingTag < ParseError; end
  class NoMethodID < ParseError; end
  class NoOpeningTag < ParseError; end
  class NoValue < ParseError; end
  class NoVarID < ParseError; end
end
