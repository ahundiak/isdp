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

class implementation GRinfline;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "grownmacros.h"

extern    IGRboolean    MA2lndis();
extern	  IGRboolean	MA2ln2dis();
extern	  IGRboolean	MAlnoffset();

method  GRcpparallel(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid)
{
    IGRchar	inf_end;

    IGRshort    new_props;

    IGRlong	OMmsg;			/* OM return value		*/
    IGRint	action;

    IGRdouble	points[12];

    struct IGRpolyline py;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    py.points = points;
    py.num_points = 4;
    action = 2;

    OMmsg = om$send (msg = message GRlinear.GRgetpolyline
		(msg,mx_type,matrix,&action,&py),
	targetid = my_id);

    if ( 1 & *msg & OMmsg)
    {
	py.num_points = 2;
	py.points = &points[3];

        /* clear the not-in-rtree and symbology override bits and set
         * the new bit as is done in the method GRcopy
         */

        new_props = me->properties & ~(GRNOT_IN_RTREE | DEHAS_OVERRIDE) |
                    GRIS_NEW;
	inf_end = me->inf_end;

	GRlnoffset(msg,offset_env,&py,projection_matrix,distance,
		distance_boreline,direction_boreline,"GR3dinfline",
		&inf_end,apparent_flag,&new_props,&my_id,objid);

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


    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_COPIED);

    return(OMmsg);
}

end implementation GRinfline;
