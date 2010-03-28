/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlinear

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
		MAutoparms
		MAptlnproj

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
	
	SDG     05/09/86 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method projects the input point onto the given object.
	For those segmented objects, the input u parameter 
	identifies the segment (plus its extension) to project to.  

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MAptlnproj();

method GRprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *locate_parms; 
		IGRpoint point,proj_pt; struct GRparms *proj_parms)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg2;			/* local return code		*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	IGRlong segnum;			/* segment number		*/
	IGRdouble tparm;		/* t parameter			*/
	struct IGRbsp_curve *curve;	/* B-spline curve		*/
	struct IGRline line;		/* line containing segment	*/


	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	proj_parms->u = locate_parms->u;
	proj_parms->v = 0;
	proj_parms->leaf_id.objid = my_id;
	proj_parms->leaf_id.osnum = OM_Gw_current_OS;
	proj_parms->polygon_inx = 2;
		
	GRgetabsg(&msg2,matrix_type,matrix,&absgptr,i);

	if (! (1 & msg2))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	if (! (1 & MAutoparms(&msg2,curve,&locate_parms->u,&segnum,&tparm)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;	
	   goto wrapup;
	}

	line.point1 = &curve->poles[(segnum - 1)*3];
	line.point2 = &curve->poles[segnum*3];

	if (! (1 & MAptlnproj(&msg2,point,&line,proj_pt,&tparm)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	}

	

wrapup:
	
	return(OMmsg);

}

end implementation GRlinear;
