/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRlbsys	
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

		MAlbxform

     Methods:

		GRgetabsg
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
	
	SDG	04/18/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	After calling GRgetabsg to get the abstract geometry,
	call MAlbxform to transform the local bounded system.
	Then post the modified geometry back into the object.  
	Since the object may have changed classes during the 
	transform, the added argument "newobjid" was necessary.

----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "madef.h"
#include "godef.h"

extern    IGRboolean    MAlbxform();

method GRxform(IGRlong *msg; struct GRmd_env *obj_dsenv; 
       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{

	IGRboolean status;		/* generic function return	*/
	IGRlong    msg1;		/* working completion code	*/
	IGRlong	   ret_status;		/* OM return status		*/
	IGRchar	   *absgptr;		/* abstract geometry pointer	*/
	struct IGRlbsys *lbsys;		/* transformed lbsys    	*/
	struct IGRlbsys newlbsys;	/* temporary lbsys		*/
	struct GRpost_info info;	/* information for GRpostabsg	*/


	/* initialize variables */

	*msg = MSSUCC;			/* initialize to success	*/
	ret_status = OM_S_SUCCESS;
	*newobjid = my_id;		/* default if mx_type = MAIDMX	*/

	/* get abstract geometry */

	GRgetabsg(&msg1,&obj_dsenv->md_env.matrix_type,
		  obj_dsenv->md_env.matrix,&absgptr,i);
	
	if (! (1 & msg1))		/* an error occurred		*/
	{
	  *msg = MSFAIL;
	  ret_status = OM_E_ABORT;
	  goto wrapup;
	}
					/* object is local bounded prism*/
	lbsys = (struct IGRlbsys *)absgptr;

	if (*matrix_type != MAIDMX)	/* identity matrix?		*/
	{
					/* transform the system		*/
	  status = MAlbxform(&msg1,lbsys,matrix,&newlbsys);

	  if (! (1 & msg1))		/* an error occurred		*/
	  {
	    *msg = MSFAIL;
	    ret_status = OM_E_ABORT;
	  }
	  else
	  {
					/* object not being constructed	*/
	    info.construct_flag = FALSE;
					/* post transformed geometry	*/
	    ret_status = om$send(mode = OM_e_wrt_object,
                                 msg = message GRvg.GRpostabsg(
					msg,obj_dsenv,&info,   
					(IGRchar *)&newlbsys,newobjid),
                                 senderid = my_id,
                                 targetid = my_id);

	    GRabsg_del_all();
	  }
	}

	GR_NOTIFY_LISTENERS(msg,&ret_status,GR_GEOM_XFORMED);

wrapup:

	return (ret_status);

}

end implementation GRlbsys;
