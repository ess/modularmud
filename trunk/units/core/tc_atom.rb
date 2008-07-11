#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-10.
#  Copyright (c) 2007. All rights reserved.

require 'test/unit'
require 'core/atom'

class TC_Atom < Test::Unit::TestCase

  def setup
  end
  
  def teardown
  end
  
  def test_atom
    atom = Atom.new("TEST_ATOM", ["-ROOT-"])
    assert(!atom.nil?, "Atom.new: Initialization failed unexpectedly.")
    assert(atom.name == "TEST_ATOM", "Atom.new: Atom name set incorrectly.")
    assert(atom.parents == ["-ROOT-"], "Atom.new: Atom parents set incorrectly.")
    
    inst_name = atom.instance_name
    assert(inst_name == "TEST_ATOM#1", "Atom.instance_name: Instance name set incorrectly.")
  end

end
