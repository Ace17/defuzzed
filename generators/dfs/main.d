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
import std.format;
import entropy;
import scope_;

void depthFirstGenerate(File f)
{
  auto tree = generate();
  f.write(tree.lexem);
}

private:

struct Node
{
  string lexem;
}

struct Context
{
  Scope sc;
  alias sc this;

  Context sub()
  {
    return Context(sc.sub());
  }
}

Node generate()
{
  Context sc;
  sc.sc = new Scope;
  return generateDeclarations(sc);
}

Node generateDeclarations(Context sc)
{
  const numDecls = randomCount(sc.depth);

  Node r;

  for(int i = 0; i < numDecls; ++i)
    r.lexem ~= generateDeclaration(sc).lexem;

  return r;
}

Node generateDeclaration(Context sc)
{
  return callRandomOne(
      [
      &generateClass,
      &generateUnion,
      &generateStruct,
      &generateFunction,
      &generateInterface,
      ], sc);
}

Node generateClass(Context sc)
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

  Node r;

  r.lexem ~= format("class %s", sc.addClass());

  if(inheritFrom)
    r.lexem ~= format(" : %s", inheritFrom);

  r.lexem ~= "\n";

  r.lexem ~= "{\n";
  r.lexem ~= generateDeclarations(sc.sub()).lexem;
  r.lexem ~= "}\n";

  return r;
}

Node generateUnion(Context sc)
{
  Node r;
  r.lexem ~= format("union U%s\n", sc.allocName());
  r.lexem ~= "{\n";
  // r.lexem ~= generateDeclarations(sc.sub()).lexem;
  r.lexem ~= "}\n";
  return r;
}

Node generateStruct(Context sc)
{
  Node r;
  r.lexem ~= format("struct S%s\n", sc.allocName());
  r.lexem ~= "{\n";
  // r.lexem ~= generateDeclarations(sc.sub()).lexem;
  r.lexem ~= "}\n";
  return r;
}

Node generateInterface(Context sc)
{
  Node r;
  r.lexem ~= format("interface %s\n", sc.addClass());

  r.lexem ~= "{\n";
  r.lexem ~= "}\n";
  return r;
}

Node generateFunction(Context sc)
{
  const name = sc.addFunction();

  Node r;
  r.lexem ~= format("void %s()\n", name);

  auto sub = sc.sub();

  r.lexem ~= "{\n";
  r.lexem ~= generateStatements(sub).lexem;
  r.lexem ~= generateDeclarations(sub).lexem;
  r.lexem ~= "}\n";
  return r;
}

Node generateStatements(Context sc)
{
  Node r;
  const N = randomCount(sc.depth);

  for(int i = 0; i < N; ++i)
    r.lexem ~= generateStatement(sc).lexem;
  return r;
}

Node generateStatement(Context sc)
{
  return callRandomOne(
      [
      &generateFunctionCall,
      &generateIfStatement,
      &generateForLoop,
      &generateVarDecl,
      ],
      sc);
}

Node generateFunctionCall(Context sc)
{
  Node r;
  const functions = sc.getVisibleFunctions();

  if(functions.length == 0)
    return r;

  const name = functions[uniform(0, $)];
  r.lexem ~= format("%s();", name);
  return r;
}

Node generateVarDecl(Context sc)
{
  Node r;
  if(uniform(0, 3))
  {
    string initializer;

    if(uniform(0, 3))
      initializer = getRandomRValue(sc);

    const name = sc.addVariable();
    const type = initializer ? "auto" : "int";
    r.lexem ~= format("%s %s", type, name);

    if(initializer)
      r.lexem ~= format("= %s", initializer);

    r.lexem ~= ";\n";
  }
  else
  {
    auto funcSymbols = filter!(a => a.flags & Scope.Symbol.FL_FUNCTION)(sc.getVisibleSymbols());

    if(!funcSymbols.empty)
    {
      const funcName = pickRandom(funcSymbols).name;
      r.lexem ~= format("auto %s = &%s;", sc.addVariable("delegate"), funcName);
    }
  }
  return r;
}

Node generateIfStatement(Context sc)
{
  const condition = getRandomRValue(sc);

  Node r;

  r.lexem ~= format("if(%s)", condition);
  r.lexem ~= "{\n";
  generateStatements(sc.sub());
  r.lexem ~= "}\n";

  if(uniform(0, 20) == 0)
  {
    r.lexem ~= "else";
    r.lexem ~= "{\n";
    generateStatements(sc.sub());
    r.lexem ~= "}\n";
  }

  return r;
}

Node generateForLoop(Context sc)
{
  const itName = sc.allocName();

  const init = getRandomRValue(sc);
  const end = getRandomRValue(sc);

  Node r;
  r.lexem ~= format("for(int %s=%s;%s < %s;++%s)\n", itName, init, itName, end, itName);
  r.lexem ~= "{\n";
  r.lexem ~= generateStatements(sc.sub()).lexem;
  r.lexem ~= "}\n";
  return r;
}

string getRandomRValue(Context sc)
{
  static bool isIntVariable(Scope.Symbol s)
  {
    return s.flags & Scope.Symbol.FL_VARIABLE && s.type == "int";
  }

  auto variables = filter!isIntVariable(sc.getVisibleSymbols());
  return variables.empty ? "0" : pickRandom(variables).name;
}

