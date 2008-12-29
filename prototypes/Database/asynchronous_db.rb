#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2008-07-12.
#  Copyright (c) 2008. All rights reserved.

Dir.chdir("../..")
require 'server/mud_server'

class AsynchronousDB < MUDServer

  # initialize
  # Sets up the TCP server for the MUD
  # -port- specifies the port to listen on (defaults to 4001)
  # -address- specifies the host address (defaults to "0.0.0.0")
  def initialize(port=4001, address='0.0.0.0')
    super(port, address)
    # The next task ID that will be given out
    @next_task_id = 1
    @database = Hash.new
    @database["object.property"] = 0
    @read_log = Hash.new
    @write_log = Hash.new
  end
  
  # handle_line (Overridden from MUDServer)
  # Handles each line of input from a connection.
  # -conn- is the Connection object from which the line came
  # -line- is the String of text that was found
  def handle_line(conn, line)
    puts "Received line from #{conn.socket.peeraddr[1]}: '#{line}'."
    args = line.split()
    conn.write("(#{args.inspect})\n")
    case args[0]
    when "NEW"
      handle_new(conn, args)
    when "GET"
      handle_get(conn, args)
    when "SET"
      handle_set(conn, args)
    end
    return nil
  end # handle_line
  
  def handle_new(conn, args)
    conn.write("NEW #{@next_task_id}\n")
    @next_task_id = @next_task_id + 1
  end
  
  def handle_get(conn, args)
    begin
      task_id = args[1]
      property = args[2]
      return conn.write("Error: Property not found.\n") unless @database.has_key?(property)
      @read_log[property] = Array.new unless @read_log.has_key?(property)
      @read_log[property] = @read_log[property] << task_id
      conn.write(@database[property].inspect + "\n")
    rescue
      conn.write("Error: Malformed GET Request. #{$!}\n")
    end
  end
  
  def handle_set(conn, args)
    begin
      task_id = args[1]
      property = args[2]
      value = eval(args[3..-1].join(" "))
      if @database.has_key?(property)
        @database[property] = value
        conn.write(value.inspect + "\n")
      else
        return conn.write("Error: Property not found.\n")
      end
    rescue
      conn.write("Error: Malformed SET Request.\n")
    end
  end
  
end

puts "Starting the Server..."
server = AsynchronousDB.new
server.run
