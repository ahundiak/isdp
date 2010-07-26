/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME   
 
     Abstract:	

-----
%SC%

     VALUE = 

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------



-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *mess	  IGRlong	 MSSUCC -- successful completion
				 MSFAIL -- fatal error

     VALUE (IGRboolean) = TRUE -- successful completion
		          FALSE -- unsuccessful ;  check message
-----
%MD%

     MODULES INVOKED:   

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

----*/
/*EH*/

/* include exec structure */

#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "igewindow.h"

/* prototype files */
#include "dpinqwsdep.h"


static struct DPws_flags ws_flags;
static IGRint display_ext[2];
static IGRdouble dit_tol;

IGRboolean DPinqwsdep( msg,ws_flags_mem,display_ext_mem,dit_tol_mem)

IGRlong *msg;
struct DPws_flags *ws_flags_mem;
IGRint *display_ext_mem;
IGRdouble *dit_tol_mem;

{

 *msg = MSSUCC;

ws_flags.display_origin = 1;
ws_flags.x_origin = 0;
ws_flags.y_origin = 1;
display_ext[0] = 1184;
display_ext[1] = 884;
dit_tol = 5.0;

ws_flags_mem->display_origin = ws_flags.display_origin;
ws_flags_mem->x_origin = ws_flags.x_origin;
ws_flags_mem->y_origin = ws_flags.y_origin;
display_ext_mem[0] = display_ext[0];
display_ext_mem[1] = display_ext[1];
*dit_tol_mem = dit_tol;

return (1);

}
