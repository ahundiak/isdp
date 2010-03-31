/* #################   APOGEE  COMPILED   ######################### */
/*----

History:
    RC    12/04/86  : Creation date
    RC    1/09/87   : added functionality for the state tree copy
    RC    03/04/87  : Modified according to new design
    AIC   04/09/87  : Add send EMascopy to assocations
    SS	  08/24/87  : Changed connect_edges flag to an options mask.
                      See EMSboundary-spec file.
    RC    10/28/87  : Modified for version 1.1.0
    SS    07/27/88  : Added support for copy of model-space
		      counterparts.
    WBC   04/03/91  : Modified to support changes to model-space counterparts.
----- */

class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMcp.h"
#include "EMSobjmgrdef.h"

extern GRclassid OPP_EMSloop_class_id, OPP_EMSshobjmgr_class_id;

from EMShelper      import EMhelperCopy;
from GRlistener     import GRnotifylis;

method EMintcopy(
  IGRlong 			*EMmsg; 
  struct GRmd_env 		*mdenv;
  GRspacenum 			obj_osnum, new_osnum; 
  IGRushort 		options; 
  GRobjid 			*newobjid;
  struct EMcp_info 		*copy_info)
{

    IGRlong  		OM_stat, mthd_stat, mask = GR_COPIED;
    IGRboolean 		lp_copy_exists, cpmsc, mscexists;
    GRobjid  		edge_id, inlpcp_id; 

    IGRushort 	props, t_props, replace_options;	
    IGRuint 	count, edcount;

    IGRint i;                   

    OM_S_CHANSELECT 	lp_edge_chan, edge_lp_chan, lp_inlp_chan,
			inlp_lp_chan;
    extern void		EMcpsearch();

    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

    /*
     * find out if I have been already copied or not.
     * If so, return my counter part's objid and I am 
     * all done
     */
    
    EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
		&lp_copy_exists);
    EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

    if (lp_copy_exists) goto wrapup;

    /* construct and copy the loop object */
    
    if (options & EMS_COPY_XYZ)
    {
      t_props = EMLP_NATURAL | EMLP_SPLIT;
      props = ((ME.EMSloop->lp_props & (~t_props))) | EMLP_XYZ;

      OM_stat = om$construct (msg = message EMSloop.EMset_props (
		 &mthd_stat, props, EMS_O_SET), 
		 classid = OPP_EMSloop_class_id,
                 osnum = new_osnum, p_objid = newobjid);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
    }
    else
    {
      /*
       * During the construct and copy, do not copy the property bit
       * indicating existence of model-space coutnerparts. This is
       * set only after successful creation of a copy MSC, later.
       */

      if (mscexists = ME.EMSloop->lp_props & EMLP_MSCEXISTS)
           ME.EMSloop->lp_props &= ~EMLP_MSCEXISTS;

      OM_stat = om$construct_and_copy(object = me, obj_osnum = obj_osnum,
                   osnum = new_osnum, p_objid = newobjid);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      if (mscexists)
        ME.EMSloop->lp_props |= EMLP_MSCEXISTS;
    }

    /*
     * put my_id and my counter part's id in the copy_info
     */

    EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3,
                &lp_copy_exists);
    EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

    /*
     * copy the inner loops
     */
    
    OM_stat = EMmake_chanselect (EMSloop_to_inner, &lp_inlp_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
    
    OM_stat = om$get_channel_count(object = me, 
			p_chanselect = &lp_inlp_chan, count = &count);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if (count > 0)
    {
      OM_stat = EMmake_chanselect (EMSloop_to_outter, &inlp_lp_chan);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      for (i = 0; i < count ; i++)
      {
        OM_stat = om$send(msg = message EMSboundary.EMintcopy
                    (&mthd_stat, mdenv, obj_osnum, new_osnum, options,
                     &inlpcp_id, copy_info),
                    senderid = my_id, p_chanselect = &lp_inlp_chan,
                    from = i, to = i);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
        
        OM_stat = om$send(msg = message Root.connect (lp_inlp_chan,
                     0, inlpcp_id, new_osnum, inlp_lp_chan, i),
                  targetid = *newobjid, targetos = new_osnum);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      } /* for (i = 0; i < count ; i++) */
 
   } /* if (count > 0) */


  /*
   * If this loop had a model-space counterpart, it should be copied
   * and attached to the copy of this loop. But if such action is expressly
   * inhibited by an option or this copy is intended for a copy of this
   * loop into model-space or if the new object space is not the current
   * object space or if the module environmemt passed in is NULL, then this
   * process is not performed.
   */

  if (ME.EMSloop->lp_props & EMLP_MSCEXISTS &&
      !(options & EMS_COPY_NOMSC) &&
      !(options & EMS_COPY_XYZ) &&
      obj_osnum == new_osnum && obj_osnum == OM_Gw_current_OS &&
      mdenv)
    cpmsc = TRUE;
  else
    cpmsc = FALSE;


    /*
     * copy edges/subedges
     */

    OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_edge_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
    
    OM_stat = om$get_channel_count(object = me,
                        p_chanselect = &lp_edge_chan, count = &edcount);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    OM_stat = EMmake_chanselect (EMSedge_to_owner, &edge_lp_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    replace_options = options;
    if (cpmsc)
      replace_options |= EMS_COPY_NOMSC;
     
    for (i = 0; i < edcount ; i++)
    {
        OM_stat = om$send(msg = message EMSboundary.EMintcopy
                     (&mthd_stat, mdenv, obj_osnum,
                     new_osnum, replace_options, &edge_id, copy_info),
                    senderid = my_id, p_chanselect = &lp_edge_chan,
                    from = i, to = i);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
        
        OM_stat = om$send(msg = message Root.connect (lp_edge_chan,
                     0, edge_id, new_osnum, edge_lp_chan, i),
                  targetid = *newobjid, targetos = new_osnum);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    } /* for (i = 0; (i < edcount ; i++) */

    /*
     * Set the correct range for this loop's copy in case this loop
     * was copied in the model space.
     */

    if (options & EMS_COPY_XYZ)
    {
      OM_stat = om$send (msg = message EMSloop.EMsetrange (&mthd_stat),
                 targetid = *newobjid, targetos = new_osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_LoopError,wrapup);
    }
    
   /*
    * if the model space loop was created during copy process,
    * send EMascopy message across its notification channel
    */

   if (! (options & EMS_COPY_XYZ))
   {
      struct GRid       copy_GRid;
      OM_S_CHANSELECT   chan;

      copy_GRid.objid = *newobjid;
      copy_GRid.osnum = new_osnum;
      OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &chan);
      if(! (1 & *EMmsg & OM_stat)) goto wrapup;
      OM_stat = om$send(msg = message EMShelper.EMhelperCopy(EMmsg,
                        &copy_GRid, copy_info), p_chanselect=&chan);
      if(! (1 & *EMmsg & OM_stat)) goto wrapup;

      OM_stat = EMmake_chanselect (GRnotify_notification, &chan);
      if(! (1 & *EMmsg & OM_stat)) goto wrapup;
      OM_stat = om$send(msg = message GRlistener.GRnotifylis(EMmsg,
                        &OM_stat, &mask, OPPmargs),p_chanselect = &chan);
      if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    }

  if (cpmsc)
    {
/*    GRobjid mscobj;  */

    mthd_stat = EMS_S_Success;

    /* create an associative model-space counterpart for the created (new)
     * loop
     */
/* KLUDGE:
 * can't try to create the model-space counterpart yet since the loop is not
 * connected to its loopset, etc. which means the parent of the msc cannot
 * be determined; hopefully we'll be able to do this through the
 * NDcopy mechanism, whenever that's implemented
    OM_stat = om$send(msg = message EMSboundary.EMgetxyzobj(&mthd_stat, NULL,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &mscobj),
                      targetid = *newobjid,
                      targetos = new_osnum);

    if (! (mthd_stat & 1))
      *EMmsg = EMS_E_Fail;
 */
    }

wrapup:
    EMWRAPUP (*EMmsg, OM_stat, "EMSloop.EMintcopy");
    return(OM_stat);
}

end implementation EMSloop;
