/*----
%HD%
 
     MODULE NAME POdistptpts
 
     Abstract:
        This function computes the square distance between two points.

-----
%SC%

     IGRdouble = POdistptpts( idim, p1, p2, rc )
	    	              I   , I , I , O

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	idim	   IGRshort	 dimension of p1 and p2
        *p1	   IGRdouble	 input point	 
	*p2        IGRdouble     input point
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

        *rc        BSrc         completion code message
                                
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


# include "bserr.h"
# include "bstypes.h"

IGRdouble POdistptpts( idim, p1, p2, rc)

IGRshort	idim;
IGRdouble       *p1;
IGRdouble	*p2;
BSrc            *rc;

{

    IGRint	i;
    IGRdouble	diff, trav;



    trav = 0.0;

    for(i=0;i<idim;i++){
	 diff = p2[i] - p1[i];
	 trav += diff * diff;
    }

    *rc = BSSUCC;

    return( trav );

}

