/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline

     METHOD NAME:	GRmodify

     Abstract: 	This method redefines the geometric representation
	      of the object by changing some attribute of its
	      geometry.
	
----
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
				  the vertex to modify 
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *new_objid    GRobjid	 modified objects id
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAptpsproj

     Methods:	

		GRgeomprops
		GRpostabsg		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
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
	of the B-spline representation of the object and replaces
	that point found by the projection with the first point of
	the input boreline.  The method assumes that the boreline  
	was obtained by calling the routine GRbrlncon.c. 

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "mapriv.h"
#include "godef.h"

extern 	IGRboolean MAdetplane();
extern	IGRboolean MAptpsproj();	/* point to point set project	*/

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline; GRobjid *new_objid)

{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	IGRlong i;			/* loop counter			*/
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/
	struct IGRpointset pt_set;	/* point set,control pts of curve*/
	struct GRprops props;		/* geometry properties		*/
	struct GRpost_info info;	/* information for GRpostabsg	*/
	IGRlong pt_num;			/* point number of point set	*/
	IGRpoint pole;			/* pole to alter		*/
      	struct IGRplane plane;
	GRobjid newobjid;		/* argument for postabsg	*/
	IGRdouble pt1[3],normal[3];
	IGRdouble tol,dist;
        IGRboolean b_status;


	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	*new_objid = my_id;
	
	GRgetabsg(&msg1,&md_env->md_env.matrix_type,md_env->md_env.matrix,
		  &absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	/*
	 * form a point set from the B-spline poles
	 * project the input point to this point set
	 */

	pt_set.num_points = curve->num_poles;
	pt_set.points = curve->poles;

	if (curve->rational)
	{
	   b_status = MAbcunweight(&msg1,curve);
	}

	if (! (1 & MAptpsproj(&msg1,point,&pt_set,pole,&pt_num)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}
	
	/*
	 * Replace the vertex found from the project with the first
	 * point of the input boreline (formed by GRbrlncon.c).
	 * Post the resulting B-spline.
	 */

	MAcopy(&curve->poles[(pt_num - 1)*3],boreline->point1,1,i);

	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRgeomprops(&msg1,&md_env->md_env.matrix_type,md_env->md_env.matrix,&props),
                        senderid = my_id,
                        targetid = my_id);

	if (! (1 & OMmsg))
	{
	   *msg = MSFAIL;
	   goto wrapup;
	}

	if ((props.closed) && ((pt_num == 1) || (pt_num == curve->num_poles)))
	{
	   if ( vert_loc->u > (curve->knots[curve->order-1] + MAETA))
	   {
		pt_num = curve->num_poles;
	   }	   
	   if ((pt_num == 1) || (pt_num == curve->num_poles))
	   {
       	      MAcopy(&curve->poles[0],boreline->point1,1,i);              
	      MAcopy(&curve->poles[(curve->num_poles - 1)*3],boreline->point1,
		     1,i);
	   }
	}
	else
	{
	    MA2pt2dis(&msg1,curve->poles,
		&curve->poles[(curve->num_poles-1)*3],&dist);
	    if (dist == 0.0)
	    {
		curve->phy_closed = TRUE;
	    }
	    else
	    {
		curve->phy_closed = FALSE;
	    }
	}
	tol = 0.00001;
	plane.point = pt1;
	plane.normal = normal;

        if (MAdetplane(&msg1,curve->poles,&curve->num_poles,&tol,&plane))
	{
	    curve->planar = TRUE;
	}
	else
	{
	    curve->planar = FALSE;
	}
	info.construct_flag = FALSE;

	if (curve->rational)
	{
	   b_status = MAbcweight(&msg1,curve);
	}

	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRpostabsg(msg,md_env,&info,        (IGRchar *)curve,&newobjid),
                        senderid = my_id,
                        targetid = my_id);
	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);
wrapup:

	return(OMmsg);

}

end implementation GRbspline;



