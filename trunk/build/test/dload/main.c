#include <stdio.h>
#include <igrtypedef.h>
#include <ma2ptdis.h>

int test1()
{
  IGRlong  sts;
  IGRpoint pt1,pt2;
  IGRdouble distance;

  pt1[0] = 1.0; pt1[1] = 1.0; pt1[2] = 1.0;
  pt2[0] = 2.0; pt2[1] = 2.0; pt2[2] = 2.0;
  sts = 1;
  distance = 0.0;

  MA2ptdis(&sts,pt1,pt2,&distance);

  printf("Distance: %.2f\n",distance);

  return 1;
}
int main(int argc, char *argv[])
{
  printf("Hello from main\n");
  test1();
}