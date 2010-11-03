class implementation Root;

%safe
#include <math.h>
%endsafe
#include <stdlib.h>

double pow(), log();

typedef double IGRdouble;

 void EMweibull(sigma,eat,iseed,deviate)
 IGRdouble  *deviate,*sigma,*eat;
 long  *iseed;

 {
 double b,c,rand;

      EMrand(iseed,&rand);
      b = fabs(log(1-rand));
      c = 1/ *eat;
      *deviate =  *sigma * pow( b, c ); 
 }

end implementation Root;
