/*
  ABSTRACT

  This function alters the input bit-field, using the change-bits sent in
  and the option specified (EMS_O_ON, EMS_O_OFF, EMS_O_TOGGLE, EMS_O_SET).


  HISTORY

  SS  :  Apr 2, 1995  :  Creation
*/

#include "igrtypedef.h"
#include "EMSopt.h"

EMbitmanip (bitfield, chgbits, option)
IGRushort *bitfield, chgbits;
IGRshort option;
{
  IGRboolean status=TRUE;
  void EFtoggle();

  switch (option)
  {
    case EMS_O_ON:
      (*bitfield) |= chgbits;
      break;

    case EMS_O_OFF:
      (*bitfield) &= (~chgbits);
      break;

    case EMS_O_TOGGLE:
      EFtoggle (chgbits, bitfield);
      break;

    case EMS_O_SET:
      (*bitfield) = chgbits;
      break;

    default:
      status = FALSE;
      break;
  }

  return (status);
}

