/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRlbsys
     METHOD NAME:  GRptproject

     Abstract: 
		This method projects the input point
		onto the given object.
-----
%SC%    

    GRptproject(msg,matrix_type,matrix,point,proj_pt,parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
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

     *parms  	GRparms 	 projection parameters (not used in
				    this routine)

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAptlbproj

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

extern    IGRboolean    MAptlbproj();

method GRptproject(IGRlong *msg; IGRshort *matrix_type; IGRmatrix 
		   matrix; IGRpoint point, proj_pt; 
		   struct GRparms *parms)

{
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRchar     *ptr;			/* pointer to geometry		*/

    *msg = MSFAIL;			/* initialize to failure	*/
    OMmsg = OM_E_ABORT;			/* initialize OM return code	*/
					/* get abstract geometry	*/
    GRgetabsg(&msg2,matrix_type,matrix,&ptr,i);

    if ( 1 & msg2)			/* check completion status	*/
    {					/* project point onto curve	*/
        if (MAptlbproj(&msg2,point,ptr,proj_pt ) )
	{
	    parms->u = 0;
	    parms->v = 0;
	    parms->leaf_id.objid = my_id;
	    parms->leaf_id.osnum = OM_Gw_current_OS;
	    parms->polygon_inx = 2;

	    OMmsg =OM_S_SUCCESS;
	    *msg = MSSUCC;
	}
	    	
   }


	
    
    return( OMmsg );

}
end implementation GRlbsys;

