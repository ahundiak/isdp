#include "dload.h"


void func_A (int x, y, z)
{
  printf ("This is the old function:  %d, %d, %d passed\n", x, y, z);
}


main ()
{
  func_A (1, 2, 3);
  dload ("new_A.so", TEXTREF | DATAREF | TEXTREDEF);
  func_A (4, 5, 6);
}
