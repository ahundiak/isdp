class implementation SKexplicit;

#include <string.h>
#include "exdef.h"
#ifndef BASE_EMS
#include "exmacros.h"
#endif
#include "DIdef.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "EMSasnucdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKptpt_class_id, OPP_SKrelang_class_id;
extern GRclassid OPP_SKfixang_class_id, OPP_SKradial_class_id;

/*

Name
  SKexplicit methods

Abstract
  Methods to create and modify explicit constraint expressions

Synopsis

Description

Return Value

Notes

Index

Keywords

History
  12/16/93 : Rajiv Agrawal : moved the code to save old dimension value before
                             it gets modified.

  04/25/94 : Satya         : md_env.md_env.matrix was not initialized --
			     TR# 119418290 

  01/09/95 : Satya         : Checked in the fix into EMS 3.2

 */


method SKgetval(long *msg; double *value)
{
  *msg = EMS_S_Success;
  if (ME.SKconstraint->props & SK_NOVALUE)
    *msg = EMS_I_NotFound;

  *value = ME.expression->value;

  return(OM_S_SUCCESS);
}
end implementation SKexplicit;
