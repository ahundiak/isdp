class implementation SKground;

#include "emsdebug.h"

#define FIRST  0
#define SECOND 1

#define SOLVED -1

method SKmakejacobian (IGRlong *msg; IGRushort options;
                       struct SKsolvevars *solvedvars, *unsolvedvars;
                       IGRdouble *jacobian; IGRdouble *funcval)
{
  IGRboolean adjreq, accreq, seconddim;
  IGRint duminx, varinx;
  OMuint count;
  IGRlong stat_OM;
  IGRdouble var;
  GRobjid varobj;
  struct SKsolvevars *varnode;
  OM_S_OBJECT_LINKAGE objlist;
  OM_S_CHANSELECT chan_to_vars;
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  count = 0;
  om$get_channel_objects (p_chanselect = &chan_to_vars, object = me,
   size = 1, count = &count, list = &objlist);
  EMerr_hndlr (count != 1, *msg, EMS_E_InvalidCase, ret_end);
  varobj = objlist.S_objid;

  /*
   * Determine the unknown variable in this constraint and obtain the index.
   * Also, find out the current values of the involved variable (both
   * known and unknown).
   */

  seconddim = options & SK_JACOB_GROUND_SECDIM;
  if (SKvarlistinx (unsolvedvars, varobj,
       seconddim ? VAR_SECONDDIM : VAR_FIRSTDIM, &varnode, &varinx))
    var = varnode->var[seconddim ? SECOND : FIRST];
  else
    {
    varinx = SOLVED;
    if (SKvarlistinx (solvedvars, varobj, 
         seconddim ? VAR_SECONDDIM : VAR_FIRSTDIM, &varnode, &duminx))
      var = varnode->var[seconddim ? SECOND : FIRST];
    else
      {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
    }

  /*
   * Plug in the appropriate values in the row of the Jacobian matrix
   */

  adjreq = options & SK_JACOB_ADJACENCY;
  accreq = options & SK_JACOB_ACCURACY;

  if (jacobian)
    {
    if (varinx != SOLVED)
      jacobian[varinx] = adjreq ? TRUE : 1;
    }

  if (funcval)
    *funcval = 0;

  DEBUG_REPORT (accreq, "Ground residual", my_id, 0.0);

ret_end:
  EMWRAPUP(*msg, stat_OM, "SKground.SKmakejacobian");
  return (stat_OM);
}

end implementation SKground;
