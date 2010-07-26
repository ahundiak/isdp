/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlbsys
     METHOD NAME:  GRlnproject

     Abstract: 
		This method projects the input point
		onto the given object.
-----
%SC%    

    GRlnproject(msg,matrix_type,matrix,line,line_pt,
		proj_pt,t,parms)


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
     proj_pt	  IGRpoint	 point on element where projection
				 occurred
     *t		  IGRdouble	 t parameter describing projected 
				 point on the line
     *parms 	  GRparms 	 this argument will not be used 
			 	 in this routine.

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAlnlbproj

     Methods:
	GRgenabsg
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
	
	MAS     04/07/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This module returns a point projected onto a geometry
	which can be represented as a local bounded system.

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAlnlbproj();

method GRlnproject(IGRlong *msg; IGRshort *matrix_type; IGRmatrix 
		   matrix; struct IGRline *line; IGRpoint line_pt,
		   lbsys_pt; IGRdouble *t; struct GRparms *parms)

{
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRchar 	*ptr;			/* pointer to geometry		*/

    *msg = MSFAIL;			/* set to failure		*/
    OMmsg = OM_E_ABORT;		
					/* get abstract geometry	*/
    GRgetabsg(&msg2,matrix_type,matrix,&ptr,i);

    if (1 & msg2)			/* check completion status	*/
    {					/* project point onto curve	*/
        if (MAlnlbproj(&msg2,line,ptr,line_pt,lbsys_pt,t))
	{
	    parms->u = 0.0;
	    parms->v = 0.0;
	    parms->leaf_id.objid = my_id;
	    parms->leaf_id.osnum = OM_Gw_current_OS;
	    parms->polygon_inx = 2;

 	    OMmsg = OM_S_SUCCESS;	/* successful completion	*/
	    *msg = MSSUCC;
	}
    }

	
    
    return( OMmsg );

}
end implementation GRlbsys;

