/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	DPoutpnt
 
     Abstract:	  This routine will display the number of points
                  specified in no_out_pnt

-----
%SC%

     VALUE = DPoutpnt(message,win_no,out_buf,no_out_pnt)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
        win_no     IGRint          pointer to hardware window no
	out_buf    IGRdouble	   buffer of points
	no_out_pnt IGRlong 	   pointer to number of points in output buffer

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
#include "dpdef.h"
#include "wl.h"

/* prototype files */
#include "dpoutpnt.h"


IGRboolean   DPoutpnt(message,win_no,out_buf,no_out_pnt,depths)

IGRlong  *message;	        /* output completion code       */
IGRint   *win_no;               /* window number                */
IGRdouble *out_buf;             /* output buffer                */
IGRlong   *no_out_pnt;		/* # of pnts in out_buf         */	   
IGRdouble *depths;		/* z depths			*/

{
	IGRlong  i = 0;
	struct WLpoint point;

 	if ( *no_out_pnt > 0)
	{	

	   while (i < *no_out_pnt)
	   {
		if ((out_buf[2] >= depths[0]) && (out_buf[2] <= depths[1]))
		{


	    	    point.x = *out_buf++;
		    point.y = *out_buf++;
		    out_buf++;
		    WLdraw_2D_point_string( *win_no, 1, &point );
		}
		else
		{
		    out_buf += 3;
		}
		   
	        i++;
	   }
	   WLflush( *win_no );
	}
	*message = MSSUCC;
	return(1);
}
