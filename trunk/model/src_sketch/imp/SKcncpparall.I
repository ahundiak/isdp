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
	not set, the offset will be in the plane of the element. The
	located object's class is SKarc; the new object's class is
	GR3dcirarc.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
     	MSFAIL - error occured

Notes
	None.

History
	JSD	02/17/92	Creation (from $GRNUC/src/go/go1/GRcncpparall.I)
	RA	06/04/92	Complete rewrite using the parent's message.

*/

class implementation SKarc;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "grownmacros.h"

method  GRcpparallel(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid)
{
    long	OM_stat;			/* OM return value		*/
    IGRchar 	classname [OM_K_MAXCLASS_LEN]; 

    *msg = MSSUCC;
    OM_stat = OM_S_SUCCESS;

    om$get_classname(objid = my_id, classname = classname);
    if ( ! strcmp( classname, "SKarc" ) )
      strcpy( classname, "GR3dcirarc" );

    /*
     * Basically use the same method defined in the parent class.  
     * Only thing to do is to change the class of the returned copied object.
     */
    
    OM_stat = om$send (msg = message GR3dcirarc.GRcpparallel(msg, 
                       mx_type, matrix, offset_env, direction_boreline,
 	               distance_boreline, distance, apparent_flag,
     	               projection_matrix, objid) , 
                       mode = OM_e_wrt_message,
                       targetid = my_id);
    EMerr_hndlr ( !(1 & OM_stat & *msg), *msg, MSFAIL, wrapup);

    OM_stat = om$change_class (osnum = offset_env->md_id.osnum,
               objid = *objid, classname = classname);
    EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

wrapup:
  EMWRAPUP (*msg, OM_stat, "SKarc.GRcpparallel");
  return (OM_stat);
}

end implementation SKarc;
