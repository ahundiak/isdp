
class implementation Root;

%safe
#include <math.h>
%endsafe
#include <stdlib.h>
double exp();

double EMgas(x,y,arglist,rc)
 double x,y;
 long  *rc;
 char *arglist;
 {
 double *mean;

 mean = (double *)arglist;
 return( (1/(y*sqrt(2*3.14159652))) * exp(-0.5 *(x- *mean)*(x- *mean)/(y*y)) );
 }
end implementation Root;
