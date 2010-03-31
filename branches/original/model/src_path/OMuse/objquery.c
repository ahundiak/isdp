#include "OMminimum.h"
#include "OMerrordef.h"
#include "PWminimum.h"
#include "PWapi/objquery.h"


/*
  ABSTRACT

  Given an objid and it's object space number this function tests for it's
  validity. If valid then the function returns TRUE.
*/

PWboolean omIsObjidValid
(
  PWobjid objid,
  PWosnum osnum
)
{
  return (som_is_objid_valid (osnum, objid) == OM_S_SUCCESS);
}
