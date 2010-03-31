class implementation NMnonmani;

#include "OMmacros.h"
#include "nm.h"
#include "grownerdef.h"
#include "emsmacros.h"
#include "EMSasdef.h"
#include "EMSasnuc.h"
#include "ndmacros.h"

from GRgrgrp import GRunion;

IGRint NMmerge_graphic_groups(EMmsg, id1, id2, construct, result)
IGRlong *EMmsg;
GRobjid id1, id2, *result;
struct GRvg_construct *construct;
{
 IGRlong	sts = OM_S_SUCCESS;
 IGRboolean	id1_grp, id2_grp;
 struct GRid	junkid[2];
 IGRint		i;
 GRspacenum	idos;

 *EMmsg = EMS_S_Success;
 *result = NULL_OBJID;
 idos = construct->env_info->md_id.osnum;
 id1_grp = EFisAncestryValid(EMmsg, id1, idos, OPP_GRgrgrp_class_id, FALSE);
 id2_grp = EFisAncestryValid(EMmsg, id2, idos, OPP_GRgrgrp_class_id, FALSE);
 for(i=0; i<2; i++)
  {
   junkid[i].osnum = idos;
   junkid[i].objid = i ? id2 : id1;
  }

 if(id1_grp && id2_grp)
  {
   sts = om$send(msg = message GRgrgrp.GRunion(EMmsg, &junkid[1], 
                 &junkid[0]), targetid = junkid[0].objid, 
                 targetos = junkid[0].osnum, senderid = NULL_OBJID);
   if(1&*EMmsg&sts)
    {
     OM_S_CHANSELECT to_comps;

     EMmake_chanselect(GRcmpowner_to_components, &to_comps);
     sts = om$send(msg = message Root.wild_disconnect(to_comps), 
           targetid = junkid[1].objid, targetos = junkid[1].osnum, 
           senderid = NULL_OBJID);
     sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, construct->env_info), 
           targetid = junkid[1].objid, targetos = junkid[1].osnum, 
           senderid = NULL_OBJID);
     *result = junkid[0].objid;
    }
  }
 else if(!id1_grp && !id2_grp)
   sts = EFbuild_graphic_group(2, NULL, junkid, construct, result, EMmsg);
 else if( (!id1_grp && id2_grp) || (id1_grp && !id2_grp))
  {
   struct GRid grpid, compid;
   IGRlong flag = 1, ownidx = MAXINT, gridx = MAXINT;

   grpid = id1_grp ? junkid[0] : junkid[1];
   compid = id1_grp ? junkid[1] : junkid[0];

   sts = om$send(msg = message GRconnector.GRflexconn(EMmsg, &flag, &grpid, 
         &ownidx, &gridx), targetid = compid.objid, targetos = compid.osnum, 
         senderid = NULL_OBJID);
   if(1&*EMmsg&sts) *result = grpid.objid;
  }

EMWRAPUP(*EMmsg, sts, "NMmerge_graphic_groups");
return(sts);
}

end implementation NMnonmani;
