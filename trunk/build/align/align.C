#include <stdio.h>

/* ----------------------------------------
 * Used to verify that the double alignment option is being passed correctly
 * Use /opt/sunstudio12.1/bin/cc align.c
 * to get a size of 20
 */
int main()
{
    typedef struct
    {
        double x1;
        int    i1;
        double x2;
    } Tstruct;;
    
    printf("Hello from alignment test 24 %d\n",sizeof(Tstruct));
}