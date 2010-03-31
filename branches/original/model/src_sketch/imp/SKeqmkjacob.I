class implementation SKequal;

%safe
#include <math.h>
%endsafe
#include "emsdebug.h"

#define SOLVED -1

#define FIRST  0
#define SECOND 1

#define A 0
#define B 1

#define VAL 0

extern GRclassid OPP_SKfixang_class_id, OPP_SKrelang_class_id;

method SKmakejacobian (IGRlong *msg; IGRushort options;
                       struct SKsolvevars *solvedvars, *unsolvedvars;
                       IGRdouble *jacobian; IGRdouble *funcval)
{
  IGRboolean adjreq, accreq;
  IGRint i, duminx, varinx[2];
  OMuint count;
  IGRlong stat_OM;
  IGRdouble var[2], diff_value = 0.0, tol;
  GRobjid varobjs[2];
  GRclassid varclass;
  struct SKsolvevars *varnode;
  OM_S_OBJECT_LINKAGE objlist[2];
  OM_S_CHANSELECT chan_to_vars;
  extern IGRboolean SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  om$get_channel_objects (p_chanselect = &chan_to_vars, object = me,
   size = 2, count = &count, list = objlist);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);
  varobjs[A] = objlist[FIRST].S_objid;
  varobjs[B] = objlist[SECOND].S_objid;

  /*
   * Determine the unknown variables in this equality and obtain their indices.
   * Also, find out the current values of the involved variables (both
   * known and unknown).
   */

  for (i=A; i<=B; i++)
    {
    if (SKvarlistinx (unsolvedvars, varobjs[i], VAR_PSEUDO_VAL,
         &varnode, &varinx[i]))
      var[i] = varnode->var[VAL];
    else
      {
      varinx[i] = SOLVED;
      if (SKvarlistinx (solvedvars, varobjs[i], VAR_PSEUDO_VAL,
           &varnode, &duminx))
        var[i] = varnode->var[VAL];
      else
        {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
      }
    }

  /*
   * Plug in the appropriate values in the row of the Jacobian matrix
   */
   /** accreq was mistakenly assigned to SK_JACOB_ADJACENCY . Corrected
	the same in EMS 3.2 -- TR# 119526290 and TR# 119526072 - Satya **/

  adjreq = options & SK_JACOB_ADJACENCY;
  accreq = options & SK_JACOB_ACCURACY;

  if (jacobian)
    {
    if (varinx[A] != SOLVED)
      jacobian[varinx[A]] = adjreq ? TRUE : 1;
    if (varinx[B] != SOLVED)
      jacobian[varinx[B]] = adjreq ? TRUE : -1;
    }

  if (funcval)
    *funcval = -(var[A] - var[B]);

  if (accreq)
    diff_value = fabs (var[A] - var[B]);

  /*
   * If the option to check accuracy was set then obtain the relevant
   * tolerances and check.
   */

  if (accreq)
    {
    om$get_classid (objid = varobjs[A], p_classid = &varclass);
    if (om$is_ancestry_valid (superclassid = OPP_SKrelang_class_id,
         subclassid = varclass) == OM_S_SUCCESS ||
        om$is_ancestry_valid (superclassid = OPP_SKfixang_class_id,
         subclassid = varclass) == OM_S_SUCCESS)
      SKgettol (NULL, &tol);
    else
      SKgettol (&tol, NULL);
    if (diff_value > tol)
      *msg = EMS_I_OutOfBounds;
    }

  DEBUG_REPORT (accreq, "Equal residual", my_id, diff_value);

ret_end:
  EMWRAPUP(*msg, stat_OM, "SKequal.SKmakejacobian");
  return (stat_OM);
}

end implementation SKequal;
