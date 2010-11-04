#include <stdio.h>

// Suppress with
// /opt/sunstudio12.1/bin/cc -erroff=E_BAD_PRAGMA_PACK_VALUE align2.c

// #pragma pack(8)

typedef struct
{
  double d1;
  int    i1;
  double d2;
} Tdata1;
// #pragma pack(0)

typedef struct
{
  double __attribute__((aligned(8))) d1;
  int i1;
  double __attribute__((aligned(8))) d2;
} Tdata2;

// This forces all Tdouble to be aligned
typedef double __attribute__((aligned(8))) Tdouble;

typedef struct
{
  Tdouble d1;
  int    i1;
  Tdouble d2;
} Tdata3;

typedef Tdouble Tpoint[3];

typedef struct
{
  Tpoint p1;
  int i1;
  Tpoint p2;
} Tpoints;
// $ /opt/sunstudio12.1/bin/cc -errtags=yes -erroff=E_BAD_PRAGMA_PACK_VALUE align2.c
// "align2.c", line 32: warning: can not set non-default alignment for parameter (E_CANT_SET_NONDEF_ALIGN_PARAM)

int xxx(Tdouble x)
{
  
}
int main(int argc, char *argv[])
{
  int size1 = sizeof(Tdata1); // 20
  int size2 = sizeof(Tdata2); // 24
  int size3 = sizeof(Tdata3); // 24
  int size4 = sizeof(Tpoint); // 24
  int size5 = sizeof(Tpoints); // 24 + 8 + 24 = 56 (52 is not aligned, 56 is define Tpoint with Tdouble)

  printf("Tdata size: %d %d %d %d %d\n",size1,size2,size3,size4,size5);
}
