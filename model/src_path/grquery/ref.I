
class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/objaccess.h"
#include "PWapi/clsid.h"

#include <string.h>

/* Imported methods */

from GRreffile  import GRrfgetfilename;

int pwGetNumRefFiles
(
  PWosnum osnum
)
{
  PWresult result=PW_K_Success;

  PWclassid refFileClassid;
  int refCount = 0;
  int numEligClass = 1, numIneligClass = 0;


  refFileClassid = omClassidFromName ("GRreffile", osnum);

  result = omGetObjsOfClass (numEligClass, &refFileClassid, 
             numIneligClass, NULL, osnum, &refCount, NULL);
  OnErrorCode (result, wrapup);

wrapup:

  PW_Wrapup (result, "pwNumRefFiles");
  return (refCount);

}

PWresult pwGetRefFiles
(
  PWosnum osnum,
  int *NumRefFiles,
  char **RefFileNames 
)
{
  PWresult result=PW_K_Success;
  char refName[256];
  int   sts, i;
  long  msg;

  PWclassid refFileClassid;
  int refCount = 0;
  PWobjid *refObjs = NULL;
  int numEligClass = 1, numIneligClass = 0;

  OnErrorState (!(*RefFileNames), result, 
            SetError (PW_K_Pathway, PW_K_Memory), wrapup);
     
  refFileClassid = omClassidFromName ("GRreffile", osnum);


  result = omGetObjsOfClass (numEligClass, &refFileClassid, 
             numIneligClass, NULL, osnum, &refCount, &refObjs);
  OnErrorCode (result, wrapup);


  OnErrorState ((refCount > *NumRefFiles), result, 
            SetError (PW_K_Pathway, PW_K_Memory), wrapup);

  *NumRefFiles = refCount;
  
  if(refCount)
  {
      for (i = 0; i < refCount; i++)
      {
	    sts = om$send (msg = message GRreffile.GRrfgetfilename(&msg, refName),
		targetid = refObjs[i], targetos = osnum, senderid = refObjs[i]);
        OnErrorState (!(1&sts&msg), result, 
                    SetError (PW_K_Pathway, PW_K_Internal), wrapup);

	    strcpy(RefFileNames[i], refName);
      }
  }


wrapup:
  if (refObjs) {  free(refObjs); refObjs = NULL; }

  PW_Wrapup (result, "pwGetRefFiles");
  return (result);
}

end implementation Root;
