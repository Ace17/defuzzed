#!/usr/bin/env rdmd
// Usage examples:
// $ rdmd fuzzalloc.d
// $ gdc -O3 fuzzalloc.d -o fuzzalloc && ./fuzzalloc
import std.stdio;
import std.random;

int main(string[] args)
{
  // make the issue appear sooner
  {
    import core.memory;
    GC.disable();
  }

  Random gen;

  gen.seed(1234);

  long[][1000] tabs;

  for(int k=0;;++k)
  {
    if(k%100000 == 0)
      writeln(k);

    {
      const i = uniform(0, tabs.length, gen);
      tabs[i].length = uniform(0, 10000, gen);
    }

    if(uniform(0, 2, gen))
    {
      const i = uniform(0, tabs.length, gen);
      const j = uniform(0, tabs.length, gen);
      tabs[i] = tabs[j];
    }
  }

  return 0;
}
