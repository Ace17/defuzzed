/**
 * @brief Minimalistic semantic checker
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
import ast;
import ast_visit;
import scope_;

bool checkDeclaration(Declaration d, Scope sc = new Scope)
{
  return visitDeclaration!(
    checkClass,
    checkFunction,
    checkVariable)
           (d, sc);
}

bool checkClass(ClassDeclaration d, Scope sc)
{
  foreach(decl; d.declarations)
    if(!checkDeclaration(decl, sc))
      return false;

  return true;
}

bool checkFunction(FunctionDeclaration d, Scope sc)
{
  if(d.body_)
    if(!checkStatement(d.body_, sc))
      return false;

  return true;
}

bool checkVariable(VariableDeclaration d, Scope sc)
{
  auto syms = sc.getVisibleSymbols();

  foreach(sym; syms)
    if(sym.name == d.name)
      return false;

  if(d.initializer)
  {
    if(!checkExpression(d.initializer, sc))
      return false;
  }

  auto sym = Scope.Symbol(d.name, Scope.Symbol.FL_VARIABLE, "int");
  sc.addSymbol(sym);
  return true;
}

///////////////////////////////////////////////////////////////////////////////

bool checkStatement(Statement s, Scope sc)
{
  return visitStatement!(
    checkDeclarationS,
    checkBlock,
    checkWhile,
    checkIf)
           (s, sc);
}

bool checkDeclarationS(DeclarationStatement s, Scope sc)
{
  return checkDeclaration(s.declaration, sc);
}

bool checkBlock(BlockStatement s, Scope sc)
{
  auto subScope = sc.sub();

  foreach(stmt; s.sub)
    if(!checkStatement(stmt, subScope))
      return false;

  return true;
}

bool checkWhile(WhileStatement s, Scope sc)
{
  if(!checkExpression(s.condition, sc))
    return false;

  if(!checkStatement(s.body_, sc))
    return false;

  return true;
}

bool checkIf(IfStatement s, Scope sc)
{
  if(!checkExpression(s.condition, sc))
    return false;

  if(!checkStatement(s.thenBody, sc))
    return false;

  if(s.elseBody)
  {
    if(!checkStatement(s.elseBody, sc))
      return false;
  }

  return true;
}

///////////////////////////////////////////////////////////////////////////////

bool checkExpression(Expression e, Scope sc)
{
  return visitExpression!(
    checkNumber,
    checkBinary)
           (e, sc);
}

bool checkNumber(NumberExpression e, Scope sc)
{
  return true;
}

bool checkBinary(BinaryExpression e, Scope sc)
{
  return checkExpression(e.operands[0], sc) && checkExpression(e.operands[1], sc);
}

