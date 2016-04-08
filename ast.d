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

class Statement
{
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

