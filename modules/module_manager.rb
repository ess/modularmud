#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-16.
#  Copyright (c) 2007. All rights reserved.

require 'core/hierarchy'
require 'core/code_store'

class ModuleManager
  
  @@loaded_modules = []
  
  # ModuleManager.load
  # Loads the module in the specified directory from the files:
  #   requires.txt - loading will fail if any of these modules are not loaded
  #   atoms.txt - loading will fail if any of these Atom descriptions fails to load
  #   code.txt - loading will fail if any of these Code definitions fails to load
  # -mod_name- is the name of the module directory
  # Returns nil on success, or an error description on failure
  def ModuleManager.load(mod_name)
    begin
      files = []
      ["requires", "atoms", "code"].each do |file|
        f = File.open("modules/#{mod_name}/#{file}.txt")
        files << f.read
        f.close
      end # each file
      requires, atoms, code = files
      requires.each do |mod|
        # Strip each line's leading and trailing whitespace
        mod.strip!
        # Ignore blank lines and lines that begin with a hash
        next if mod == "" or mod[0].chr == '#'
        # Assert that the module is loaded
        raise "Required module '#{mod}' not loaded" unless loaded?(mod)
      end # require checking
      result = Hierarchy.load(atoms)
      raise "Atom-parsing error near: '#{result}'" unless result.nil?
      result = CodeStore.load(code)
      raise "Code-parsing error near: #{result}" unless result.nil?
      @@loaded_modules << mod_name
    rescue
      return "Failed to load module '#{mod_name}': #{$!}"
    end
    # Return nil on success
    return nil
  end # ModuleManager.load
  
  # ModuleManager.loaded?
  # Returns whether or not a given module has been successfully loaded
  # -mod_name- is the String module name to check for
  def ModuleManager.loaded?(mod_name)
    return !@@loaded_modules.index(mod_name).nil?
  end # ModuleManager.loaded?
  
end # ModuleManager