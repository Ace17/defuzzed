#! /usr/bin/env rdmd
/**
 * @brief Generate a random D (valid) source file
 * @author Sebastien Alaiwan
 * @date 2016-04-02
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

import std.string;
import std.stdio;
import std.conv;
import std.math;
import std.random: unpredictableSeed, Random;

int main(string[] args)
{
  auto seed = unpredictableSeed;

  if(args.length > 1)
    seed = to!int (args[1]);

  string outputPath = "-";

  if(args.length > 2)
    outputPath = args[2];

  auto f = openOutput(outputPath);

  generateRandomSourceFile(seed, f);

  return 0;
}

File openOutput(string path)
{
  if(path == "-")
    return stdout;
  else
    return File(path, "w");
}

void generateRandomSourceFile(int seed, File f)
{
  gen.seed(seed);

  auto sc = new Scope;

  f.writefln("// generated by defuzzed, seed %s", seed);
  generateDeclarations(f, sc);
}

void generateDeclarations(File f, Scope sc)
{
  const numDecls = randomCount(sc);

  for(int i = 0; i < numDecls; ++i)
    generateDeclaration(f, sc);
}

void generateDeclaration(File f, Scope sc)
{
  generateRandomOne(f, sc,
                    [
                      &generateClass,
                      &generateUnion,
                      &generateStruct,
                      &generateFunction,
                      &generateInterface,
                    ]);
}

void generateClass(File f, Scope sc)
{
  string inheritFrom;

  if(false)
  {
    if(uniform(0, 2))
    {
      auto classes = sc.getVisibleClasses();
      if(classes.length > 0)
        inheritFrom = classes[uniform(0, $)];
    }
  }

  f.writef("class %s", sc.addClass());
  if(inheritFrom)
    f.writef(" : %s", inheritFrom);
  f.writeln();

  f.writefln("{");
  generateDeclarations(f, sc.sub());
  f.writefln("}");
}

void generateUnion(File f, Scope sc)
{
  f.writefln("union U%s", sc.allocName());
  f.writefln("{");
  //generateDeclarations(f, sc.sub());
  f.writefln("}");
}

void generateStruct(File f, Scope sc)
{
  f.writefln("struct S%s", sc.allocName());
  f.writefln("{");
  //generateDeclarations(f, sc.sub());
  f.writefln("}");
}

void generateInterface(File f, Scope sc)
{
  f.writefln("interface %s", sc.addClass());

  f.writefln("{");
  f.writefln("}");
}

void generateFunction(File f, Scope sc)
{
  const name = sc.addFunction();

  f.writefln("void %s()", name);

  auto sub = sc.sub();

  f.writefln("{");
  generateStatements(f, sub);
  generateDeclarations(f, sub);
  f.writefln("}");
}

void generateStatements(File f, Scope sc)
{
  const N = randomCount(sc);

  for(int i = 0; i < N; ++i)
    generateStatement(f, sc);
}

void generateStatement(File f, Scope sc)
{
  generateRandomOne(f, sc,
                    [
                      &generateFunctionCall,
                      &generateVarDecl,
                    ]);
}

void generateFunctionCall(File f, Scope sc)
{
  const functions = sc.getVisibleFunctions();

  if(functions.length == 0)
    return;

  const name = functions[uniform(0, $)];
  f.writefln("%s();", name);
}

void generateVarDecl(File f, Scope sc)
{
  if(uniform(0, 3))
  {
    string initializer;

    if(uniform(0, 3))
    {
      const varNames = sc.getVisibleVariables();

      if(varNames.length > 1)
        initializer = format(" = %s", varNames[uniform(0, $)]);
    }

    const name = sc.addVariable();
    const type = initializer ? "auto" : "int";
    f.writef("%s %s", type, name);
    f.write(initializer);
    f.writeln(";");
  }
  else
  {
    const funcNames = sc.getVisibleFunctions();
    if(funcNames.length > 0)
      f.writefln("auto %s = &%s;", sc.addVariable(), funcNames[uniform(0, $)]);
  }
}

void generateRandomOne(File f, Scope sc, void function(File f, Scope sc)[] genFuncs)
{
  auto generator = genFuncs[uniform(0, cast(int)$)];
  generator(f, sc);
}

///////////////////////////////////////////////////////////////////////////////
// generated program environment

class Scope
{
  Scope parent;

  struct Symbol
  {
    string name;
    uint flags;

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
    symbols ~= Symbol(name, Symbol.FL_CLASS);
    return name;
  }

  string addVariable()
  {
    const name = format("v%s", symbols.length);
    symbols ~= Symbol(name, Symbol.FL_VARIABLE);
    return name;
  }

  string addFunction()
  {
    const name = format("f%s", symbols.length);
    symbols ~= Symbol(name, Symbol.FL_FUNCTION);
    return name;
  }

  string[] getVisible(uint flags) const
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

///////////////////////////////////////////////////////////////////////////////
// random

int randomCount(Scope sc)
{
  int left, right;

  if(sc.depth <= 2)
  {
    left = 1;
    right = 6;
  }
  else if(sc.depth > 20)
  {
    left = 0;
    right = 2;
  }
  else
  {
    left = 1;
    right = 4;
  }

  return uniform(left, right);
}

Random gen;

int uniform(int min, long max)
{
  return std.random.uniform(min, cast(int)max, gen);
}

