
#include <stdio.h>
#include <string.h>

int GRvalidate_rtree_range( double *range )
{
    char tstr[1024];
    char *p=NULL;

    sprintf(tstr,"%f %f %f %f %f %f", range[0], range[1], range[2],
                      range[3], range[4], range[5]);

    
    p = strpbrk( tstr, "Nn" );
    if(p) 
        return(0);
    else
        return(1);

}
