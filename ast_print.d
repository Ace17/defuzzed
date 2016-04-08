/**
 * @brief Print an AST to a File
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
import ast;
import ast_visit;

void printStatement(Statement s, File f)
{
  visitStatement!(
    printBlock,
    printWhile,
    printIf)
    (s, f);
}

void printBlock(BlockStatement s, File f)
{
  f.writeln("{");

  foreach(stmt; s.sub)
    printStatement(stmt, f);

  f.writeln("}");
}

void printWhile(WhileStatement s, File f)
{
  f.writef("while(");
  printExpression(s.condition, f);
  f.writef(")");
  f.writeln();

  printStatement(s.body_, f);
}

void printIf(IfStatement s, File f)
{
  f.writef("if(");
  printExpression(s.condition, f);
  f.writef(")");
  f.writeln();

  f.writeln("{");
  printStatement(s.thenBody, f);
  f.writeln("}");

  if(s.elseBody)
  {
    f.writeln("else");
    f.writeln("{");
    printStatement(s.elseBody, f);
    f.writeln("}");
  }
}

///////////////////////////////////////////////////////////////////////////////

void printExpression(Expression e, File f)
{
  visitExpression!(
    printNumber,
    printBinary)
    (e, f);
}

void printNumber(NumberExpression e, File f)
{
  if(e.value < 0)
    f.writef("(");

  f.writef("%s", e.value);

  if(e.value < 0)
    f.writef(")");
}

void printBinary(BinaryExpression e, File f)
{
  f.writef("(");
  printExpression(e.operands[0], f);
  f.writef("%s", e.operator);
  printExpression(e.operands[1], f);
  f.writef(")");
}

