#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-25.
#  Copyright (c) 2007. All rights reserved.

require 'pp'

class Parser
  
  def initialize(command_line)
    @line = command_line
    @tokens = []
    @current_index = 0
    quote = false
    buffer = ""
    prev = ""
    command_line.each_byte do |byte|
      ch = byte.chr
      if quote and ch != "\""
        buffer += ch
      elsif ch == "\"" and prev != "\\"
        if quote
          @tokens << "\"" + buffer + "\""
        else
          @tokens << buffer if buffer != ""
        end
        buffer = ""
        quote = !quote
      elsif ch == " "
        @tokens << buffer if buffer != ""
        buffer = ""
      elsif (byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90)
        # It's a number or upper-case letter
        buffer += ch
      elsif (byte >= 97 and byte <= 122)
        # It's a lower-case letter
        buffer += ch.upcase
      end
      prev = ch
    end
    @tokens << buffer
    puts "Initialized:"
    pp @tokens
  end # initialize
  
  def advance
    @current_index = @current_index + 1
    current_token()
  end # advance
  
  def current_token
    puts "Current: #{@tokens[@current_index]}"
    @tokens[@current_index]
  end # current_token
  
  def retract
    @current_index = @current_index - 1
    current_token()
  end # retract
  
  # <noun group> ::= [ quantifier ] { adjective } ( noun | string)
  def parse_noun_group
    parse_article()
    parse_integer()
    while parse_adjective()
    end
    return (parse_noun() or parse_string())
  end
  
  # <quantifier> ::= (ALL | THE | MY) [integer] [OF] [THE | MY]
  #                  | [ALL | THE | MY] integer [OF] [THE | MY]
  def parse_quantifier
    current = current_token()
    first = (current == "ALL" or current == "THE" or current == "MY")
    current = advance() if first
    
    integer = parse_integer()
    
    return false unless (first or integer)
    
    if current == "OF"
      current = advance()
    end
    if (current == "THE" or current == "MY")
      advance()
    end
    return true
  end #parse_quantifier
  
  def parse_integer
    current = current_token()
    if current.scan(/^[+-]?\d+$/) != []
      advance()
      return true
    end
    return false
  end
end # Parser

parse = Parser.new("the 12 of my books")
puts "---"
pp "Result #{parse.parse_quantifier()}"