/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
  DESCRIPTION

    This function is intended as a replacement for the om$make_chanselect
    call throughout EMS-code. The idea is to speed up "making" a channel.
    Studies have shown that this call is atleast 10 times as fast as
    the om$make_chanselect.

    The static data is initialized the first time this call is made.

  HISTORY

    SS  :  10/11/88  :  Creation
*/

class implementation Root;

//%safe
#include <math.h>
//%endsafe

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "emserr.h"
#include "emsdef.h"

%safe
static IGRint chan_set = FALSE;
static IGRboolean EMinit_chanselect();
%endsafe

/* made channum a global so that EMmake_nonmds_chanselect could call it. */
OM_S_CHANNUM channum[NUM_TOTAL_EMS_CHANNELS];

IGRlong EMmake_chanselect (chan_label, chan_sel)
IGRint chan_label;
OM_S_CHANSELECT *chan_sel;
{
  if (chan_label < 0 || chan_label > NUM_TOTAL_EMS_CHANNELS-1 ||
      (!chan_set && !EMinit_chanselect()))
    return (OM_E_ABORT);

  chan_sel->type = OM_e_num;
  chan_sel->u_sel.number = channum[chan_label];
  return (OM_S_SUCCESS);
}

static IGRboolean EMinit_chanselect()
{
  IGRboolean stat_func;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan;

  stat_func = TRUE;

  stat_OM = om$make_chanselect (channame = "GRconnector.to_owners",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[GRconnector_to_owners] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "GRcmpowner.to_components",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[GRcmpowner_to_components] = chan.u_sel.number;


  stat_OM = om$make_chanselect (channame = "GRnotify.notification",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[GRnotify_notification] = chan.u_sel.number;

  /* call EMinit_model_chanselect() - this should be stubbed out in MDS */

  stat_func = EMinit_model_chanselect();
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);


  stat_OM = om$make_chanselect (channame = "NDfather.father",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[NDfather_father] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "NDchildren.children",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[NDchildren_children] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKconstraint.to_mgr",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKconstraint_to_mgr] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKconstraint.to_variables",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKconstraint_to_variables] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKconstraint.to_super_constrs",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKconstraint_to_super_constrs] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKgeometry.to_defpts",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKgeometry_to_defpts] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKinterface.to_member_constrs",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKinterface_to_member_constrs] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKmgr.to_vars",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKmgr_to_vars] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKmgr.to_constrs",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKmgr_to_constrs] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKvariable.to_constraints",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKvariable_to_constraints] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKvariable.to_geometries",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKvariable_to_geometries] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "SKvariable.to_mgr",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[SKvariable_to_mgr] = chan.u_sel.number;

#ifndef BASE_EMS

  stat_OM = om$make_chanselect (channame = "module.primary",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[module_primary] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "GRgrset.to_owners",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[GRgrset_to_owners] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "ci_executor.to_graphic",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  channum[ci_executor_to_graphic] = chan.u_sel.number;
#endif // #ifndef BASE_EMS

  chan_set = TRUE;

ret_end:
  if (!stat_func)
    fprintf (stderr, "EMinit_chanselect");
  return (stat_func);
}

end implementation Root;
