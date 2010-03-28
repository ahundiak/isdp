/* #######################    APOGEE COMPILED   ######################## */
/*\
Name

	GRdetplane -  determines a plane from a graphics
		object.

Synopsis
	GRdetplane(msg,matrix_type,matrix,plane)

	IGRlong *msg		Completion code
	IGRshort *matrix_type   Type of environment matrix
	IGRmatrix matrix	Environment matrix
	struct IGRplane	plane   the plane of the object

Description

	This method invokes the GRdetplane method on the 
	graphics object defining the clipping polygon.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC if successful
	MASDGENRAT if all points are collinear
	MANONPLANAR if plane cannot be found which contains all points
	GRDEFAULT_USED - prism has height therefore, it is not planar.
		The plane of the front face is returned.
	MSFAIL - error
Notes
	None.
History
	MAS 	04/05/87	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "refpriv.h"
#include "msdef.h"
#include "grerr.h"

method GRdetplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  struct IGRplane *plane)
{
	IGRshort type;

	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/

	IGRchar *absgptr;		/* abstract geometry pointer	*/

	struct IGRcv_prism *prism;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	
	GRgetprism(&msg1,matrix_type,matrix,&absgptr,i);
	if ( 1 & msg1)
	{
	    prism = (struct IGRcv_prism *)absgptr;
	    if (prism->height != 0)
	    {
		*msg = GRDEFAULT_USED;
	    }
	    MAtypemx(&msg1,prism->matrix,&type);

	    OMmsg = om$send(
		msg = message GRvg.GRdetplane
     			(&msg1,&type,prism->matrix,plane),
		targetid = me->cv_objid);

	    if (!(1 & OMmsg & msg1))
	    {
		*msg = msg1;
	    }
	}
    		

	return(OMmsg);

}

end implementation GRclippoly;
