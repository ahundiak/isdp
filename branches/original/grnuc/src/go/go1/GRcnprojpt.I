/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRconic

     METHOD NAME:	GRprojpt

     Abstract: 	This method projects the input point onto the 
		given object.  If an extension of the object is
		closer than the actual object, then the point will
		be projected onto the extension.
	
-----
%SC%    

     GRprojpt(msg,matrix_type,matrix,locate_parms,point,proj_pt,proj_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *locate_parms GRparms	  used to identify segment to project
				  to (segmented objects only)
     point	   IGRpoint	  point to project

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
		MAptbcproj

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
	This method projects the input point onto the given object.
	If the extended portion of the conic object is closer to
	the input point than the actual object, then the projected
	point returned will be on the extension.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "gocmacros.h"
#include "godef.h"
#include "msdef.h"
#include "mapriv.h"

extern    IGRboolean    MAptbcproj();

method GRprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *locate_parms; 
		IGRpoint point,proj_pt; struct GRparms *proj_parms)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local return code		*/
	IGRchar *absgptr,*ptr;		/* abstract geometry pointer	*/
	IGRdouble tol = MAETA;		/* tolerance used in project	*/
	struct IGRbsp_curve *curve,*conic; /* B-spline curves		*/
	IGRlong nbytes;			/* number of bytes to allocate	*/

	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
	proj_parms->u = locate_parms->u;
	
	GRgetabsg(&msg1,matrix_type,matrix,&absgptr,i);

	if (1 & msg1)
	{

	   curve = (struct IGRbsp_curve *)absgptr;

	   GRbc_size(curve->order,7,curve->rational,curve->num_boundaries,
		     nbytes);

	   ptr = om$malloc(size = nbytes);

	   /* get the extended geometry of the conic object */

	   OMmsg = om$send(mode = OM_e_wrt_object,
               msg = message GRconic.GRgetexgeom
			(&msg1,matrix_type,matrix,ptr),
               senderid = my_id,
               targetid = my_id);

	   if (1 & OMmsg)
	   {
	      conic = (struct IGRbsp_curve *)ptr;

	      /* project the input point onto the extended geometry */

	      if (! (1 & MAptbcproj(&msg1,point,conic,&tol,proj_pt,
				    &proj_parms->v)))
	      {
	         OMmsg = OM_E_ABORT;	
	      }
	      else
	      {
		 *msg = MSSUCC;
	      }
	   }

	   om$dealloc(ptr = ptr);		/* deallocate storage	*/
	   
	}

	


	return(OMmsg);
}

end implementation GRconic;
