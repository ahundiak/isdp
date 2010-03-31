class implementation SKeqrelation;

#define STATIC_NUMVARS 5

extern GRclassid OPP_SKexplicit_class_id, OPP_SKequal_class_id;

from SKexplicit import SKgetval;

method SKgetconstrs (IGRlong *msg; IGRushort opts;
                     struct SKsolvevars *in_vars;
                     IGRint *num_constrs, *num_constrs_mem;
                     struct SKconstrinfo **constrs)
{
  IGRboolean eligible, found, is_equalclass;
  IGRuint myprops, chkprops;
  IGRushort cprops;
  IGRuint count;
  IGRint i, j, inx, num, blksize;
  IGRlong msg_loc, stat_OM;
  GRobjid varobj;
  GRclassid varclass, myclass;
  struct SKconstrinfo *constrs_ptr = NULL;
  OM_S_OBJECT_LINKAGE *objlist, objlist_store[STATIC_NUMVARS];
  OM_S_CHANSELECT chan_to_vars, chan_to_comps;
  extern IGRlong SKgetadjvars();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  objlist = NULL;

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

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass,
       superclassid = OPP_SKequal_class_id) == OM_S_SUCCESS)
    is_equalclass = TRUE;
  else
    is_equalclass = FALSE;

  eligible = TRUE;
  if (opts)
    {
    myprops = ME.SKconstraint->props;
    if (opts & SK_GETCN_NEW && !(myprops & SK_NEWADD))
      eligible = FALSE;
    if (opts & SK_GETCN_GENEQN && is_equalclass)
      eligible = FALSE;
    if (opts & SK_GETCN_HNDL)
      {
      if (! (ME.SKconstraint->props & SK_INVISIBLEHNDL) ||
          opts & SK_GETCN_GEOMHNDL)
        {
        EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
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
    }
  if (!eligible)
    goto ret_end;

  /*
   * If any of my component variables are explicit constraints then add
   * them to the list of constraints being returned, marking them as
   * CONSTR_PSEUDO_VARs. This, to account for the addition of pseudo-variables
   * into the system. But, if the explicit constraint is marked as having
   * a specified, known value, then the equation to return could be
   * simpler. It is then simply - variable=constant. Such an equation 
   * constraint, called a CONSTR_PSEUDO_EQN is appropriately marked.
   */

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  om$get_channel_count (object = me, p_chanselect = &chan_to_vars,
   count = &count);

  if (count > STATIC_NUMVARS)
    objlist = (OM_p_OBJECT_LINKAGE) om$malloc (size = count * 
                sizeof (OM_S_OBJECT_LINKAGE));
  else
    objlist = objlist_store;
  EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);

  om$get_channel_objects (object = me, p_chanselect = &chan_to_vars,
   list = objlist, size = count, count = &count);
  EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

  if (constrs)
    {
    blksize = num + count + 1;
    if (blksize > *num_constrs_mem)
      {
      if (!*num_constrs_mem)
        *constrs = (struct SKconstrinfo *) om$malloc (size = blksize *
                    sizeof (struct SKconstrinfo));
      else
        *constrs = (struct SKconstrinfo *) om$realloc (size = blksize * 
                    sizeof (struct SKconstrinfo), ptr = (char *) *constrs);
      EMerr_hndlr (!*constrs, *msg, EMS_E_NoDynamicMemory, ret_end);
      *num_constrs_mem = blksize;
      }
    constrs_ptr = *constrs;
    }

  inx = *num_constrs;
  for (i=0; i<count; i++)
    {
    varobj = objlist[i].S_objid;
    om$get_classid (objid = varobj, p_classid = &varclass);
 
    stat_OM = om$is_ancestry_valid (subclassid = varclass,
               superclassid = OPP_SKexplicit_class_id);
    if (stat_OM == OM_S_SUCCESS && !(opts & SK_GETCN_GENEQN))
      {
      cprops = NULL;
      stat_OM = om$send (msg = message SKconstraint.SKgetprops (&msg_loc,
                 &cprops), targetid = varobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      if (opts & SK_GETCN_NEW && !(cprops & SK_NEWADD))
        break;
        
      if (cprops & SK_NOVALUE)
        chkprops = CONSTR_PSEUDO_VAR;
      else
        chkprops = CONSTR_PSEUDO_EQN;

      found = FALSE;
      for (j=0; j<num; j++)
        if (constrs_ptr[j].constrid == varobj &&
            constrs_ptr[j].cprops & chkprops)
          {
          found = TRUE;
          break;
          }
      if (found)
        continue;
 
      if (cprops & SK_NOVALUE)
        {
        if (constrs)
          {
          constrs_ptr[inx].cprops = CONSTR_REGULAR | CONSTR_PSEUDO_VAR;
          constrs_ptr[inx].constrid = varobj;
          constrs_ptr[inx].vprops = NULL;
          constrs_ptr[inx].varsolveid = NULL_OBJID;
          }
        inx++;
        }
      else
        {
        if (constrs)
          {
          constrs_ptr[inx].cprops = CONSTR_PSEUDO_EQN;
          constrs_ptr[inx].constrid = varobj;
          constrs_ptr[inx].vprops = VAR_PSEUDO_VAL;
          constrs_ptr[inx].varsolveid = varobj;
          }
        inx++;
        }
      
      if (opts & SK_GETCN_ADJVARS && in_vars)
        {
        stat_OM = SKgetadjvars (&msg_loc, NULL, in_vars, 1, &constrs_ptr[inx],
                   OM_Gw_current_OS);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      }
    }

  /*
   * Add myself as an equational constraint
   */

  if (constrs)
    {
    constrs_ptr[inx].cprops = CONSTR_REGULAR | 
                               (is_equalclass ?
                                CONSTR_EQUAL_EQN : CONSTR_GEN_EQN);
    constrs_ptr[inx].constrid = my_id;
    constrs_ptr[inx].vprops = NULL;
    constrs_ptr[inx].varsolveid = NULL_OBJID;

    if (opts & SK_GETCN_ADJVARS && in_vars)
      {
      stat_OM = SKgetadjvars (&msg_loc, NULL, in_vars, 1, &constrs_ptr[inx],
                 OM_Gw_current_OS);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    }
  inx++;

  /*
   * Update the number of constraints counter
   */

  *num_constrs = inx;

ret_end:
  if (objlist && objlist != objlist_store)
    om$dealloc (ptr = objlist);
  EMWRAPUP (*msg, stat_OM, "SKgetconstrs");
  return (stat_OM);
}

end implementation SKeqrelation;
