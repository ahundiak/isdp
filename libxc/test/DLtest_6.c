#include "dload.h"
extern int Main_ref1 ();
extern int Main_ref2 ();
extern int Main_ref3 ();

static int Stat1 (int a, int b, int c, int d, int e, int f, int g)
{
  return -(a + b + c + d + e + f + g);
}
static int Stat2 (int a, int b, int c, int d, int e, int f, int g)
{
  return (a - b + c - d + e - f + g);
}

static int (*funcptrs[])() = { Main_ref1, Stat1, Main_ref2, Stat2, Main_ref3 };


char Title[] = { "Data initialized with pointers to functions" };
int main (int testnum)
{
  if (funcptrs[0] != Main_ref1) return 0;
  if (funcptrs[1] != Stat1)     return 0;
  if (funcptrs[2] != Main_ref2) return 0;
  if (funcptrs[3] != Stat2)     return 0;
  if (funcptrs[4] != Main_ref3) return 0;

  if (funcptrs[0](1,2,3,4,5,6,7) !=  28) return 0;
  if (funcptrs[1](1,2,3,4,5,6,7) != -28) return 0;
  if (funcptrs[2](1,2,3,4,5,6,7) !=  56) return 0;
  if (funcptrs[3](1,2,3,4,5,6,7) !=   4) return 0;
  if (funcptrs[4](1,2,3,4,5,6,7) !=  84) return 0;
  return 1;
}
