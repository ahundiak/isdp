/* ###################   APOGEE COMPILED   ################## */
class implementation EMSchatch;

/*
History

    RC  01/09/89    Creation Date
*/

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"
# endif

# ifndef emserr_include
# include "emserr.h"
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMGD_UPTODATE  */
# endif

# include "OMmacros.h"

method EMputdef(IGRlong *EMmsg; struct EMSxh_info xh_info)

{
  IGRlong   OM_stat = OM_S_SUCCESS;
    
   *EMmsg = EMS_S_Success;

   me->angle = xh_info.angle;
   OM_BLOCK_MOVE (xh_info.origin, me->origin, sizeof(IGRpoint));
   me->num_u_sgrps = xh_info.num_u_sgrps;
   me->num_v_sgrps = xh_info.num_v_sgrps;

   OM_stat = om$vla_set_dimension (varray = me->sgrp_info,
             size = (xh_info.num_u_sgrps + xh_info.num_v_sgrps) );
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   if (me->num_u_sgrps)
     OM_BLOCK_MOVE (xh_info.u_sgrp_info, me->sgrp_info,
              sizeof(struct EMSxh_sgrp_info) * xh_info.num_u_sgrps);

   if (me->num_v_sgrps)
     OM_BLOCK_MOVE (xh_info.v_sgrp_info, &me->sgrp_info[me->num_u_sgrps],
              sizeof(struct EMSxh_sgrp_info) * xh_info.num_v_sgrps);

   ME.EMShelper->props &= ~EMGD_UPTODATE;

   wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSchatch.EMputdef");
   return(OM_stat);
}

end implementation EMSchatch;
