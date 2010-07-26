/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRbspline	
     METHOD NAME:   GRxform

     Abstract: 

		This method transforms the geometry of a 
	graphics object by a matrix.  

-----
%SC%    

     GRxform(msg,obj_dsenv,matrix_type,matrix,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *obj_dsenv	  GRmd_env	 md_env structure 
     *matrix_type IGRshort	 the type of the matrix as determined
				 by math function MAtypemx()
     matrix	  IGRmatrix	 the given transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *newobjid	  GRobjid	 objid of the transformed object
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - GRIZRNGCHG (info) if 2-d 
					object transforms to other
					than a constant elevation
					and is adjusted
				    - GRSNOINVTRAN (severe) if
					matrix in env_info is not 
					invertible
				    - GRSDGNEXCEED (severe) if 
					design space limits are 
					exceeded
				    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	

		MAoptsxform
		MArptsxform
		GRabsg_del_all

     Methods:

		GRgenabsg
		GRpostabsg

-----
%RL%

     RELATIONS REFERENCED:	None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	REJ	01/27/86 : Creation date.
	SDG	03/27/86 : Addition of new argument.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	After calling GRgetabsg to get the abstract data (B-spline
	curve data structure), call MAoptsxform to transform the 
	curve.  Then post the modified geometry back into the
	object.  Since the object may have changed classes during 
	the transform, the added argument "newobjid" was necessary.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAoptsxform();
extern    IGRboolean    MArptsxform();
extern    IGRboolean    GRabsg_del_all();

method GRxform(IGRlong *msg; struct GRmd_env *obj_dsenv; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{

	IGRboolean status;		/* generic function return	*/
	IGRlong    msg1;		/* working completion code	*/
	IGRlong	   ret_status;		/* OM return status		*/
	IGRchar	   *absgptr;		/* abstract geometry pointer	*/
	struct IGRbsp_curve *curve;	/* curve pointer		*/
    	struct GRpost_info info;	/* information for GRpostabsg	*/


	*msg = MSSUCC;			/* initialize to success	*/
	ret_status = OM_S_SUCCESS;
	*newobjid = my_id;

	GRgetabsg(&msg1,&obj_dsenv->md_env.matrix_type,
		  obj_dsenv->md_env.matrix,&absgptr,i);
	
	if (! (1 & msg1))		/* an error occurred		*/
	{
	  *msg = MSFAIL;
	  ret_status = OM_E_ABORT;
	  goto wrapup;
	}
					/* geometry is a curve		*/
	curve = (struct IGRbsp_curve *) absgptr;

	if (*matrix_type != MAIDMX)	/* identity matrix?		*/
	{

	  if (! curve->rational)
	  {
	    status = MAoptsxform(&msg1,&curve->num_poles,
				matrix_type,matrix,
			       	curve->poles,curve->poles);
	  }
	  else
	  {
	    status = MArptsxform(&msg1,&curve->num_poles,
				&curve->rational,curve->weights,matrix,
			       	curve->poles,curve->poles);
	  }

	  if (! (1 & status))		/* an error occurred		*/
	  {
	    *msg = MSFAIL;
	    ret_status = OM_E_ABORT;
	  }
	  else
	  {
				/* object is not being constructed	*/
	    info.construct_flag = FALSE;
				/* post transformed geometry		*/
	    ret_status = om$send(
		mode = OM_e_wrt_object,
                msg = message GRvg.GRpostabsg
		    (msg,obj_dsenv,&info,absgptr,newobjid),
                senderid = my_id,
                targetid = my_id);
	  }

	  if (! (1 & ret_status))
	  {				/* delete object from the cache	*/
	     GRabsg_del_all();
	  }

	}

	GR_NOTIFY_LISTENERS(msg,&ret_status,GR_GEOM_XFORMED);

wrapup:

	return (ret_status);

}
end implementation GRbspline;
