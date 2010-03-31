class implementation SKvalvar;

#include <string.h>

#define STATIC_MAX_NUMLEN 40

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKasvlgrnd_class_id;

from SKmgr import SKgetvarconstrs;
from SKasvlgrnd import SKinit_assocvl_ground;

/**
DLB	10/23/91	Pass short msg_loc to expression.create instead
			of long msg_loc.  SUN problem.
**/

method SKinit (IGRlong *msg; IGRushort options;
               IGRushort varprops;
               IGRdouble *varval;
               GRobjid mgrobjid;
               IGRchar *varname)
{
  IGRchar expvalstr[STATIC_MAX_NUMLEN];
  IGRlong msg_loc, stat_OM;
  IGRshort s_msg_loc;
  IGRdouble expval, numvalvars;
  GRobjid grndid;
  struct GRid my_grid;
  struct SKsolvevars *valvars;
  OM_S_CHANSELECT chan_to_mgr, chan_to_mgrvars;
  void SKfreevarlist();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  valvars = NULL;

  /*
   * Initialize myself into the expression system, unless I am to be simpy a
   * reflection of another expression outside this system.
   */

  if (! (options & SK_VARCREATE_NEWINPUTEXPR))
    {
    if (!varval)
      {
      stat_OM = om$send (msg = message SKmgr.SKgetvarconstrs (&msg_loc,
                  SK_GETVR_VALVAR, &valvars, NULL, NULL),
                  targetid = mgrobjid);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      numvalvars = 0;
      while (valvars)
        {
        numvalvars++;
        valvars = valvars->next;
        }
      sprintf (expvalstr, "%lf", numvalvars+1);
      }
    else
      sprintf (expvalstr, "%lf", *varval);

    stat_OM = om$send (msg = message expression.create (varname, expvalstr,
               &s_msg_loc), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & s_msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  /*
   * Connect myself to the manager as a variable in it's system (if
   * not inhibited).
   */

  if (! (options & SK_OPT_NO_MGR_CONNECT))
    {
    EMmake_chanselect (SKvariable_to_mgr, &chan_to_mgr);
    EMmake_chanselect (SKmgr_to_vars, &chan_to_mgrvars);

    stat_OM  = om$send (msg = message Root.connect (chan_to_mgr,
                 MAXINT, mgrobjid, OM_Gw_current_OS, chan_to_mgrvars, 0),
                 targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    }

  /*
   * If the options indicate that I must be constructed
   * as simpy a reflection of another expression in the system, value-grounds
   * are constructed and my property bit set indicating this to be the
   * case.
   */

  if (options & SK_VARCREATE_NEWINPUTEXPR)
    {
    ME.SKvariable->props = SK_VAR_READEXPR;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    stat_OM = om$construct (classid = OPP_SKasvlgrnd_class_id,
               p_objid = &grndid, 
               msg = message SKasvlgrnd.SKinit_assocvl_ground
               (&msg_loc, NULL, &my_grid, NULL, mgrobjid, NULL, NULL));
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  if (valvars)
    SKfreevarlist (valvars, NULL);

  EMWRAPUP (*msg, stat_OM, "SKvalvar.SKconstruct");
  return (stat_OM);
}

end implementation SKvalvar;
