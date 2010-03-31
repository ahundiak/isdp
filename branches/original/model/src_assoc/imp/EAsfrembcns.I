class implementation EMSsfrembnd;

/*
HISTORY

 August, 1991  : AMD :  Creation

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

method EMconstruct_associative(IGRlong *msg;
                               IGRushort options;
                               OM_S_OBJID old_objid;
                               IGRint nparents;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct)

{
   IGRint   i, recompute, num_loops;
   IGRlong  sts;
   union EMSparent_info *parents = NULL;
   GRobjid   *loops;
   struct GRid   active_GRid;
   IGRuint *parent_types;

     /* check options for recompute */

    loops = (GRobjid *) om$malloc (size = nparents * sizeof(GRobjid));

    recompute = options & EMSasconst_recompute;

    /* unwind the parent information */

    parents = (union EMSparent_info *) alloca
              (sizeof(union EMSparent_info) * nparents);
    parent_types = (IGRuint *) alloca(sizeof(IGRint) * nparents);
    for (i = 0; i < nparents; i++) parent_types[i] = EMSgrid;

    sts = om$send(msg = message EMSassoc.EMget_parent_info
                       (msg, NULL, nparents, parent_info,
                        parent_types, parents),
                  targetid = my_id);

    ERROR(sts, *msg, "EMSsfimpbnd$EMconstruct_associative", ret_end);

    num_loops = nparents - 1; 
 
    /* Get the loops to be removed */

    for (i=0; i < num_loops; i++)
    {

       loops[i] = parents[i].grobj.grid.objid;

       if (loops[i] == NULL_OBJID)
       {
         /*Must have been a mismatch!!!.*/
         *msg = EMS_I_CantRecompute;
         goto ret_end;
       }

    }

    active_GRid = parents[num_loops].grobj.grid;

    /* Perform the deletion */

    sts = om$send (msg = message EMSsfrembnd.EMremove_boundaries( msg,
                          &construct->env_info->md_env.matrix_type, 
			  construct->env_info->md_env.matrix,
                          *construct,
		          active_GRid,
                          num_loops, 
                          loops),
             targetid = my_id);
    EMomerr_hndlr ( sts, ret_end, "EMSsfassbnd.EMremove_boundaries");


ret_end:
  
  if (loops) om$dealloc (ptr=loops);
  return (sts);

}

end implementation EMSsfrembnd;    
