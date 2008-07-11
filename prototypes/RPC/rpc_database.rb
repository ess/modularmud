#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-18.
#  Copyright (c) 2007. All rights reserved.

require "xmlrpc/server"

################################################################################
#  Exceptions
################################################################################
E_ObjNotFound = XMLRPC::FaultException.new(1, "Object Not Found")
E_PackNotFound = XMLRPC::FaultException.new(2, "Package Not Found")
E_PropNotFound = XMLRPC::FaultException.new(3, "Property Not Found")

################################################################################
#  Server Initialization
################################################################################
db_server = XMLRPC::Server.new(3002) 

################################################################################
#  In-Memory Cache
################################################################################
$cache = Hash.new

################################################################################
#  Getters
################################################################################
db_server.add_handler("db.get") do |object, package, property|
  out = $cache[object]
  unless out
    raise E_ObjNotFound
  end
  out = out[package]
  unless out
    raise E_PackNotFound
  end
  out = out[property]
  unless out
    raise E_PropNotFound
  end
  out
end

db_server.add_handler("db.get_pack") do |object, package|
  out = $cache[object]
  unless out
    raise E_ObjNotFound
  end
  out = out[package]
  unless out
    raise E_PackNotFound
  end
  out
end

db_server.add_handler("db.get_obj") do |object|
  out = $cache[object]
  unless out
    raise E_ObjNotFound
  end
  out
end

################################################################################
#  Setters
################################################################################
db_server.add_handler("db.set") do |object, package, property, value|
  unless $cache.has_key?(object)
    $cache[object] = Hash.new
  end
  unless $cache[object].has_key?(package)
    $cache[object][package] = Hash.new
  end
  $cache[object][package][property] = value
end 

db_server.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, 
    "Method #{name} missing or wrong number of parameters!")
end

################################################################################
#  Deleters
################################################################################
db_server.add_handler("db.delete") do |object, package, property|
  raise E_ObjNotFound if not $cache.has_key?(object)
  temp = $cache[object]
  raise E_PackNotFound if not temp.has_key?(package)
  temp = temp[package]
  raise E_PropNotFound if not temp.has_key?(property)
  temp.delete(property)
end
  
db_server.add_handler("db.delete_pack") do |object, package|
  raise E_ObjNotFound if not $cache.has_key?(object)
  temp = $cache[object]
  raise E_PackNotFound if not temp.has_key?(package)
  temp.delete(package)
end
  
db_server.add_handler("db.delete_obj") do |object|
  raise E_ObjNotFound if not $cache.has_key?(object)
  $cache.delete(object)
end
  

db_server.add_multicall
db_server.serve