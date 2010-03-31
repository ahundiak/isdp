/*

Name
  SKarc.SKcreate_self_constraints

Abstract
  
Synopsis

Description
  This method creates an equal constraint between the two legs of an
  arc element of a profile.

Return Value

Notes

Index

Keywords
  arc, self-constraints

History
  04/26/93 : Rajiv Agrawal : Added an option to not create expressions for the equality
                             constraint.  (CR#11923746).
  09/14/93 : Rajiv Agrawal : Removed the option from the call since it is the default
                             behavior for the constraint now.
  09/17/93 : Rajiv Agrawal : Removed the settting of SK_INVISIBLEHNDL to revert to 2.2 behavior.

 */
class implementation SKarc;

#define CENTRE  0
#define START   1
#define STOP    2

extern GRclassid OPP_SKequal_class_id;

from SKconstraint import SKinit;

method SKcreate_self_constraints (IGRlong *msg; IGRushort opts;
                                  struct GRmd_env *md_env;
                                  IGRint *num_cnstrs; GRobjid **cnstrs)
{
  IGRuint 		count;
  IGRlong		stat_OM, msg_loc;
  GRobjid 		ptvars[3], eqcnstr;
  OM_S_CHANSELECT 	chan_to_defpts;
  OM_S_OBJECT_LINKAGE 	defpts[3];
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain this arc's defining points in the local co-ordinate
   * system.
   */

  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  count = 0;
  om$get_channel_objects (object = me, p_chanselect = &chan_to_defpts,
                          count = &count, list = defpts, size = 3);
  EMerr_hndlr (count != 3, *msg, EMS_E_InvalidCase, ret_end);
  ptvars[CENTRE] = defpts[1].S_objid;
  ptvars[START] = defpts[0].S_objid;
  ptvars[STOP] = defpts[2].S_objid;

  /*
   * Construct an equal length constraint between first-centre and the
   * centre-second points.
   */

  stat_OM = om$construct (classid = OPP_SKequal_class_id,
                          msg = message SKconstraint.SKinit 
                                (&msg_loc, NULL, 
                                 md_env, 3, ptvars, SK_SELFCNSTR,
                                 NULL, NULL),
                          p_objid = &eqcnstr);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Format the output if requested
   */

  if (cnstrs && num_cnstrs)
  {
    if (! (*num_cnstrs % SK_INCR_SIZE))
    {
      if (*cnstrs)
        *cnstrs = (GRobjid *) om$realloc (ptr = (char *) *cnstrs, size = 
                   (*num_cnstrs + SK_INCR_SIZE) * sizeof (GRobjid));
      else
        *cnstrs = (GRobjid *) om$malloc (size = SK_INCR_SIZE *
                   sizeof (GRobjid));
      EMerr_hndlr (!*cnstrs, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  
    (*cnstrs)[*num_cnstrs] = eqcnstr;
  }

  if (num_cnstrs)
    (*num_cnstrs)++;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKarc.SKcreate_self_constraints");
  return (stat_OM);
}

end implementation SKarc;

