/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME   DPaxisalign
 
     Abstract:

		   	     
-----
%SC%

     VALUE = DPaxisalign (mess,rotation,axis_aligned)   

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     vt    	    pointer	  pointer to the view structure
     wn	    	    pointer	  pointer to the window structure
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     mess	  IGRlong	 MSSUCC -- successful completion
				 DPVWNODEF -- no view structure for view
				 DPVUPPRLVPN -- vup and vpn are parallel, 
				 hence the matrices can not be computed

     VALUE (IGRboolean) = TRUE -- successful completion
		       FALSE -- unsuccessful ;  check message
-----
%MD%

     MODULES INVOKED:	MAzrotmx()
		      	MAyrotmx()
		        MAinvmx()	
 			MAptpldis()
			MAmulmx()
			MAidmx()
----- 
%NB%

     NOTES: 
-----
%CH%
     CHANGE HISTORY:
	
	MSP  07/25/85  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N

   This function checks to see if the view's coordinate system or any
   rotation matrix is aligned with the world's coordinate system.  
   The following are checks for axis alignment.  First the 
   the matrix must be orthogonal.  Next the matrix is checked for 
   0's, 1's, and -1's, since the only rotation accepted is a 90 degree
   rotation. 

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include <math.h>

/* prototype files */
#include "dpaxisalign.h"


IGRboolean DPaxisalign (mess,rotation,axis_aligned)   

IGRlong *mess;          /* The message passed back from called routines */
IGRdouble *rotation;    /* pointer to the view's rotation matrix        */
IGRshort *axis_aligned; /* a flag indicating whether the view's axis
			   is aligned with the world coordinate's axis  
			   1 - if aligned
			   0 - if not aligned				*/
{

/*****************************************************************************/

IGRboolean status;           /* If status = 1 or true then this routine has
			        been completed successfully.
				If status = 0 or false there has been a fatal
				error.                                       */ 
IGRshort i;
IGRshort j;
IGRdouble temp;

/*****************************************************************************/
 
status = TRUE;

/* Call a math routine to check for matrix orthogonality or perhaps
   check for orthogonality when the user inputs the rotation        */

/* The view axis is not aligned with the world axis if the number's
   in the matrix are not equal to zero, one, or a negative one.     */

*axis_aligned = 1;


for ( i = 0; i < 3; ++i)
 {
    for ( j = 0; j < 3; ++j)
     {
	temp = *rotation++;

        if (temp != 0.0 && temp != 1.0 && temp != -1.0 ) 
	     {
		*axis_aligned = 0;
	     }
      }  /* close for "for j" */
  }  /* close for "for i" */
return (status);
}
