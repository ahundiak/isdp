/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRcentcurv

     Abstract: This routine returns the origin of the conic as the
	center of curvature of a conic element.  

	This is not actually the center of curvature of an elliptical
	conic but it is the desired result from this method.
-----
%SC%    

	 GRcentcurv( msg,mat_type,matrix,parms,center )
     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     mat_type	  IGRshort	 environment matrix type
     matrix	  IGRmatrix      environment matrix
     parms	  struct GRparms parameter

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure

     center	  IGRpoint	 centroid of element
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     
     Methods:
		GRcenter	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     01/20/88 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method invokes the GRcenter method on the object.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"

method GRcentcurv(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		  struct GRparms *parms; IGRpoint center)
{
  IGRlong OMmsg;


  OMmsg =  om$send(msg = message GRconic.GRcenter(msg,mat_type,matrix,
						   center),
		   targetid = my_id);

  return( OMmsg );

}

end implementation GRconic;
