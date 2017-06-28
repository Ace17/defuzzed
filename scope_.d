/**
 * @brief Scope for the generated program
 * @author Sebastien Alaiwan
 */

/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This file is part of defuzzed, a fuzzer for D compilers;
 */

import std.algorithm;
import std.string;

class Scope
{
  bool onlyStaticInitializers;
  Scope parent;

  struct Symbol
  {
    string name;
    uint flags;
    string type;

    enum FL_CLASS = 1;
    enum FL_VARIABLE = 2;
    enum FL_FUNCTION = 4;
  }

  Symbol[] symbols;

  int depth() const
  {
    if(parent)
      return 1 + parent.depth();
    else
      return 0;
  }

  Scope sub()
  {
    auto sc = new Scope;
    sc.parent = this;
    return sc;
  }

  string allocName()
  {
    static int id;
    ++id;
    return format("i%s", id++);
  }

  string addClass()
  {
    const name = format("C%s", symbols.length);
    addClass(name);
    return name;
  }

  void addClass(string name)
  {
    symbols ~= Symbol(name, Symbol.FL_CLASS);
  }

  void addSymbol(Symbol sym)
  {
    symbols ~= sym;
  }

  string addVariable(string type = "int")
  {
    for(int i = 0;; ++i)
    {
      const name = format("v%s_%s", symbols.length, i);

      if(canFind(getVisible(Symbol.FL_VARIABLE), name))
        continue;

      symbols ~= Symbol(name, Symbol.FL_VARIABLE, type);
      return name;
    }
  }

  string addFunction()
  {
    const name = format("f%s", symbols.length);
    addFunction(name);
    return name;
  }

  void addFunction(string name)
  {
    symbols ~= Symbol(name, Symbol.FL_FUNCTION);
  }

  Symbol[] getVisibleSymbols() const
  {
    auto r = symbols.dup;

    if(parent)
      r ~= parent.getVisibleSymbols();

    return r;
  }

  string[] getVisible(uint flags = ~0) const
  {
    auto r = getVisibleLocal(flags);

    if(parent)
      r ~= parent.getVisible(flags);

    return r;
  }

  string[] getVisibleLocal(uint flags) const
  {
    string[] r;

    foreach(sym; symbols)
      if(sym.flags & flags)
        r ~= sym.name;

    return r;
  }

  string[] getVisibleClasses() const
  {
    return getVisible(Symbol.FL_CLASS);
  }

  string[] getVisibleVariables() const
  {
    return getVisible(Symbol.FL_VARIABLE);
  }

  string[] getVisibleFunctions() const
  {
    return getVisible(Symbol.FL_FUNCTION);
  }
}

