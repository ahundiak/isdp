/*
  DESCRIPTION

    This function is intended as a replacement for the om$make_chanselect
    call throughout EMS-code. The idea is to speed up "making" a channel.
    Studies have shown that this call is atleast 10 times as fast as
    the om$make_chanselect.

    The static data is initialized the first time this call is made.

  HISTORY

    SRH :  02/06/92 :  created  for MODEL compiles.  Must be stubbed out
	               for MDS builds since these classes are not in MDS.
*/

class implementation Root;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "emserr.h"
#include "emsdef.h"

IGRboolean EMinit_model_chanselect()
{
  IGRboolean stat_func;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan;
  extern OM_S_CHANNUM channum[];
  stat_func = TRUE;


  stat_OM = om$make_chanselect (channame = "EMSrequester.to_helpers",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSrequester_to_helpers] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMShelper.to_requesters",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMShelper_to_requesters] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSsubbs.to_loopset",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSsubbs_to_loopset] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSloopset.to_surface",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSloopset_to_surface] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSloopset.to_loops",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSloopset_to_loops] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSloop.to_outter",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSloop_to_outter] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSloop.to_inner",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSloop_to_inner] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSbd_owner.to_comps",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSbd_owner_to_comps] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSedge.to_owner",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSedge_to_owner] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSedge.to_common_edge",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSedge_to_common_edge] = chan.u_sel.number;

/****************feature loops gone 10/25/91
  stat_OM = om$make_chanselect (channame = "EMSfeaturelp.to_surface",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSfeaturelp_to_surface] = chan.u_sel.number;
**********************************/

#ifndef BASE_EMS

  stat_OM = om$make_chanselect (channame = "EMScleaner.to_objmgr",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMScleaner_to_objmgr] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSobjmgr.to_cleaner",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSobjmgr_to_cleaner] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSshovflow.to_shobjmgr",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSshovflow_to_shobjmgr] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSshobjmgr.to_overflow",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSshobjmgr_to_overflow] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSxsection.to_model",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSxsection_to_model] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "EMSsfspltwsf.to_mirror_image",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[EMSsfspltwsf_to_mirror_image] = chan.u_sel.number;

#endif // #ifndef BASE_EMS

ret_end:
  if (!stat_func)
    fprintf (stderr, "EMinit_model_chanselect");
  return (stat_func);
}

end implementation Root;
