class implementation EMSassoc;

#include <stdio.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "OMmacros.h"
#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"


extern OMuword OPP_EMSparameter_class_id,
               OPP_EMSparampt_class_id,
               OPP_EMSparamvc_class_id,
               OPP_expression_class_id,
               OPP_EMSparvcnstr_class_id,
               OPP_EMSasptcnstr_class_id,
               OPP_EMScnstr_class_id,
               OPP_EMSexpcnstr_class_id,
               OPP_SKexplicit_class_id;

from EMSasptcnstr import EMalt_init;
from EMSexpcnstr import EMputval;
from EMScnstr import EMinit;
from expression import NDset_value;

method NDchange_connect(int nb_change; struct GRid *old,*new)
/*
 * Disallow change_connect if the parent being changed is a 
 * constraint or a parameter since we have to play some special 
 * games in that case. We shall address the same if this functionality
 * is deemed critical and evaluate it for a future release if 
 * necessary.
 *
 * Creation 
 *  History : PP : 12/21/91
 */
{
 IGRlong status;
 IGRlong EMmsg;
 IGRint i;
 IGRint sizbuf, nret;
 IGRboolean allow_change_connect = FALSE, object_added = FALSE;
 struct GRmd_env env;
 OM_S_OBJID cnstr_objid;
 OMuword cnstr_os;

 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;

 sizbuf = sizeof(struct GRmd_env);

 gr$get_module_env ( msg = &EMmsg,
                     sizbuf = &sizbuf,
                     buffer = &env,
                     nret = &nret );
 if (!(1&EMmsg)) goto wrapup;

 for (i=0;i<nb_change;i++)
 {
   allow_change_connect = 0;
   if (EFisAncestryValid(&EMmsg,old[i].objid,old[i].osnum,
                         OPP_EMSparampt_class_id, FALSE))
   {
    struct EMSasptinfo ptinfo;
    struct ret_struct info_struct;

    ptinfo.type = GRst_KEYPOINT;
    ptinfo.win_pln.objid = NULL_OBJID;

    if (!EFisAncestryValid(&EMmsg,new[i].objid,new[i].osnum,
                         OPP_EMSparampt_class_id, FALSE))
    {
     cnstr_os = new[i].osnum;
     status = om$send (msg = message NDnode.NDgive_structure(&EMmsg,
                            &info_struct, &env),
                      targetid = new[i].objid,
                      targetos = new[i].osnum);
     EMerr_hndlr(!(1&status&EMmsg), EMmsg, MSFAIL, wrapup);
     OM_BLOCK_MOVE(info_struct.var.point_st.pt,ptinfo.pts[0],sizeof(IGRpoint));

     status = om$construct(classid = OPP_EMSasptcnstr_class_id,
                          msg = message EMSasptcnstr.EMalt_init(&EMmsg,
                                NULL,&env,
                                1, &new[i], NULL,
                                (char *) &ptinfo,1,
                                &old[i]),
                          osnum = cnstr_os,
                          p_objid = &cnstr_objid);
     EMerr_hndlr(!(1&status&EMmsg), EMmsg, MSFAIL, wrapup);
     object_added = TRUE;

    }
   }
   else if (EFisAncestryValid(&EMmsg, old[i].objid, old[i].osnum,
            OPP_EMSparamvc_class_id, FALSE))
   {
    if (!(EFisAncestryValid(&EMmsg, new[i].objid, new[i].osnum,
            OPP_EMSparamvc_class_id, FALSE)))
   
    {
     cnstr_os = new[i].osnum;
     status = om$construct (classid = OPP_EMSparvcnstr_class_id,
                           msg = message EMScnstr.EMinit(&EMmsg,
                                 NULL,&env,1, &new[i],
                                 NULL,NULL,1, &old[i]),
                           osnum = cnstr_os,
                           p_objid = &cnstr_objid);
     EMerr_hndlr(!(1&status&EMmsg), EMmsg, MSFAIL, wrapup);
     object_added = TRUE;
    }
   }
   else if (EFisAncestryValid(&EMmsg, old[i].objid, old[i].osnum,
                         OPP_EMSexpcnstr_class_id, FALSE))
   {
    if ((!EFisAncestryValid(&EMmsg, new[i].objid, new[i].osnum,
                         OPP_EMSexpcnstr_class_id, FALSE)) &&
            (EFisAncestryValid(&EMmsg, new[i].objid, new[i].osnum,
                         OPP_expression_class_id, FALSE)))
   {
    struct ret_struct info_struct;

    status = om$send (msg = message NDnode.NDgive_structure(&EMmsg,
                            &info_struct, &env),
                      targetid = new[i].objid,
                      targetos = new[i].osnum);
    if (info_struct.type & parameter_generic)
    {
     status = om$send (msg = message EMSexpcnstr.EMputval(&EMmsg,NULL,
                              info_struct.var.root_pm_st.value,NULL),
                      targetid = old[i].objid,
                      targetos = old[i].osnum);
     EMerr_hndlr(!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);
    }
   }
   } 
   else
   {
    status = om$send (msg = message NDnodein.NDchange_connect(1,
                         &old[i],&new[i]),
                   mode = OM_e_wrt_message,
                   targetid = my_id);
    EMerr_hndlr(!(1&status), EMmsg, EMS_E_Fail, wrapup);
   }

   if (object_added)
   {
    int cn_type;
    struct GRid new_GRid;

    new_GRid.objid = cnstr_objid;
    new_GRid.osnum = cnstr_os;

    cn_type = ND_COMP;
    nd$wait_batch(type = GR_GEOM_POSTED,
                   l_object = &new_GRid,
                   l_obj_info = &cn_type,
                   nb_obj   = 1);
   }
 }

wrapup:
 return (OM_S_SUCCESS);
}
end implementation EMSassoc;

