class implementation SKconstraint;

#include <alloca.h>

#define INCR_SIZE 10

extern GRclassid OPP_NDnode_class_id, OPP_SKexplicit_class_id;
extern GRclassid OPP_SKinterface_class_id;
extern GRclassid OPP_SKhorizvert_class_id, OPP_SKhvptpt_class_id, OPP_SKaxisptpt_class_id;

method SKduplicate ( long *msg; unsigned short opts; OM_S_OBJID *duplicate_cnstr )
{
  IGRboolean          duplicate_found, is_interface;
  unsigned short      other_props;
  int                 i, inx;
  OMuint              num_vars, num_other_vars, num_cnstrs, num_members;
  long                stat_OM, msg_loc;
  GRclassid           myclass, class;
  OM_S_CHANSELECT     chan_to_vars, chan_to_cnstrs;
  OM_S_OBJECT_LINKAGE *varlist, *other_varlist, *cnstrlist;

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  *duplicate_cnstr = NULL_OBJID;

  /*
   * Interface constraints are handled with their members being treated
   * as the variables.
   */

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
      superclassid = OPP_SKinterface_class_id) == OM_S_SUCCESS)
  {
    is_interface = TRUE;
    EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_vars);
  }
  else
  {
    is_interface = FALSE;
    EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  }

  /*
   * Obtain the variables governed by this constraint. Check if any
   * of the variables is governed by another constraint of the same
   * class as this one. If so, check if this similar constraint has the
   * same variables as this one. If it does, then a duplicate constraint
   * has been found.
   */

  om$get_channel_count (object = me, p_chanselect = &chan_to_vars,
                        count = &num_vars);
  if (num_vars)
  {
    varlist = (OM_p_OBJECT_LINKAGE) alloca (num_vars * sizeof (OM_S_OBJECT_LINKAGE));
    EMerr_hndlr (!varlist, *msg, EMS_E_NoStackMemory, ret_end);

    om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
                            count = &num_vars, size = num_vars, list = varlist);

    om$get_classid (objid = varlist[0].S_objid, p_classid = &class);
    if (om$is_ancestry_valid (subclassid = class,
        superclassid = OPP_SKconstraint_class_id) == OM_S_SUCCESS)
      EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_cnstrs);
    else
      EMmake_chanselect (SKvariable_to_constraints, &chan_to_cnstrs);
    om$get_channel_count (objid = varlist[0].S_objid,
                          p_chanselect = &chan_to_cnstrs, count = &num_cnstrs);

    if (num_cnstrs)
    {
      cnstrlist = (OM_p_OBJECT_LINKAGE) alloca (num_cnstrs * sizeof (OM_S_OBJECT_LINKAGE));
      EMerr_hndlr (!cnstrlist, *msg, EMS_E_NoStackMemory, ret_end);

      om$get_channel_objects (objid = varlist[0].S_objid,
                              p_chanselect = &chan_to_cnstrs, count = &num_cnstrs,
                              size = num_cnstrs, list = cnstrlist);

      for (i=0; i<num_cnstrs; i++)
      {
        if (cnstrlist[i].S_objid != my_id)
        {
          om$get_classid (objid = cnstrlist[i].S_objid, p_classid = &class);
          if (myclass == class)
          {
            om$get_channel_count (objid = cnstrlist[i].S_objid,
                p_chanselect = &chan_to_vars, count = &num_other_vars);
            if (num_other_vars)
            {
              other_varlist = (OM_p_OBJECT_LINKAGE) alloca (num_other_vars *
                  sizeof (OM_S_OBJECT_LINKAGE));
              EMerr_hndlr (!other_varlist, *msg, EMS_E_NoStackMemory, ret_end);

              om$get_channel_objects (objid = cnstrlist[i].S_objid,
                  p_chanselect = &chan_to_vars, count = &num_other_vars,
                  size = num_other_vars, list = other_varlist);

              if (num_vars == num_other_vars)
              {
                for (inx=0; inx<num_other_vars; inx++)
                  if (varlist[inx].S_objid != other_varlist[inx].S_objid)
                    break;

                if (inx == num_vars)
                {
                  if (myclass == OPP_SKhorizvert_class_id ||
                      myclass == OPP_SKhvptpt_class_id ||
                      myclass == OPP_SKaxisptpt_class_id)
                  {
                    stat_OM = om$send (msg = message SKconstraint.SKgetprops
                                             (&msg_loc, &other_props), 
                                       targetid = cnstrlist[i].S_objid);
                    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
                    if (!(ME.SKconstraint->props & SK_HORIZONTAL ^ other_props & SK_HORIZONTAL))
                      duplicate_found = TRUE;
                    else
                      duplicate_found = FALSE;
                  }
                  else
                    duplicate_found = TRUE;

                  if (duplicate_found)
                  {
                    *msg = EMS_I_Found;
                    *duplicate_cnstr = cnstrlist[i].S_objid;
                    goto ret_end;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  /*
   * If this is an interface constraint, also check if any of it's member
   * constraints have a duplicate. If so, then this constraint is deemed to
   * have a duplicate.
   */

  if (is_interface)
  {
    num_members = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_vars,
                          count = &num_members);
    if (num_members)
      for (i=0; i<num_members; i++)
      {
        stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_vars,
                           from = i, to = i);
        if (*msg == EMS_I_Found)
          goto ret_end;
      }
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKconstraint.SKduplicate" );
  return stat_OM;
}

end implementation SKconstraint;
