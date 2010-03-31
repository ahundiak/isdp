/* ###################   APOGEE COMPILED   ################## */
/*----

     CHANGE HISTORY:
	RC	12/04/86  : Creation date	
	RC	03/04/87  : Modified according to new design
        SS	25/08/87  : Changed the connect_edges flag to an options
                            mask to handle various other options See
                            EMSboundary-spec file.
        RC      10/28/87  : Modified for version 1.1
	SM	05-Jul-89 : Support EMS_COPY_ACTIVETOPOLOGY
---- */

class implementation EMSpartedge;

#include "EMS.h"

#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "EMcp.h"

method EMintcopy(
  IGRlong                  *EMmsg; 
  struct GRmd_env          *mdenv;
  GRspacenum               obj_osnum;
  GRspacenum               new_osnum;
  IGRushort        options; 
  GRobjid                  *newobjid;
  struct EMcp_info         *copy_info)
{

  IGRlong           OM_stat;
IGRlong   mthd_stat;
  GRobjid           edcp_id, botedge = NULL_OBJID;
  IGRuint   num_edges;	

  OM_S_CHANSELECT   edge_chan, edge_owner_chan;
  IGRboolean	    activeonly = FALSE, natural = FALSE;
  IGRushort locoptions = NULL;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  activeonly = options & EMS_COPY_ACTIVETOPOLOGY;
  natural = ME.EMSedge->ed_props & EMED_NATURAL;
  locoptions = options;

  /* The effect of EMS_COPY_ACTIVETOPOLOGY is same as EMS_COPY_PRIMEDGE for
     all edges except part natural edges. For part natural edges the former
     copies it and it's primitive natural edge (and connects the copies)
     while the later copies a part natural edge into the appropriate primitive
     edge type.
  */
  if(natural && activeonly)
   {
    locoptions &= ~EMS_COPY_ACTIVETOPOLOGY;
    locoptions &= ~EMS_COPY_PRIMEDGE;
   }
  else if(activeonly) locoptions |= EMS_COPY_PRIMEDGE;

   OM_stat = om$send (mode = OM_e_wrt_message,
		msg = message EMSedge.EMintcopy(&mthd_stat, mdenv,
                   obj_osnum, new_osnum, locoptions, newobjid, copy_info),
                targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_EdgeError,wrapup);

 if (! (locoptions & EMS_COPY_PRIMEDGE))
 {
    /*
     * find out if the edge I am part of, is already
     * copied or not. If so, connect my copy with the
     * copy of the edge I am a part of. Otherwise, send
     * a message to the edge.
     */

    OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &edge_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);

    /* 
     * the following channel count is done to avoid 
     * failure in case part edge is saved in state tree
     * that does not own another edge. This should be taken
     * out as soon the necessary changes are made such
     * that there exists any part edge which does not own a
     * edge (part edge or edge).
     */
    
    if(natural && activeonly)
     {
      OM_stat = om$send(msg = message EMSedge.EMget_bottom_edge(&mthd_stat, 
				&botedge), targetid = my_id);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);
      if(IF_NULL_OBJID(botedge)) {*EMmsg = EMS_E_Fail; goto wrapup;}
      num_edges = 1;
     }
    else
     {
      OM_stat = om$get_channel_count(object = me, p_chanselect = &edge_chan,
                                   count = &num_edges);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);
     }

    if (num_edges)
    {	
     if(natural && activeonly)
       OM_stat = om$send (msg = message EMSboundary.EMintcopy (
		       &mthd_stat, mdenv, obj_osnum, new_osnum, options,
                       &edcp_id, copy_info), targetid = botedge);
     else
      OM_stat = om$send (msg = message EMSboundary.EMintcopy (
		       &mthd_stat, mdenv, obj_osnum, new_osnum, options,
                       &edcp_id, copy_info),
                 p_chanselect = &edge_chan, from = 0, to = 0);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_EdgeError,wrapup);

      /*
       * since the index of an owner object (part edge or
       * a loop ) from the edge point is irrelevent. The
       *  owner is always inserted at the 0 index from the
       * edge point of view. 
       */
		 
      OM_stat = EMmake_chanselect (EMSedge_to_owner, &edge_owner_chan);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);

      OM_stat = om$send(msg = message Root.connect (edge_chan, 0,
                         edcp_id, new_osnum, edge_owner_chan, 0),
                    targetid = *newobjid, targetos = new_osnum);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror,wrapup);

    } /* if (num_edges) */

 } /* if (! (options & EMS_COPY_PRIMEDGE)) */

wrapup:

   EMWRAPUP (*EMmsg, OM_stat, "In EMSpartedge.EMintcopy");

   return(OM_stat);
}

end implementation EMSpartedge;
