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

import std.stdio: File;
import ast;
import ast_visit;

void printStatement(Statement s, File f)
{
  printStatement(s, new Printer(f));
}

void printStatement(Statement s, Printer f)
{
  visitStatement!(
    printDeclaration,
    printBlock,
    printWhile,
    printIf)
    (s, f);
}

void printDeclaration(DeclarationStatement s, Printer f)
{
  f.writef("int %s", s.name);

  if(s.initializer)
  {
    f.writef(" = ");
    printExpression(s.initializer, f);
  }

  f.writefln(";");
}

void printBlock(BlockStatement s, Printer f)
{
  f.writeln("{");

  {
    auto id = f.indent();

    foreach(stmt; s.sub)
      printStatement(stmt, f);
  }

  f.writeln("}");
}

void printWhile(WhileStatement s, Printer f)
{
  f.writef("while(");
  printExpression(s.condition, f);
  f.writef(")");
  f.writeln();

  printStatement(s.body_, f);
}

void printIf(IfStatement s, Printer f)
{
  f.writef("if(");
  printExpression(s.condition, f);
  f.writef(")");
  f.writeln();

  f.writeln("{");
  {
    auto id1 = f.indent();
    printStatement(s.thenBody, f);
  }
  f.writeln("}");

  if(s.elseBody)
  {
    f.writeln("else");
    f.writeln("{");
    {
      auto id2 = f.indent();
      printStatement(s.elseBody, f);
    }
    f.writeln("}");
  }
}

///////////////////////////////////////////////////////////////////////////////

void printExpression(Expression e, Printer f)
{
  visitExpression!(
    printNumber,
    printBinary)
    (e, f);
}

void printNumber(NumberExpression e, Printer f)
{
  if(e.value < 0)
    f.writef("(");

  f.writef("%s", e.value);

  if(e.value < 0)
    f.writef(")");
}

void printBinary(BinaryExpression e, Printer f)
{
  f.writef("(");
  printExpression(e.operands[0], f);
  f.writef("%s", e.operator);
  printExpression(e.operands[1], f);
  f.writef(")");
}

///////////////////////////////////////////////////////////////////////////////

private:
class Printer
{
  this(File f_)
  {
    f = f_;
  }

  auto indent()
  {
    static struct ScopedIndenter
    {
      this(Printer parent_)
      {
        parent = parent_;
        parent.indentLevel++;
      }

      ~this()
      {
        parent.indentLevel--;
      }

      Printer parent;
    }

    return ScopedIndenter(this);
  }

  void writef(T...)(string fmt, T args)
  {
    indentIfNeeded();
    f.writef(fmt, args);
  }

  void writefln(T...)(string fmt, T args)
  {
    indentIfNeeded();
    f.writefln(fmt, args);
    emptyLineFlag = true;
  }

  void writeln(string line = "")
  {
    indentIfNeeded();
    f.writeln(line);
    emptyLineFlag = true;
  }

  void indentIfNeeded()
  {
    if(!emptyLineFlag)
      return;

    for(int i = 0; i < indentLevel; ++i)
      f.writef("  ");

    emptyLineFlag = false;
  }

  File f;
  int indentLevel;
  bool emptyLineFlag = true;
}

