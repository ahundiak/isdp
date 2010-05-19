/* $Id: VDctyMisc.c,v 1.1 2001/01/14 16:00:47 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctyMisc.c
 *
 * Description: Misc routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctyMisc.c,v $
 *      Revision 1.1  2001/01/14 16:00:47  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDcty.h"

VDASSERT_FFN("vdcty/base/VDctyMisc.c");

/* -----------------------------------------------
 * Helper to fill up attribute info
 */
void VDctySetAttrInfo(IGRchar *name,
		      IGRint   type,
		      IGRchar *base,
		      IGRchar *desc,
		      TVDctyAttrInfo *info)
{
  VDASSERT_FN("VDctySetAttrInfo");

  // Arg check
  VDASSERTW(info);
  memset(info,0,sizeof(TVDctyAttrInfo));
  
  // Doit
  if (name) strcpy(info->name,name);
  if (base) strcpy(info->base,base);
  if (desc) strcpy(info->desc,desc);
  info->type = type;
  
 wrapup:
  return;
}




