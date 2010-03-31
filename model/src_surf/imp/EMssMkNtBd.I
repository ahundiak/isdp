/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>

# ifndef msdef_include
# include "msdef.h"         /* MS message codes     */
# endif

# include "EMSbnddef.h"
# include "emsmacros.h"
# include "EMSopt.h"
# include "EMSfrtdef.h"

extern  OMuword  OPP_EMSloopset_class_id, OPP_EMSnatedge_class_id;

from EMSloopset import EMmake_natural_loopset;
from EMSgradata import EMget_class_info, EMinit, EMset_props;

method EMmk_nat_bdry (
    IGRlong                     *EMmsg;
    struct GRmdenv_info         *md_env;
    GRobjid                     *edge_ids)

/*
Description
        This method creates a natural boundary of the surface.
        The following properties of natural edges are checked
        by default:

         EMED_DEGENERATE
         EMED_XYZ_CLOSED
         EMED_SEAM
         EMED_REVERSE_CONNECT

        It is assumed that only EDGEU0 and EDGEU1 natural edges pair
        and EDGEV0 and EDGEV1 natural edges pair are 
        valid seam edge pairs.
        Also, if a pair of natural edges are seam edges, they are
        reverse connected too.

Arguments
        EMmsg   -- output
                   EMS_S_Success        if successful
                   EMS_E_LoopsetError   if failure in making a natural
                                        loopset.
                   EMS_E_OMerror        if failure in an om call.
                   EMS_I_InvalidSend    if surface already had a loopset.
        md-env  -- input
                module environment info of the surface.

        edge_ids -- output
                An array of objids of the edges constructed.
                If the caller needs th edge ids back, the memory
                should be allocated for this array. The array should
                be large enough to hold four objids.
                If the edge ids are not needed, the caller should
                pass NULL.

        
Algorithm
        1. Get the curve_type and edge properties of natural 
           edges to be construected. The properties that are
           evaluated correspond to model space. These
           are EMED_DEGENERATE, EMED_XYZ_CLOSED , EMED_SEAM.
           If EMED_SEAM is on, EMED_REVERSE_CONNECT is also set
           to true.
        2.construct a loopset object.
        3. send EMmake_natural_loopset message to
           the constructed loopset.
        4. connect the loopset to the surface.

Return Values
    
History
        RC     12/09/86 : Creation date.
        RC     09/15/87 : Check if there is a cross-hatch
                          frt. If so, connect it to the
                          natural loop.
        RC     11/08/87 : Changed arguments and code.
        DLB    05/25/89 : Check for existing loopset and return
                          EMS_I_InvalidSend.
        DLB    06/02/91 : Support creator id.
        Jack   06/05/91 : Modified to return existing natural edges as
                          long as edge_ids was not passed in as NULL. 
                          Will still return EMS_I_InvalidSend in this
                          case in order to not break anything else. (see
                          change by DLB 05/25/89.) 
        DLB    06/17/91 : Removed setting of current_creator.
        Jack   06/24/91 : Initialized edge_GRids to NULL;
        NP     08/25/92 : Modified for ANSI compliance. Changed "count" to "IGRuint".

*/

