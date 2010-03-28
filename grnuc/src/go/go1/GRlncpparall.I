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

class implementation GRlinear;

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
    IGRchar 	*absgptr;		/* abstract geometry pointer	*/

    IGRshort    new_props;

    IGRlong	OMmsg;			/* OM return value		*/



    IGRchar 	classname [OM_K_MAXCLASS_LEN]; 

    struct IGRbsp_curve *curve;		/* pointer to B-spline curve	*/
    struct IGRpolyline  py;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    GRgetabsg(msg,mx_type,matrix,&absgptr,i);
    
    if ( 1 & *msg)
    {
	curve = (struct IGRbsp_curve *) absgptr;

	if (curve->num_poles > 2)
	{
	    om$send(mode = OM_e_wrt_message,
		msg = message GRbspline.GRcpparallel
		    (msg,mx_type,matrix,offset_env,direction_boreline,
		     distance_boreline,distance,apparent_flag,
		     projection_matrix,objid),
		targetid = my_id);
	}
	else
	{
	    /* offset line segment
	     */

	    om$get_classname(objid = my_id,
			classname = classname);

            /* clear the not-in-rtree and symbology override bits and set
             * the new bit as is done in the method GRcopy
             */

            new_props = me->properties & ~(GRNOT_IN_RTREE | DEHAS_OVERRIDE) |
                        GRIS_NEW;
	    py.points = curve->poles;
	    py.num_points = curve->num_poles;

	    OMmsg = GRlnoffset(msg,offset_env,&py,projection_matrix,
		distance,distance_boreline,direction_boreline,classname,
		NULL,apparent_flag,&new_props,&my_id,objid);

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

    	    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_COPIED);
	}	
    }
    else
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
    }


    GRabsg_del_all();			/* clear the cache		*/

    return(OMmsg);
}

end implementation GRlinear;
