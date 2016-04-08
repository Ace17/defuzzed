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

Declaration cloneDeclaration(Declaration d)
{
  return visitDeclaration!(
    cloneClass,
    cloneFunction,
    cloneVariable)
           (d);
}

Declaration cloneClass(ClassDeclaration d)
{
  auto r = new ClassDeclaration;
  r.name = d.name;

  foreach(decl; d.declarations)
    r.declarations ~= cloneDeclaration(decl);

  return r;
}

Declaration cloneFunction(FunctionDeclaration d)
{
  auto r = new FunctionDeclaration;
  r.name = d.name;
  r.body_ = cloneStatement(d.body_);
  return r;
}

Declaration cloneVariable(VariableDeclaration d)
{
  auto r = new VariableDeclaration;
  r.name = d.name;

  if(d.initializer)
    r.initializer = cloneExpression(d.initializer);

  return r;
}

///////////////////////////////////////////////////////////////////////////////

Statement cloneStatement(Statement s)
{
  return visitStatement!(
    cloneDeclarationS,
    cloneBlock,
    cloneWhile,
    cloneIf)
           (s);
}

Statement cloneDeclarationS(DeclarationStatement s)
{
  auto r = new DeclarationStatement;
  r.declaration = cloneDeclaration(s.declaration);
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

