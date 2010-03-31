class implementation EMSsurface;

#include "EMS.h"
# include "msdef.h"
#include "msmacros.h"
#include "emsclasses.h"
#include "ECmsg.h"
#include "gr.h"
#include "emssfint.h"

method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *const_args;
                 IGRboolean offset_inward;
                 IGRdouble thickness;
                 IGRint num_spec_thick;
                 IGRdouble *val_spec_thick;
                 struct GRobjid_set *spec_thick_sf_sets;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *offsetobj;
                 struct EMSerror_help *errkey_list)
{
  *msg = EMS_E_NotSupported;
  *offsetobj = NULL_OBJID;
  return (OM_S_SUCCESS);
}


method EMgetstatedesc(IGRlong *EMmsg; IGRchar *desc)
/*
Description
   This method will return the description of me wrt. being a tree node.

Return Values
   EMS_S_Success always

Notes
   The desc array is a maximum of 54 characters in length.

History
   DLB 03/27/88          Creation
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 struct GRobj_info info;


 *EMmsg = EMS_S_Success;    

 OM_stat = om$send(msg = message GRgraphics.GRgetobjinfo(EMmsg, &info),
                   targetid = my_id);

 strcpy(desc, info.type);

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsurface.EMgetstatedesc")
  return(OM_stat);
}


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
  IGRchar myclassname[OM_K_MAXCLASS_LEN], myinfo[30];
  IGRlong sts = OM_S_SUCCESS;

  *msg = MSSUCC;

  sts = om$get_classname(objid = my_id, classname = myclassname);
  if(!(1&sts)) goto wrapup;
  
  ex$message(msgname = myclassname, buff = info->type)

wrapup:
    return(sts);
}


end implementation EMSsurface;


