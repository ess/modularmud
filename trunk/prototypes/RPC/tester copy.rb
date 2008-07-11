#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-18.
#  Copyright (c) 2007. All rights reserved.

require "xmlrpc/client"
require "pp"

server = XMLRPC::Client.new("localhost", "/RPC2", 3002)
begin

50.times do
    
  ok, param = server.call2("db.set", 1, "foo", "bar", 10)
  if ok
    pp param
  else
    puts "error: #{param.faultString}(#{param.faultCode})"
  end

  ok, param = server.call2("db.get_obj", 1)
  if ok
    pp param
  else
    puts "error: #{param.faultString}(#{param.faultCode})"
  end

  ok, param = server.call2("db.delete_pack", 1, "foo")
  if ok
    pp param
  else
    puts "error: #{param.faultString}(#{param.faultCode})"
  end
  
  ok, param = server.call2("db.get_obj", 1)
  if ok
    pp param
  else
    puts "error: #{param.faultString}(#{param.faultCode})"
  end
  
  ok, param = server.call2("db.get_pack", 1, "foo")
  if ok
    pp param
  else
    puts "error: #{param.faultString}(#{param.faultCode})"
  end
  
end
rescue XMLRPC::FaultException => e
  puts "Error:"
  puts e.faultCode
  puts e.faultString
end