/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRconic
     METHOD NAME:	GRgetrang

     Abstract: This routine retrieves the range of the conic object.

-----
%SC%    
	GRgetrang(msg,matrix_type,matrix,world,range)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type IGRshort	 type pf environment matrix
     matrix	  IGRmatrix	 environment matrix
     world	  IGRboolean	 indicator of whether to apply the
				 environment matrix
				  0 - compute range in local coordinates
			          1 - compute range in world coordinates
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
      range	   GRrange	 range of the conic object
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	MAarextents

     Methods:
	GRgetarc
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

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAarextents();

method GRgetrang(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		 IGRboolean *world; GRrange range)
{
	IGRshort *type;
	IGRshort mat_type = MAIDMX;

	IGRlong OMmsg;
	IGRlong msg1;			

	IGRdouble matrix2[16];
	IGRdouble *mx;

	struct IGRarc arc;


	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	if (*world)
	{
	    type = matrix_type;
	    mx = matrix;
	}
	else
	{
	    type = &mat_type;
	    mx = matrix2;
	    MAidmx(&msg1,matrix2);
	}

	OMmsg = om$send(msg = message GRconic.GRgetarc(msg,type,mx,&arc),
			targetid = my_id);

	if (1 & OMmsg)
	{
	   if (! MAarextents(&msg1,&arc,&range[0],&range[3]))
	   {
		OMmsg = OM_E_ABORT;
		*msg = MSFAIL;
	   }
	}

	

	
	return(OMmsg);
}

end implementation GRconic;

