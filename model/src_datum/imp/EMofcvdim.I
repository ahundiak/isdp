class implementation GAcurve;

#include "bserr.h"
#include "bsparameters.h"
#include "EMSdef.h" /* For EMparms */
#include "EMSconstruct.h"
#include "OMmacros.h"
#include "bs_values.h"
#include "exmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "nddef.h"    /* For ND_NC_NEW */
#include "asmacros.h" /* For as$make_source */
#include "parametric.h"
%safe
#include <math.h>
%endsafe

from EMSdimoff import EMofcvdim;

extern OMuword OPP_EMSdimoff_class_id;
extern OMuword OPP_EMSdimoff1_class_id;


IGRint EEplace_autodim(EMmsg,
                       const_list,
                       octrl,
                       my_id,
                       res_id)
        IGRlong                *EMmsg;
        struct GRvg_construct  *const_list;
        unsigned int           octrl;
        GRobjid                my_id;
        GRobjid                res_id;

{  
    int     XXXXX;   
    IGRlong sts;
    IGRlong msg_loc;
    

    /* autodim */
    sts  = om$send (msg = message GAcurve.EMofcvdim(&msg_loc,
                                                    octrl,
                                                    const_list->env_info),
                   /*mode = OM_e_wrt_message,*/
                   senderid = my_id,
                   targetos = const_list->env_info->md_id.osnum,
                   targetid = res_id);
    if(!(1&sts)) {
      printf("autodimensioning failed\n");
      goto wrapup;
    }
 wrapup:

  return (sts);
}



method EMofcvdim (IGRlong             *EMmsg;
                  unsigned int        octrl;
                  struct GRmd_env     *mod_env )
{
 IGRlong status;
 OM_S_OBJID dim_id;
 struct GRid original, my_GRid;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 original.objid = NULL_OBJID;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 status = om$construct (classid = OPP_EMSdimoff1_class_id,
                        p_objid = &dim_id,
                        msg = message NDnode.NDconnect(1, &my_GRid,
                              original, ND_ADD));
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 status = om$send (msg = message EMSdimoff.EMofcvdim(EMmsg, octrl, mod_env),
                   mode = OM_e_wrt_message,
                   targetid = dim_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

              
 status =1;
wrapup:
 EMWRAPUP (*EMmsg, status, "EMSoffcurve: NDconnect error");
 status =1;
 return (status);
}

end implementation GAcurve;
