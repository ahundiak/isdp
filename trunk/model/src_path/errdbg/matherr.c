#include "bserr.h"
#include "PWminimum.h"
#include "PWerror.h"

/*
  DESCRIPTION

  This function returns the equivalent Pathway code for the input
  BS-subsystem code.
*/

PWresult pwMathRetCode
(
  long bsrc
)
{
  PWresult result;

  switch (bsrc)
  {
    case BSSUCC:
      result = SetError (PW_K_BspMath, PW_K_Success);
      break;

    case BSCOINCIDENT:
      result = SetInfo (PW_K_BspMath, PW_K_Coincident);
      break;

    case BSINARG:
      result = SetError (PW_K_BspMath, PW_K_InvalidArg);
      break;

    case BSNOSOLUTION:
      result = SetError (PW_K_BspMath, PW_K_Internal);
      break;

    case BSDGENRAT:
      result = SetError (PW_K_BspMath, PW_K_Degenerate);
      break;

    case BSPARNOTFOUND:
      result = SetError (PW_K_BspMath, PW_K_Bounds);
      break;

    case BSNOSTKMEMORY:
    case BSNOMEMORY:
      result = SetError (PW_K_BspMath, PW_K_DynamicMemory);
      break;

    default:
      result = SetInfo (PW_K_BspMath, PW_K_Error);
      break;
    }

  return (result);
}
