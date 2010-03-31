class implementation EMSsfunitesf;

/*
HISTORY

  07/14/92  : AMD :  Creation
  12/16/93  : WBC :  Make sure display_ids gets posted if necessary.

*/

#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmapdef.h"
#include "emsimpdef.h"

#if DEBUG
#define ERROR(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERROR(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif
#define KLUDGE_NECESSARY 0

from GRcurve import EMcvtanorm;
from EMSsubbs import EMsftanorm;
from EMSdprparam import EMget_display_ids, EMput_display_ids;

method EMconstruct_associative(IGRlong *msg;
                               IGRushort options;
                               OM_S_OBJID old_objid;
                               IGRint nparents;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct)

{
   IGRint   i, recompute, num_surfs;
   IGRlong  sts, loc_msg;
   union EMSparent_info *parents = NULL;
   GRobjid   *surfs;
   struct GRid   active_GRid;
   IGRuint    *parent_types;
   IGRushort  mrg_options=NULL;
   IGRboolean update_display_ids = FALSE;
   GRobjid    newplane;
   GRobjid    *display_ids=NULL, param_id;
   IGRint     display_count;

   /* check options for recompute */
    display_count = 0;
    surfs = (GRobjid *) om$malloc (size = nparents * sizeof(GRobjid));

    recompute = options & EMSasconst_recompute;

    /* unwind the parent information */

    parents = (union EMSparent_info *)alloca(sizeof
              (union EMSparent_info) * nparents);
    parent_types = (IGRuint *) alloca(sizeof(IGRint) * nparents);
    for (i = 0; i < nparents; i++) parent_types[i] = EMSgrid;

    sts = om$send(msg = message EMSassoc.EMget_parent_info
                       (msg, NULL, nparents, parent_info,
                        parent_types, parents),
                  targetid = my_id);

    ERROR(sts, *msg, "EMSsfunitesf$EMconstruct_associative", ret_end);

    num_surfs = nparents - 1; 
 
    for (i=0; i < num_surfs; i++)
       surfs[i] = parents[i].grobj.grid.objid;

    active_GRid = parents[num_surfs].grobj.grid;

    if (recompute)
    {
     sts = EFsend_to_param(msg, 
                 message EMSdprparam.EMget_display_ids(
                 msg, &display_count, &display_ids, NULL),
              my_id, OM_Gw_current_OS, &param_id, NULL); 
     if (!(1 & sts & *msg)) goto ret_end;

     update_display_ids = TRUE;
    }    
    
    /* Just do it!!!!!! */

    mrg_options = EMS_DO_DISPLAY | (recompute ? EMS_DONT_REDRAW : NULL);

    sts = om$send (msg = message EMSsfunitesf.EMmerge_coincident_surfs(
			  msg,
                          *construct,
                          mrg_options,
		          active_GRid,
                          num_surfs, 
                          surfs,
                          &newplane,
                          recompute ? &display_ids : NULL, 
                          recompute ? &display_count : NULL),
              targetid = my_id);
    EMomerr_hndlr ( sts, ret_end, "EMSsfunitesf.EMmerge_coincident_surfs");

ret_end:

  if(update_display_ids)
  {
   /* Put the display_ids in the param object */
   sts = om$send(msg = message EMSdprparam.EMput_display_ids(
                    &loc_msg, display_count, display_ids, NULL),
               targetid = param_id);
  }
  
  if (surfs) om$dealloc (ptr=surfs);
  return (sts);

}

end implementation EMSsfunitesf;    
