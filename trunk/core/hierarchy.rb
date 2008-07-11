#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-13.
#  Copyright (c) 2007. All rights reserved.

require 'core/atom'

class Hierarchy
  # Storage for Atom hierarchy
  @@atoms = Hash.new
  
  # Hierarchy.clear
  # Removes all the Atoms from the hierarchy
  def Hierarchy.clear
    @@atoms.clear
  end # clear
  
  # Hierarchy.load
  # Loads a hierarchy of Atoms from an Array of configuration Strings
  # Format of the Array is a series of lines like:
  # ATOM_NAME PARENT_ATOM_1 PARENT_ATOM_2 ...
  # Lines are stripped of leading and trailing white space
  # Blank lines and lines beginning with a hash(#) are ignored
  # -lines- is an Arrays of Strings specifying the Atoms
  def Hierarchy.load(lines)
    lines.each do |line|
      # Strip each line's leading and trailing whitespace
      line.strip!
      # Ignore blank lines and lines that begin with a hash
      unless line == "" or line[0].chr == '#'
        # Register the first 'word' as the Atom name, and the rest as parents
        tokens = line.split
        # Fail if one of the Atoms fails to register, returning the offending line
        return line if register(tokens[0], tokens[1..-1]).nil?
      end # comment skipping
    end # each line
    # Return nil on success
    return nil
  end # load
  
  # Hierarchy.register
  # Defines an Atom and its list of parents in the hierarchy
  # -name- is the String representing the Atom
  # -parents- is a list of Strings representing each of the Atom's parent Atoms
  # Returns the registered Atom on success
  def Hierarchy.register(name, parents)
    # Instantiate the Atom
    atom = Atom.new(name, parents)
    result = calculate_ancestors(atom)
    if result.nil?
      return nil
    else
      # Ancestor calculation didn't fail, put it in the hierarchy and return it
      @@atoms[atom.name] = atom
      return atom
    end
  end # register
  
  # Hierarchy.remove
  # Removes the given Atom from the hierarchy
  # -atom- is either the name of the Atom to delete, or the atom itself
  def Hierarchy.remove(atom)
    atom = atom.name if atom.class == Atom
    @@atoms.delete(atom)
  end # delete
  
  # Hierarchy.lookup
  # Returns the Atom associated with the specified name
  # -name- is the String representing the Atom to look up
  def Hierarchy.lookup(name)
    return @@atoms[name]
  end # lookup

  # Hierarchy.calculate_ancestors
  # Returns the ancestor list of the given Atom, calculating it if it hasn't been yet
  # -atom- is either an Atom object, or a String representing an Atom
  # -force_recalc- (optional) forces recalculation if provided and true
  def Hierarchy.calculate_ancestors(atom, force_recalc=false)
    # Lookup the Atom if it's not already an Atom
    atom = Hierarchy.lookup(atom) if atom.class != Atom
    # Fail if the Atom was invalid
    return nil if atom.nil?
    # Just return the list if it's already calculated and we're not being forced
    return atom.ancestor_list unless ( force_recalc or atom.ancestor_list.nil? )
    # Put yourself first
    ancestors = [atom]
    # Foreach parent
    atom.parents.each do |parent_name|
      # Look up the actual class
      parent = lookup(parent_name)
      # Give up if this parent isn't in the hierarchy
      if parent.nil?
        puts "WARN: Failed to calculate ancestors for '#{atom.name}': unable to lookup '#{parent_name}'."
        return nil
      end
      # Foreach ancestor of the parent
      calculate_ancestors(parent).each do |ancestor|
        # Make sure there are no duplicates, and append it to the list
        ancestors.delete(ancestor)
        ancestors << ancestor
      end # each ancestor
    end # each parent
    return atom.ancestor_list = ancestors
  end # calculate_ancestors
  
  # Hierarchy.instantiate
  # Registers and returns a uniquely-named child of the specified Atom
  # -atom- is either an Atom object or a String representing the Atom
  def Hierarchy.instantiate(atom)
    # Lookup the Atom if it's not already an Atom
    atom = Hierarchy.lookup(atom) if atom.class != Atom
    # Fail if the Atom was invalid
    return nil if atom.nil?
    # If the Atom was valid, get the next unique name and register the new child
    return register(atom.instance_name, [atom.name])
  end # instantiate
  
end # Hierarchy