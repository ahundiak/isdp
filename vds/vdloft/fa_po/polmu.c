/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  POlmu
 
     Abstract:     This function computes the bernstein basic functions.

-----
%SC%

     POlmu(order,par,bern,rc)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     order        IGRint         the order of the polynomila
     par          IGRdouble      the parameter for which the base functions
                                     are calculated
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *bern        IGRdouble      the Bernstein functions
     *rc          BSrc           return code
-----
%MD%

-----
%NB%

     NOTES:     The calling function should allocate space for the array
           of Bernstein values.  This array should be dimensioned as b[order].

-----
%CH%
     CHANGE HISTORY:
	
	JLL 12 nov 92  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------


----*/
/*EH*/

#include "bs.h"
#include "bsparameters.h"


POlmu(order,par,bern,rc)

IGRint order;      
IGRdouble par;
IGRdouble *bern;
BSrc *rc; 

{

  IGRint 	i, j, m;
  IGRdouble	unMpar;

  *rc = BSSUCC;    

  bern[0] = 1;
  unMpar = 1.0 - par;

  for(i=1;i<order;i++){

    	bern[i] = par * bern[i-1];

    	for(j=1;j<i;j++){
      		m = i - j;
      		bern[m] = unMpar * bern[m] + par * bern[m - 1];
    	}

    	bern[0] = unMpar * bern[0];
  }

  return;

}
