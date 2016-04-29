/**
 * @brief AST mutation logic
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

import std.stdio;
import std.string;
import entropy;
import ast;
import ast_visit;

///////////////////////////////////////////////////////////////////////////////

void mutateDeclaration(Declaration d)
{
  visitDeclaration!(
    mutateClass,
    mutateList,
    mutateFunction,
    mutateVariable)
    (d);
}

void mutateClass(ClassDeclaration d)
{
  mutateDeclaration(d.declarations);
}

void mutateList(ListDeclaration d)
{
  if(d.decls.length > 0 && uniform(0, 2))
    mutateDeclaration(d.decls[uniform(0, $)]);
  else
    d.decls ~= randomDeclaration();
}

void mutateFunction(FunctionDeclaration d)
{
  if(d.body_)
    mutateStatement(d.body_);
}

void mutateVariable(VariableDeclaration d)
{
  if(d.initializer)
    mutateExpression(d.initializer);
  else
    d.initializer = randomExpr();
}

///////////////////////////////////////////////////////////////////////////////

void mutateStatement(Statement s)
{
  visitStatement!(
    mutateDeclarationS,
    mutateBlock,
    mutateWhile,
    mutateIf)
    (s);
}

void mutateDeclarationS(DeclarationStatement s)
{
  mutateDeclaration(s.declaration);
}

void mutateBlock(BlockStatement s)
{
  foreach(sub; s.sub)
    mutateStatement(sub);

  const N = uniform(1, 4);

  foreach(i; 0 .. N)
    s.sub ~= randomStatement();
}

void mutateWhile(WhileStatement s)
{
  mutateExpression(s.condition);
}

void mutateIf(IfStatement s)
{
  mutateExpression(s.condition);

  if(!s.thenBody)
    s.thenBody = randomStatement();
}

Statement randomStatement()
{
  static Statement onIf()
  {
    auto s = new IfStatement;
    s.condition = randomExpr();
    s.thenBody = new BlockStatement;
    return s;
  }

  static Statement onBlock()
  {
    return new BlockStatement;
  }

  static Statement onWhile()
  {
    auto s = new WhileStatement;
    s.condition = randomExpr();
    s.body_ = new BlockStatement;
    return s;
  }

  static Statement onDecl()
  {
    auto s = new DeclarationStatement;
    s.declaration = randomDeclaration();
    return s;
  }

  static const funcs = [&onIf, &onBlock, &onWhile, &onDecl];
  static const probs = [23, 4, 20, 53];
  const idx = dice(probs);
  return funcs[idx] ();
}

Declaration randomDeclaration()
{
  if(uniform(0, 4))
  {
    auto r = new VariableDeclaration;
    r.name = format("i%s", uniform(0, 10));
    return r;
  }
  else if(uniform(0, 2))
  {
    auto r = new FunctionDeclaration;
    static counter = 0;
    r.name = format("f%s", counter++);

    if(uniform(0, 10))
      r.body_ = new BlockStatement;

    return r;
  }
  else
  {
    auto r = new ClassDeclaration;
    static classCounter = 0;
    r.name = format("C%s", classCounter++);
    r.isInterface = uniform(0, 3) == 0;
    r.declarations = new ListDeclaration;
    return r;
  }
}

///////////////////////////////////////////////////////////////////////////////

void mutateExpression(Expression e)
{
  visitExpression!(
    mutateNumber,
    mutateIdentifier,
    mutateFunctionCall,
    mutateBinary)
    (e);
}

void mutateNumber(NumberExpression e)
{
  e.value += uniform(-10, 11);
}

void mutateIdentifier(IdentifierExpression e)
{
  e.name = format("i%s", uniform(0, 100));
}

void mutateBinary(BinaryExpression e)
{
  immutable operators = "+-*";
  const strategy = dice([45, 45, 10]);
  switch(strategy)
  {
  case 0:
    e.operator = operators[uniform(0, $)];
    break;
  case 1:
    mutateExpression(e.operands[uniform(0, $)]);
    break;
  case 2:
    {
      auto idx = uniform(0, 2);
      auto newOp = new BinaryExpression;
      newOp.operands[0] = e.operands[idx];
      newOp.operands[1] = randomExpr();

      e.operands[idx] = newOp;
      break;
    }
  default:
    assert(0);
    break;
  }
}

void mutateFunctionCall(FunctionCallExpression e)
{
  if(uniform(0, 10))
    e.name = format("f%s", uniform(0, 10));
  else
    e.name = "f";
}

Expression randomExpr()
{
  switch(uniform(0, 4))
  {
  case 0:
    {
      return randomNumberExpression();
    }

  case 1:
    {
      auto r = new BinaryExpression;
      r.operands[0] = randomNumberExpression();
      r.operands[1] = randomNumberExpression();
      return r;
    }

  case 2:
    {
      auto r = new FunctionCallExpression;

      if(uniform(0, 10))
        r.name = format("f%s", uniform(0, 10));
      else
        r.name = "f";

      return r;
    }

  case 3:
    {
      auto r = new IdentifierExpression;
      r.name = format("i%s", uniform(0, 100));
      return r;
    }
  default:
    assert(0);
  }
}

NumberExpression randomNumberExpression()
{
  auto r = new NumberExpression;
  r.value = uniform(-100, 100);
  return r;
}

