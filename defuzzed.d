#!/usr/bin/env rdmd

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
 */

import std.conv;
import std.string;
import std.range;
import std.stdio;
import std.parallelism;
import std.process;
import std.file;
import std.path;

__gshared int count;

// TODO: add options:
// -v (verbose)
// -s (approx. generated program size)
int main(string[] args)
{
  try
  {
    auto seeds = iota(int.max);
    foreach(seed; seeds)
      processSeed(seed);

    return 0;
  }
  catch(Exception e)
  {
    writefln("Fatal: %s", e.msg);
    return 1;
  }
}

void processSeed(int seed)
{
  try
  {
    safeProcessSeed(seed);
  }
  catch(Exception e)
  {
    throw new Exception(format("Seed %s: %s", seed, e.msg));
  }
}

void safeProcessSeed(int seed)
{
  const sourcePath = buildPath(tempDir(), format("crashed_%s.d", seed));
  scope(success) remove(sourcePath);

  const objectPath = buildPath(tempDir(), format("crashed_%s.o", seed));
  scope(success) remove(objectPath);

  {
    const status = execute(["rdmd", "generate_source_file.d", to!string(seed), sourcePath ]);
    if(status.status > 0)
      throw new Exception("can't generate source file");
  }

  {
    //const cmd = ["gdc", "-c", sourcePath, "-o", objectPath ];
    const cmd = ["dmd", "-c", sourcePath, "-of" ~ objectPath ];
    writefln("%s", cmd);
    const status = execute(cmd);
    if(status.status > 0)
    {
      stderr.writefln("%s", status.output);
      const msg = format("can't compile source file\ncommand: %s\nexitcode: %s", join(cmd, " "), status.status);
      throw new Exception(msg);
    }
  }

  synchronized
  {
    if(count % 100 == 0)
    {
      writef("\rTest cases: %s", count);
      stdout.flush();
    }
    ++count;
  }
}

