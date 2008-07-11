#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-19.
#  Copyright (c) 2007. All rights reserved.

require 'core/hierarchy'
require 'core/code_store'

class Database
  
  @@runtime_atoms = []
  @@runtime_code = []
  
  # Database.define
  # Associates a code block with a list of atoms.
  # -atoms- is a list of Atom objects, or strings representing them
  # -code- is a Proc or a String of code
  #   to put in the code block associated with the given Atoms
  def Database.define(atoms, code)
    return CodeStore.define(atoms, code)
  end # define
  
  # Database.call
  # Looks up the given code object in the hierarchy and then executes it
  # -atoms- can be a list of Atom objects, or strings representing them
  # -args- will be passed to the code along with the list of Atom objects.
  def Database.call(atoms, args=[])
    return CodeStore.call(atoms, args)
  end # call
  
  # Database.undefine
  # Removes a code block from the code store
  # -atoms- is the list of Atoms, or a list of Strings representing them, to be removed
  def Database.undefine(atoms)
    return CodeStore.undefine(atoms)
  end # undefine
  
  
  # Database.instantiate
  # Registers and returns a uniquely-named child of the specified Atom
  # -atom- is either an Atom object or a String representing the Atom
  def Database.create(atom)
    return Hierarchy.instantiate(atom)
  end # create
  
  # Database.lookup
  # Returns the code associated with a list of Atoms, or the Atom associated with a String
  # -item- can be a single String, or list of Atom objects or Strings representing them
  def Database.lookup(item)
    if item.class == Array
      return CodeStore.lookup(item)
    elsif item.class == String
      return Hierarchy.lookup(item)
    end
    return nil
  end # lookup
  
  # Database.remove
  # Removes the given Atom from the hierarchy
  # -atom- is either the name of the Atom to delete, or the atom itself
  def Database.destroy(atom)
    return Hierarchy.remove(atom)
  end # destroy
  
end # Database