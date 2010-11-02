#include <stdio.h>
#include "igrtypedef.h"

/* ----------------------------------------
 * Used to verify that the double alignment option is being passed correctly
 * Use /opt/sunstudio12.1/bin/cc align.c
 * to get a size of 20
 *
 * Looks like the -Ddouble trick does not work for old style function declerations
 * with doubles aa arguments
 */
int old(d1,i1,d2,i2)
IGRdouble d1;
int       i1;
IGRdouble d2;
int       i2;
{
  printf("OLD %.2f %d %.2f %d\n",d1,i1,d2,i2);
}
int main()
{
    typedef struct
    {
        IGRdouble x1;
        int    i1;
        IGRdouble x2;
    } Tstruct;;

    double *volume;
    
    printf("Hello from alignment test 24 %d\n",sizeof(Tstruct));
    old(1.0,1,2.0,2);
}
#if 0
int xxx(volume)
double __attribute__((aligned(8))) *volume;
{
    return 0;
}
#endif
