/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRgraphics
     METHOD NAME:  GRptprocess

     Abstract: 
	This method does the processing to do a proximity check
	for a point locate of an object.
-----
%SC%    

    GRptprocess(msg,matrix_type,matrix,acc_tolerance,point,
	proj_pt,proj_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     acc_tolerance IGRdouble	  accept tolerance     
     point         IGRpoint	  point to project onto object
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     proj_pt	  IGRpoint	 point on element where projection
				 occurred

     *proj_parms  GRparms 	 projection parameters

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     04/13/88 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This module defaults to call GRptproject method.
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "grerr.h"

method GRptprocess(IGRlong *msg; IGRshort *matrix_type; IGRmatrix 
		matrix; IGRdouble *acc_tolerance; 
		IGRpoint point, proj_pt; struct GRparms *proj_parms)

{
    IGRlong	OMmsg,
		msg1;

    IGRdouble	dis;
    
    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    OMmsg = om$send(msg = message GRgraphics.GRptproject
		(msg,matrix_type,matrix,point,proj_pt,proj_parms),
	targetid = my_id);

    if (1 & OMmsg & *msg)
    {	
    	MA2pt2dis(&msg1,point,proj_pt,&dis);

    	if (dis <=  (*acc_tolerance * *acc_tolerance) )
    	{
	    *msg = MSSUCC;
    	}
    	else
    	{
	    *msg = GR_I_OUTSIDE_TOL;
	}
    }    

    return( OMmsg );

}
end implementation GRgraphics;
