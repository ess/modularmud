#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-25.
#  Copyright (c) 2007. All rights reserved.

require 'socket'

class Connection
  
  attr_reader :socket, :closing
  attr_accessor :atom
  
  # initialize
  # Sets up the Connection object from its TCPSocket and an optional buffer size.
  # -socket- is the TCPSocket created by the server when it accepts a connection
  # -buffer_size- (optional) is the size of this socket's read buffer (default: 8192)
  def initialize(socket, buffer_size=8192)
    @socket,@buffer_size=socket,buffer_size
    @closing = false
    @in_buffer = ""
    @in_lines = []
    @out_buffer = ""
    # Create an Atom for this connection
    @atom = Hierarchy.instantiate("PLAYER")
    # Define the [SEND PLAYER???](message_lines) code
    CodeStore.define(["SEND", @atom], proc { |atoms, args| write(args.join("\n") << "\n") })    
  end # initialize
  
  # close
  # Closes this connection's socket.
  def close
    CodeStore.undefine(["SEND", @atom])
    @socket.close
  end # close
  
  # read_line
  # Reads input from the socket.
  # Returns a line if one is ready, nil otherwise.
  def read_line
    begin
      line = @socket.recv(@buffer_size)
      # An empty line signals a closed connection on the client side
      @closing = true if line == ""
      
      # Process each incoming character to filter out trash.
      line.each_byte do |ch|
        # Accept any printable characters, and the newline character.
        if (ch >= 32 and ch <= 126) or ch.chr == "\n"
          @in_buffer << ch
        # Just treat carriage returns as newlines on input.
        #  This will detect line endings like \r \n\r, \r\n, etc.
        elsif ch.chr == "\r"
          @in_buffer << "\n"
        # Handle a backspace character in case the client doesn't.
        elsif ch.chr == "\x08"
          @in_buffer.delete_at(-1)
        end
      end
      # Characters processed.  Now split up the lines.
      n = @in_buffer.index("\n")
      # Go until we run out of newlines in the buffer.
      until n.nil?
        # Append this line to the line list, and chop the \n off the end.
        line =  @in_buffer.slice!(0..n)
        line.chop!
        # Skip empty lines.
        @in_lines << line if line != ""
        # Look for the next newline.
        n = @in_buffer.index("\n")
      end
      # Return the first line in the queue (nil if there are none).    
      return @in_lines.shift
    rescue EOFError, Errno::ECONNRESET, Errno::ECONNABORTED
      @closing = true;
      return nil
    end
  end # read_line

  # write
  # Send a String out over this Connection's TCPSocket
  # -message- is the String message to be sent.
  # Returns whether the complete message was sent
  def write(message)
    @out_buffer << message
    n = @socket.send(@out_buffer, 0)
    # Chop what we already sent off the front of the buffer.
    @out_buffer.slice!(0...n)
    # Return whether we are done sending.
    return @out_buffer.size == 0
  end # write
  
end # Connection
