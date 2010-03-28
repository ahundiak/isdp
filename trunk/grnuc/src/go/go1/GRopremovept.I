/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRorthpoly

     METHOD NAME: GRremovepts

     Abstract: 	

		This method removes a set of points from an 
	orthogonal polygon object.  The requested number of
	points are removed beginning with the next to last
	point.  The repeated last point is preserved.

-----
%SC%    

	GRremovepts(msg,env,num)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *num	  IGRshort	 number of points to remove
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				   - MSSUCC if successful     
				   - MSFAIL (severe) if other error
				   - GRNOTALLREMOVED (warning) not all
				     requested points could be removed
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		MApytobc

     Methods:
		GRgenabsg
		GRputpolyline
-----
%RL%

     RELATIONS REFERENCED:	None.

-----
%NB%

     NOTES:  Before any points are removed from the object, the
	     total number of points in the object is compared to
	     the number of points to remove.  If the difference
 	     is less than the number of required points to define
	     the geometry, then only a valid number of points 
	     will be removed and a proper warning message will
	     be returned.

-----
%CH%

     CHANGE HISTORY:
	
	KMO     02/09/87 : Design date.
	KMO	02/09/87 : Creation date.
	KMO	10/26/87 : Revision date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	The abstract geometry is generated and the number of
	points (poles) in the object is decremented by "num".
	A temporary polyline is formed from the curve and used
	to post the changes into the instance data.
*/

class implementation GRorthpoly;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "grerr.h"

method  GRremovepts(IGRlong *msg; struct GRmd_env *env; IGRshort *num)
{
	IGRchar *ptr;			/* pointer			  */
	IGRlong OMreturn;		/* OM return value		  */
	IGRlong msg2;			/* local return message		  */
	IGRlong new_num_poles;		/* new number of poles		  */
	IGRlong required_total = 5;	/* required # of pts for geometry */
	struct  IGRbsp_curve *curve;	/* structure for B-spline curve   */
	struct  IGRpolyline   py;	/* polyline structure		  */
	struct  GRpost_info  info;	/* information for GRpostabsg	  */
	GRobjid	new_objid;


	*msg = MSSUCC;
	OMreturn = OM_S_SUCCESS;

/* 
 *
 * Generate the abstract geometry.
 *
 */

	GRgetabsg(&msg2,&env->md_env.matrix_type,env->md_env.matrix,
		  &ptr,i);

	if (! (1 & msg2))
	{
	  *msg = MSFAIL;
	  OMreturn = OM_E_ABORT;
	  goto wrapup;
	}

	curve = (struct IGRbsp_curve *) ptr;

	if (( curve->num_poles - *num) < required_total )
	{
	    *msg = GRNOTALLREMOVED;
	    new_num_poles = required_total;
	}
	else
	{	
	    new_num_poles = curve->num_poles - *num;
	}

        /*
	 *  object is closed, save repeated end point
	 */

	    curve->poles[(new_num_poles-1)*3] =
			 curve->poles[(curve->num_poles-1)*3];
	    curve->poles[((new_num_poles-1)*3)+1] =
			 curve->poles[((curve->num_poles-1)*3)+1];
	    curve->poles[((new_num_poles-1)*3)+2] =
			 curve->poles[((curve->num_poles-1)*3)+2];
	    
/*
 *
 *  post the geometry back into the object.
 *
 */

        py.num_points = new_num_poles;
	py.points = curve->poles;

	info.construct_flag = FALSE;

	OMreturn = om$send(mode = OM_e_wrt_object,
                           msg = message GRlinear.GRputpolyline
				 ( &msg2, env, &info,&py,&new_objid),
                           senderid = my_id,
                           targetid = my_id);

	if ( msg2 != MSSUCC )
	{
	    *msg = msg2;
	}

	GRabsg_del (ptr);

	GR_NOTIFY_LISTENERS(msg,&OMreturn,GR_GEOM_MODIFIED);

wrapup:

	return (OMreturn);
}


end implementation GRorthpoly;
