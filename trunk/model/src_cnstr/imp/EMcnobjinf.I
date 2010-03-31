class implementation EMScnstr;

#include "msdef.h"

extern GRclassid OPP_EMSexpcnstr_class_id;
extern GRclassid OPP_EMShvcnstr_class_id, OPP_EMSasptcnstr_class_id;
extern GRclassid OPP_EMSpervcnstr_class_id, OPP_EMSparvcnstr_class_id;
extern GRclassid OPP_EMSptelcnstr_class_id;

method GRgetobjinfo (IGRlong *msg; struct GRobj_info *info)
{
  GRclassid objclass;

  *msg = MSSUCC;

  om$get_classid (object = me, p_classid = &objclass);
  if (om$is_ancestry_valid (subclassid = objclass,
       superclassid = OPP_EMSexpcnstr_class_id) == OM_S_SUCCESS)
    strcpy (info->type, "Dimension constraint");
  else if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMShvcnstr_class_id) == OM_S_SUCCESS)
    {
    if (ME.EMScnstr->cnstr_props & EMScnstr_horizontal)
      strcpy (info->type, "Horizontal constraint");
    else
      strcpy (info->type, "Vertical constraint");
    }
  else if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMSparvcnstr_class_id) == OM_S_SUCCESS)
    strcpy (info->type, "Parallel constraint");
  else if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMSpervcnstr_class_id) == OM_S_SUCCESS)
    strcpy (info->type, "Perpendicular constraint");
  else if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMSasptcnstr_class_id) == OM_S_SUCCESS)
    strcpy (info->type, "Point coincident constraint");
  else if (om$is_ancestry_valid (subclassid = objclass,
            superclassid = OPP_EMSptelcnstr_class_id) == OM_S_SUCCESS)
    strcpy (info->type, "Point on element constraint");
  else
    strcpy (info->type, "Constraint");

  return (OM_S_SUCCESS);
}

end implementation EMScnstr;
