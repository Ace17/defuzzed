#! /usr/bin/env rdmd

/**
 * @brief Generate random D source files, and try to compile them.
 * @author Sebastien Alaiwan
 * @date 2016-04-02
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

import std.array;
import std.conv;
import std.file;
import std.parallelism;
import std.path;
import std.process;
import std.range;
import std.stdio;
import std.string;

// TODO: add options:
// -v (verbose)
// -s (approx. generated program size)
int main(string[] args)
{
  try
  {
    if(args.length < 2)
    {
      writefln("Usage: ./defuzzed.d <compiler command line>");
      writefln("'%%s' gets replaced with the source file name");
      writefln("'%%o' gets replaced with the object file name");
      writefln("Examples:");
      writefln("./defuzzed.d gdc -c %%s -o %%o");
      writefln("./defuzzed.d dmd -c %%s -of%%o");
      return 1;
    }

    auto seeds = iota(int.max);

    foreach(seed; seeds)
      processSeed(seed, args[1 .. $]);

    return 0;
  }
  catch(Exception e)
  {
    writefln("Fatal: %s", e.msg);
    return 1;
  }
}

void processSeed(int seed, string[] cmd)
{
  try
  {
    safeProcessSeed(seed, cmd);
  }
  catch(Exception e)
  {
    throw new Exception(format("Seed %s: %s", seed, e.msg));
  }
}

void safeProcessSeed(int seed, string[] baseCmd)
{
  const tmpDir = buildPath(tempDir(), format("defuzzed-seed-%s", seed));

  mkdirRecurse(tmpDir);
  scope(success) rmdirRecurse(tmpDir);

  const sourcePath = buildPath(tmpDir, "test.d");
  const objectPath = buildPath(tmpDir, "test.o");

  {
    const status = execute(["rdmd", "generate_source_file.d", to!string(seed), sourcePath]);

    if(status.status > 0)
      throw new Exception("can't generate source file");
  }

  {
    string[] cmd;

    foreach(word; baseCmd)
    {
      word = replace(word, "%s", sourcePath);
      word = replace(word, "%o", objectPath);
      cmd ~= word;
    }

    writefln("%s", cmd);
    const status = execute(cmd);

    if(status.status > 0)
    {
      stderr.writefln("%s", status.output);
      const msg = format("can't compile source file\ncommand: %s\nexitcode: %s", join(cmd, " "), status.status);
      throw new Exception(msg);
    }
  }
}

