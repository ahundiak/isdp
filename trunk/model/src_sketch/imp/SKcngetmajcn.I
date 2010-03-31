/*

Name
  SKconstraint.SKgetmajconstrs

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords

History
  06/11/93 : Rajiv Agrawal : Added some badly needed documentation.
  09/17/93 : Rajiv Agrawal : Add self-cosntraints also to the list since they
                             do not have a constraint handle.
  01/12/94 : Sudha : Changed > to >= to do a realloc.  (TR119301030)
  07/13/94 : Satya : Changed <= back to > for realloc and added code to handle
		     the = case.
  01/09/95 : Satya : Checked in the fix for EMS 3.2

 */
class implementation SKconstraint;
#include "OMmacros.h"

method SKgetmajconstrs (IGRlong *msg; IGRushort opts;
                        IGRint num_in_buff;
                        IGRint *num_major_constrs; GRobjid **major_constrs)
{
  IGRboolean 		found;
  IGRuint 		count;
  IGRint 		i;
  IGRlong 		stat_OM;
  OM_S_CHANSELECT 	chan_to_comps, chan_to_super;
  GRobjid		*temp_major_constrs;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * If the constraint does not have an invisible handle, check if there 
   * is a constraint-handle attached to it on its component channel.
   */
  count = 0;
  if (! (ME.SKconstraint->props & SK_INVISIBLEHNDL))
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
                          count = &count);
  }

  /*
   * Either the constraint has an invisible handle, or it is a self-constraint,
   * or had some handle attached.
   */
  if (ME.SKconstraint->props & SK_INVISIBLEHNDL || 
      ME.SKconstraint->props & SK_SELFCNSTR || 
      count)
  {
    /*
     * Check if the constraint already exists in our list.
     */
    for (i = 0, found = FALSE; i < *num_major_constrs && !found; i++)
      if ((*major_constrs)[i] == my_id)
        found = TRUE;

    /*
     * not there in the list ... add it and ensure we have enough space.
     */        
    if (!found)
    {
      count = *num_major_constrs + 1;
      if (num_in_buff < count)
      {
        if (*num_major_constrs > num_in_buff)
        {
          *major_constrs = (GRobjid *) om$realloc (
                            ptr = (char *) *major_constrs,
                            size = count * sizeof (GRobjid));
        }
        else
        {
          if(*num_major_constrs == num_in_buff)
          {
            temp_major_constrs = *major_constrs;
            *major_constrs = NULL;
            *major_constrs = (GRobjid *) om$malloc (size = count * sizeof (GRobjid));
            OM_BLOCK_MOVE(temp_major_constrs,*major_constrs,*num_major_constrs*sizeof(GRobjid));
          }
          else
          {
            *major_constrs = (GRobjid *) om$malloc (size = count * sizeof (GRobjid));  
          }
        }
        EMerr_hndlr (!*major_constrs, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
      (*major_constrs)[*num_major_constrs] = my_id;
      (*num_major_constrs)++;
    }     
  }

  /*
   * Send the message to the the constraint super-channel to see if anything can
   * be added from there.
   */
  EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_super);
  stat_OM = om$send (msg = OPPmargs, p_chanselect = &chan_to_super);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKconstraint.SKgetmajconstrs");
  return (stat_OM);
}

end implementation SKconstraint;
