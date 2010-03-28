/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg

     METHOD NAME:	GRprojpt

     Abstract: 	This method projects the input point onto the 
		given object.  If an extension of the object is
		closer than the actual object, then the point will
		be projected onto the extension.
	
-----
%SC%    

     GRprojpt(msg,matrix_type,matrix,locate_parms,point,proj_pt,proj_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *locate_parms GRparms	  used to identify segment to project
				  to (segmented objects only)
     point	   IGRpoint	  point to project

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     proj_pt	   IGRpoint	 the projected point on the object
				 (or on an extension)
     *proj_parms   GRparms	 projection parameters

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:	GRptproject
		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	SDG     04/16/86 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method projects the input point onto the given object.
	At this level, the method simply utilizes GRptproject.  An
	override method exists for those objects who have segments
	or possible extensions.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *locate_parms; 
		IGRpoint point,proj_pt; struct GRparms *proj_parms)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg2;			/* local return code		*/

	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRptproject(&msg2,       
				matrix_type,matrix,point,proj_pt,
				proj_parms),
                        senderid = my_id,
                        targetid = my_id);

	if ( 1 & (OMmsg & msg2))
	{
	   *msg = MSSUCC;
	}
	else
	{
	   OMmsg = OM_E_ABORT;
	   *msg = MSFAIL;
	}

	

	return(OMmsg);
}

end implementation GRvg;
