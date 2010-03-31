class implementation EMScompsurf;

#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igr.h"
#include "ex.h"
#include "exdef.h"
#include "griodef.h"
#include "grio.h"
#include "dp.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "EMSasopts.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "REsfboolean.h"

extern GRclassid OPP_EMSsfboolean_class_id;

method ECtrmcmpsfs(struct GRlc_info **crvs_info;
                    IGRint num_crvs;
                    struct GRlc_info *compsf_info;
                    IGRushort imp_options;
                    IGRint num_lrgst_crvs;
                    IGRint *crv_index;
                    IGRlong crv_reversed;
                    GRobjid *lrgst_cmpid;
                    IGRboolean is_associative;
                    IGRint *num_bad_pts;
                    IGRdouble **bad_pts;
                    struct GRid *dprid;
                    IGRlong *EMmsg)

{

	IGRlong stat_OM;
        IGRint i, bufsiz, nret, num_parents;
        IGRboolean assoc_flag = TRUE;
        struct IGRdisplay display_attr;
        struct EMSobject_info *parents = NULL;
        struct GRvg_construct construct_list;
        
        extern IGRlong EMsfimpose();

        *EMmsg = EMS_S_Success;
	stat_OM = OM_S_SUCCESS;

        dprid->osnum = compsf_info->located_obj.osnum;
        if(IF_NULL_OBJID(dprid->objid)) {
        stat_OM = om$construct(
                  classid = OPP_EMSsfboolean_class_id,
                  p_objid = &(dprid->objid),
                  osnum   = dprid->osnum);
                  EMerr_hndlr (!(1&stat_OM), *EMmsg, EMS_E_OMerror, ret_end);
        }

        if(is_associative) {
        bufsiz = sizeof(struct IGRdisplay);
        gr$get_active_display(msg = EMmsg,
                              sizbuf = &bufsiz,
                              buffer = &display_attr,
                              nret = &nret);

        parents = (struct EMSobject_info *)
                   alloca(sizeof(struct EMSobject_info) * (num_crvs + 1));
       
        construct_list.msg = EMmsg;
        construct_list.env_info = &compsf_info->module_info;
        construct_list.newflag = FALSE;
        construct_list.geometry = NULL;
        construct_list.class_attr = NULL;
        construct_list.level = NULL;
        construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        construct_list.display = &display_attr;
        construct_list.name = NULL;

        for(i = 0; i < (num_crvs + 1); i++) {
            if(i == num_crvs) {
               parents[i].grid.objid = compsf_info->located_obj.objid;
               parents[i].grid.osnum = compsf_info->located_obj.osnum;
               OM_BLOCK_MOVE(&compsf_info->module_info,
                             &parents[i].env, sizeof(struct GRmd_env));
              }
            else {
               parents[i].grid.objid = crvs_info[i]->located_obj.objid;
               parents[i].grid.osnum = crvs_info[i]->located_obj.osnum;
               OM_BLOCK_MOVE(&crvs_info[i]->module_info,
                             &parents[i].env, sizeof(struct GRmd_env));
              }      
           }
       stat_OM = om$send (msg = message EMSsurface.EMis_associative(EMmsg,
                                &assoc_flag),
                          targetid = compsf_info->located_obj.objid,
                          targetos = compsf_info->located_obj.osnum);
       EMerr_hndlr(!(stat_OM & *EMmsg & 1), *EMmsg, EMS_E_Fail, ret_end);

       if(!assoc_flag) {
          stat_OM = om$send(msg = message EMSsurface.EMtransform_to_associative
                           (EMmsg, &parents[num_crvs].grid.objid),
                           targetid = compsf_info->located_obj.objid,
                           targetos = compsf_info->located_obj.osnum);
          EMerr_hndlr(!(stat_OM & *EMmsg & 1), *EMmsg, EMS_E_Fail, ret_end);
         }
       
       num_parents = num_crvs + 1;
       stat_OM = om$send(msg = message EMSassoc.EMinit_associative
                        (EMmsg,             /* return code */
                         EMS_no_const_assoc,/* options */
                         num_parents,       /* number of parents */
                         parents,           /* parent information */
                         EMS_ASbool_TrimCompsfs,/* type of operation */
                         sizeof(IGRint),    /* size of info to store */
                         (IGRchar *)&crv_reversed,
                         &construct_list),   /* construction parameters */
                   targetid = dprid->objid);
       EMerr_hndlr(!(stat_OM & *EMmsg & 1), *EMmsg, EMS_E_Fail, ret_end);
       }  

       stat_OM = EMsfimpose(crvs_info,
                            num_crvs,
                            compsf_info,
                            imp_options,
                            num_lrgst_crvs, 
                            crv_index,
                            crv_reversed,
                            lrgst_cmpid,
                            num_bad_pts,
                            bad_pts,
                            dprid,
                            EMmsg);

                  if(!(1 & stat_OM & *EMmsg))
                    goto ret_end;

ret_end :

if(1&stat_OM)
return(OM_S_SUCCESS);
else
return(OM_E_ABORT);
}
end implementation EMScompsurf;
