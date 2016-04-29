#! /usr/bin/env rdmd
/**
 * @brief Generate a random D (valid) source file
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

import std.algorithm;
import std.conv;
import std.random: unpredictableSeed;
import std.stdio;

import entropy;
import scope_;
import dfs_generator;

int main(string[] args)
{
  auto seed = unpredictableSeed;

  if(args.length > 1)
    seed = to!int (args[1]);

  string outputPath = "-";

  if(args.length > 2)
    outputPath = args[2];

  auto f = openOutput(outputPath);

  generateRandomSourceFile(seed, f);

  return 0;
}

File openOutput(string path)
{
  if(path == "-")
    return stdout;
  else
    return File(path, "w");
}

void generateRandomSourceFile(int seed, File f)
{
  gen.seed(seed);

  f.writefln("// generated by defuzzed, seed %s", seed);

  if(uniform(0, 2))
    depthFirstGenerate(f);
  else
    breadthFirstGenerate(f);
}

import ast;
import ast_check;
import ast_clone;
import ast_mutate;
import ast_print;

void breadthFirstGenerate(File f)
{
  auto tree = getValidRandomProgram();

  printDeclaration(tree, f);
  f.writeln();
}

Declaration getValidRandomProgram()
{
  Declaration tree = new ListDeclaration;

  for(int i = 0; i < 100; ++i)
  {
    auto mutatedTree = cloneDeclaration(tree);
    mutateDeclaration(mutatedTree);

    auto sc = new Scope;
    sc.onlyStaticInitializers = true;

    if(checkDeclaration(mutatedTree, sc))
      tree = mutatedTree;
  }

  return tree;
}

