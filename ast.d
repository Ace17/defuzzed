/**
 * @brief AST definition
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

class Declaration
{
}

class ClassDeclaration : Declaration
{
  bool isInterface;
  string name;
  Declaration[] declarations;
}

class FunctionDeclaration : Declaration
{
  string name;
  Statement body_;
}

class VariableDeclaration : Declaration
{
  string name;
  Expression initializer;
}

///////////////////////////////////////////////////////////////////////////////

class Statement
{
}

class DeclarationStatement : Statement
{
  Declaration declaration;
}

class BlockStatement : Statement
{
  Statement[] sub;
}

class WhileStatement : Statement
{
  Expression condition;
  Statement body_;
}

class IfStatement : Statement
{
  Expression condition;
  Statement thenBody;
  Statement elseBody;
}

///////////////////////////////////////////////////////////////////////////////

class Expression
{
}

class NumberExpression : Expression
{
  int value;
}

class BinaryExpression : Expression
{
  Expression[2] operands;
  char operator = '+';
}

class FunctionCallExpression : Expression
{
  string name;
  Expression[] args;
}

