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
import entropy;
import ast;
import ast_visit;

///////////////////////////////////////////////////////////////////////////////

void mutateStatement(Statement s)
{
  visitStatement!(
    mutateBlock,
    mutateWhile,
    mutateIf)
    (s);
}

void mutateBlock(BlockStatement s)
{
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
  switch(uniform(0, 3))
  {
  case 0:
    {
      auto s = new IfStatement;
      s.condition = randomExpr();
      s.thenBody = new BlockStatement;
      return s;
    }
  case 1:
    {
      return new BlockStatement;
    }
  case 2:
    {
      auto s = new WhileStatement;
      s.condition = randomExpr();
      s.body_ = new BlockStatement;
      return s;
    }
  default:
    assert(0);
  }
}

///////////////////////////////////////////////////////////////////////////////

void mutateExpression(Expression e)
{
  visitExpression!(
    mutateNumber,
    mutateBinary)
    (e);
}

void mutateNumber(NumberExpression e)
{
  e.value += uniform(-10, 11);
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

Expression randomExpr()
{
  auto r = new NumberExpression;
  r.value = uniform(-100, 100);
  return r;
}

