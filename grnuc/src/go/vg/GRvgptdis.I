/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg

     METHOD NAME:	GRptdis

     Abstract: 	This method determines the distance between the 
		input point and the given object.
	
-----
%SC%    

     GRptdis(msg,matrix_type,matrix,point,distance)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     point	   IGRpoint	  point to determine distance from

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *distance    IGRdouble	 distance from point to object


-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  	MA2ptdis

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
	
	SDG     04/14/86 : Design date.
	SDG	04/14/86 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method returns the distance between an input point and
	a graphic object.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MA2ptdis();

method GRptdis(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		IGRpoint point; IGRdouble *distance)
{
	IGRlong OMmsg;			/* OM return value		*/
	IGRlong msg2;			/* local return code		*/
	IGRpoint proj_pt;		/* projected point on object	*/
	struct GRparms proj_parms;	/* struct for routine called	*/

	*msg = MSFAIL;

	OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRptproject(&msg2,       
				matrix_type,matrix,point,proj_pt,
				&proj_parms),
                        senderid = my_id,
                        targetid = my_id);

	if (1 & (OMmsg & msg2))
	{
	   if (MA2ptdis(&msg2,point,proj_pt,distance))
	   {
	      *msg = MSSUCC;
	   }
	   else
	   {
	      OMmsg = OM_E_ABORT;
	   }
	}

	

	return(OMmsg);
}

end implementation GRvg;
