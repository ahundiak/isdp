class implementation SKconstraint;

extern GRclassid OPP_SKexplicit_class_id, OPP_SKimplicit_class_id;
extern GRclassid OPP_SKasptgrnd_class_id;

method SKpass_by_class_type (IGRlong *msg; OM_p_MESSAGE pass_msg; 
                             IGRushort class_types)
{
  IGRboolean is_explicit, pass_the_msg;
  GRclassid myclass;

  *msg = EMS_S_Success;

  pass_the_msg = FALSE;

  om$get_classid (object = me, p_classid = &myclass);
  if (om$is_ancestry_valid (subclassid = myclass, 
       superclassid = OPP_SKexplicit_class_id) == OM_S_SUCCESS)
    is_explicit = TRUE;
  else
    is_explicit = FALSE;

  if (class_types & SK_PASS_EXPLICIT_CLASS)
    {
    if (is_explicit)
      pass_the_msg = TRUE;
    }

  if (class_types & SK_PASS_IMPLICIT_CLASS)
    {
    if (!is_explicit)
      {
      if (class_types & SK_PASS_NotPublic_ASGROUND)
        {
        if (om$is_ancestry_valid (subclassid = myclass,
             superclassid = OPP_SKasptgrnd_class_id) == OM_S_SUCCESS)
          pass_the_msg = TRUE;
        }
      else
        pass_the_msg = TRUE;
      }
    }

  if (pass_the_msg)
    return (om$send (msg = pass_msg, targetid = my_id));
  else
    return (OM_S_SUCCESS);
}

end implementation SKconstraint;
