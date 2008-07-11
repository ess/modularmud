#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-10.
#  Copyright (c) 2007. All rights reserved.

require 'test/unit'
require 'core/hierarchy'

class TC_Hierarchy < Test::Unit::TestCase

  def setup
    Hierarchy.clear
  end
  
  def teardown
    Hierarchy.clear
  end
  
  def test_hierarchy
    atom = Hierarchy.lookup("TEST_ATOM")
    assert(atom.nil?, "Hierarchy.lookup: Un-initialized Hierarchy returned Atom.")
    
    Hierarchy.register("-ROOT-", "")
    result = Hierarchy.register("TEST_ATOM", ["-ROOT-"])
    assert(result, "Hierarchy.register: Unexpected failure.")
    
    atom = Hierarchy.lookup("TEST_ATOM")
    assert(!atom.nil?, "Hierarchy.lookup: Unexpected nil.")
    assert(atom.name == "TEST_ATOM", "Hierarchy.lookup: Wrong Atom name.")
    assert(atom.parents == ["-ROOT-"], "Hierarchy.lookup: Wrong Atom parents.")
    
    ancestors = Hierarchy.calculate_ancestors(atom)
    assert(!ancestors.nil?, "Hierarchy.calculate_ancestors: Unexpected failure.")
    assert(ancestors.length == 2, "Hierarchy.calculate_ancestors: Calculated wrong number of ancestors. Expected 2, found #{ancestors.length}.")
    assert(ancestors[0].name == "TEST_ATOM", "Hierarchy.calculate_ancestors: Atom's first ancestor is not itself.")
    assert(ancestors[1].name == "-ROOT-", "Hierarchy.calculate_ancestors: Atom's second ancestor is not '-ROOT-'.")
    
    inst = Hierarchy.instantiate(atom)
    assert(!inst.nil?, "Hierarchy.instantiate: Unexpected nil return value.")
    assert(inst.name == "TEST_ATOM#1", "Hierarchy.instantiate: Instance name set incorrectly.")
    assert(inst.parents == ["TEST_ATOM"], "Hierarchy.instantiate: Atom parents set incorrectly.")

    ancestors = Hierarchy.calculate_ancestors(inst)
    assert(!ancestors.nil?, "Hierarchy.calculate_ancestors: Unexpected failure.")
    assert(ancestors.length == 3, "Hierarchy.calculate_ancestors: Calculated wrong number of ancestors. Expected 3, found #{ancestors.length}.")
    assert(ancestors[0].name == "TEST_ATOM#1", "Hierarchy.calculate_ancestors: Atom's first ancestor is not itself.")
    assert(ancestors[1].name == "TEST_ATOM", "Hierarchy.calculate_ancestors: Atom's second ancestor is not 'TEST_ATOM'.")
    assert(ancestors[2].name == "-ROOT-", "Hierarchy.calculate_ancestors: Atom's third ancestor is not '-ROOT-'.")
    
    Hierarchy.clear
    atom = Hierarchy.lookup("TEST_ATOM")
    assert(atom.nil?, "Hierarchy.lookup: Expected nil, returned Atom.")
  end

end