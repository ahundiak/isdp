/*

Name
  SKintdelete

Abstract
  Internal cleanup method for SKconstraint GRdelete call.
  
Synopsis

Description

Return Value

Notes

Index

Keywords
  delete, profile, constraint

History
  03/04/93 : Rajiv Agrawal : Removed the condition of not deleting a self-constraint.

 */
class implementation SKconstraint;

#include <alloca.h>

#define MEMBERS    0
#define VARIABLES  1

extern GRclassid OPP_SKinterface_class_id;

from SKvariable import SKintdelete;

method SKintdelete (IGRlong *msg; IGRushort opts;
                    struct GRmd_env *md_env)
{
  IGRboolean deletable;
  IGRint startinx, inx, i;
  OMuint count;
  IGRlong stat_OM, msg_loc;
  GRclassid myclass;
  OM_S_CHANSELECT chan_to_comps, chan_to_super;
  OM_S_CHANSELECT chan_to_peons;
  OM_S_OBJECT_LINKAGE *objlist;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Criteria for deletablility: If I do not have a graphic handle
   * (including any invisible handle), and I am not owned by any
   * super-constraint, I am deletable.  
   */

  deletable = FALSE;
  if (! (ME.SKconstraint->props & SK_INVISIBLEHNDL))
    {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
     count = &count);
  
    if (!count)
      deletable = TRUE;
    }

  if (deletable)
    {
    EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_super);
    om$get_channel_count (object = me, p_chanselect = &chan_to_super,
     count = &count);

    if (count)
      deletable = FALSE;

    if (deletable)
      {
      /*
       * Propogation of the SKintdelete message
       */

      om$get_classid (object = me, p_classid = &myclass);
      stat_OM = om$is_ancestry_valid (subclassid = myclass,
                 superclassid = OPP_SKinterface_class_id);
      if (stat_OM == OM_S_SUCCESS)
        startinx = MEMBERS;
      else
        startinx = VARIABLES;

      for (inx=startinx; inx<=VARIABLES; inx++)
        {
        if (inx == MEMBERS)
          EMmake_chanselect (SKinterface_to_member_constrs, &chan_to_peons);
        else
          EMmake_chanselect (SKconstraint_to_variables, &chan_to_peons);

        om$get_channel_count (object = me, p_chanselect = &chan_to_peons,
         count =&count);

        if (count)
          {
          objlist = (OM_p_OBJECT_LINKAGE) alloca (count * 
                     sizeof (OM_S_OBJECT_LINKAGE));
          EMerr_hndlr (!objlist, *msg, EMS_E_NoStackMemory, ret_end);

          om$get_channel_objects (object = me, p_chanselect = &chan_to_peons,
           count = &count, size = count, list = objlist);

          om$send (msg = message Root.wild_disconnect (chan_to_peons),
           targetid = my_id);

          for (i=0; i<count; i++)
            {
            om$send (msg = message SKconstraint.SKintdelete (&msg_loc,
             opts, md_env), targetid = objlist[i].S_objid);
        
            om$send (msg = message SKvariable.SKintdelete (&msg_loc,
             opts, md_env), targetid = objlist[i].S_objid);
            }
          }
        }

      /*
       * Delete myself
       */

      om$send (msg = message Root.delete (TRUE), targetid = my_id);

      /*
       * The solution path for this sketch manager must be redone
         no longer being done ... Rajiv 7/30/92
      SKfree_solvepath ();
       */
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKconstraint.GRdelete");
  return (stat_OM);
}

end implementation SKconstraint;
