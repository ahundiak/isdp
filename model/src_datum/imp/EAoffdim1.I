class implementation EMSdimoff;

/*
  HISTORY

        dfl   11/93  
        dfl - 09/94 - moved method to delete myself to class EMSdimoff1    
*/


#include "OMmacros.h"
#include <alloca.h>
#include "nddef.h"
#include "REdatpln.h"
#include "dimangular.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#define  EMSPARAMVL "EMSparamvl"
#define  ASSOURCE "ASsource"

extern OMuword   OPP_EMSplane_class_id;
extern OMuword   OPP_ASsource_class_id;
extern OMuword   OPP_EMSparamvl_class_id;
extern OMuword   OPP_EMSdatpln_class_id;
extern OMuword   OPP_GRlistener_class_id;

from EMSassoc import EMget_info;
/*from ASsource import ASreturn_go;*/
from GRlinear import GRgetpolyline;
from GRcurve import GRendpts;
from GRvg import GRdetplane;

method ASreturn_go ( struct GRid * go;
                     IGRshort    * mat_type;
                     IGRdouble   * matrix )
{
    IGRlong         msg;
    struct GRmd_env mod_env;
    IGRint          sizbuf, nret;

    go->objid = my_id;
    go->osnum = OM_Gw_current_OS;


    if (matrix && mat_type)
    {
      sizbuf = sizeof(struct GRmd_env);

      gr$get_module_env ( msg = &msg,
                            sizbuf = &sizbuf,
                            buffer = &mod_env,
                            nret = &nret );

      *mat_type = mod_env.md_env.matrix_type;    

      OM_BLOCK_MOVE(mod_env.md_env.matrix, matrix, sizeof(IGRmatrix));
    }
    return OM_S_SUCCESS;
}


method EMofcvdim ( IGRlong             *EMmsg;
                   unsigned int        octrl;
                   struct GRmd_env     *md_env)
{
 int i, j;
 IGRboolean value_found;
 IGRlong status,msg_loc;
 OMuint num_parents;
 OMuword class_id;
 IGRint type, info_size, trak_dir;
 IGRint parvl_idx;
 IGRpoint dumpt;
 int EAoff;
 IGRchar *info = NULL;
 struct GRid *parents = NULL, 
             curve_GRid,
             dim_GRid, 
             my_GRid;


 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 
 me->offset_control = octrl;
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 dumpt[0] = dumpt[1] = dumpt[2] = 0.0;
 
 pp_get_gacurve(&msg_loc, &my_GRid, &curve_GRid);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


 EFget_parents_and_info (&msg_loc, &curve_GRid, &type, &info_size, NULL,
                         &num_parents, NULL);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if (num_parents)
 {
  parents = (struct GRid *) alloca (sizeof (struct GRid) * num_parents);
  EMerr_hndlr(!parents, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 if (info_size)
 {
  info = (char *) alloca (info_size);
  EMerr_hndlr(!info, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 EFget_parents_and_info (&msg_loc, &curve_GRid, &type, &info_size, info,
                         &num_parents, parents);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);


 /* determine offset distance */

 value_found = FALSE;
 EAoff = 124;

 for(i=0, j=0; i<num_parents;i++) {
   status = om$get_classid(
                     objid = (parents + i)->objid,
                     osnum = (parents + i)->osnum,
                     p_classid = &class_id);
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 

   if(!value_found) {
     status = om$is_ancestry_valid(subclassid = class_id, 
                     superclassid = OPP_EMSparamvl_class_id); 
     EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     if(status == OM_S_SUCCESS) {
          parvl_idx = i;
          value_found = TRUE;
     }
   }
 }
 EAoff = 345;
 if(!value_found) {
   status = 0;  
   EMerr_hndlr (!(1&status), *EMmsg, EMS_E_Fail, wrapup);
 }
  

    EAoff = 126;
    dim_GRid.objid = NULL_OBJID;
    trak_dir = 0;
    
    dm$place_sglpara ( orig_grid    = &my_GRid,
                       orig_pt      = dumpt,
                       plane_grid   = &my_GRid,
                       /*plane_matrix = (IGRmatrix *) dimmatrix,*/
                       trak_dir     = trak_dir,
                       trak_dist    = 0.0,
                       owner        = &parents[parvl_idx],
                       dim_grid     = &dim_GRid );
    EMerr_hndlr (dim_GRid.objid == NULL_OBJID, *EMmsg, EMS_E_Fail, wrapup);

    return(status);
 
wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSdimoff : EMautodim error");
 return (status);
}



pp_get_gacurve(EMmsg, dim_ref_GRid, gacurve_GRid)
IGRlong *EMmsg;
struct GRid *dim_ref_GRid;
struct GRid *gacurve_GRid;
{
 OMuint num_parents;
 IGRlong status;
 OM_S_CHANSELECT father;
 OM_S_OBJECT_LINKAGE parent_list;

 *EMmsg = EMS_S_Success;

 EMmake_chanselect (NDfather_father, &father);

 status = om$get_channel_objects (objid = dim_ref_GRid->objid,
                                  osnum = dim_ref_GRid->osnum,
                                  p_chanselect = &father,
                                  list = &parent_list,
                                  size = 1,
                                  count = &num_parents);
 if (status == OM_I_LISTOVFLOW)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

 gacurve_GRid->objid = parent_list.S_objid;
 gacurve_GRid->osnum = parent_list.osnum;

wrapup:
 return (status);
}


end implementation EMSdimoff;

