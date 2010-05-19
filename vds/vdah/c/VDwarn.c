/* $Id: VDwarn.c,v 1.1 2002/04/01 15:31:50 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdah/om/VDwarn.c
 *
 * Description: A few misc routines, move to c for pload
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDwarn.c,v $
 *      Revision 1.1  2002/04/01 15:31:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/11/16 14:26:12  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"

VDASSERT_FFN("VDwarn.c");

static IGRint warn_struct_2nd_parent_is_missing = 0;

IGRint VDwarnGetStruct2ndParentIsMissing()
{
  return warn_struct_2nd_parent_is_missing;
}
void VDwarnSetStruct2ndParentIsMissing(IGRint flag)
{
  warn_struct_2nd_parent_is_missing = flag;
  return;
}
