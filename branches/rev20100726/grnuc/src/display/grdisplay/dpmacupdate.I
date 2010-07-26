
class implementation IGEgragad;

#include <stdio.h>

#include "grimport.h"
#include "exmacros.h"
#include "msdef.h"

/* prototype files */
%safe
#include "dpmacupdate.h"
%endsafe


IGRint DPmacupdate( IGRlong 		*msg,
		    struct DPdit_range	*range,
		    GRobjid		objid,
		    GRspacenum		osnum )

     {
	
       IGRint  	status;	
        GRobjid  mod_id;
       GRspacenum mod_osnum;
       IGRboolean    all = FALSE;
 
	if (objid != NULL_OBJID)
	{
	   status = om$send(msg = message IGEdisplay.DPupdate(msg,range,&all),
			 senderid = NULL_OBJID,
			 targetid = objid,
			 targetos = osnum);
			
	   if (!(1 & status))
	   {
#ifdef DEBUG
	      printf("Error in DPmacupdate's send to DPupdate\n");
	      om$report_error(sts = status);
#endif
	      *msg = MSFAIL;
	   }
	}
	else
	{

	      ex$get_cur_mod (id = &mod_id,
			      osnum = &mod_osnum);


	
	   status = om$send(msg = message IGEdisplay.DPupdate(msg,range,&all),
			 senderid = NULL_OBJID,
			 targetid = mod_id,
			 targetos = mod_osnum);

	   if (!(status & 1))
    	   {
#ifdef DEBUG
              printf("Error in DPmacupdate's send to DPupdate\n");
              om$report_error(sts = status);
#endif
              goto wrapup;
           }
	}
	
wrapup:
  	return(status);

    }

end implementation IGEgragad;
