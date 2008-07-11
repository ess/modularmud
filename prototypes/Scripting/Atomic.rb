#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-27.
#  Copyright (c) 2007. All rights reserved.

class AtomicEngine
  
  def initialize
    @db = {}
  end #initialize
  
  def get(atom_list)
    current = @db
    atom_list.each do |atom|
      if (current.has_key?(atom))
        current = db{atom}
        puts "Found #{atom}"
      end
    end
  end