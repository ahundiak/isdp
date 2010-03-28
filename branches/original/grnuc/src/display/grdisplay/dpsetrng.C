/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPsetrng

          Abstract:    This routine will set the DPrange_check structure
			to tell which corners of viewing cube are low
			and high x, y, and z.

----
%SC%

     VALUE = DPsetrng(msg,win);
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *win		struct DPwindow		window's instance data

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
	*msg	      IGRlong		         return status
				  	     MSSUCC - successfully completed
				  	     MSFAIL - unsuccessfully completed

      VALUE() =    TRUE if successful
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  


		DPsetrng()	

----
%NB%

      NOTES:   None

----
%CH%

       AET   06/25/86   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

	     This routine will use the world to view matrix to see
	which corners of the view volume are the low and high x, y, and
	z.
---*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"

/* prototype files */
#include "dpsetrng.h"
#include "dpsetrow.h"


 IGRint DPsetrng(msg,matrix,range_chk)

    IGRlong 			*msg;
    IGRdouble			*matrix;
    struct DPrange_check	*range_chk;


     {

       IGRint status;

	*msg = MSSUCC;

	/* set range  for wls_to_viewport  */
	
	if (!(status =DPsetrow(msg,&matrix[0],&range_chk->xlo,
					 &range_chk->xhi)))
	{
	   goto wrapup;
	}

		
	if (!(status =DPsetrow(msg,&matrix[4],&range_chk->ylo,
					 &range_chk->yhi)))
	{
	  goto wrapup;
	}


	if (!(status =DPsetrow(msg,&matrix[8],&range_chk->zlo,
					 &range_chk->zhi)))
	{
	  goto wrapup;
	}

	

					
wrapup:

     return(status);	

    }
