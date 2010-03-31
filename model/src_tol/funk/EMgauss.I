class implementation Root;

%safe
#include <math.h>
%endsafe
#include <stdlib.h>

 void EMgauss(iseed,deviate)
 double  *deviate;
 long  *iseed;
 {
 int iset=0;
 double gset,v1,v2,fac,r,rand;

  /*srand(*iseed); */

  if(iset == 0) {
      do {
         EMrand(iseed,&rand);
         v1 = 2.0 * rand -1.0;
         EMrand(iseed,&rand);
         v2 = 2.0 * rand -1.0;
/*
         v1 = 2.0 * (double)rand()/(double)(32767+1.0)-1.0;
         v2 = 2.0 * (double)rand()/(double)(32767+1.0)-1.0;
*/
         r  = v1*v1 + v2*v2;
      } while (r >= 1.0 || r == 0);

      fac = sqrt(-2.0 * log(r)/r);
      gset = v1 * fac;
      iset = 1;
      *deviate =  v2*fac; 
  }
  else{
      iset = 0;
      *deviate =   gset; 
     }
 }
end implementation Root;
