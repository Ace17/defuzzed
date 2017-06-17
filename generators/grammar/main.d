module generators.grammar.main;

import std.algorithm;
import std.array;
import std.string;
import entropy;

enum Node
{
  Number,
  Identifier,
  ClassIdentifier,
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

  Axiom,
  Condition,
  Expr,
  ExprWithSideEffects,
  LValue,
  Type,
  TopLevelDeclaration,
  TopLevelDeclarationList,
  FunctionDeclaration,
  VariableDeclaration,
  ClassDeclaration,
  Statement,
  StatementList,
}

struct Rule
{
  Node left;
  Node[] right;
};

Rule[] grammar = getGrammar();

Rule[] getGrammar()
{
  with(Node)
  {
    return
    [
      Rule(Axiom, [TopLevelDeclarationList]),

      Rule(TopLevelDeclarationList, [TopLevelDeclaration]),
      Rule(TopLevelDeclarationList, [TopLevelDeclaration, TopLevelDeclarationList]),

      Rule(TopLevelDeclaration, [FunctionDeclaration]),
//    Rule(TopLevelDeclaration, [VariableDeclaration]),
      Rule(TopLevelDeclaration, [ClassDeclaration]),

      Rule(FunctionDeclaration, [Void, FunctionIdentifier, LeftPar, RightPar, LeftBrace, StatementList, RightBrace]),

      Rule(VariableDeclaration, [Type, Identifier, Equals, Expr, Semicolon]),

      Rule(ClassDeclaration, [Class, ClassIdentifier, LeftBrace, TopLevelDeclarationList, RightBrace]),

      Rule(StatementList, [Statement]),
      Rule(StatementList, [StatementList, Statement]),
      Rule(StatementList, [StatementList, TopLevelDeclarationList]),

      Rule(Statement, [ExprWithSideEffects, Semicolon]),
//    Rule(Statement, [Return, Expr, Semicolon]),
//    Rule(Statement, [VariableDeclaration]),
      Rule(Statement, [If, LeftPar, Condition, RightPar, LeftBrace, StatementList, RightBrace ]),
      Rule(Statement, [For, LeftPar, ExprWithSideEffects, Semicolon, Condition, Semicolon, ExprWithSideEffects, RightPar, LeftBrace, StatementList, RightBrace ]),

      Rule(Condition, [Number]),

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
  }
}

Rule[] getMatchingRules(Node type)
{
  bool matches(in Rule r)
  {
    return r.left == type;
  }

  return array(filter!matches(grammar));
}

string randomTree(Node from, int depth=0)
{
  // terminals first
  switch(from)
  {
  case Node.Number: return format("%s", uniform(0,100));
  case Node.Identifier: return format("i%s ", uniform(0, 100));
  case Node.FunctionIdentifier: return format("f%s ", uniform(0, 100));
  case Node.ClassIdentifier: return format("c%s ", uniform(0, 100));
  case Node.Class: return "class ";
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
  default: break;
  }

  assert(from >= Node.Axiom, "The above switch is missing one terminal");

  const rules = getMatchingRules(from);

  const proportions = getProportions(cast(int)rules.length, depth);

  const choice = dice(proportions);
  const rule = rules[choice];

  string result;

  foreach(child; rule.right)
    result ~= randomTree(child, depth+1);

  return result;
}

// favor first elements of the list as depth increases
float[] getProportions(int length, int depth)
{
  float[] r;
  foreach(int i; 0 .. length)
  {
    const x = length - 1 - i;
    r ~= 1 + x*depth*0.2;
  }
  return r;
}

import std.stdio;

void fuzzyGenerate(File f)
{
  f.writef("int ");
  for(int i=0;i < 100;++i)
  {
    if(i > 0)
      f.write(", ");
    f.writef("i%s", i);
  }
  f.writeln(";");

  const tree = randomTree(Node.Axiom);
  f.writeln(tree);
}

