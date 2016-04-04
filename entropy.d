import std.random;

auto pickRandom(Range)(ref Range r)
{
  auto result = r.front();

  while(!r.empty() && uniform(0, 10) != 0)
  {
    result = r.front();
    r.popFront();
  }

  return result;
}

int randomCount(int depth)
{
  int left, right;

  if(depth <= 2)
  {
    left = 1;
    right = 6;
  }
  else if(depth > 20)
  {
    left = 0;
    right = 2;
  }
  else
  {
    left = 1;
    right = 4;
  }

  return uniform(left, right);
}

int uniform(int min, long max)
{
  return std.random.uniform(min, cast(int)max, gen);
}

Random gen;

