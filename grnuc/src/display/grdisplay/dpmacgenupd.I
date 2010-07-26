
class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "exmacros.h"
#include "msdef.h"

/* prototype files */
%safe
#include "dpmacgenupd.h"
%endsafe

struct pas_str
{
   OM_p_MESSAGE 	msg;
   IGRchar		*chan;
   IGRint		strt;
   IGRint		end_index;
};

struct gen_upd_str
{
   IGRlong	*msg;
   struct DPdit_range	*range;
   IGRboolean    *upd_all;
   enum GRdpmode mode;
   IGRboolean    erase;
};

from module import GRmod_passon;

IGRint DPgenupdate(	IGRlong 		*msg,
			struct DPdit_range	*range,
			enum GRdpmode 		mode,
			IGRboolean    		erase,
			GRobjid			mod_objid,
			GRobjid			objid,
			GRspacenum		osnum )

     {
	
       IGRint  	status;	
       IGRint	strt=NULL,end_index = NULL;
       GRobjid  mod_id;
       GRspacenum mod_osnum;
       IGRboolean all=FALSE;
       struct 	pas_str		pas_arg;
       struct	gen_upd_str	gen_upd_arg;
       OM_S_MESSAGE  gen_upd_msg,pas_msg;

	if (objid != NULL_OBJID)
	{
	   status = om$send(msg = message IGEgragad.DPgen_update(msg,range,
						&all,mode,erase),
			 senderid = NULL_OBJID,
			 targetid = objid,
			 targetos = osnum);
			
	   if (!(1 & status))
	   {
#ifdef DEBUG
	      printf("Error in DPgenupdate's send to DPgen_update\n");
	      om$report_error(sts = status);
#endif
	      *msg = MSFAIL;
	   }
	}
	else
	{
	   if (mod_objid = NULL_OBJID)
	   {
	      ex$get_cur_mod (id = &mod_id,
			      osnum = &mod_osnum);
	   }
	   else
	   {
	      mod_id = mod_objid;
	      mod_osnum = osnum;
	   }
	
	   status = om$make_message(classname = "IGEwindow",
				    methodname = "passon",
				    size = sizeof(struct pas_str),
				    p_arglist = &pas_arg,
				    p_msg = &pas_msg);
				
    	   if (!(status & 1))
    	   {
#ifdef DEBUG
       	      printf("Error in DPgenupdate's passon make message\n");
              om$report_error(sts = status);
#endif
       	      goto wrapup;
    	   }

	
	   status = om$make_message(classname = "IGEgragad",
				    methodname = "DPgen_update",
				    size = sizeof(struct gen_upd_str),
				    p_arglist = &gen_upd_arg,
				    p_msg = &gen_upd_msg);
				
    	   if (!(status & 1))
    	   {
#ifdef DEBUG
              printf("Error in DPgenupdate's DPgen_update make message\n");
              om$report_error(sts = status);
#endif
              goto wrapup;
           }

    	   gen_upd_arg.msg = msg;
    	   gen_upd_arg.range = range;
    	   gen_upd_arg.upd_all = &all;
    	   gen_upd_arg.mode = mode;
    	   gen_upd_arg.erase = erase;

	   pas_arg.msg = &gen_upd_msg;
 	   pas_arg.chan = "IGEgadget.to_children";
	   pas_arg.strt = NULL;
	   pas_arg.end_index = NULL;

    	   status = om$send(msg = message module.GRmod_passon(msg,&pas_msg,
						"module.windows",
						 &strt,&end_index),
		     senderid = NULL_OBJID,
		     targetid = mod_id,
		     targetos = mod_osnum);

	   if (!(status & 1))
    	   {
#ifdef DEBUG
              printf("Error in DPlevel's send to GRmod_passon\n");
              om$report_error(sts = status);
#endif
              goto wrapup;
           }
	}
	
wrapup:
  	return(status);

    }

end implementation IGEgragad;
