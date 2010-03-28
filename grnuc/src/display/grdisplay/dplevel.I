
class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "exmacros.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"

/* prototype files */
%safe
#include "dplevel.h"
%endsafe

struct pas_str
{
   OM_p_MESSAGE 	msg;
   IGRchar		*chan;
   IGRint		strt;
   IGRint		end_index;
};

struct level_str
{
   IGRlong	*msg;
   IGRint	*levels;
   IGRint	num_of_entries;
   IGRint	*level_mask;
   IGRboolean	on_off;
   IGRboolean   update;
};

from module import GRmod_passon;

IGRint DPlevel(	IGRlong 	*msg,
		IGRint		*lev,
		IGRint		num,
		IGRint		*mask,
		IGRboolean	on_off,
		IGRboolean	update,
		GRobjid		mod_objid,
		GRobjid		objid,
		GRspacenum	osnum )

     {
	
       IGRint  	status;	
       IGRint	strt=NULL,end_index = NULL;
       GRobjid  mod_id;
       GRspacenum mod_osnum;
       struct 	pas_str		pas_arg;
       struct	level_str	level_arg;
       OM_S_MESSAGE  level_msg,pas_msg;

	if (objid != NULL_OBJID)
	{
	   status = om$send(msg = message IGEgragad.DPlevels(msg,lev,num,mask,
						on_off,update),
			 senderid = NULL_OBJID,
			 targetid = objid,
			 targetos = osnum);
			
	   if (!(1 & status))
	   {
#ifdef DEBUG
	      printf("Error in send to DPlevels\n");
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
       	      printf("Error in DPlevel's passon make message\n");
              om$report_error(sts = status);
#endif
       	      goto wrapup;
    	   }

	
	   status = om$make_message(classname = "IGEgragad",
				    methodname = "DPlevels",
				    size = sizeof(struct level_str),
				    p_arglist = &level_arg,
				    p_msg = &level_msg);
				
    	   if (!(status & 1))
    	   {
#ifdef DEBUG
              printf("Error in DPlevel's level make message\n");
              om$report_error(sts = status);
#endif
              goto wrapup;
           }

    	   level_arg.msg = msg;
    	   level_arg.levels = lev;
    	   level_arg.num_of_entries = num;
    	   level_arg.level_mask = mask;
    	   level_arg.on_off = on_off;
           level_arg.update = update;

	   pas_arg.msg = &level_msg;
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


IGRint DPinq_level(	IGRlong 	*msg,
			IGRint		*num_of_levels,
			IGRshort	*levels,
			IGRint		on_off_flag,
			GRobjid		objid,
			GRspacenum	osnum )
{

  IGRint  status;
  struct  var_list v_list[2];
  IGRint  level_mask[32];
  IGRlong bytes_returned;
  IGRint  which_error;
  IGRint  level_count = 0;
  IGRint  i;


	*msg = MSSUCC;

	v_list[0].var = LEVELS;
	v_list[0].var_ptr = (char *)level_mask;
	v_list[0].num_bytes = sizeof (level_mask);
	v_list[0].bytes_returned = &bytes_returned;

	v_list[1].var = END_PARAM;

	status = om$send(msg = message IGEgragad.DPinquire(msg,
					(IGRlong *)&which_error, v_list),
			 senderid = NULL_OBJID,
			 targetid = objid,
			 targetos = osnum);

	if (!(1 & status))
	{
#ifdef DEBUG
	   printf("Error in send to DPlevels\n");
	   om$report_error(sts = status);
#endif
	   *msg = MSFAIL;
	   goto wrapup;
	}


	if (on_off_flag)
	{
	   for(i = 0; i < DP_NUM_OF_LEVELS; i++)
	   {
	      if (DPlevel_check(i,level_mask))
	      {
		 if ((level_count + 1) > *num_of_levels)
		 {
		    status = 0;
		 }
		 else
		 {
		    levels[level_count] = i;
		 }
		 level_count++;
	      }
	   }
	}
	else
	{
	   for(i = 0; i < DP_NUM_OF_LEVELS; i++)
	   {
	      if (!DPlevel_check(i,level_mask))
	      {
		 if ((level_count + 1) > *num_of_levels)
		 {
		    status = 0;
		 }
		 else
		 {
		    levels[level_count] = i;
		 }
		 level_count++;
	      }
	   }
	}

	*num_of_levels = level_count;


wrapup:
	return(status);

  }

end implementation IGEgragad;
