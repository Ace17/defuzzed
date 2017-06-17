import std.string;
import std.random;

enum Node
{
  Number,
  Identifier,
  Plus,
  Minus,
  Equals,
  LeftPar,
  RightPar,
  LeftBrace,
  RightBrace,
  Semicolon,
  Return,
  Type,
  If,
  For,

  Axiom,
  Expr,
  Function,
  TopLevelDeclaration,
  TopLevelDeclarationList,
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

      Rule(TopLevelDeclaration, [Function]),

      Rule(Function, [Type, Identifier, LeftPar, RightPar, LeftBrace, StatementList, RightBrace]),

      Rule(StatementList, [Statement]),
      Rule(StatementList, [StatementList, Statement]),

      Rule(Statement, [Expr, Semicolon]),
      Rule(Statement, [Return, Expr, Semicolon]),
      Rule(Statement, [Type, Identifier, Equals, Expr, Semicolon]),
      Rule(Statement, [If, LeftPar, Expr, RightPar, LeftBrace, StatementList, RightBrace ]),
      Rule(Statement, [For, LeftPar, Expr, Semicolon, Expr, Semicolon, Expr, RightPar, LeftBrace, StatementList, RightBrace ]),

      Rule(Expr, [Number]),
      Rule(Expr, [Identifier]),
      Rule(Expr, [LeftPar, Expr, RightPar]),
      Rule(Expr, [Expr, Plus, Expr]),
      Rule(Expr, [Expr, Minus, Expr]),
      Rule(Expr, [Expr, Equals, Expr]),
    ];
  }
}

Rule[] getMatchingRules(Node type)
{
  Rule[] r;
  foreach(rule; grammar)
    if(rule.left == type)
      r ~= rule;
  return r;
}

string randomTree(Node from, int depth=0)
{
  // terminals first
  switch(from)
  {
  case Node.Number: return format("%s", uniform(0,100));
  case Node.Identifier: return format("i%s ", uniform(0, 100));
  case Node.Type: return "int ";
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

float[] getProportions(int length, int depth)
{
  float[] r;
  foreach(int i; 0 .. length)
  {
    const x = length - 1 - i;
    r ~= 1 + x*depth*0.1;
  }
  return r;
}

import std.stdio;

int main()
{
  const tree = randomTree(Node.Axiom);
  writefln("%s", tree);
  return 0;
}

