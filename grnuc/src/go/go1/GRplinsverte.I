/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRplanar
     METHOD NAME:  GRinsvertex

     Abstract:  This routine inserts the input vertex into
		the planar object at the specified location.  
		Special processing is performed if the
		input vertex should be inserted at a current
		vertex point or if the object is a polygon
		and the vertex is to be inserted at the
		start/end point.
-----
%SC%    

     GRinsvertex(msg,md_env,ref_parms,boreline,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	   GRmd_env	  environment information 
     *ref_parms	   GRparms	  parameters identifying segment
     *boreline     IGRline	  the desired vertex to insert
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *newobjid     GRobjid	 will contain a new object id if the
				    object changes classes 
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   MAdetplane
		MAlnplproj

     Methods:   GRinsvertex
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  The inserted vertex maintains
	     the planarity of the object.
-----
%CH%

     CHANGE HISTORY:
	
	KMO     05/22/86 : Design date.
	KMO	05/22/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine receives a vertex point to insert into
	the planar object at a specified location (also received
	as input).  The insertion does not affect the planarity 
	of the object.  Special processing will occur based on the
	type of object.  Following is a description of this
	special processing:

	point:
	  a line is formed, the new point becomes the start
		point and the original point becomes the
		endpoint

        line:
	  if selected location is exactly an endpoint,
		new point becomes new endpoint
	  otherwise, new point is added between 
	       	endpoints

	line string:
	  if selected location is exactly start or end
		point, start or end is replaced by new point
	  if selected location is a vertex of segment,
		new point is inserted before vertex of segment
	  if selected location is between the endpoints of a
		segment, the new point is inserted there

	polygon:
	  processed exactly like the line string except for the
	  	following case
 	  if selected location is the start/end point,
		the new point is inserted before the start point
		to become the new start point and the original
		endpoint is modified to close the polygon (becomes
		the new point also).
----*/
/*EH*/

class implementation GRplanar;

#include "grimport.h"
#include "msdef.h"
#include "maerr.h"
#include "gocmacros.h"
#include "mapriv.h"
#include "godef.h"

method GRinsvertex(IGRlong *msg; struct GRmd_env *md_env;
	    	  struct GRparms *ref_parms; struct IGRline *boreline;
		  GRobjid *newobjid)
{
    IGRlong 		status;		/* return status for method	*/
    IGRchar		*buffer;	/* pointer to dynamic buffer	*/
    struct IGRbsp_curve *curve;
    IGRdouble		tparm;
    IGRpoint		lnpt,plpt;
    IGRdouble	  	tol = 0.5;
    struct IGRplane 	plane;
    IGRdouble		pl_point[3];
    IGRdouble		pl_normal[3];
    IGRlong		i;
    IGRlong		internal_msg;
extern    IGRboolean    MAdetplane();
extern    IGRboolean    MAlnplproj();

/*
 *  initialize variables
 */

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

/*
 *  get abstract geometry of object
 */

    GRgetabsg(&internal_msg,&md_env->md_env.matrix_type,
	      md_env->md_env.matrix,&buffer,i);
 
    if (! (1 & internal_msg))
    {
	*msg = MSFAIL;
	status = OM_E_ABORT;
	goto wrapup;
    }  

    curve = (struct IGRbsp_curve *)buffer;

/*
 *  determine the plane of the object
 *
 *  if no plane can be found,
 *	the first point of the boreline will be inserted into the object
 *	otherwise, the boreline will be projected onto the plane
 *		and the point on the plane will be inserted
 */

    plane.point = pl_point;
    plane.normal = pl_normal;

    MAdetplane(&internal_msg,curve->poles,&curve->num_poles,&tol,&plane);

    if ( internal_msg != MASDGENRAT )
    {
	/*
	 *  project the boreline onto
	 *  the plane of the object 
	 */

	MAlnplproj(&internal_msg,boreline,&plane,lnpt,plpt,&tparm);
	MAcopy(plpt,boreline->point1,1,i);
    }

    /*
     *  insert the vertex into the object
     */

    status = om$send(mode = OM_e_wrt_message,
                     msg = message     GRlinear.GRinsvertex(msg,md_env,    ref_parms,boreline,newobjid),
                     senderid = my_id,
                     targetid = my_id);

	GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_MODIFIED);
wrapup:

	return(status);

}

end implementation GRplanar;