{

IGRlong                 OM_stat;
IGRlong   mthd_stat;
IGRuint                 count;
IGRint                  array_size,
                        num_edges,
                        i;
IGRuchar	        curve_type[4];
IGRushort	        edge_props[4];
GRobjid                 ls_id;
OMuword                 frt_classid;
OM_S_CHANSELECT         sf_ls_chan, ls_sf_chan, to_helpers;
struct GRid            *edge_GRids = NULL;



OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

sf_ls_chan.type = OM_e_addr;
sf_ls_chan.u_sel.addr = &ME.EMSsubbs->to_loopset;

/*Added by DLB 5/25/89.*/
om$get_channel_count(object = me,
                     p_chanselect = &sf_ls_chan,
                     count = &count);

/* return the existing natural edges if the caller wants them. 
   If there are only 4 edges, return them whether they are natural or
   not.
*/ 
if (count)
{
  IGRboolean nonnat = FALSE;

  if(edge_ids)
  {
   IGRlong option = NULL;


   edge_GRids = NULL; 
   array_size = 0;
   num_edges = 0; 

   OM_stat = om$send (msg = message EMSsubbs.EMget_edges( 
                                            &mthd_stat,
                                             MAXINT,
                                             EMS_OPT_ALL,
                                             NULL,          
                                             NULL, 
                                             NULL, 
                                            &num_edges),
                      senderid = my_id,
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 

   if(num_edges != 4) option = EMS_OPT_NATURAL;
   else option = NULL;
   num_edges = 0; 
   OM_stat = om$send (msg = message EMSsubbs.EMget_edges( 
                                            &mthd_stat,
                                             MAXINT,
                                             option,
                                             NULL,          
                                            &edge_GRids,
                                            &array_size,
                                            &num_edges),
                      senderid = my_id,
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 

   for(i=0; i < 4; i++)
    {
     edge_ids[i] = edge_GRids[i].objid;

     if( (option != EMS_OPT_NATURAL) &&
         (!EFisAncestryValid(&mthd_stat, edge_ids[i], OM_Gw_current_OS, 
	 OPP_EMSnatedge_class_id, TRUE)))
       nonnat = TRUE;
    }
  }

 if(nonnat) *EMmsg = EMS_I_Fail;
 else *EMmsg = EMS_I_InvalidSend;

}
else
{
  
  /*
   * construct a loopset, send it a message to construct
   * a natural loop, natural edges and connect it my self
   */

  OM_stat = om$send (msg = message EMSsubbs.EMget_natedge_info (&mthd_stat,
                      md_env, curve_type, edge_props), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_SurfaceError,wrapup);

  OM_stat = om$construct (classid = OPP_EMSloopset_class_id,
              p_objid = &ls_id, 
              msg = message EMSloopset.EMmake_natural_loopset( &mthd_stat,
                   curve_type, edge_props, edge_ids));
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 

  OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message Root.connect (ls_sf_chan,
                     NULL, my_id, OM_Gw_current_OS, sf_ls_chan, NULL),
                    targetid = ls_id);
  EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

  /*
   * If there is a cross-hatch frt already connected to the
   * surface, connect it to the natural loop
   */

  to_helpers.type = OM_e_addr;
  to_helpers.u_sel.addr = &me^^EMSrequester.to_helpers;

  mthd_stat = EMS_I_NoResponse;
  OM_stat = om$send(msg = message EMSgradata.EMget_class_info(&mthd_stat,
                    &frt_classid, NULL), p_chanselect = &to_helpers);
  if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  if (mthd_stat != EMS_I_NoResponse)
  {
    OM_S_CHANSELECT       ls_lp_chan;
    OM_S_OBJID            lp_id;
    OMuword               lp_os;

    OM_stat = EMmake_chanselect (EMSloopset_to_loops, &ls_lp_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$get_objid_at_index (objid = ls_id, 
                  p_chanselect = &ls_lp_chan,
                  index = NULL, objidaddr = &lp_id, osnumaddr = &lp_os);
    EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);
 
    OM_stat = om$send (msg = message EMSgradata.EMinit (&mthd_stat,
                          NULL_OBJID, lp_id), p_chanselect = &to_helpers);
    if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    /*
     * Since a natural loopset is attached to the surface, the clip
     * information of the graphic data object should still be valid.
     * Reset the graphic data to uptodate.  -- RC 1/03/90
     */

    OM_stat = om$send (msg = message EMSgradata.EMset_props (&mthd_stat,
                        EMGD_UPTODATE, EMS_O_ON),
                       p_chanselect = &to_helpers);
    if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
  
  } /* if (mthd_stat != EMS_I_NoResponse) */
} /* else */
wrapup:
  if (edge_GRids)   om$dealloc (ptr = edge_GRids);
  EMWRAPUP (*EMmsg, OM_stat, "In EMSsubbs.EMmk_nat_bdry");
  return (OM_stat);
}
end implementation EMSsubbs;
