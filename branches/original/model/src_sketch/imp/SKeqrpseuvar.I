class implementation SKeqrelation;

#include "DIdef.h"

#define STATIC_NUMVARS 5

extern GRclassid OPP_SKexplicit_class_id;

from SKexplicit import SKgetval, SKgetname;

method SKgetpseudovarlist (IGRlong *msg; IGRushort opts;
                           struct SKsolvevars **varlist)
{
  IGRchar varname[DI_PATH_MAX];
  IGRint i;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRdouble val;
  GRobjid varobj;
  GRclassid varclass;
  OM_S_OBJECT_LINKAGE *objlist, objlist_store[STATIC_NUMVARS];
  OM_S_CHANSELECT chan_to_vars;
  extern void SKaddvarlist();
  extern IGRboolean SKisvarlinlist();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  objlist = NULL;

  /*
   * Check the options for eligibility
   */

  if (opts & SK_GETVR_NDCHILDREN)
    goto ret_end;
  else if (opts & SK_GETVR_VALVAR)
    goto ret_end;

  om$make_chanselect (channame = "SKconstraint.to_variables",
   p_chanselect = &chan_to_vars);

  om$get_channel_count (object = me, p_chanselect = &chan_to_vars,
   count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

  if (count > STATIC_NUMVARS)
    objlist = (OM_p_OBJECT_LINKAGE) om$malloc (size = count * 
               sizeof (OM_S_OBJECT_LINKAGE));
  else
    objlist = objlist_store;
  EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
   list = objlist, size = count, count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

  for (i=0; i<count; i++)
    {
    varobj = objlist[i].S_objid;
    om$get_classid (objid = varobj, p_classid = &varclass);

    stat_OM = om$is_ancestry_valid (subclassid = varclass,
               superclassid = OPP_SKexplicit_class_id);
    if (stat_OM == OM_S_SUCCESS)
      {
      if (! SKvarlistinx (*varlist, varobj, VAR_SOMEVAL, NULL, NULL))
        {
        if (! (opts & SK_GETVR_FIND))
          {
          stat_OM = om$send (msg = message SKexplicit.SKgetval (&msg_loc,
                     &val), targetid = varobj);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          stat_OM = om$send (msg = message SKexplicit.SKgetname (&msg_loc,
                     opts | SK_GETVR_SIGNIFNAME, varname), targetid = varobj);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail,
           ret_end);

          SKaddvarlist (&msg_loc, NULL, varlist, VAR_PSEUDO_VAL, varobj,
           NULL, NULL, &val, varname);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
          }
        }
      else if (opts & SK_GETVR_FIND)
        {
        *msg = EMS_I_Found;
        stat_OM = OM_I_STOP_SENDING;
        goto ret_end;
        }
      }
    }
  
ret_end:
  if (objlist && objlist != objlist_store)
    om$dealloc (ptr = objlist);

  EMWRAPUP (*msg, stat_OM, "SKgetpseudo");
  return (stat_OM);
}

end implementation SKeqrelation;
