class implementation SKground;

#define INCR_SIZE 10

extern GRclassid OPP_NDnode_class_id, OPP_SKexplicit_class_id;

method SKgetconstrs (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars *in_vars;
                     IGRint *num_constrs, *num_constrs_mem;
                     struct SKconstrinfo **constrs)
{
  IGRboolean eligible, gethndl;
  IGRushort myprops, valprop;
  IGRuint count;
  IGRint i, num, blksize;
  IGRlong msg_loc, stat_OM;
  GRclassid myclass, valclass;
  struct SKconstrinfo *constrs_ptr;
  OM_S_OBJECT_LINKAGE objlist;
  OM_S_CHANSELECT chan_to_vars, chan_to_comps;
  extern IGRlong SKgetadjvars();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Check if I am already in the list being built.
   */

  num = *num_constrs;
  if (constrs)
    {
    constrs_ptr = *constrs;
    for (i=0; i<num; i++)
      if (constrs_ptr[i].constrid == my_id)
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
   * Check if I am eligible.
   */

  eligible = TRUE;
  gethndl = FALSE;
  myprops = ME.SKconstraint->props;
  if (opts)
    {
    gethndl = opts & SK_GETCN_HNDL;
    if (gethndl)
      {
      if (! (myprops & SK_INVISIBLEHNDL) ||
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
    if (opts & SK_GETCN_NEW && !(myprops & SK_NEWADD))
      eligible = FALSE;
    if (opts & SK_GETCN_GENEQN)
      eligible = FALSE;
    if (opts & SK_GETCN_NOGROUND)
      eligible = FALSE;
    }
  if (!eligible)
    goto ret_end;

  /*
   * Append the constraints I represent into the list of constraints being
   * built
   */

  if (constrs)
    {
    if (num + 2  > *num_constrs_mem)
      {
      if (!*num_constrs_mem)
        {
        blksize = INCR_SIZE;
        *constrs = (struct SKconstrinfo *) om$malloc (size = blksize *
                    sizeof (struct SKconstrinfo));
        }
      else
        {
        blksize = *num_constrs_mem + INCR_SIZE;
        *constrs = (struct SKconstrinfo *) om$realloc (size = blksize *
                    sizeof (struct SKconstrinfo), ptr = (char *) *constrs);
        }
      EMerr_hndlr (!*constrs, *msg, EMS_E_NoDynamicMemory, ret_end);
      *num_constrs_mem = blksize;
      }
    constrs_ptr = *constrs;

    EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
    om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
     list = &objlist, size = 1, count = &count);
    EMerr_hndlr (count != 1, *msg, EMS_E_InvalidCase, ret_end);

    constrs_ptr[num].cprops = constrs_ptr[num+1].cprops = NULL;
    constrs_ptr[num].vprops = constrs_ptr[num+1].vprops = NULL;
    }

  if (myprops & SK_GROUND_X)
    {
    if (constrs)
      {
      constrs_ptr[num].cprops |= CONSTR_REGULAR | CONSTR_GRND_X;
      constrs_ptr[num].constrid = my_id;
      constrs_ptr[num].vprops |= VAR_X;  
      constrs_ptr[num].varsolveid = objlist.S_objid;

      if (opts & SK_GETCN_ADJVARS && in_vars)
        {
        stat_OM = SKgetadjvars (&msg_loc, NULL, in_vars, 1, &constrs_ptr[num],
                   OM_Gw_current_OS);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    if (!gethndl)
      num++;
    }
  if (myprops & SK_GROUND_Y)
    {
    if (constrs)
      {
      constrs_ptr[num].cprops |= CONSTR_REGULAR | CONSTR_GRND_Y;
      constrs_ptr[num].constrid = my_id;
      constrs_ptr[num].vprops |= VAR_Y;
      constrs_ptr[num].varsolveid = objlist.S_objid;

      if (opts & SK_GETCN_ADJVARS && in_vars)
        {
        stat_OM = SKgetadjvars (&msg_loc, NULL, in_vars, 1, &constrs_ptr[num],
                   OM_Gw_current_OS);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    if (!gethndl)
      num++;
    }
  if (! (myprops & (SK_GROUND_X | SK_GROUND_Y)))
    {
    if (constrs)
      {
      constrs_ptr[num].cprops |= CONSTR_REGULAR | CONSTR_GRND_V;
      constrs_ptr[num].constrid = my_id;
      om$get_classid (objid = objlist.S_objid, p_classid = &valclass);
      if (om$is_ancestry_valid (subclassid = valclass,
           superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS)
        valprop = VAR_PSEUDO_VAL;
      else
        valprop = VAR_VAL;
      constrs_ptr[num].vprops = valprop;
      constrs_ptr[num].varsolveid = objlist.S_objid;

      if (opts & SK_GETCN_ADJVARS && in_vars)
        {
        stat_OM = SKgetadjvars (&msg_loc, NULL, in_vars, 1, &constrs_ptr[num],
                   OM_Gw_current_OS);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    if (!gethndl)
      num++;
    }
  if (gethndl)
    num++;

  *num_constrs = num;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgetconstrs");
  return (stat_OM);
}

end implementation SKground;
