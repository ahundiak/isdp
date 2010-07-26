/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRbspline
     METHOD NAME:  GRlnproject

     Abstract: 
		This method projects the input boreline
		onto the object.
-----
%SC%    

    GRlnproject(msg,matrix_type,matrix,line,line_pt,
		curve_pt,t,curve_parms)


-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *line         IGRline	  line to project onto object
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     line_pt	  IGRpoint	 projected point on the line
     curve_pt	  IGRpoint	 point on element where projection
				 occurred
     *t  	  IGRdouble	 parameter describing projected 
				 point on the line
     *curve_parms GRparms 	 parameters describing projected
				 point on the curve

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
	
	MAS     04/03/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This module returns a point projected onto a geometry
	which can be represented as a B-spline curve.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAlnbcproj();

method GRlnproject(IGRlong *msg; IGRshort *matrix_type; IGRmatrix 
		   matrix; struct IGRline *line; IGRpoint line_pt,
		   curve_pt; IGRdouble *t; struct GRparms *curve_parms)

{
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRchar 	*ptr;			/* character pointer		*/

    IGRdouble 	tolr;			/* tolerance for project	*/


    *msg = MSFAIL;			/* initialize to failure	*/
    OMmsg = OM_E_ABORT;			/* initialize OM return code	*/
					/* get abstract geometry	*/
    GRgetabsg(&msg2,matrix_type,matrix,&ptr,i);

    if ( 1 & msg2)			/* check completion status	*/
    {					
        tolr = 0.0000000001;		/* tolerance for projection	*/

					/* project point onto curve	*/
        if (MAlnbcproj(&msg2,line,ptr,&tolr,line_pt,curve_pt,
		       t, &curve_parms->u) )
	{
	    OMmsg = OM_S_SUCCESS;	/* successful completion	*/
	    *msg = MSSUCC;
	    curve_parms->polygon_inx = 0;
	    curve_parms->leaf_id.objid = my_id;
	    curve_parms->leaf_id.osnum = OM_Gw_current_OS;
	}
    }

	
    
    return( OMmsg );
}

end implementation GRbspline;

