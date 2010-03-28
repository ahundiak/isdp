/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlinear

     METHOD NAME:	GRapprojpt

     Abstract: 	This method projects the input boreline onto the 
		given object.  If an extension of the object is
		closer than the actual object, then the boreline 
		will be projected onto the extension.
	
-----
%SC%    

     GRapprojpt(msg,matrix_type,matrix,locate_parms,boreline,
		proj_pt,proj_parms)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *locate_parms GRparms	  used to identify segment to project
				  to (segmented objects only)
     boreline	   IGRline	  input line to project

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
     *proj_parms   GRparms	 the parameter from the input locate
			         structure.

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAutoparms
		MA2lnproj

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
	This method projects the input boreline onto the given 
	object.  For those segmented objects, the input u parameter 
	identifies the segment (plus its extension) to project to.  

	There is no u parameter for the extended segment therefore
	the projected parameters returned are the same as the 
	locate parameters.

----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bserr.h"

extern    IGRboolean    MAutoparms();
extern    IGRboolean    MA2lnproj();
extern	  IGRboolean	BSprptoncv();

method GRapprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct GRparms *locate_parms; struct IGRline *boreline; 
		IGRpoint proj_pt; struct GRparms *proj_parms)
{
	IGRchar *absgptr;		/* abstract geometry pointer	*/

	IGRboolean on_curve;

	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg2;			/* local return code		*/
	IGRlong segnum;			/* segment number		*/

	IGRdouble t;  			/* t parameter of pt on boreline*/
	IGRdouble t2;			/* t parm of point on extension */

	IGRpoint boreline_pt;		/* project pt on boreline	*/

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

	if (! (1 & MAutoparms(&msg2,curve,&locate_parms->u,&segnum,&t)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;	
	   goto wrapup;
	}

	line.point1 = &curve->poles[(segnum - 1)*3];
	line.point2 = &curve->poles[segnum*3];

	if (! (1 & MA2lnproj(&msg2,boreline,&line,boreline_pt,proj_pt,&t,&t2)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	}
        else if ((t2 <= 1.0) && (t2 >= 0.0))
	{
	   BSprptoncv(&msg2,curve,proj_pt,&proj_parms->u,&on_curve);
	   if (msg2 != BSSUCC)
	   {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	   }
	}
	else
	{
	   if (t2 > 1.0)
	   {		/* knot for end pole of segment		*/
	      proj_parms->u = curve->knots[segnum+1];
	   }
	   else
	   {		/* knot for beg pole of segment		*/
	      proj_parms->u = curve->knots[segnum];
	   }
	}
wrapup:
	return(OMmsg);
}
end implementation GRlinear;
