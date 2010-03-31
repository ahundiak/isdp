/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME EMidmatrix
 
     Abstract: 

       This function simply fills up the incoming matrix, to be
     an identity matrix and sets the type variable correctly. 

-----
%SC%

     EMidmatrix (msg, mattyp, mat);

-----
%EN%
 
     ON ENTRY:
                         
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	  return code:
					MSSUCC - successful
                                  N.B.: Always successful.

      *mattyp      IGRshort       The appropriate code for identity
                                   matrix.

      mat          IGRmatrix      The output identity matrix.

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
        SS  09/17/86 : Design date
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------


----*/
/*EH*/



/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
#include "madef.h"
#include "msdef.h"

void EMidmatrix (msg, mattyp, mat)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
{
  IGRint i;

  *msg = MSSUCC;

  *mattyp = MAIDMX;
  for (i=0; i<16; i++)
    mat[i] = 0.0;
  for (i=0; i<16; i+=5)
    mat[i] = 1.0;
}

