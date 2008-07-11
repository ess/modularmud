#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-25.
#  Copyright (c) 2007. All rights reserved.

@enquoting = ["SAY"]

class Tokenizer
  def initialize(command_line)
    @line = command_line
    @tokens = []
    quote = false
    buffer = ""
    prev = ""
    command_line.each_byte do |ch|
      ch = ch.chr
      if ch == "\"" and prev != "\\"
        if quote
          @tokens << "\"" + buffer + "\""
          buffer = ""
          quote = false
        else
          @tokens << buffer if buffer != ""
          buffer = ""
          quote = true
        end
      elsif ch == " " and !quote
        @tokens << buffer if buffer != ""
        buffer = ""
      else
        buffer += ch
      end
      prev = ch
    end
    @tokens << buffer
  end
end

Tokenizer.new("This is a test.")
puts "---"
Tokenizer.new("This \"is       a\" test.")
puts "---"
Tokenizer.new("\tThis\t  is a test.\r\n\n\r\t\r")
