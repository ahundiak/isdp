#include <stdio.h>
#include <igrtypedef.h>
#include <ma2ptdis.h>

IGRboolean MA2ptdis(IGRlong *sts, IGRpoint pt1, IGRpoint pt2, IGRdouble *distance)
{
  *distance = 666.66;
  printf("MA2ptdis override\n");
  return 1;
}
