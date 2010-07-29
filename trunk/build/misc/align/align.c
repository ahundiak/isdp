#include "stdio.h"

typedef double IGRdouble;

typedef struct
{
    int i1;
    IGRdouble d1;
    IGRdouble d2;
} xxx;

int main()
{
    xxx rec;
    int a1 = (int)(&rec);
    int a2 = (int)(&rec.d1);

    printf("__STDC__=%d, Size %d %d\n",__STDC__,sizeof(rec),a2 - a1);
}
