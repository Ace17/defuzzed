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
import generators.dfs.main;
import generators.mutate.main;
import generators.grammar.main;

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

  auto generators =
    [
    &depthFirstGenerate,
    &breadthFirstGenerate,
    &fuzzyGenerate,
    ];

  generators[uniform(0, $)](f);
}

