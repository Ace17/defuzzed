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

auto visitStatement(alias visitDeclaration, alias visitBlock, alias visitWhile, alias visitIf, T...)
  (Statement s, T extraArgs)
{
  if(auto stmt = cast(DeclarationStatement)s)
  {
    return visitDeclaration(stmt, extraArgs);
  }
  else if(auto stmt = cast(BlockStatement)s)
  {
    return visitBlock(stmt, extraArgs);
  }
  else if(auto stmt = cast(WhileStatement)s)
  {
    return visitWhile(stmt, extraArgs);
  }
  else if(auto stmt = cast(IfStatement)s)
  {
    return visitIf(stmt, extraArgs);
  }
  else
    assert(0);
}

auto visitExpression(alias visitNumber, alias visitBinary, T...)
  (Expression e, T extraArgs)
{
  if(auto expr = cast(NumberExpression)e)
  {
    return visitNumber(expr, extraArgs);
  }
  else if(auto expr = cast(BinaryExpression)e)
  {
    return visitBinary(expr, extraArgs);
  }
  else
    assert(0);
}

