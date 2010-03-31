/* ###################   APOGEE COMPILED   ################## */
/* #################   APOGEE  COMPILED   ######################### */
/* ************************************************************************

Description

 This method constructs associative objects of the class GAcompcurve.

Arguments
 Input
  nb_root : Number of roots.
  type : Type to interpret the recomputation information.
  const_options : Currently can be set to NULL.
  parent_info : Information about parents.
  env : Module environment of the master file.
  construct_list : construction information
  info : Recomputation information. This better not be NULL.

 Output
  EMmsg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_SurfaceError : If there is an error in doing one of these:
           a) Get the surface definition
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

History
 03/28/91 : WBC : Creation date.

*********************************************************************** */

class implementation GAcompcurve;

#include "EMS.h"
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "EMSdpb.h"
#include <stdio.h>
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdef.h"
#include "EMSopt.h"
#include "EMSconstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlcdef.h"
#include "DEsomacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;


method EMconstruct_associative(IGRlong *EMmsg;
                               IGRushort options;
                               OM_S_OBJID old_objid;
                               IGRint num_parents;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct_list)

{
    extern IGRlong       EFcreate_composite_curve_from_loop();
    int                  is_msc;
    IGRlong              status;
    IGRuint      info_type;
    OM_S_OBJID           amsc_with_loop,
                         loop_objid;
    OMuword              loop_osnum;
    union EMSparent_info root;

    status = OM_S_SUCCESS;
    *EMmsg = EMS_S_Success;

    (void) EFis_msc(EMmsg, type, &is_msc);

    if (!is_msc) 
    {
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
    }

    /* get the objid of the loop corresponding to this associative
     * model-space counterpart
     */

    amsc_with_loop = (old_objid == NULL_OBJID) ? my_id : old_objid;

    status = om$send(msg = message GAcurve.GAget_msc_component(EMmsg,
                                                 &loop_objid, &loop_osnum),
                     targetid = amsc_with_loop);
    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    /* get the module environment of the parent; there should only be 1 */

    if (num_parents == 1)
    {
        info_type = EMSgrid;
        status = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,
                                                         NULL, 1, parent_info,
                                                         &info_type, &root),
                         targetid = my_id);
    }
    else
        status = OM_E_ABORT;
    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    /* call a function the will finish creating the composite curve */

    status = EFcreate_composite_curve_from_loop(EMmsg, EMSlcopt_noassoc,
                                                OM_Gw_current_OS, my_id,
                                                loop_osnum,
                                                loop_objid, NULL,
                                                &root.grobj.env,
                                                construct_list);
    EMerr_hndlr(!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

    return (status);
}
end implementation GAcompcurve;
