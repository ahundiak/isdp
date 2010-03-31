/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include <stdio.h>
#include "EMSopt.h"
#include "emserr.h"
#include "emsmacros.h"

method EMconnect_edges(
        IGRlong                 *EMmsg; 
        IGRushort       props;
        IGRboolean              tst_reversibility;
        GRobjid                 partner_id,
                                my_srf_id,
                                partner_srf_id;
        struct GRmdenv_info     *md_env)
/*
History

        AIC     02/27/87        Creation date
        RC      03/23/87        Changed arguments to include
                                option to test reversibility and
                                to allow the caller to be able to
                                pass the surface ids.
	RV	02/25/88	Separated tst_reversibility into a
				method and added code to check for
				existing connection with inactive
				edge.
				
*/
{
  IGRlong               OM_stat;
IGRlong   mthd_stat;
IGRlong   rc;
OMuint    count; 
  GRobjid		ex_mate_id, loop_id;
  OM_S_CHANSELECT       to_common_edge;
  IGRushort     partner_props;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
  EMerr_hndlr(!(1&OM_stat), *EMmsg,EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count(object = me, 
		p_chanselect = &to_common_edge, count = &count);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  if (count)
  {
	   OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
					 &ex_mate_id),
				senderid = my_id,
				p_chanselect = &to_common_edge);
           EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

	   loop_id = NULL_OBJID;
	   OM_stat = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg,
					&loop_id),
			ex_mate_id, 0, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
	   EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

	   if (loop_id == NULL_OBJID)
	   {
	     OM_stat = om$send(msg = message Root.disconnect(to_common_edge,
			 my_id, OM_Gw_current_OS, to_common_edge),
		 targetid = ex_mate_id);
	     EMerr_hndlr(!(1&OM_stat), *EMmsg,EMS_E_OMerror, wrapup);
	   }
	   else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
  }
  OM_stat = om$get_channel_count(objid = partner_id,
		p_chanselect = &to_common_edge, count = &count);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  if (count)
  {
	   OM_stat = om$send(msg = message EMSboundary.EMget_objid(EMmsg,
					 &ex_mate_id),
				senderid = partner_id,
				p_chanselect = &to_common_edge);
           EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

	   loop_id = NULL_OBJID;
	   OM_stat = EMsend_loops(&rc, message EMSboundary.EMget_objid(EMmsg,
					&loop_id),
			ex_mate_id, 0, OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
	   EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

	   if (loop_id == NULL_OBJID)
	   {
	     OM_stat = om$send(msg = message Root.disconnect(to_common_edge,
			 partner_id, OM_Gw_current_OS, to_common_edge),
		 targetid = ex_mate_id);
	     EMerr_hndlr(!(1&OM_stat), *EMmsg,EMS_E_OMerror, wrapup);
	   }
	   else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
   }

  OM_stat = om$send(msg = message Root.connect(to_common_edge, 0, my_id,
	OM_Gw_current_OS, to_common_edge, 0), targetid = partner_id);
  EMerr_hndlr(!(1&OM_stat), *EMmsg,EMS_E_OMerror, wrapup);

  /*
   * perform reversibility test if requested 
   * by the user.
   */

  if (tst_reversibility)
  {
   IGRboolean 		 rev_connect;
   struct GRmd_env       mod_info;

   mod_info.md_env = *md_env;
   mod_info.md_id.osnum = 2;
   mod_info.md_id.objid = 0;

   OM_stat = om$send (msg = message EMSedge.EMtst_reversibility(&mthd_stat,
					&rev_connect, partner_id,
					my_srf_id, partner_srf_id,
					props & EMED_SEAM,
					&mod_info),
			targetid = my_id);
   EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
   
   if (rev_connect) props |= EMED_REVERSE_CONNECT;
   else props &= ~EMED_REVERSE_CONNECT;
  }

	
/*
 * get my partner's edge property. Set my EMIS_SUBORDINATE property
 * bit to true while that of my partner's to false.
 * If I am reversed, set mine as well as my partner's reversibility
 * property bit to true. Otherwise, set it to false for both of us.
 * If the incoming props state that I am a seam edge, the mine
 * as well as my partner's seam proptery bit to true. Otherwise
 * set to false for me as well as my partner.
 */

 OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                      &partner_props), targetid = partner_id);
 EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

if(ME.EMSedge->ed_props & EMED_NATURAL)
{
  ME.EMSedge->ed_props &= ~EMED_SUBORDINATE;
  partner_props |= EMED_SUBORDINATE;
}
else
{
  ME.EMSedge->ed_props |= EMED_SUBORDINATE;
  partner_props &= ~EMED_SUBORDINATE;
}
/*
if(me->ed_props & EMED_MSCEXISTS) partner_props |= EMED_MSCCOMMON;
else if(partner_props & EMED_MSCEXISTS) me->ed_props |= EMED_MSCCOMMON;
*/
if(props & EMED_REVERSE_CONNECT)
{
   ME.EMSedge->ed_props |= EMED_REVERSE_CONNECT;
   partner_props |= EMED_REVERSE_CONNECT;
}
else 
{  
   ME.EMSedge->ed_props &= ~EMED_REVERSE_CONNECT;
   partner_props &= ~EMED_REVERSE_CONNECT;
}

if (props & EMED_SEAM)
{
    ME.EMSedge->ed_props |= EMED_SEAM;
    partner_props |= EMED_SEAM;
}
else /* Not a seam */
{
    ME.EMSedge->ed_props &= ~EMED_SEAM;
    partner_props &= ~EMED_SEAM;
}

OM_stat = om$send(msg = message EMSedge.EMset_props( &mthd_stat,
                   partner_props, EMS_O_SET),
                  targetid = partner_id);
EMerr_hndlr(!(1&OM_stat& mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"In EMSedge.EMconnect_edges")
  return(OM_stat);

}

end implementation EMSedge;
