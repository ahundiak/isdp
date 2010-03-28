/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRgraphics	
     METHOD NAME:   GRtform

     Abstract: 

		This method transforms a graphics object by a 
	given matrix.  Also, the dataset information (i.e.,
	R-tree) is maintained.

-----
%SC%    

     GRtform(msg,md_env,matrix,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	  GRmd_env	 md_env structure (context info)
     matrix	  IGRmatrix	 the given transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	MAtypemx

     Methods:   GRxform

-----
%RL%

     RELATIONS REFERENCED:	None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	REJ	01/21/86 : Design date.
	KMO     01/21/86 : Creation date. 
	KMO	03/26/86 : Revision date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method transforms the graphics object by the given
	matrix and replaces the object in the dataset (i.e., the
	R-tree).

----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"

extern    IGRboolean    MAtypemx();

method GRtform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRmatrix matrix; GRobjid *newobjid)
{
    IGRshort		type;			/* matrix type     */
    IGRlong		status;			/* function return */
    
    /* initialize variables */

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    MAtypemx(msg,matrix,&type);

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRxform(msg,md_env,    &type,matrix,newobjid),
                     senderid = my_id,
                     targetid = my_id);
    return (status);

}

end implementation GRgraphics;
