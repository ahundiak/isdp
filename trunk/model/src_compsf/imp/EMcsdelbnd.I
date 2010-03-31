/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#define SURF_BUF	1
#else
#define SURF_BUF	20
#endif

#include "OMmacros.h"
#include "emsdef.h"

method EMdelete_boundary(IGRlong *EMmsg; struct GRmd_env *env;
			 struct GRid *md_id;
			 struct GRid *surfid)
{
 IGRlong		sts;
 IGRint			num_surfs, surfs_returned, i;
 struct GRid		*surfs, static_buf[SURF_BUF], owner_GRid;
 OM_S_CHANSELECT	to_owners;
 IGRshort		surf_props;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 surfs = NULL;
 num_surfs = 0;

 /*
   Collect all my leaf nodes (single surfaces)
 */

 sts = om$send(msg = message GRowner.GRget_number_components
                                (EMmsg, &num_surfs), 
                        targetid = my_id);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

 if(num_surfs > SURF_BUF)
  surfs = (struct GRid *) om$malloc(size = num_surfs * sizeof(struct GRid));
 else 
  surfs = static_buf;
 EMerr_hndlr(!surfs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$send(msg = message GRowner.GRget_components
                        (EMmsg, env, surfs, num_surfs, &surfs_returned, 
			 0, MAXINT), targetid = my_id);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
 EMerr_hndlr(surfs_returned != num_surfs, *EMmsg, EMS_E_Fail, wrapup);
 
 sts = EMmake_chanselect (GRconnector_to_owners, &to_owners);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

 /* Disconnect all the surfaces from their owners so that GRdelete
    message (to be sent to me does not hit them). Leave the surfaces that
    are currently non displayable/locatable, for them to be deleted.
 */
 for(i=0; i<num_surfs; i++)
  {
   surf_props = NULL;
   sts = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &surf_props), 
			targetid = surfs[i].objid, targetos = surfs[i].osnum);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

   if( (surf_props & GRIS_DISPLAYABLE) &&
       (surf_props & GRIS_LOCATABLE))
    {
     sts = om$get_objid_at_index(objid = surfs[i].objid, 
				 osnum = surfs[i].osnum, 
				 index = 0, 
				 objidaddr = &owner_GRid.objid, 
				 osnumaddr = &owner_GRid.osnum, 
				 p_chanselect = &to_owners);
     if(1&sts)
      {
       sts = om$send (msg = message GRconnector.GRdisconn
                    (EMmsg, &owner_GRid), 
                     targetid = surfs[i].objid, senderid = owner_GRid.objid, 
		     targetos = surfs[i].osnum);
      }
    }
   else surfs[i].objid = NULL_OBJID;
  }

 sts = om$send(msg = message GRgraphics.GRdelete(EMmsg, env), 
				targetid = my_id);
 EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

 /* Send the EMdelete_boundary message down to each surface. The override
    for EMSsubbs will delete all the topology and return.
 */
 for(i=0; i<num_surfs; i++)
  {
   if(!IF_NULL_OBJID(surfs[i].objid))
    {
     sts = om$send(msg = OPPmargs, targetid = surfs[i].objid, 
		 targetos = surfs[i].osnum);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);
    }
  }

wrapup:
if(surfs && (surfs != static_buf))
 om$dealloc(ptr = surfs);

EMWRAPUP(*EMmsg, sts, "In EMScompsurf.EMdelete_boundary");
return(sts);
}

end implementation EMScompsurf;
