/*----
%HD%
 
     MODULE NAME POcvevpgbind
 
     Abstract:
        This function evaluate the pole of a Bspline giving the blossoming
	parametrisation of this pole.
	Supose you want to evaluate the pole P(t0,t1,t2) of a giving curve,
	then you must evaluate the polar Ni functions whith t0>=t1>=t2.
	Everybody understood that polar form or blossom are two different 
	names for the same meaning. 
	In fact the current point of a curve is a pole viewed as
	the limit of the blossom which could be written P(t,t,t).
	If t0 and t2 belongs to a given interval of the knots vector then
	you will get one pole of the knot insertion mechanism Else you
	do an extrapolation.
	in the rational case we transfert the weighted poles and his weight.
	
	
-----
%SC%

      POcvevpgbind( idim, cv, par, ikt, pole, &weight, &rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        idim	   IGRshort	 	the dimension 
        *cv        struct IGRbsp_curve  the input curve
	*par       IGRdouble		the polar form or
					blossoming parametrisation.
					dimension of par is then equal
					to the degre .
	ikt	   IGRint		the index of the knot to start to
					evaluate the Ni functions.
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*pole	   IGRdouble	the pole solution
	*weight    IGRdouble	the weight solution
        *rc        BSrc         completion code message
                                 - BSSUCC or BSFAIL
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : 10 April 92 Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "v_.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
#include "bsvalues.h"

POcvevpgbind (		IGRshort	idim,
		struct	IGRbsp_curve	*cv,
			IGRdouble	*par,
			IGRint		ikt,
			IGRdouble	*pole,
			IGRdouble	*weight,
			BSrc		*rc )


{

#define		MAX_OD		3 * MAX_ORDER


  IGRint		i, k, ipol;
  IGRdouble		Nif[MAX_OD];
  IGRint		order;

  
  order = cv->order;
  
  POpolarnif( order, cv->knots, ikt, par, Nif, rc);
  if( *rc != BSSUCC ) goto wrapup;

  for(k=0;k<idim;k++){
	pole[k] = 0.0;
	ipol = k + ( ikt - order + 1 ) * idim;

	for(i=0;i<order;i++){
		pole[k] += Nif[i] * cv->poles[ipol];
		ipol += idim;
	}
  }

  if( cv->rational ){

	*weight = 0.0;
	ipol = ikt - order + 1;

	for(i=0;i<order;i++)
		*weight += Nif[i] * cv->weights[ipol+i];
  }

  *rc = BSSUCC;
  return;

wrapup:
  *rc = BSFAIL;

}
