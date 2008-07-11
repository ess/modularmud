#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-11.
#  Copyright (c) 2007. All rights reserved.

require 'core/code_store'
require 'core/hierarchy'

class TC_code_store < Test::Unit::TestCase

  def setup
    Hierarchy.clear
    Hierarchy.register("-ROOT-", "")
    result = Hierarchy.register("ATTRIBUTE", ["-ROOT-"])
    result = Hierarchy.register("STRENGTH", ["ATTRIBUTE"])
    result = Hierarchy.register("DEXTERITY", ["ATTRIBUTE"])
    result = Hierarchy.register("INTELLIGENCE", ["ATTRIBUTE"])
    
    result = Hierarchy.register("PLAYER", ["-ROOT-"])
    
    result = Hierarchy.register("CREATURE", ["-ROOT-"])
    result = Hierarchy.register("HUMANOID", ["CREATURE"])
    result = Hierarchy.register("GOBLINOID", ["CREATURE"])
    result = Hierarchy.register("GOBLIN", ["GOBLINOID"])
    result = Hierarchy.register("HUMAN", ["HUMANOID"])
    result = Hierarchy.register("DWARF", ["HUMANOID"])
    result = Hierarchy.register("FERGGO", ["DWARF", "PLAYER"])
  end
  
  def teardown
    Hierarchy.clear
  end
  
  def test_code_store
    ferggo = Hierarchy.lookup("FERGGO")
    strength = Hierarchy.lookup("STRENGTH")

    code = CodeStore.lookup([strength, ferggo])
    assert(!code.nil?, "CodeStore.lookup: Unexpected failure.")
    
    p = proc { |atoms, args| return :success , 50}
    code = CodeStore.define(["ATTRIBUTE", "CREATURE"], p)
    assert(!code.nil?, "CodeStore.define: Unexpected failure.")
    
    success, result = code.call([strength, ferggo], [ferggo])
    assert(success == :success, "Unexpected code failure.")
    assert(result == 50, "Expected result 50, found #{result}")

    success, result = CodeStore.call(["ATTRIBUTE", "CREATURE"], [ferggo])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 50, "CodeStore.call: Expected result 50, found #{result}")
    
    success, result = CodeStore.call([strength, ferggo], [ferggo])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}, #{result}")
    assert(result == 50, "CodeStore.call: Expected result 50, found #{result}")

    CodeStore.clear
    success, result = CodeStore.call(["ATTRIBUTE", "CREATURE"], [ferggo])
    assert(success == :error_undefined, "CodeStore.call: Unexpected code success. #{success}")

  end
  
  def test_inheritance
    CodeStore.define(["ATTRIBUTE", "CREATURE"], "return :success, 50")

    CodeStore.define(["ATTRIBUTE", "HUMANOID"], "return :success, 60")

    CodeStore.define(["DEXTERITY", "CREATURE"], "return :success, 40")

    CodeStore.define(["INTELLIGENCE", "HUMAN"], "return :success, 100")

    success, result = CodeStore.call(["STRENGTH", "HUMAN"], [])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 60, "CodeStore.call: Unexpected result: #{result}")

    success, result = CodeStore.call(["DEXTERITY", "HUMAN"], [])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 40, "CodeStore.call: Unexpected result: #{result}")
        
    success, result = CodeStore.call(["INTELLIGENCE", "HUMAN"], [])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 100, "CodeStore.call: Unexpected result: #{result}")
        
    success, result = CodeStore.call(["STRENGTH", "GOBLIN"], [])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 50, "CodeStore.call: Unexpected result: #{result}")
        
    success, result = CodeStore.call(["DEXTERITY", "GOBLIN"], [])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 40, "CodeStore.call: Unexpected result: #{result}")
        
    success, result = CodeStore.call(["INTELLIGENCE", "GOBLIN"], [])
    assert(success == :success, "CodeStore.call: Unexpected code failure. #{success}")
    assert(result == 50, "CodeStore.call: Unexpected result: #{result}")
        
    success, result = CodeStore.call(["STRENGTH", "INTELLIGENCE"], [])
    assert(success == :error_undefined, "CodeStore.call: Unexpected code success. #{success}")
        
  end  

end
