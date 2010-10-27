/* $Id: VDbuf.c,v 1.2 2001/08/10 15:13:51 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDobj.c
 *
 * Description: Object Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbuf.c,v $
 *      Revision 1.2  2001/08/10 15:13:51  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/14 18:46:51  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/14/00  ah      Creation
 ***************************************************************************/

/* -----------------------------------------------
 * These are stub routines needed by standalone programs
 * which use VDlog functions
 *
 * The real om implementations are in vdahom directory
 * Those functions will override these
 */

#include "VDtypedefc.h"
#include "VDassert.h"
/* #include "VDbuf.h" */

VDASSERT_FFN("vdah/s/VDbuf.c");

IGRstat VDbufGetInternalData(TGRobj_env *bufOE, IGRchar **data)
{
  return 1;
}
IGRstat VDbufPlaceMacro(IGRchar    *libName,
			IGRchar    *macName,
			IGRchar    *name,
			IGRchar    *data,
			TGRobj_env *macOE)
{
  return 1;
}
IGRstat VDbufCreateDrawingGeometry(VDosnum osnum, IGRint size, TGRid *drwGmID)
{
  return 1;
}

IGRstat VDbufCreateCollector(VDosnum osnum, TGRid *colID)
{
  return 1;
}

IGRstat VDbufAddGeometryChild(TGRid *drwGmID, TGRid *childID)
{
  return 1;
}

IGRstat VDbufGetDomTree(TGRobj_env *bufOE, TGRid *treeID)
{
  return 1;
}

