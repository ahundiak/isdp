/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emserr.h"
#include "emsdef.h"

extern OMuword OPP_EMSedge_class_id;

IGRboolean EFis_edge_owned_by_edlp(EMmsg, edge_id, edlp_id, curr_os)
IGRlong *EMmsg;
GRobjid edge_id;
GRobjid edlp_id;
OMuword curr_os;
/*
History
    DLB     ??/??/89    Creation.
    DLB     05/16/91    speeded up by getting all the owners in one shot.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          ii, count;
  IGRboolean      EFisAncestryValid();
  OM_S_OBJECT_LINKAGE *obj_link=NULL, *curr_obj_link;
  OM_S_CHANSELECT     to_owner;


  *EMmsg = EMS_S_Success;

  EMmake_chanselect(EMSedge_to_owner, &to_owner);
  OM_stat = om$is_objid_on_channel(objid_c = edge_id,
                                  osnum_c = curr_os,
                                  p_chanselect = &to_owner,
                                  objid = edlp_id,
                                  osnum2 = curr_os);
  if (OM_stat == OM_S_SUCCESS)
  {
    *EMmsg = EMS_I_DirectlyOwned;
    return(TRUE);
  }
  else if (!(1 & OM_stat) && (OM_stat != OM_W_NOTONCHAN)) goto wrapup;
  else
  {
    OM_stat = om$get_channel_count(objid = edge_id,
                                   osnum = curr_os,
                                   p_chanselect = &to_owner,
                                   count = (OMuint *) &count);
    if (!(1 & OM_stat)) goto wrapup;

    obj_link = (OM_S_OBJECT_LINKAGE *) stackalloc
               (count * sizeof(OM_S_OBJECT_LINKAGE));            
    if (!obj_link) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}
      
    OM_stat = om$get_channel_objects(objid = edge_id,
                                     osnum = curr_os,
                                     p_chanselect = &to_owner,
                                     list = obj_link,
                                     size = count,
                                     count = (OMuint *) &count);
    if (!(1 & OM_stat)) goto wrapup;                                     

    curr_obj_link = obj_link;

    for(ii=0; ii<count; ii++, curr_obj_link++)
    {
      if (EFisAncestryValid(EMmsg, curr_obj_link->S_objid, curr_os, 
                            OPP_EMSedge_class_id, FALSE))
      {
        if (EFis_edge_owned_by_edlp(EMmsg, curr_obj_link->S_objid, edlp_id,
                                    curr_os))
        {
          *EMmsg = EMS_S_Success;   /*Not directly owned*/
          return(TRUE);
        }
      }
    }    
  }

wrapup:
  if (obj_link) stackfree(obj_link);
  EMWRAPUP(*EMmsg, OM_stat, "EFis_edge_owned_by_loop")
  return(FALSE);  
}
