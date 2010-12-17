#include "machine.h"
/*************************************************************************
 *                                                                       *
 *     Module:    NETswapbyte.c                                         *
 *     Author:    Karen Tice                                             *
 *     Date:      19 Sep 1991                                            *
 *                                                                       *
 *************************************************************************/

long swapbytes(n)
	long n;
{
char *p1,*p2;
long m,i;

p1 = (char *) &n;
p2 = (char *) &m;
p2+=3;

for(i=0;i <4 ; i++)
    {
    *p2 = *p1 ;
    p1++;
    p2--;
    }
return(m);
}
