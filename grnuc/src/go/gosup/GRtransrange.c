/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	GRtransrange
 
     Abstract:  
	This routine transforms the range from R-tree
	format to the format expected by the Graphics
	Objects
-----
%SC%
     VALUE = GRtransrange(message,range_key,range)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     range_key    OM_p_KEY_DESC structure for range in R_tree 
				 format

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong 	 completion code
				    - MSSUCC if successful
				    - MSFAIL if error occured

     range  	  GRrange	 range in internal format


     VALUE (boolean) = TRUE	    - if successful
		       FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:
	 	none.
-----
%NB%

     NOTES:
		none.
-----
%CH%
     CHANGE HISTORY:
	
	MAS  7/16/86  : Creation date.
        mrm  4/23/91  : Always assume 3d double range key

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This  module translates the range to the internal format expected
by the graphics objects.

----*/
/*EH*/


#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "OMindex.h"

IGRboolean GRtransrange(message,range_key,range)

IGRlong               *message;		/* return code			*/
OM_p_KEY_DESC	      range_key;	/* range in R_tree format	*/
GRrange		      range;		/* range in internal format	*/

{
    *message = MSSUCC;
    blkmv(sizeof(DB_3D_DBL_BOX), range_key->key.p_3ddbl, range);
    return(TRUE);
}
