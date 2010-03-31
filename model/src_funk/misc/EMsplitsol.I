/* ###################   APOGEE COMPILED   ################## */
/*


  HISTORY


*/

class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrtypedef.h"
#include "gr.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsbool.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"

extern OMuword OPP_EMSslboolean_class_id;

from EMSsfboolean import EMjoiningBoolean;

IGRlong EMsplit_solid(EMmsg, const_list, solid, surf, half1, half2)

IGRlong *EMmsg;
struct GRvg_construct *const_list;
struct GRid *solid;
GRobjid surf;
GRobjid *half1, *half2;

{
 IGRlong OM_stat, count;
 GRobjid solid_copy, surf_copy;
 IGRchar stat_str[54];
 enum EMSbooltype bool_type;
 IGRboolean is_primitive_surface;
 OM_S_CHANSELECT   to_loopset;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 strcpy (stat_str, "Processing");
 if (!half1 || !half2) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
 *half1 = *half2 = NULL_OBJID;

 /* check if the parting surface needs a natural loopset */

 OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 count = 0;
 OM_stat = om$get_channel_count(
          objid = surf,
          osnum = solid->osnum,
          p_chanselect = &to_loopset,
          count = (OMuint *)&count);
 is_primitive_surface = (1 & OM_stat); /* Will fail if not primitive */
 if (is_primitive_surface && count == 0)
 {
    OM_stat = om$send(msg = message EMSsurface.EMmk_nat_bdry(EMmsg, 
			             &const_list->env_info->md_env, NULL), 
                   senderid = NULL_OBJID, 
		   targetos = solid->osnum,
		   targetid = surf);
    EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 } 

 /* make copies of the solid and the parting surface */

 OM_stat = om$send(msg = message GRgraphics.GRcopy (EMmsg,
                           const_list->env_info, const_list->env_info,
			   &solid_copy),
                   senderid = NULL_OBJID, 
		   targetos = solid->osnum,
		   targetid = solid->objid);
 EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 OM_stat = om$send(msg = message GRgraphics.GRcopy (EMmsg,
                           const_list->env_info, const_list->env_info,
			   &surf_copy),
                   senderid = NULL_OBJID, 
		   targetos = solid->osnum,
		   targetid = surf);
 EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 /* reverse the orientation of the parting-surf copy */

 OM_stat = om$send(msg = message EMSsurface.EMrevorient(EMmsg),
                   senderid = NULL_OBJID, 
		   targetos = solid->osnum,
		   targetid = surf_copy);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

 /* construct the dpr objects */

 OM_stat = om$construct(classid = OPP_EMSslboolean_class_id,
                         p_objid = half1,
                         osnum = solid->osnum);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$construct(classid = OPP_EMSslboolean_class_id,
                         p_objid = half2,
                         osnum = solid->osnum);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 /* perform difference operations */

 bool_type = EMSbool_difference;
 OM_stat = om$send(msg = message EMSsfboolean.EMjoiningBoolean(EMmsg,
			&const_list->env_info->md_env.matrix_type,
			const_list->env_info->md_env.matrix,
			solid->objid, 1, &surf, const_list,
			bool_type, EMSsfbool_opt_display,
			stat_str, NULL, NULL, NULL, NULL),
                   senderid = NULL_OBJID, 
		   targetos = solid->osnum,
		   targetid = *half1);
 EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

 strcpy (stat_str, "Processing");
 OM_stat = om$send(msg = message EMSsfboolean.EMjoiningBoolean(EMmsg,
			&const_list->env_info->md_env.matrix_type,
			const_list->env_info->md_env.matrix,
			solid_copy, 1, &surf_copy, const_list,
			bool_type, EMSsfbool_opt_display,
			stat_str, NULL, NULL, NULL, NULL),
                   senderid = NULL_OBJID, 
		   targetos = solid->osnum,
		   targetid = *half2);
 EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);


wrapup:

  EMWRAPUP (*EMmsg, OM_stat, "EMsplitsol");
  return (OM_stat);
}


end implementation EMSsurface;

