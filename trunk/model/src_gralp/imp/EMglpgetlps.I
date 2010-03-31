/*
Notes
	Return a feature loop only if option is EMS_OPT_ALL_WITH_FEATURES
	or EMS_OPT_FEATURES.

History     ?       ?  : Created.
        03/20/92  Jack : Changed from EMSfeaturelp class to EMSgraloop.
        10/03/92  msm  : ANSI-C conversion

*/

class implementation EMSgraloop;

#include "EMSopt.h"

#define LOOP_INC 10

method EMget_loops(IGRlong *EMmsg;IGRlong option;IGRint *depth;
                       GRobjid **loop_ids;
			IGRushort **props;
                       IGRint *buf_size,*count)
{
  IGRlong 		sts;
  IGRboolean		valid;

  *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;
  valid = FALSE;

  EMerr_hndlr (*depth <= 0, *EMmsg, EMS_E_InvalidArg, wrapup);

  if( (option == EMS_OPT_ALL_WITH_FEATURES) || (option == EMS_OPT_FEATURES))
   {
     if(buf_size && !(*buf_size))
      {
       if(*count)
        {
	  if(loop_ids)
            *loop_ids = (GRobjid *) om$realloc(ptr=(IGRchar *)*loop_ids,size=
				(*count+LOOP_INC)*sizeof(GRobjid));
	  if(props)
	    *props = (IGRushort *) om$realloc(ptr=(IGRchar *)*props,size=
			(*count+LOOP_INC)*sizeof(IGRushort));
        }
       else
        {
	  if(loop_ids)
            *loop_ids = (GRobjid *) om$malloc(size=LOOP_INC*sizeof(GRobjid));
          if(props)
	    *props = (IGRushort *) om$malloc(size=LOOP_INC*sizeof
				(IGRushort));
        }
       if(loop_ids)
         EMerr_hndlr((!*loop_ids),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       if(props)
         EMerr_hndlr(!*props,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
       *buf_size = LOOP_INC;

      } /* if(!(*buf_size)) */

    if(loop_ids)  (*loop_ids)[*count]= my_id;
    if(props)     (*props)[*count] = ME.EMSloop->lp_props;
    if(buf_size)  (*buf_size)--;
    (*count)++;
   }  

  else *EMmsg = EMS_I_FeatureLoop;

wrapup:
  EMWRAPUP(*EMmsg,sts,"In EMSgraloop.EMget_loops")
  return(sts);

}

end implementation EMSgraloop;
