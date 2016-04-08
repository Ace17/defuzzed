/**
 * @brief AST cloning function.
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

Statement cloneStatement(Statement s)
{
  return visitStatement!(
    cloneFunctionDeclaration,
    cloneVariableDeclaration,
    cloneBlock,
    cloneWhile,
    cloneIf)
           (s);
}

Statement cloneFunctionDeclaration(FunctionDeclarationStatement s)
{
  auto r = new FunctionDeclarationStatement;
  r.name = s.name;
  r.body_ = cloneStatement(s.body_);
  return r;
}

Statement cloneVariableDeclaration(VariableDeclarationStatement s)
{
  auto r = new VariableDeclarationStatement;
  r.name = s.name;

  if(s.initializer)
    r.initializer = cloneExpression(s.initializer);

  return r;
}

Statement cloneBlock(BlockStatement s)
{
  auto r = new BlockStatement;

  foreach(stmt; s.sub)
    r.sub ~= cloneStatement(stmt);

  return r;
}

Statement cloneWhile(WhileStatement s)
{
  auto r = new WhileStatement;

  r.condition = cloneExpression(s.condition);
  r.body_ = cloneStatement(s.body_);

  return r;
}

Statement cloneIf(IfStatement s)
{
  auto r = new IfStatement;

  r.condition = cloneExpression(s.condition);
  r.thenBody = cloneStatement(s.thenBody);
  if(s.elseBody)
    r.elseBody = cloneStatement(s.elseBody);

  return r;
}

///////////////////////////////////////////////////////////////////////////////

Expression cloneExpression(Expression e)
{
  return visitExpression!(
    cloneNumber,
    cloneBinary)
           (e);
}

Expression cloneNumber(NumberExpression e)
{
  auto r = new NumberExpression;
  r.value = e.value;
  return r;
}

Expression cloneBinary(BinaryExpression e)
{
  auto r = new BinaryExpression;
  r.operator = e.operator;
  r.operands[0] = cloneExpression(e.operands[0]);
  r.operands[1] = cloneExpression(e.operands[1]);
  return r;
}

