/*

Name
  SKcircle.SKcreate_self_constraints

Abstract

Synopsis

Description
  This method creates an invisible horizontal constraint between the center point 
  and the endpoint of the circle element of a profile.

Return Value

Notes

Index

Keywords

History
  06/11/93 : Rajiv Agrawal : Added SK_INVISIBLEHNDL to the self constraint.
  09/17/93 : Rajiv Agrawal : Removed the settting of SK_INVISIBLEHNDL to revert to 2.2 behavior.

 */
class implementation SKcircle;

#define CENTRE  0
#define CIRCUMF 1

extern GRclassid OPP_SKhorizvert_class_id;

from SKconstraint import SKinit;

method SKcreate_self_constraints (IGRlong *msg; IGRushort opts;
                                  struct GRmd_env *md_env;
                                  IGRint *num_cnstrs; GRobjid **cnstrs)
{
  IGRuint count;
  IGRlong stat_OM, msg_loc;
  GRobjid ptvars[2], horcnstr;
  OM_S_CHANSELECT chan_to_defpts;
  OM_S_OBJECT_LINKAGE defpts[2];
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain this circle's defining points in the local co-ordinate
   * system.
   */

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_defpts,
   count = &count, list = defpts, size = 3);
  EMerr_hndlr (count != 2, *msg, EMS_E_InvalidCase, ret_end);
  ptvars[CIRCUMF] = defpts[0].S_objid;
  ptvars[CENTRE] = defpts[1].S_objid;

  /*
   * Construct a horizontal constraint between centre and the
   * circumference points.
   */

  stat_OM = om$construct (classid = OPP_SKhorizvert_class_id,
                          msg = message SKconstraint.SKinit (&msg_loc, NULL,
                                md_env, 2, ptvars, 
                                SK_HORIZONTAL | SK_SELFCNSTR, NULL, NULL),
                          p_objid = &horcnstr);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Format the output if requested
   */

  if (cnstrs && num_cnstrs)
    {
    if (! (*num_cnstrs % SK_INCR_SIZE))
      {
      if (*cnstrs)
        *cnstrs = (GRobjid *) om$realloc (ptr = (char *) *cnstrs, 
                   size = (*num_cnstrs + SK_INCR_SIZE) * sizeof (GRobjid));
      else
        *cnstrs = (GRobjid *) om$malloc (size = SK_INCR_SIZE *
                   sizeof (GRobjid));
      EMerr_hndlr (!*cnstrs, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
  
    (*cnstrs)[*num_cnstrs] = horcnstr;
    }

  if (num_cnstrs)
    (*num_cnstrs)++;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcircle.SKcreate_self_constraints");
  return (stat_OM);
}

end implementation SKcircle;

