#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-25.
#  Copyright (c) 2007. All rights reserved.

require 'modules/module_manager'
require 'server/mud_server'

modules = %w(core)

puts "Loading Modules..."
begin
  modules.each do |mod|
    puts "\tLoading Module '#{mod}'"
    result = ModuleManager.load(mod)
    raise result unless result.nil?
  end # each module
  
  puts "Starting the Server..."
  server = MUDServer.new
  
  # Special built-in code:
  builtin_broadcast = proc { |atoms, args|
    if args.class == Array
      str = args.join("\n")
    else
      str = args.to_s
    end
    server.broadcast("***System Message***\n#{str}\n")
  }
  Database.define(["BROADCAST"], builtin_broadcast)
  builtin_shutdown = proc { |atoms, args|
    server.shutdown("Host-Initiated Shutdown")
  }
  Database.define(["SHUTDOWN"], builtin_shutdown)
  server.run
rescue
  #TODO: Error Logging
  raise
end # error checking

puts "Exiting"
