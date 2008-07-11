#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-18.
#  Copyright (c) 2007. All rights reserved.

require '../../core/atom.rb'
require 'pp'

f = File.open('blank_code.txt')
str = f.read
f.close

str2 = "50"
p = proc { |atoms, player, args|
  eval str
}

status, result = p.call([Atom.new("one", [""]),Atom.new("two", [""]),Atom.new("three", [""])], nil, [])

puts status
puts result