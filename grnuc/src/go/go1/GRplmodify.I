/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRplanar

     METHOD NAME:	GRmodify

     Abstract: 	This method redefines the geometric representation
	      of the planar object by changing some attribute of 
	      its geometry.
	
-----
%SC%    

     GRmodify(msg,md_env,vert_loc,point,boreline,new_objid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env       GRmd_env	  environment information
     *vert_loc	   GRparms	  locates the appropriate vertex 
				  (i.e. line strings which may have
				 	repeated vertices)
     point	   IGRpoint	  point to identify vertex to modify
     *boreline	   IGRline	  locates new vertex that replaces
				  vertex to modify 
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *new_objid    GRobjid 	 modified objects id
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAdetplane
		MAlnplproj

     Methods:	

		GRmodify		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:	The new vertex that replaces the original 
		maintains the planarity of the object.

-----
%CH%

     CHANGE HISTORY:
	
	SDG	05/29/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method projects the input point onto the control points
	of the B-spline representation of the planar object and 
	replaces that point found by the projection with the first 
	point of the input boreline.  This replacement does not 
	affect the planarity of the object.  The method assumes that
	the boreline was obtained by using the routine GRbrlncon.c. 

----*/
/*EH*/

class implementation GRplanar;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAdetplane();
extern    IGRboolean    MAlnplproj();

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline;GRobjid *new_objid)

{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	IGRlong i;			/* loop counter			*/
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/
	struct IGRplane plane;		/* plane of object		*/
	IGRpoint pl_pt;			/* plane point			*/
	IGRvector normal;		/* normal vector of plane	*/
	IGRdouble tol = 0.5;		/* tolerance for planarity	*/
	IGRdouble tparm;		/* t parm of project		*/
	IGRpoint line_pt,plane_pt;	/* projected points		*/

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
        *new_objid = my_id;
	plane.point = pl_pt;
	plane.normal = normal;
	
	GRgetabsg(&msg1,&md_env->md_env.matrix_type,md_env->md_env.matrix,
		  &absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	/* determine the plane of the object */

        if (curve->num_poles > 2)
	{
	    /* if MAdetplane fails, just use the boreline as it came
	     * in.
	     */

	    if (MAdetplane(&msg1,curve->poles,&curve->num_poles,
			      &tol,&plane))
	    {
	    /* project the input boreline onto the plane of the object
	     * to find the vertex on same plane as the object that 
	     * replaces the one identified to modify
	     */
	        if (MAlnplproj(&msg1,boreline,&plane,line_pt,plane_pt,&tparm))
	        {
	       	    MAcopy(boreline->point1,plane_pt,1,i);
		}
		else
		{
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		}
	    }
	}

	/* call the B-spline modify to replace the proper pole */

	OMmsg = om$send(mode = OM_e_wrt_message,
                        msg = message GRbspline.GRmodify(msg,md_env,vert_loc,point,boreline,new_objid),
                        senderid = my_id,
                        targetid = my_id);

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);
wrapup:

	return(OMmsg);

}

end implementation GRplanar;
