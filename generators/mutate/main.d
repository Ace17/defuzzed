module generators.mutate.main;

import std.stdio;

import scope_;

import generators.mutate.ast;
import generators.mutate.ast_check;
import generators.mutate.ast_clone;
import generators.mutate.ast_mutate;
import generators.mutate.ast_print;

void breadthFirstGenerate(File f)
{
  auto r = getValidRandomProgram();

  f.writefln("// mutation ratio: %.2f", r.mutationRatio);
  printDeclaration(r.tree, f);
  f.writeln();
}

auto getValidRandomProgram()
{
  static struct Result
  {
    Declaration tree;
    float mutationRatio;
  }

  Declaration tree = new ListDeclaration;

  int numMutations;
  const MAX_MUTATIONS = 100;

  for(int i = 0; i < MAX_MUTATIONS; ++i)
  {
    auto mutatedTree = cloneDeclaration(tree);
    mutateDeclaration(mutatedTree);

    auto sc = new Scope;
    sc.onlyStaticInitializers = true;

    if(checkDeclaration(mutatedTree, sc))
    {
      tree = mutatedTree;
      numMutations++;
    }
  }

  return Result(tree, cast(float)numMutations/MAX_MUTATIONS);
}

