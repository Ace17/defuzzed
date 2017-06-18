module generators.grammar.main;

import generators.grammar.generator;

import std.string;

import entropy;
import scope_;

import std.stdio;

class Context
{
  this()
  {
    sc = new Scope;
  }

  Scope sc;
}

void fuzzyGenerate(File f)
{
  static void onBeginBlock(Object userParam)
  {
    auto ctx = cast(Context)userParam;
    ctx.sc = ctx.sc.sub();
  }

  static void onEndBlock(Object userParam)
  {
    auto ctx = cast(Context)userParam;
    ctx.sc = ctx.sc.parent;
  }

  with(Node)
  {
    auto grammar =
      [
      Rule(Axiom, [Prelude, StaticDeclarationBlock]),

      // force at least one global variable
      Rule(Prelude, [VariableDeclaration]),

      Rule(StaticDeclarationBlock,
          [TopLevelDeclarationList],
          &onBeginBlock,
          &onEndBlock
          ),

      Rule(TopLevelDeclarationList, [TopLevelDeclaration]),
      Rule(TopLevelDeclarationList, [TopLevelDeclaration, TopLevelDeclarationList]),

      Rule(TopLevelDeclaration, [FunctionDeclaration]),
      Rule(TopLevelDeclaration, [VariableDeclaration]),
      Rule(TopLevelDeclaration, [ClassDeclaration]),

      Rule(FunctionDeclaration, [Void, FunctionIdentifier, LeftPar, RightPar, BlockStatement]),

      Rule(VariableDeclaration, [Type, NewIdentifier, Equals, Number, Semicolon]),

      Rule(ClassDeclaration, [Class, NewClassIdentifier, LeftBrace, StaticDeclarationBlock, RightBrace]),

      Rule(StatementList, [Statement]),
      Rule(StatementList, [StatementList, Statement]),

      Rule(Statement, [ExprWithSideEffects, Semicolon]),
      //    Rule(Statement, [Return, Expr, Semicolon]),
      Rule(Statement, [TopLevelDeclaration]),
      Rule(Statement, [If, LeftPar, Condition, RightPar, BlockStatement ]),
      Rule(Statement, [For, LeftPar, ExprWithSideEffects, Semicolon, Condition, Semicolon, ExprWithSideEffects, RightPar, BlockStatement ]),

      Rule(BlockStatement, [LeftBrace, StatementList, RightBrace],
          &onBeginBlock,
          &onEndBlock),

      Rule(Condition, [Number]),
      Rule(Condition, [Identifier]),
      Rule(Condition, [Expr, Plus, Expr]),
      Rule(Condition, [Expr, Minus, Expr]),

      Rule(Type, [Int]),
      //    Rule(Type, [Char]),
      //    Rule(Type, [Float]),

      Rule(Expr, [Number]),
      Rule(Expr, [Identifier]),
      Rule(Expr, [LeftPar, Expr, RightPar]),
      Rule(Expr, [Expr, Plus, Expr]),
      Rule(Expr, [Expr, Minus, Expr]),
      Rule(Expr, [ExprWithSideEffects]),

      Rule(LValue, [Identifier]),

      Rule(ExprWithSideEffects, [LeftPar, LValue, Equals, Expr, RightPar]),
      ];

    const tree = randomTree(grammar, new Context, Node.Axiom, &reduceTerminal);
    f.writeln(tree);
  }
}

string reduceTerminal(int from, Object opaqueContext)
{
  auto context = cast(Context)opaqueContext;

  // terminals first
  switch(from)
  {
  case Node.Number: return format("%s", uniform(0,100));
  case Node.Identifier: return context.sc.getVisibleVariables()[uniform(0, $)];
  case Node.NewIdentifier: return context.sc.addVariable();
  case Node.FunctionIdentifier: return format("f%s ", uniform(0, 100));
  case Node.NewClassIdentifier: return context.sc.addClass();
  case Node.ClassIdentifier: return context.sc.getVisibleClasses()[uniform(0, $)];
  case Node.Class: return "\nclass ";
  case Node.Int: return "int ";
  case Node.Void: return "void ";
  case Node.Char: return "char ";
  case Node.Float: return "float ";
  case Node.If: return "if";
  case Node.For: return "for";
  case Node.Plus: return "+";
  case Node.Minus: return "-";
  case Node.Equals: return "=";
  case Node.LeftPar: return "(";
  case Node.RightPar: return ")";
  case Node.LeftBrace: return "\n{\n";
  case Node.RightBrace: return "\n}\n";
  case Node.Semicolon: return ";";
  case Node.Return: return "return ";
  default: assert(0, "The above switch is missing one terminal");
  }
}

enum Node
{
  Number,
  Identifier, // a ref to an existing identifier
  NewIdentifier, // a new identifier
  ClassIdentifier,
  NewClassIdentifier,
  FunctionIdentifier,
  Plus,
  Minus,
  Equals,
  LeftPar,
  RightPar,
  LeftBrace,
  RightBrace,
  Semicolon,
  Return,
  Void,
  Int,
  Char,
  Float,
  If,
  For,
  Class,

  Axiom = 100,
  Prelude, // HACK
  Condition,
  Expr,
  ExprWithSideEffects,
  LValue,
  Type,
  StaticDeclarationBlock,
  TopLevelDeclaration,
  TopLevelDeclarationList,
  FunctionDeclaration,
  VariableDeclaration,
  ClassDeclaration,
  BlockStatement,
  Statement,
  StatementList,
}

