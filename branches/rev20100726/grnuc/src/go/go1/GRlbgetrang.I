/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlbsys
     METHOD NAME:	GRgetrang

     Abstract: This routine retrieves the range of the object.

-----
%SC%    
	GRgetrang(msg,matrix_type,matrix,world,range)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	 type of environment matrix
     matrix	   IGRmatrix	 environment matrix
     *world	   IGRboolean    indicator of whether the range should
			 	 be computed in world or local coordinates
				  1 : apply the environment matrix
				  0 : do not apply the environment matrix
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
      range	   GRrange	 range of the object

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	none.

     Methods:
	none.
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
	
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
----*/
/*EH*/

class implementation GRlbsys;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetrang(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRboolean *world; GRrange range)
{
	char *ptr;

	IGRlong OMreturn;
	IGRlong msg1;
	IGRlong msg2;

	IGRshort mat_type = MAIDMX;
	IGRshort *type;

	IGRdouble matrix2[16];
	IGRdouble *mx;

	struct IGRlbsys old_lbsys;
	struct IGRlbsys lbsys;

	IGRchar *old_ptr;

	int  in_buffer;
	GRspacenum osnum = OM_Gw_current_OS;

	*msg = MSSUCC;
	OMreturn = OM_S_SUCCESS;

	if (! (*world))			/* compute in what coordinates	*/
	{
	    MAidmx(&msg2,matrix2);
	    mat_type = MAIDMX;
	    mx = matrix2;
	    type = &mat_type;
	}
	else
	{
	    mx = matrix;
	    type = matrix_type;
	}

   	ptr = (IGRchar *) &lbsys;

	in_buffer = GRabsg_test(&msg1,type,mx,&osnum,&my_id,
				&old_ptr);
	if (in_buffer)
	{
	  old_lbsys = *((struct IGRlbsys *) old_ptr);
	  GRabsg_del(old_ptr);
	}

	OMreturn = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetgeom(msg,type,mx,ptr),
                           senderid = my_id,
                           targetid = my_id);

	if (! (1 & OMreturn))
	{
	  *msg = MSFAIL;
	  goto wrapup;
	}

	MAlbextents(&msg2,&lbsys,&range[0],&range[3]);

	if (! (1 & msg2))
	{
	  *msg = MSFAIL;
	  OMreturn = OM_E_ABORT;
	}

	if (in_buffer)
	{
	    *((struct IGRlbsys *) old_ptr) = old_lbsys;
	}

	

wrapup:
	
	return(OMreturn);
}

end implementation GRlbsys;

