class implementation Root;

%safe
#include <math.h>
%endsafe
#include <stdlib.h>

#define  M  714025
#define  IA 1366
#define  IC 150889

void EMrand(idum,dev)
double *dev;
long *idum;
{
     static long iy, ir[98];
     static int iff=0;
     int j;
     
     if (*idum < 0 || iff == 0) {
        iff = 1;
        if((*idum = (IC-(*idum)) % M) < 0) 
             *idum = -(*idum);
        for (j=1; j<=97; j++) {
             *idum = (IA * (*idum)+IC) % M;
             ir[j] = *idum;
        }
        *idum = (IA*(*idum)*IC) %M;
        iy = (*idum);
     }
     j=1+97.0 * iy/M;
     if(j>97 || j<1)
        printf("RANDOM NUMBER GENERATOR ERROR\n");
     iy= ir[j];
     *idum = (IA * (*idum)+IC) % M;
     ir[j] = (*idum);
     *dev = (double) iy/M;
}

end implementation Root;
