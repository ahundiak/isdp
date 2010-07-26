/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRpoint

     METHOD NAME:	GRmodify

     Abstract: 	This method redefines the geometric representation
	      of the object by changing some attribute of its
	      geometry.
	
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

     Methods:	

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

class implementation GRpoint;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "godef.h"

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline; GRobjid *new_objid)

{
	IGRlong	OMmsg;			/* OM return value		*/
	struct IGRpolyline py;
	struct GRpost_info info;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	*new_objid = my_id;

	py.points = boreline->point1;
	py.num_points = 1;
	info.construct_flag = 0;

	OMmsg = om$send(msg = message GRlinear.GRputpolyline
	    (msg,md_env,&info,&py,new_objid),
	    targetid = my_id);


	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

	return(OMmsg);
}
end implementation GRpoint;
