class implementation Root;

/* Includes */

#include "OMminimum.h"          /* OM */
#include "OMerrordef.h"           

#include "PWminimum.h"          /* Pathway */
#include "PWerror.h"

/* Prototypes */

#include "PWapi/objdel.h"

/*
  ABSTRACT

  Deletes an object from the given object space.

  NOTES

  None
*/

PWresult omDeleteObject
(
  PWobjid object,
  PWosnum os
)
{
  return (PWresult) om$send (msg = message Root.delete (0),
                             senderid = PW_K_NullObjid,
                             targetid = object,
                             targetos = os); 
}

end implementation Root; 
