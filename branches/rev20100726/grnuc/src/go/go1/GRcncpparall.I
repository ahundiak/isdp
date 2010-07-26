/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract:
	This method creates a new object parallel to the 
  	original object.

Synopsis

 GRcpparallel(IGRlong *msg; IGRshort *mx_type, 
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid)

	IGRlong *msg; 			return message
	IGRshort *mx_type, 		matrix type of original object
	IGRmatrix matrix; 		matrix for original object
	struct GRmd_env *offset_env;	environment for offset
	struct IGRline *direction_boreline; 
					boreline to indicate direction
					of offset
	struct IGRline *distance_boreline; 
					boreline to indicate distance 
					for offset ( send NULL pointer
					if sending distance)
	IGRdouble *distance; 		distance for offset (send NULL
					if sending distance_boreline)	
	IGRboolean *apparent_flag;	flag to indicate if the offset 
					is to be apparent
					 1 - do apparant offset
					 0 - offset in plane of element
     	IGRmatrix projection_matrix;   matrix to use for apparent offset
			NOTE: non-planar elements will always be an
			      apparent offset
	GRobjid *objid   	      	offset object's id

Description

	This method does a copy parallel of an object.  If the object
 	is not planar or the mode is apparent offset, the object will
	be flattened using the projection matrix before the offset 
	is done.  If the object is planar and the apparent flag is
	not set, the offset will be in the plane of the element.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
     	MSFAIL - error occured

Notes
	None.
History
	MAS  	08/04/88 	Design date.

*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "grownmacros.h"

extern	  IGRboolean	MAptsxform();
extern	  IGRboolean	MAlnarproj();
extern	  IGRboolean	MAlnplproj();

method  GRcpparallel(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid)
{

    IGRshort	chan_flag,
		del_flag,
		num_points,
                new_props;

    IGRlong	OMmsg;			/* OM return value		*/

    IGRint 
		num;			/* loop counter			*/

    IGRdouble	t[2];
    IGRdouble 	test_value,
		dist,
		dist1;

    IGRdouble	curve_pt[6],
		line_pt[6],
		normal[3],
		dir_pt[3],
		dir_pt2[3];

    IGRchar 	classname [OM_K_MAXCLASS_LEN]; 
    IGRmatrix	tmat;

    struct IGRarc arc,ar1,new_arc;

    struct IGRplane	plane;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$send(msg = message GRconic.GRgetarc
	    (msg,mx_type,matrix,&ar1),
	targetid = my_id);

    if ( 1 & *msg)
    {
	if (*apparent_flag)
	{
	    /* the object must be projected using the input matrix
	     */

	    MAarxform(msg,&ar1,projection_matrix,&arc);
	}
	else
	{
	    arc = ar1;
	}
	plane.point = arc.origin;
	plane.normal = normal;

	normal[0] = arc.rot_matrix[2];
	normal[1] = arc.rot_matrix[6];
 	normal[2] = arc.rot_matrix[10];

        /* if the user has not sent in a distance, compute the 
	 * distance for offset.
	 */

    	if ( ! distance)
	{
	    /* project to the arc
	     */

       	    if (MAlnarproj(msg,distance_boreline,&arc,
			line_pt,curve_pt,t,&num_points) )
	    {
	    	MA2ptdis(msg,line_pt,curve_pt,&dist);
		if ( num_points == 2)
		{
	    	    MA2ptdis(msg,&line_pt[3],&curve_pt[3],&dist1);
		    if (dist1 < dist)
		    {
			dist = dist1;
		    }
		}
	    }
	    else
	    {
		*msg = MSFAIL;
	    }
	}
	else
	{
	    dist = *distance;
	}

	/* now determine the offset direction point.
	 * Project the direction boreline to the plane of the element.
	 */
		
	if (MAlnplproj(msg,direction_boreline,&plane,line_pt,dir_pt,
			t))
	{
	    /* transform the direction point to the coordinate 
	     * system of the arc.
	     */

	    MAwclsmx(msg,arc.origin,arc.rot_matrix,tmat);

	    num = 1;
	    MAptsxform(msg,&num,tmat,dir_pt,dir_pt2);

	    test_value = ((dir_pt2[0] * dir_pt2[0]) /
			  (arc.prim_axis * arc.prim_axis)) +
			  ((dir_pt2[1] * dir_pt2[1]) /
			  (arc.sec_axis * arc.sec_axis));
	    if (test_value < 1)
	    {
		dist1 = MAminimum(arc.prim_axis,arc.sec_axis);
		if (dist > dist1)
		{
		    *msg = MSINARG;
		    OMmsg = OM_E_ABORT;
		    goto wrapup;
		}
		dist = -dist;
	    }
	}
	new_arc = arc;
	new_arc.prim_axis += dist;
	new_arc.sec_axis += dist;

	om$get_classname(objid = my_id,
		classname = classname);

        /* clear the not-in-rtree and symbology override bits and set
         * the new bit as is done in the method GRcopy
         */

        new_props = me->properties & ~(GRNOT_IN_RTREE | DEHAS_OVERRIDE) |
                    GRIS_NEW;
        chan_flag = FALSE;
	del_flag = FALSE;

	GRaltchgclass(msg, offset_env, &my_id, classname, &new_props,
		&new_arc, &chan_flag, &del_flag, objid);

        if ( 1 & *msg)
	{
	   gr$add_to_active_owner(	msg = msg,
					mod_env = offset_env,
					objid = *objid);
		
	   if (! (1 & *msg))
	   {
		*msg = MSFAIL;
  		OMmsg = OM_E_ABORT;
	   }	    
	}
	else
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }

wrapup:

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_COPIED);

    return(OMmsg);
}

end implementation GRconic;
