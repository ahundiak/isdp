/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRconic

     METHOD NAME:	GRapprojpt

     Abstract: 	This method projects the input boreline onto the 
		given object.  If an extension of the object is
		closer than the actual object, then the boreline 
		will be projected onto the extension.
	
-----
%SC%    

     GRapprojpt(msg,matrix_type,matrix,locate_parms,boreline,
		proj_pt,proj_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *locate_parms GRparms	  used to identify segment to project
				  to (segmented objects only)
     boreline	   IGRline	  input line to project

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     proj_pt	   IGRpoint	 the projected point on the object
				 (or on an extension)
     *proj_parms   GRparms	 projection parameters

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAlnbcproj

     Methods:	
		GRgetexgeom
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	SDG     06/09/86 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method projects the input boreline onto the given 
	object.  If the extended portion of the conic object is
	closer to the input boreline than the actual object, then 
	the projected point returned will be on the extension.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "OMminimum.h"
#include "mapriv.h"
#include "madef.h"
#include "msdef.h"
#include "godef.h"
#include "igrtypedef.h"
#include "gocmacros.h"

extern    IGRboolean    MAlnbcproj();

method GRapprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *locate_parms; struct IGRline *boreline; 
		IGRpoint proj_pt; struct GRparms *proj_parms)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local return code		*/


%safe
	IGRchar buffer[sizeof(struct IGRbsp_curve) + 
		sizeof(IGRdouble) * (MAELPOLE_SIZE * 4 + MAELKNOT_SIZE)
		+ 8];
%endsafe

	IGRdouble tparm;  		/* t parm of projected line pt  */
	IGRdouble tol = MAETA;		/* tolerance used in project	*/

	IGRpoint line_pt;		/* project pt on boreline	*/
	struct IGRbsp_curve *curve; 	/* B-spline curve		*/

	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;

	proj_parms->u = locate_parms->u;
 	proj_parms->leaf_id.objid = my_id;
	proj_parms->leaf_id.osnum = OM_Gw_current_OS;
	proj_parms->polygon_inx = 4;	/* v of parameter structure has
					 * projection to extension	*/

	/* get the extended geometry of the conic object */
	
	curve = (struct IGRbsp_curve *)GRalign_quad(buffer);
	
	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRconic.GRgetexgeom
			    (&msg1,matrix_type,matrix,(IGRchar *)curve),
                        senderid = my_id,
                        targetid = my_id);

	if (1 & OMmsg)
	{
	   /* project the input boreline onto the extended geometry */

	   if (! (1 & MAlnbcproj(&msg1,boreline,curve,&tol,
			line_pt,proj_pt,&tparm,&proj_parms->v)))
	   {
	      OMmsg = OM_E_ABORT;	
	   }
	   else
	   {
	      *msg = MSSUCC;
	   }
	}
	
	

	
	return(OMmsg);
}
end implementation GRconic;
