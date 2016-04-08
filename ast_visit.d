/**
 * @brief AST visitors
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

import ast;

void visitStatement(alias visitBlock, alias visitWhile, alias visitIf, T...)
  (Statement s, T extraArgs)
{
  if(auto stmt = cast(BlockStatement)s)
  {
    visitBlock(stmt, extraArgs);
  }
  else if(auto stmt = cast(WhileStatement)s)
  {
    visitWhile(stmt, extraArgs);
  }
  else if(auto stmt = cast(IfStatement)s)
  {
    visitIf(stmt, extraArgs);
  }
  else
    assert(0);
}

void visitExpression(alias visitNumber, alias visitBinary, T...)
  (Expression e, T extraArgs)
{
  if(auto expr = cast(NumberExpression)e)
  {
    visitNumber(expr, extraArgs);
  }
  else if(auto expr = cast(BinaryExpression)e)
  {
    visitBinary(expr, extraArgs);
  }
  else
    assert(0);
}

