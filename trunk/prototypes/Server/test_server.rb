#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-19.
#  Copyright (c) 2007. All rights reserved.

require 'socket'
require 'fcntl'
require 'pp'

class Connection
  
  attr_reader :socket, :closing
  
  def initialize(socket, buffer_size=8192)
    @socket,@buffer_size=socket,buffer_size
    @closing = false;
    @in_buffer = ""
    @in_lines = []
    @out_buffer = ""
  end
  
  # Closes this connection's socket.
  def close
    @socket.close
  end
  
  # Reads input from the socket.
  #   Returns a line if one is ready, nil otherwise.
  def read_line
    begin
      # Process each incoming character to filter out trash.
      #@in_buffer << @socket.gets().gsub(/[\x00-\x09\x0B-\x0C\x0E-\x1F]/, "").gsub(/\r/, "\n")
      line = @socket.recv(@buffer_size)
      @closing = true if line == ""
      line.each_byte do |ch|
        # Accept any printable characters, and the newline character.
        if (ch >= 32 and ch <= 126) or ch.chr == "\n"
          @in_buffer << ch
        # Just treat carriage returns as newlines on input.
        #  This will detect line endings like \r \n\r, \r\n, etc.
        elsif ch.chr == "\r"
          puts "Found a CR"
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
        line.slice!(-1)
        # Skip empty lines.
        @in_lines << line if line != ""
        # Look for the next newline.
        n = @in_buffer.index("\n")
      end
      # Return the first line in the queue (nil if there are none).    
      @in_lines.shift
    rescue EOFError, Errno::ECONNRESET, Errno::ECONNABORTED
      @closing = true;
      return nil
    end
  end

  def write(message)
    @out_buffer << message
    n = @socket.send(@out_buffer, 0)
    # Chop what we already sent off the front of the buffer.
    @out_buffer.slice!(0...n)
    # Return whether we are done sending.
    @out_buffer.size == 0
  end
end

class MUDServer
  
  def initialize(port=4000, address='0.0.0.0')
    @shutdown = false
    @connections = []
    @server = TCPServer.new(address, port)
    @server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    unless RUBY_PLATFORM =~ /win32/
      @server.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK)
    end
  end
  
  def run
    Signal.trap("INT", method(:shutdown))
    Signal.trap("TERM", method(:shutdown))
    Signal.trap("KILL", method(:shutdown))
    until @shutdown
      sockets = []
      @connections.each do |conn|
        sockets << conn.socket
      end
      sockets << @server

      sockets = IO.select(sockets, nil, nil, 10)
      next if sockets.nil?
      sockets = sockets[0]
      #puts "selected: sockets: #{sockets}\n"
      
      if sockets.include?(@server)
        begin
          conn = accept(@server.accept_nonblock)
          #conn.read_line
          #next
        rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
          puts "Error in accept."
        end
      end
      #if sockets.length > 0
        begin
          @connections.each do |conn|
            if (sockets.include?(conn.socket))
              if conn.closing
                puts "Disconnecting: #{conn.socket.peeraddr[1]}"
                conn.close
                @connections.delete(conn)
              else
                line = conn.read_line
                handle_line(conn, line) if line
              end
            end
          end
        rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
          puts "Error in handling."
        end
      #end
    end
    
  end
  
  def accept(socket)
    conn = Connection.new(socket)
    @connections << conn
    conn.write("Welcome!\n")
    puts "Accepted a new connection: #{socket.peeraddr[1]}\n"
    return conn
  end
  
  def shutdown(sig)
    puts "Shutting Down. (Signal: #{sig})"
    @shutdown = true
  end
  
  def handle_line(conn, line)
    puts "Received line: #{conn.socket.peeraddr[1]}: '#{line}'."
    broadcast(line << "\n")
    return line
  end
  
  def broadcast(message)
    @connections.each do |conn|
      conn.write(message)
    end
  end
end

#socketio = SocketIO.new(socket)
#socketio.write("This is only a test.\n")

server = MUDServer.new
server.run