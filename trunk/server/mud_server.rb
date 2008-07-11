#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-25.
#  Copyright (c) 2007. All rights reserved.

require 'socket'
require 'fcntl'
require 'server/connection'
require 'core/database'

class MUDServer
  
  # initialize
  # Sets up the TCP server for the MUD
  # -port- specifies the port to listen on (defaults to 4000)
  # -address- specifies the host address (defaults to "0.0.0.0")
  def initialize(port=4000, address='0.0.0.0')
    @shutdown = false
    @connections = []
    puts "Listening on #{address}:#{port}"
    @server = TCPServer.new(address, port)
    @server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    
    # TODO: Find out if non-blocking IO is still a problem with win32
    unless RUBY_PLATFORM =~ /win32/
      @server.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK)
    end
  end # initialize
  
  # run
  # Main server loop that handles new connections and low-level data transfer
  def run
    # Trap signals to allow graceful shutdowns
    Signal.trap("INT", method(:shutdown))
    Signal.trap("TERM", method(:shutdown))
    Signal.trap("KILL", method(:shutdown))
    
    # Run until a shutdown is signalled
    until @shutdown
      # Get the list of active sockets
      sockets = []
      @connections.each do |conn|
        sockets << conn.socket
      end
      # Add the server's socket (to check for new connections)
      sockets << @server

      # Select sockets that are ready to be read
      sockets = IO.select(sockets, nil, nil, 10)
      # Restart the loop if select timed out
      next if sockets.nil?
      # We're only interested in the readable sockets at this point
      sockets = sockets[0]

      # If the server's socket is readable, a new connection is incoming
      if sockets.include?(@server)
        begin
          # Accept the new socket
          conn = accept(@server.accept_nonblock)
        rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
          puts "Error in accept."
        end
      end # if socket is server
      
      # Handle all the readable sockets
      if !sockets.empty?
        begin
          # Check each active Connection to see if its socket is in the readable set
          @connections.each do |conn|
            if (sockets.include?(conn.socket))
              if conn.closing
                # Handle closing sockets
                puts "Disconnecting: #{conn.socket.peeraddr[1]}"
                conn.close
                @connections.delete(conn)
              else
                # Handle reading from open sockets
                line = conn.read_line
                handle_line(conn, line) if line
              end # is connection closing?
            end # is this Connection in the readable sockets?
          end # foreach @connections
        rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
          puts "Error in handling."
        end
      end # If !sockets.empty?
    end # until @shutdown
  end # run
  
  # accept
  # Accepts a new connection socket and creates a Connection object for it.
  # -socket- is the TCPSocket object created by the server on a new connection
  # returns the Connection object for this connection
  def accept(socket)
    conn = Connection.new(socket)
    # Add this Connection to the active connection list
    @connections << conn
    # Display a splash screen.
    conn.write("Welcome!\n")
    puts "Accepted a new connection: #{socket.peeraddr[1]}\n"
    return conn
  end # accept
  
  # shutdown
  # Signals for the server to gracefully shut down.
  # -sig- is the trapped signal
  def shutdown(sig)
    puts "Shutting Down. (Signal: #{sig})"
    @shutdown = true
  end # shutdown
  
  # handle_line
  # Handles each line of input from a connection.
  # -conn- is the Connection object from which the line came
  # -line- is the String of text that was found
  def handle_line(conn, line)
    puts "Received line from #{conn.socket.peeraddr[1]}: '#{line}'."
    command, args = line.split(":")
    conn.write("[#{command}](#{args})\n")
    result = Database.call(command.squeeze(" ").split, [args])
    conn.write("=> " << result.to_s << "\n")
    #broadcast(line << "\n")
    return nil
  end # handle_line
  
  # broadcast
  # Sends a message to all active Connections
  # -message- is the message to be sent to each connection
  def broadcast(message)
    @connections.each do |conn|
      conn.write(message)
    end
    return nil
  end # broadcast
  
end # MudServer
