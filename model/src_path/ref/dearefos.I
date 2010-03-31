/* ------------------------------------------------------------------------- */
/*                                                                           */ 
/*-------------------------------------------------------------------------- */ 
/*
API Definition

  ABSTRACT

  This API deactivates the given reference file by OS. 

  NOTES
  This API returns no error. This has become necessary b'coz an API should
  not differentiate between Master and Reference File and since now Activation
  API has been modified to accept master os, deactivation for master is now
  accepted. 

  ARGUMENTS

  KEYWORDS

  Deactivation, Reference File, OS

  CAVEATS

  None so far

  HISTORY

  Satish - Creation -

*/

class implementation Root;

#include "OMminimum.h"
#include "exmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "refmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "madef.h"

#include "exudata.h"

PWresult pwDeactivateOS
(
)
{
   int status;
   IGRboolean aflag;

   exUDataActref rfact;

   aflag = pwIsActivationOn();
   if (aflag)
   {
      /** Update the global variables **/
      rfact.aflag = FALSE;
      rfact.osn   = 0;
      rfact.refid.objid = NULL_OBJID;

      status = exPostUData(EX_UDATA_ACTREF, (char *)&rfact);
   }
   return(PW_K_Success);
}


end implementation Root;
