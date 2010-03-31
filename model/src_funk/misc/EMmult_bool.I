/* ###################   APOGEE COMPILED   ################## */
/*

History : 02/01/88 : Gupta  Creation date

*/
class implementation GRbspline;

#include "EMS.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSmsgdef.h"

IGRlong	EMmult_boolean(EMmsg,
                       curve_set,
                       num_sets,
                       code, 
                       const_list_p,
                       num,
                       comp_crv_ids)

IGRlong 		        *EMmsg; 
struct GRlc_info        curve_set[];
IGRint                  num_sets;
IGRint                  code;
struct GRvg_construct 	*const_list_p; 
IGRint                  *num;
GRobjid                 **comp_crv_ids;

{
  IGRlong                  msg, stat_OM;
  IGRint                   i;
  GRobjid                  *comp_ids;
  struct GRlc_info         result_comp;

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMcvcvboolean(&msg, &curve_set[0], &curve_set[1], code, const_list_p,
                num, &comp_ids);
  if ((msg == EMS_I_NoIntersection) || (msg == EMS_I_CvsNonCoplanar))
   {
    *EMmsg = msg;
    goto wrapup;
   }
  EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
  
  *comp_crv_ids = comp_ids;

  if ((num_sets > 2) && (*num > 1))
   {
    *EMmsg = EMS_I_BoolFail;
    goto wrapup;
   }

  for (i = 0; i < (num_sets-2); i++)
   {
    result_comp.located_obj.objid = comp_crv_ids[0][0];
    result_comp.located_obj.osnum = curve_set[i+2].located_obj.osnum;
    result_comp.module_info = curve_set[i+2].module_info;
    
    *num = 0;
    EMcvcvboolean(&msg, &result_comp, &curve_set[i+2], code, const_list_p,
                  num, &comp_ids);
    if ((msg == EMS_I_NoIntersection) || (msg == EMS_I_CvsNonCoplanar))
     {
      *EMmsg = msg;
      stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg,
                              &result_comp.module_info),
                        senderid = NULL_OBJID,
                        targetid = result_comp.located_obj.objid,
                        targetos = result_comp.located_obj.osnum);
      goto wrapup;
     }
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
    
    *comp_crv_ids = comp_ids;

    stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg,
                            &result_comp.module_info),
                      senderid = NULL_OBJID,
                      targetid = result_comp.located_obj.objid,
                      targetos = result_comp.located_obj.osnum);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    if ((i != num_sets-3) && (*num > 1))
     {
      *EMmsg = EMS_I_BoolFail;
      goto wrapup;
     }
   }

wrapup:

	return(stat_OM);
}
end implementation GRbspline;
