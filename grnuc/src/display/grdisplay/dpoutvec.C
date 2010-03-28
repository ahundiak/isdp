/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	DPoutvec
 
     Abstract:	  This routine will display the number of vectors
                  specified in no_out_pnt

-----
%SC%

     VALUE = DPoutvec(message,win_no,out_buf,no_out_pnt)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	win_no	   IGRint 	 pointer to hard ware window no.	
	out_buf    IGRdouble     buffer of points
	no_out_pnt IGRlong       pointer to number of points in output buffer
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong 	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure occurred

     VALUE (boolean) = TRUE	    - if successful
		       FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
	
	XXX  mm/dd/yy  : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
	


----*/
/*EH*/


#include "grimport.h"
#include "igrtypedef.h"	
#include "msdef.h"
#include <math.h>
#include <values.h>

/* prototype files */
#incclude "dpoutvec.h"


#define  MAXDOUBLE  1.79769313486231470e+308

IGRint   DPoutvec(message,win_no,out_buf,no_out_pnt)

IGRlong  *message;	        /* output completion code       */
IGRint   *win_no;               /* hard ware window no          */
IGRdouble *out_buf;             /* output buffer                */
IGRlong   *no_out_pnt;		/* # of pnts in out_buf         */	   

{

	IGRshort  x;
	IGRshort  y;
	IGRshort  mve = 0;
	IGRshort  i = 0;

 	if ( *no_out_pnt > 1)
	{	
	   if (*out_buf != MAXDOUBLE)
	   {
	      x = (IGRshort) (*out_buf++ + 0.5);
	      y = (IGRshort) (*out_buf++ + 0.5);
	      out_buf++;
	      i++;
	      move(*win_no,x,y);
	   }
	  

	   while (i < *no_out_pnt)
	   {
	      if (*out_buf == MAXDOUBLE)
	      {
		   mve = 1;
		   out_buf += 3;
	      }
	      else
	      {
		   x = (IGRshort) (*out_buf++ + 0.5);
		   y = (IGRshort) (*out_buf++ + 0.5);

		   out_buf++;
		   if (mve)
		   {
		      move(*win_no,x,y);
		      mve = 0;
		   }
		   else
		   {
		      draw(*win_no,x,y);
		   }
	      }
	      i++;
	   }

	}
	*message = MSSUCC;
	return(TRUE);
}
