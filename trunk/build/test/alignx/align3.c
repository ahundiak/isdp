#include <stdio.h>

typedef double IGRdouble __attribute__ ((aligned (8)));

typedef struct
{
  IGRdouble  d1;
  int        i1;
  IGRdouble  d2;
} Tdata1;
typedef struct
{
  double  d1;
  int     i1;
  double  d2;
} Tdata2;

int process(IGRdouble d)
{
  return 0;
}
int process2(d)
IGRdouble d;
{
  return 0;
}
extern int fake(IGRdouble p);

int main(int argc, char *argv[])
{
  int size1 = sizeof(Tdata1); // 24
  int size2 = sizeof(Tdata2); // 20

  printf("Tdata size: %d %d\n",size1,size2);
}
