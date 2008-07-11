#!/usr/bin/env ruby
#
#  Created by Greg Mefford on 2007-09-13.
#  Copyright (c) 2007. All rights reserved.

require 'core/hierarchy'
require 'core/atom'

class CodeStore
  # Storage for the code hierarchy
  @@code_db = Hash.new
  
  # This default code will be executed if the requested code does not match anything
  # It also gives the basic template for code:
  #   The block takes three parameters: |atoms, player, args|
  #   The block returns a status code, and a return value
  # -atoms- must be the list of Atom objects used to call the code
  # -args- should be any list of arguments to the code
  @@default_code = proc { |atoms, args|
    atom_names = []
    atoms.each do |atom|
      if atom.nil?
        atom_names << "!NIL!"
      else
        atom_names << "\"#{atom.name}\""
      end
    end
    return :error_undefined , "No code was defined for [#{atom_names.join(", ")}]!"
  }
  
  # CodeStore.call
  # Looks up the given code object in the hierarchy and then executes it
  # -atoms- can be a list of Atom objects, or strings representing them
  # -args- will be passed to the code along with the list of Atom objects.
  def CodeStore.call(atoms, args)
    atoms = lookup_atoms(atoms)
    return lookup(atoms).call(atoms, args)
  end # CodeStore.call
  
  # CodeStore.clear
  # Removes all the code from the hierarchy
  def CodeStore.clear
    @@code_db.clear
  end # CodeStore.clear
    
  # CodeStore.define
  # Associates a code block with a list of atoms.
  # -atoms- is a list of Atom objects, or strings representing them
  # -code- is a Proc or a String of code
  #   to put in the code block associated with the given Atoms
  def CodeStore.define(atoms, code)
    code = parse_code(code) if code.class == String
    # Fail if the code is not a Proc
    raise "Invalid code type.  Must be a String or Proc" if code.class != Proc
    # Get a pointer to the code hierarchy
    current_level = @@code_db
    atoms.each do |atom|
      # We just need the name of the Atoms (do nothing if it's already just a String)
      atom = atom.name if atom.class == Atom
      # Fail if something other than a String or Atom was given
      return nil if atom.class != String
      # If there hasn't already been any code defined under this Atom, create the Hash
      current_level[atom] = Hash.new if current_level[atom].nil?
      # Traverse into the deeper Hash
      current_level = current_level[atom]
    end # each atom
    # We have traversed through all the Atoms, now set the code block
    return current_level["#CODE#"] = code
  end # CodeStore.define

  # CodeStore.load
  # Loads a collection of code definitions from an Array of Strings
  # Format of the Array is a series of blocks like:
  # ATOM_1 ATOM_2 ATOM_3 ...
  # <CODE>
  # .
  # Outside of Code Blocks:
  #   Lines are stripped of leading and trailing white space
  #   Blank lines and lines beginning with a hash(#) are ignored
  # -lines- is an Arrays of Strings specifying the Atoms
  # Returns nil on success, or a String failure reason on failure
  def CodeStore.load(lines)
    # Whether or not we're parsing code
    code_flag = false
    atoms = []
    code_buffer = ""
    lines.each do |line|
      #puts "Loading Code Line: #{line}"
      if (code_flag)
        if (line =~ /^\.\n?$/)
          code_flag = false
          code = parse_code(code_buffer)
          # Return the failure reason if the code fails to parse
          return code if code.class == String
          # Define the code if the parse succeeded
          define(atoms, code)
          code_buffer = ""
        else
          code_buffer += line
        end # if line == "."
      else
        # Strip each line's leading and trailing whitespace
        line.strip!
        # Ignore blank lines and lines that begin with a hash
        unless line == "" or line[0].chr == '#'
          # Use this list of Atoms to define the code that follows
          atoms = line.split
          code_flag = true
        end # comment skipping
      end # if code_flag
    end # each line
    # Return nil on success
    return nil
  end # CodeStore.load
  
  # CodeStore.lookup
  # Finds and returns the code associated with a list of Atoms, if any exists
  # -atoms- can be a list of Atom objects, or strings representing them
  def CodeStore.lookup(atoms)
    # Use the recursive helper function to look up the code in the hierarchy
    code = lookup_helper(@@code_db, atoms)
    # Either return the code found or the default code
    if code.nil?
      return @@default_code
    else
      return code
    end
  end # CodeStore.lookup
    
  # CodeStore.lookup_helper
  # Recursive helper function for CodeStore.lookup
  # -db_level- is the code hierarchy hash to start the search at
  # -atoms- can be a list of Atom objects, or strings representing them
  # Implements the following lookup algorithm:
  #   Match the atoms in the list from left to right with the code hierarchy definitions
  #   In case of failure, back out and retry with next ancestor of the previous Atom
  #   In case of failure with no more ancestors to try, return nil
  def CodeStore.lookup_helper(db_level, atoms)
    # Make a copy of the first atom
    atom = atoms[0]
    # Make a copy of the rest of the list
    atom_list = atoms[1..-1]
    # Make sure we're working with an Atom object
    atom = Hierarchy.lookup(atom) if atom.class != Atom
    # Fail if we don't have a valid Atom object
    return nil if atom.nil?
    # Allow backing out to each of the Atom's ancestors
    Hierarchy.calculate_ancestors(atom).each do |ancestor|
      # Try to traverse to a deeper hierarchy level
      next_level = db_level[ancestor.name]
      if !next_level.nil?
        # There was a match
        if atom_list.length == 0
          # This is the last Atom in the list, return the code defined here
          return next_level["#CODE#"]
        else
          # Dig deeper into the hierarchy, looking for the rest of the Atoms
          code = lookup_helper(next_level, atom_list)
          # Return the code if any was found deeper in the hierarchy
          return code if !code.nil?
        end # atoms.length == 0
      end # !next_level.nil?
    end # ancestors
    # Fail if no matching code was found
    return nil
  end # CodeStore.lookup_helper
  
  # CodeStore.lookup_atoms
  # Returns a list of Atom objects represented by -atoms-
  # -atoms- can be a list of Atom objects, or strings representing them
  # -ignore_nil- can be set to true to return nils for failed lookups instead of failing
  # Raises an error on failed hierarchy lookup, unless ignore_nil is true
  def CodeStore.lookup_atoms(atoms, ignore_nil=false)
    atom_list = []
    atoms.each do |item|
      # Make sure each atom is actually an Atom class
      if item.class == Atom
        atom_list << item
      elsif item.class == String
        # Look up the Atom (will be nil if undefined)
        item = item.upcase
        atom = Hierarchy.lookup(item)
        # Fail if an Atom was not defined
        raise "Atom '#{item}' not defined" if !ignore_nil and atom.nil?
        atom_list << atom
      end # if atom.class == Atom
    end # each atom
    return atom_list
  end # CodeStore.lookup_atoms
  
  # CodeStore.parse_code
  # Parses a properly formated String into a Proc
  # -code_string- is the String body of the code to go in the Proc
  # Returns the Proc on success, or the error String on failure
  def CodeStore.parse_code(code_string)
    begin
      raise "code_string must be a String" if code_string.class != String
      code = proc { |atoms, args|
        eval code_string
      }
      return code
    rescue
      return $!
    end
  end # CodeStore.parse_code
  
  # CodeStore.undefine
  # Removes a code block from the code store
  # -atoms- is the list of Atoms, or a list of Strings representing them, to be removed
  def CodeStore.undefine(atoms)
    return undefine_helper(@@code_db, atoms)    
  end # CodeStore.undefine
  
  # CodeStore.undefine_helper
  # Recursively removes a code block from the code store
  # -db_level- is the nested Hash to start at
  # -atoms- is the list of Atoms, or a list of Strings representing them, to be removed below db_level
  def CodeStore.undefine_helper(db_level, atoms)
    atom = atoms[0]
    if atom.class == Atom
      atom = atom.name
    elsif atom.class != String
      return "Invalid Atom identifier: '#{atom}'"
    end
    next_level = db_level[atom]
    return "Code not found" if next_level.nil?
    if atoms.length == 1
      next_level.delete("#CODE#")
    else
      result = undefine_helper(next_level, atoms[1..-1])
      return result unless result.nil?
    end
    db_level.delete(atom) if next_level.size == 0
    return nil
  end # undefine_helper
  
end # CodeStore