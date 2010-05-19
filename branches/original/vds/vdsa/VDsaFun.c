/* $Id: VDsaFun.c,v 1.1 2001/11/09 15:10:42 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaFun.c
 *
 * Description: Smart Attribute Function Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaFun.c,v $
 *      Revision 1.1  2001/11/09 15:10:42  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:50:50  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/18/01  ah      Creation
 * 11/08/01  ah      Moved to correct directory, still need to implemnent
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

/* ------------------------------------------------------
 * Give Struct Function Interface
 */
IGRstat VDsaGiveStructureFUN(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  return 0;
}
