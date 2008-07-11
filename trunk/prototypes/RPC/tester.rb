#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-18.
#  Copyright (c) 2007. All rights reserved.

require "xmlrpc/client"
require "pp"

server = XMLRPC::Client.new("localhost", "/RPC2", 3002)
begin

50.times do
  
  params = server.multicall(
    ["db.set", 1, 1, 1, 10],
    ["db.get_obj", 1],
    ["db.delete_pack", 1, 1],
    ["db.get_obj", 1],
    ["db.get_pack", 1, 1]
    )
  params.each do |param|
    pp param
  end
  
end
rescue XMLRPC::FaultException => e
  puts "Error:"
  puts e.faultCode
  puts e.faultString
end