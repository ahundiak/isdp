/*----
%HD%
 
     MODULE NAME POcvevlen
 
     Abstract:
        This function evaluates teh len of a curve using Gauss integration
	points. This function works now on just bezier curve.
-----
%SC%

     result = POcvevlen( cv, ustart, uend, &rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *cv        IGRbsp_curve  the input curve  
        ustart     IGRdouble     start parameter for curve length
	uend       IGRdouble	 end parameter for curve length 
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
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
        
        JLL    : 26 april 1993.
      
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

IGRdouble POcvevlen( cv, ustart, uend, rc )
struct	IGRbsp_curve	*cv;
	IGRdouble       ustart;
	IGRdouble	uend;
	BSrc            *rc;

{

extern	IGRdouble	sqrt();
extern	void		BScveval();


static double gpa[10]  = {
 
	-0.97390653, -0.8650634, -0.67940957, -0.43339539, -0.14887434,
	 0.14887434,  0.43339539, 0.67940957,  0.8650634,   0.97390653    

};

static double gh[10]  = {
 
	 0.06667134, 0.14945135, 0.21908636, 0.26926672, 0.29552422,
	 0.29552422, 0.26926672, 0.21908636, 0.14945135, 0.06667134

};


IGRint		i;
IGRdouble 	len, lenDev, u, dv[6];
IGRdouble	ueMus, uePus;


	len = 0.0;
	ueMus = ( uend - ustart ) * 0.5;
	uePus = ( uend + ustart ) * 0.5;

    	for(i=0;i<10;i++){

/*		u = ( (uend - ustart)*gpa[i] + (uend + ustart) ) * 0.5; */
		u = ueMus * gpa[i] + uePus;	 
	
		BScveval( cv, u, 1, dv, rc );
		lenDev = sqrt( (dv[3]*dv[3] + dv[4]*dv[4] + dv[5]*dv[5]) );
		len += lenDev * gh[i];
    	}


/*	len *= (uend - ustart) * 0.5; */
	len *= ueMus;

    	*rc = BSSUCC;
    	return( len );

}
