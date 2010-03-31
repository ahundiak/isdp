class implementation Root;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "nmchandef.h"
#include "emserr.h"

%safe
static IGRint nm_chan_set = FALSE;
static OM_S_CHANNUM nm_channum[NUM_TOTAL_NM_CHANNELS];
static IGRboolean NMinit_chanselect();
%endsafe

IGRlong NMmake_chanselect (nm_chan_label, chan_sel)
IGRint nm_chan_label;
OM_S_CHANSELECT *chan_sel;
{
  if (nm_chan_label < 0 || nm_chan_label > NUM_TOTAL_NM_CHANNELS-1 ||
      (!nm_chan_set && !NMinit_chanselect()))
    return (OM_E_ABORT);

  chan_sel->type = OM_e_num;
  chan_sel->u_sel.number = nm_channum[nm_chan_label];
  return (OM_S_SUCCESS);
}

static IGRboolean NMinit_chanselect()
{
  IGRboolean stat_func;
  IGRlong stat_OM;
  OM_S_CHANSELECT chan;

  stat_func = TRUE;

  stat_OM = om$make_chanselect (channame = "NMvertex.to_vtx_uses",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  nm_channum[NMvertex_to_vtx_uses] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "NMinters.to_other_int",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  nm_channum[NMinters_to_other_int] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "NMvertex_use.to_vtx",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  nm_channum[NMvertex_use_to_vtx] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "NMlistedge.to_edges",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  nm_channum[NMlistedge_to_edges] = chan.u_sel.number;

  stat_OM = om$make_chanselect (channame = "NMlistvtxuse.to_edges",
             p_chanselect = &chan);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, stat_func, FALSE, ret_end);
  nm_channum[NMlistvtxuse_to_edges] = chan.u_sel.number;

  nm_chan_set = TRUE;

ret_end:
  if (!stat_func)
    fprintf (stderr, "NMinit_chanselect");
  return (stat_func);
}

end implementation Root;
