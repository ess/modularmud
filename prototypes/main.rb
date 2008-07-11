#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-30.
#  Copyright (c) 2007. All rights reserved.

require '../Atoms/Hierarchy'
require 'pp'

Hierarchy::load('../Atoms/Atoms.txt')

Hierarchy::lookup("JAB").ancestor_list.reverse.each do |ancestor|
  puts ancestor.name
end
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("CONTAINER").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("CONTAINER").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("CONTAINER").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
puts Hierarchy::lookup("DWARF").instance_of.name
