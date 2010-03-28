/*

Name
  SSExit.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <memory.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "SSmacros.h"
#include "bserr.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"


/*

Name
  SSExit

Abstract
 Closes the Smart Sketch (free data, ...). Note that it deactivates the
 Smart Sketch. This routine should be called in the sleep of a command
 that uses the Smart Sketch.

Synopsis
  int SSExit ( )

Description

Return Value
  OM_S_SUCCESS  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */
int SSExit ()
{
  int  index;

  for (index = 0; index < SSnb_objects; index++)
  {
    SSListFreeMember(index);
  }

  SSnb_objects = 0;
  SSLastAvailable = 0;

  /* TR 119313968 12/7/93 */
  SSLastObject1 = NULL;
  SSLastObject2 = NULL;

  ss$deactivate ();

  return OM_S_SUCCESS;
}

end implementation Root;

