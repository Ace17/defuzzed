module generators.grammar.generator;

import entropy;
import std.algorithm;
import std.array;

struct Rule
{
  int left;
  int[] right;
  void function(Object context) pre;
  void function(Object context) post;
};

string randomTree(Rule[] grammar, Object opaqueContext, int from, string function(int, Object opaqueContext) reduceTerminal, int depth=0)
{
  if(isTerminal(from))
    return reduceTerminal(from, opaqueContext);

  const rules = getMatchingRules(grammar, from);

  const proportions = getProportions(cast(int)rules.length, depth);

  const choice = dice(proportions);
  const rule = rules[choice];

  if(rule.pre)
    rule.pre(opaqueContext);

  string result;

  foreach(child; rule.right)
    result ~= randomTree(grammar, opaqueContext, child, reduceTerminal, depth+1);

  if(rule.post)
    rule.post(opaqueContext);

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

Rule[] getMatchingRules(Rule[] grammar, int type)
{
  bool matches(in Rule r)
  {
    return r.left == type;
  }

  return array(filter!matches(grammar));
}

bool isTerminal(int from)
{
  return from < 100;
}

