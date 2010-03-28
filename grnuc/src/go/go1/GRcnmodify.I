/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRconic

     METHOD NAME:	GRmodify

     Abstract: 	This method redefines the geometric representation
	      of the conic object by changing some attribute of its 
	      geometry.  The overall shape of the object is maintained.
	
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
     point	   IGRpoint	  approx point to modify
     *boreline	   IGRline	  locates new point that extended 
				  conic must pass through
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *new_objid	   GRobjid	 modified object id
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAeltobc
		MAlnbcproj
		MA2ptdis
		MAartobc

     Methods:	

		GRgetarc
		GRpostabsg

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:	The modified conic object maintains the axis ratio
		of the original object.

-----
%CH%

     CHANGE HISTORY:
	
	SDG	06/11/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method gets the abstract geometry of the conic object 
	and converts it to an IGRarc.  The input boreline is 
	projected onto the extension of the conic object.  It is the 
	projected point on the boreline that the modified conic 
	object will pass through.  The new axes are modified such 
	that their ratio is equivalent to the ratio of the old.  
	The new conic element is converted to a B-spline curve and
	is posted.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAlnarproj();
extern    IGRboolean    MA2ptdis();

method GRmodify(IGRlong *msg; struct GRmd_env *md_env; 
		struct GRparms *vert_loc; IGRpoint point; 
		struct IGRline *boreline; GRobjid *new_objid)

{
	IGRshort num_points;
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRdouble tparm[2];		/* t parm of project		*/
	IGRpoint pt1,pt2;		/* pointers			*/
	IGRvector normal;		/* vector			*/
	IGRlong i;			/* loop counter			*/
	struct IGRline line;		/* line to project		*/
	struct IGRplane plane;		/* plane of object		*/
	IGRdouble line_pt[6],
		proj_pt[6];		/* projected points		*/
	struct IGRarc arc;		/* arc for conic object		*/
	struct GRpost_info info;	/* information for GRpostabsg	*/
	GRspacenum osnum;		/* current space		*/
	IGRdouble dis1,dis2,dis3,dis4;	/* distances between points	*/
	IGRpoint prim_pt,sec_pt;	/* points on prim & second axes */

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	*new_objid = my_id;
	line.point1 = pt1;
	line.point2 = pt2;
	
	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRconic.GRgetarc(msg,
				&md_env->md_env.matrix_type,
				md_env->md_env.matrix,&arc),
                        senderid = my_id,
                        targetid = my_id);

	if (1 & OMmsg & *msg)
	{   
	    plane.normal = normal;
	    plane.point = arc.origin;
	    normal[0] = arc.rot_matrix[2];
	    normal[1] = arc.rot_matrix[6];
	    normal[2] = arc.rot_matrix[10];

	    if (1 & MAlnplproj(&msg1,boreline,&plane,line_pt,line.point1,
				    tparm))
	    {
		MAcopy(line.point2,arc.origin,1,i);

	        if (1 & MAlnarproj(&msg1,&line,&arc,line_pt,
				   proj_pt,tparm,&num_points))
		{
	            prim_pt[0] = arc.prim_axis * arc.rot_matrix[0] 
				    + arc.origin[0];
	            prim_pt[1] = arc.prim_axis * arc.rot_matrix[4]  
				    + arc.origin[1];
	            prim_pt[2] = arc.prim_axis * arc.rot_matrix[8] 
				    + arc.origin[2];

               	    sec_pt[0] = arc.sec_axis * arc.rot_matrix[1] 
				   + arc.origin[0];
	            sec_pt[1] = arc.sec_axis * arc.rot_matrix[5] 
				   + arc.origin[1];
	            sec_pt[2] = arc.sec_axis * arc.rot_matrix[9] 
				   + arc.origin[2];
			
	            MA2ptdis(&msg1,proj_pt,arc.origin,&dis1);
	            MA2ptdis(&msg1,prim_pt,arc.origin,&dis2);
	            MA2ptdis(&msg1,line.point1,arc.origin,&dis3);
		    MA2ptdis(&msg1,sec_pt,arc.origin,&dis4);

	 	    arc.prim_axis = (dis3/dis1) * dis2;
	
	            arc.sec_axis = (arc.prim_axis/dis2) * dis4;

	       	    info.construct_flag = FALSE;

                    OMmsg = om$send(
                       	msg = message GRconic.GRputarc
		           (msg,md_env,&info,&arc,new_objid),
                       	senderid = my_id,
                       	targetid = my_id);
				    
                    if (1 & OMmsg)
		    { 
	    	 	osnum = OM_Gw_current_OS;
		     	GRabsg_del_by_objid(&my_id,&osnum);
		    }
		}
		else
		{
		    OMmsg = OM_E_ABORT;
		    *msg = MSFAIL;
		}
	    } 
	    else
	    {
		OMmsg = OM_E_ABORT;
		*msg = MSFAIL;
	    }
	} 
	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_MODIFIED);

	return(OMmsg);

}

end implementation GRconic;
