/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRorthogonal
     METHOD NAME:  GRinsvertex

     Abstract:  This routine inserts the input vertex into
		the orthogonal object at the specified location.  
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

     Modules:   MAlnlsproj
 	        MAutoparms

     Methods:   GRinsvertex
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  The inserted vertex maintains
	     the orthogonality of the object.
-----
%CH%

     CHANGE HISTORY:
	
	KMO	08/01/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This routine receives a vertex point to insert into
	the orthogonal object at a specified location (also
	received as input).  The insertion does not affect the
	orthogonality of the object.  Special processing will
	occur based on the type of object.  Following is a
	description of this special processing:

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

class implementation GRorthogonal;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MAlnlsproj();

method GRinsvertex(IGRlong *msg; struct GRmd_env *md_env;
	    	  struct GRparms *ref_parms; struct IGRline *boreline;
		  GRobjid *newobjid)
{

    IGRlong 		status;		/* return status for method	*/
    struct IGRbsp_curve *curve;
    IGRchar		*buffer;
    struct IGRline	new_boreline;
    struct IGRline_seg	line_seg;
    IGRpoint		point1;
    IGRpoint		point2;
    IGRdouble		tparm;
    IGRdouble		t1;
    IGRdouble		t2;
    IGRlong		segnum;
    IGRlong		internal_msg;

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
 *  determine where to insert the vertex (which segment)
 */

    if (MAutoparms(&internal_msg,curve,&ref_parms->u,&segnum,&tparm))
    {
    
	line_seg.beg_point = &curve->poles[(segnum-1) * 3];
	line_seg.end_point = &curve->poles[segnum * 3];

	MAlnlsproj(&internal_msg,boreline,&line_seg,point2,point1,&t1,&t2);

	new_boreline.point1 = point1;
	new_boreline.point2 = point1;

	status = om$send(mode = OM_e_wrt_message,
                         msg = message GRlinear.GRinsvertex(msg,md_env,ref_parms,&new_boreline,newobjid),
                         senderid = my_id,
                         targetid = my_id);
    }

	GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_MODIFIED);
wrapup:

	return(status);

}

end implementation GRorthogonal;
