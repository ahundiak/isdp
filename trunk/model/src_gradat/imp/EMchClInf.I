/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

#include "EMS.h"
/*
History

    RC          01/13/89    Modified to allow material cross hatching
                            patterns.

    17 December 87  AIC     Changed include files

    RC          12/04/87    Modified for cross hatching in both
                            directions.

    RC, AIC     09/23/87    Creation date
*/

# include "OMmacros.h"

# ifndef EMSerrordef_include
# include "EMSerrordef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

extern  OMuword  OPP_EMSchatch_class_id;

method EMget_class_info (
IGRlong		*EMmsg;
OMuword		*frt_classid;
OM_p_MESSAGE	messg)

{
  struct EMSchatch_EMputdef_Msg		*parglist;
  IGRlong                               OM_stat;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  if(frt_classid) *frt_classid = OPP_EMSchatch_class_id;
  
  if (messg)
  {
    struct EMSxh_info  *xh_info;

    parglist = NULL;
    parglist= (struct EMSchatch_EMputdef_Msg *) 
		om$malloc(size = sizeof(struct EMSchatch_EMputdef_Msg));
    EMerr_hndlr (!parglist, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

    parglist->EMmsg = EMmsg;

    xh_info = &parglist->xh_info;
    xh_info->angle = me->angle;
    OM_BLOCK_MOVE (me->origin, xh_info->origin, sizeof(IGRpoint));
    xh_info->num_u_sgrps = me->num_u_sgrps;
    xh_info->num_v_sgrps = me->num_v_sgrps;
    xh_info->u_sgrp_info = me->sgrp_info;
    xh_info->v_sgrp_info = &me->sgrp_info[me->num_u_sgrps];

    OM_stat = om$make_message (classname = "EMSchatch",
		methodname = "EMputdef", 
		size = (OMuword) sizeof(struct EMSchatch_EMputdef_Msg),
		p_arglist = (char *) parglist, p_msg = messg);
    EMerr_hndlr (!parglist, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  } /* if (messg) */

  OM_stat = OM_I_STOP_SENDING;

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSchatch_EMget_class_info");

  return (OM_stat);
}


end implementation EMSchatch;
