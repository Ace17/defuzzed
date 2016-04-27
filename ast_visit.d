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

auto visitDeclaration(alias visitClass, alias visitFunction, alias visitVariable, T...)
  (Declaration d, T extraArgs)
{
  assert(d);

  if(auto decl = cast(ClassDeclaration)d)
  {
    return visitClass(decl, extraArgs);
  }
  else if(auto decl = cast(FunctionDeclaration)d)
  {
    return visitFunction(decl, extraArgs);
  }
  else if(auto decl = cast(VariableDeclaration)d)
  {
    return visitVariable(decl, extraArgs);
  }
  else
    assert(0);
}

auto visitStatement(alias visitDeclaration, alias visitBlock, alias visitWhile, alias visitIf, T...)
  (Statement s, T extraArgs)
{
  assert(s);

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

auto visitExpression(alias visitNumber, alias visitIdentifier, alias visitFunctionCall, alias visitBinary, T...)
  (Expression e, T extraArgs)
{
  if(auto expr = cast(NumberExpression)e)
  {
    return visitNumber(expr, extraArgs);
  }
  else if(auto expr = cast(IdentifierExpression)e)
  {
    return visitIdentifier(expr, extraArgs);
  }
  else if(auto expr = cast(FunctionCallExpression)e)
  {
    return visitFunctionCall(expr, extraArgs);
  }
  else if(auto expr = cast(BinaryExpression)e)
  {
    return visitBinary(expr, extraArgs);
  }
  else
    assert(0);
}

