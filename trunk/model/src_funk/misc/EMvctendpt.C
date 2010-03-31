/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"

#include <bsdefs.h>
#include <bserr.h>

IGRboolean EMvctendpt (rc, begin_pt, vctr, end_pt)

BSrc 		*rc;
IGRpoint 	begin_pt;
IGRpoint	end_pt;
IGRvector	vctr;

 {
   IGRboolean		status;

   status = TRUE;
   *rc = BSSUCC;

   end_pt[0] = begin_pt[0] + vctr[0];
   end_pt[1] = begin_pt[1] + vctr[1];
   end_pt[2] = begin_pt[2] + vctr[2];
 
   return(status);
 }
