/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

#include "EMS.h"
/*
History

    RC  01/13/89    Modified arguments and code such that
                    material cross hatch patterns can be allowed.
    RC  10/17/88    Creation Date.
*/

# include "OMmacros.h"

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE  */
# endif

method EMgetdef (IGRlong              *EMmsg;
                 struct  EMSxh_info   *xh_info)
{
   IGRlong  OM_stat = OM_S_SUCCESS;
    
   *EMmsg = EMS_S_Success;
   
   xh_info->u_sgrp_info = xh_info->v_sgrp_info = NULL;

   xh_info->angle = me->angle;
   OM_BLOCK_MOVE (me->origin, xh_info->origin, sizeof(IGRpoint));
   xh_info->num_u_sgrps = me->num_u_sgrps;
   xh_info->num_v_sgrps = me->num_v_sgrps;

   if (me->num_u_sgrps)
   {
     xh_info->u_sgrp_info = (struct EMSxh_sgrp_info *) om$malloc (
              size = me->num_u_sgrps * sizeof(struct EMSxh_sgrp_info) );
     EMerr_hndlr (!xh_info->u_sgrp_info,*EMmsg,EMS_E_Fail,wrapup);

     OM_BLOCK_MOVE (me->sgrp_info, xh_info->u_sgrp_info, 
                    sizeof(struct EMSxh_sgrp_info) * me->num_u_sgrps);
   } /* if (me->num_u_sgrps); */

   if (me->num_v_sgrps)
   {
     xh_info->v_sgrp_info = (struct EMSxh_sgrp_info *) om$malloc (
              size = me->num_v_sgrps * sizeof(struct EMSxh_sgrp_info) );
     EMerr_hndlr (!xh_info->v_sgrp_info,*EMmsg,EMS_E_Fail,wrapup);

     OM_BLOCK_MOVE (&me->sgrp_info[me->num_u_sgrps], 
                    xh_info->v_sgrp_info, 
                    sizeof(struct EMSxh_sgrp_info) * me->num_v_sgrps);

   } /* if (me->num_u_sgrps); */

   OM_stat = OM_I_STOP_SENDING;
   
 wrapup:   
   EMWRAPUP (*EMmsg, OM_stat, "EMSchatch.EMgetdef");
   return(OM_stat);
}

end implementation EMSchatch;
