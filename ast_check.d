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

bool checkStatement(Statement s, Scope sc = new Scope)
{
  return visitStatement!(
    checkDeclaration,
    checkBlock,
    checkWhile,
    checkIf)
           (s, sc);
}

bool checkDeclaration(DeclarationStatement s, Scope sc)
{
  auto syms = sc.getVisibleSymbols();

  foreach(sym; syms)
    if(sym.name == s.name)
      return false;

  if(s.initializer)
  {
    if(!checkExpression(s.initializer, sc))
      return false;
  }

  auto sym = Scope.Symbol(s.name, Scope.Symbol.FL_VARIABLE, "int");
  sc.addSymbol(sym);
  return true;
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

