/*
  ABSTRACT

  This function return all the point-variables that are involved in
  this constraint
*/

class implementation SKconstraint;

extern GRclassid OPP_SKptvar_class_id;

IGRlong SKgetcnptvars (msg, cnstr, os, num_vars, vars)
IGRlong *msg; 
GRobjid cnstr;
GRspacenum os;
IGRint *num_vars;
GRobjid **vars;
{
  IGRuint i, j, count, num_varobjs;
  IGRlong stat_OM;
  GRobjid *varobjs;
  GRclassid classid;
  OM_S_CHANSELECT chan_to_vars;
  OM_p_OBJECT_LINKAGE chanobjs;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);

  count = 0;
  om$get_channel_count (objid = cnstr, osnum = os, 
   p_chanselect = &chan_to_vars, count = &count);
  EMerr_hndlr (!count, *msg, EMS_I_NotFound, wrapup);

  chanobjs = (OM_p_OBJECT_LINKAGE) alloca (count * 
             sizeof (OM_S_OBJECT_LINKAGE));
  varobjs = (GRobjid *) alloca (count * sizeof (GRobjid));
  num_varobjs = 0;
  
  om$get_channel_objects (objid = cnstr, osnum = os,
   p_chanselect = &chan_to_vars, count = &count, size = count,
   list = chanobjs);
  for (i=0; i<count; i++)
  {
    om$get_classid (objid = chanobjs[i].S_objid, p_classid = &classid,
     osnum = os);
    if (om$is_ancestry_valid (superclassid = OPP_SKptvar_class_id,
         subclassid = classid) == OM_S_SUCCESS)
    {
      varobjs[num_varobjs++] = chanobjs[i].S_objid; 
    }
    else if (om$is_ancestry_valid (superclassid = OPP_SKconstraint_class_id,
              subclassid = classid) == OM_S_SUCCESS)
            
    {
      stat_OM = SKgetcnptvars (msg, chanobjs[i].S_objid, os, num_vars, vars);
      EMerr_hndlr (EMSerror (stat_OM & *msg), *msg, *msg, wrapup);
    }
  }
 
  if (num_varobjs)
  {
    if (!*vars)
    {
      *vars = (GRobjid *) malloc (num_varobjs * sizeof (GRobjid));
    }
    else
    {
      *vars = (GRobjid *) realloc (*vars, 
               (*num_vars + num_varobjs) * sizeof (GRobjid));
    }
    EMerr_hndlr (!*vars, *msg, EMS_E_NoDynamicMemory, wrapup);

    for (i=*num_vars, j=0; i<*num_vars+num_varobjs; i++, j++)
    {
      (*vars)[i] = varobjs[j];
    }
    (*num_vars) += num_varobjs;
  }

wrapup:
  EMWRAPUP (*msg, stat_OM, "SKcngetptv");
  return (stat_OM);
}

end implementation SKconstraint;
