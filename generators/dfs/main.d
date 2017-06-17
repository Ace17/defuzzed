/**
 * @file dfs_generator.d
 * @brief Explicit non-AST based generator.
 * @author Sebastien Alaiwan
 * @date 2016-04-12
 */

/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */

module generators.dfs.main;

import std.stdio;
import std.algorithm;
import entropy;
import scope_;

void depthFirstGenerate(File f)
{
  auto sc = new Scope;
  generateDeclarations(f, sc);
}

void generateDeclarations(File f, Scope sc)
{
  const numDecls = randomCount(sc.depth);

  for(int i = 0; i < numDecls; ++i)
    generateDeclaration(f, sc);
}

void generateDeclaration(File f, Scope sc)
{
  callRandomOne(
    [
      &generateClass,
      &generateUnion,
      &generateStruct,
      &generateFunction,
      &generateInterface,
    ], f, sc);
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
  // generateDeclarations(f, sc.sub());
  f.writefln("}");
}

void generateStruct(File f, Scope sc)
{
  f.writefln("struct S%s", sc.allocName());
  f.writefln("{");
  // generateDeclarations(f, sc.sub());
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
  const N = randomCount(sc.depth);

  for(int i = 0; i < N; ++i)
    generateStatement(f, sc);
}

void generateStatement(File f, Scope sc)
{
  callRandomOne(
    [
      &generateFunctionCall,
      &generateIfStatement,
      &generateForLoop,
      &generateVarDecl,
    ],
    f, sc);
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
      initializer = getRandomRValue(sc);

    const name = sc.addVariable();
    const type = initializer ? "auto" : "int";
    f.writef("%s %s", type, name);

    if(initializer)
      f.writef("= %s", initializer);

    f.writeln(";");
  }
  else
  {
    auto funcSymbols = filter!(a => a.flags & Scope.Symbol.FL_FUNCTION)(sc.getVisibleSymbols());

    if(!funcSymbols.empty)
    {
      const funcName = pickRandom(funcSymbols).name;
      f.writefln("auto %s = &%s;", sc.addVariable("delegate"), funcName);
    }
  }
}

void generateIfStatement(File f, Scope sc)
{
  const condition = getRandomRValue(sc);

  f.writefln("if(%s)", condition);
  f.writefln("{");
  generateStatements(f, sc.sub());
  f.writefln("}");

  if(uniform(0, 20) == 0)
  {
    f.writefln("else");
    f.writefln("{");
    generateStatements(f, sc.sub());
    f.writefln("}");
  }
}

void generateForLoop(File f, Scope sc)
{
  const itName = sc.allocName();

  const init = getRandomRValue(sc);
  const end = getRandomRValue(sc);

  f.writefln("for(int %s=%s;%s < %s;++%s)", itName, init, itName, end, itName);
  f.writefln("{");
  generateStatements(f, sc.sub());
  f.writefln("}");
}

string getRandomRValue(Scope sc)
{
  auto variables = filter!isIntVariable(sc.getVisibleSymbols());
  return variables.empty ? "0" : pickRandom(variables).name;
}

static bool isIntVariable(Scope.Symbol s)
{
  return s.flags & Scope.Symbol.FL_VARIABLE && s.type == "int";
}

