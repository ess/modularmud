#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-08-28.
#  Copyright (c) 2007. All rights reserved.

class Atom
  
  attr_accessor :ancestor_list
  attr_reader :name, :parents 
  
  def initialize(name, parents)
    @name = name.gsub(" ", "").upcase
    @parents = []
    parents.each do |parent|
      @parents << parent.gsub(" ", "").upcase
    end
    @ancestor_list = nil
    @next_index = 0
  end
  
  def instance_name
    return "#{@name}##{@next_index += 1}"
  end
end

