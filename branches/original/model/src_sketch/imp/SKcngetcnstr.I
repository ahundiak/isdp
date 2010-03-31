class implementation SKconstraint;

#define INCR_SIZE 10

extern GRclassid OPP_NDnode_class_id;
extern GRclassid OPP_SKexplicit_class_id, OPP_SKimplicit_class_id;

method SKgetconstrs (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars *in_vars;
                     IGRint *num_constrs, *num_constrs_mem;
                     struct SKconstrinfo **constrs)
{
  IGRboolean eligible;
  IGRushort myprops, addprops;
  IGRint i, num, blksize;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  GRclassid myclass;
  OM_S_CHANSELECT chan_to_comps;
  struct SKconstrinfo *constrs_ptr;
  extern IGRlong SKgetadjvars();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Check if I am already in the list of constraints. If so, I am not
   * eligible. If the option is to simply find the constraint, then
   * also set the stop-sending return code.
   */

  num = *num_constrs;
  if (constrs)
    {
    constrs_ptr = *constrs;
    for (i=0; i<num; i++)
      if (constrs_ptr[i].constrid == my_id &&
          constrs_ptr[i].cprops & CONSTR_REGULAR)
        {
        if (opts & SK_GETCN_FIND)
          stat_OM = OM_I_STOP_SENDING;
        *msg = EMS_I_Found;
        goto ret_end;
        }
    if (opts & SK_GETCN_FIND)
      goto ret_end;
    }

  /*
   * Check if I am eligible vis-a-vis the search options.
   */

  eligible = TRUE;
  if (opts)
    {
    myprops = ME.SKconstraint->props;
    if (opts & SK_GETCN_NEW && !(myprops & SK_NEWADD))
      eligible = FALSE;
    if (opts & SK_GETCN_GENEQN)
      eligible = FALSE;
    if (opts & SK_GETCN_HNDL)
      {
      if (! (ME.SKconstraint->props & SK_INVISIBLEHNDL) ||
          opts & SK_GETCN_GEOMHNDL)
        {
        om$make_chanselect (channame = "GRcmpowner.to_components",
         p_chanselect = &chan_to_comps);
  
        count = 0;
        om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
         count = &count);

        if (!count)
          eligible = FALSE;
        }
      }
    if (opts & SK_GETCN_NDPARENTS)
      {
      om$get_classid (object = me, p_classid = &myclass);
      if (om$is_ancestry_valid (subclassid = myclass,  
           superclassid = OPP_NDnode_class_id) != OM_S_SUCCESS)
        eligible = FALSE;
      }
    if (opts & SK_GETCN_IMPLICIT)
      {
      om$get_classid (object = me, p_classid = &myclass);
      if (om$is_ancestry_valid (subclassid = myclass,  
           superclassid = OPP_SKimplicit_class_id) != OM_S_SUCCESS)
        eligible = FALSE;
      }
    }
  if (!eligible)
    goto ret_end;

  /*
   * Append myself onto the list of constraints being built
   */
  
  if (constrs)
    {
    if (num + 1  > *num_constrs_mem)
      {
      if (!*num_constrs_mem)
        {
        blksize = INCR_SIZE;
        *constrs = (struct SKconstrinfo *) om$malloc
                    (size = blksize * sizeof (struct SKconstrinfo));
        }
      else
        {
        blksize = *num_constrs_mem + INCR_SIZE;
        *constrs = (struct SKconstrinfo *) om$realloc 
                    (size = blksize * sizeof (struct SKconstrinfo),
                    ptr = (char *) *constrs);
        }
      EMerr_hndlr (!*constrs, *msg, EMS_E_NoDynamicMemory, ret_end);
      *num_constrs_mem = blksize;
      }
    constrs_ptr = *constrs;

    om$get_classid (object = me, p_classid = &myclass);
    if (om$is_ancestry_valid (subclassid = myclass,
         superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS &&
        ME.SKconstraint->props & SK_NOVALUE)
      addprops = CONSTR_PSEUDO_VAR;
    else
      addprops = NULL;

    constrs_ptr[num].cprops = CONSTR_REGULAR | addprops;
    constrs_ptr[num].constrid = my_id;
    constrs_ptr[num].vprops = NULL;  
    constrs_ptr[num].varsolveid = NULL_OBJID;

    if (opts & SK_GETCN_ADJVARS && in_vars)
      {
      stat_OM = SKgetadjvars (&msg_loc, NULL, in_vars, 1, &constrs_ptr[num],
                 OM_Gw_current_OS);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
  (*num_constrs)++;
    
ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgetconstrs");
  return (stat_OM);
}

end implementation SKconstraint;
