/* $Id: VDui.c,v 1.4 2001/02/01 16:09:06 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/s/VDui.I
 *
 * Description: UI_ routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDui.c,v $
 *      Revision 1.4  2001/02/01 16:09:06  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 * Revision 1.1  2000/12/07  13:35:56  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:54:16  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:03:18  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/30/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"

/* -----------------------------------------------
 * Stub for UI_status
 */
void UI_status(IGRchar *buf)
{
  if (buf == NULL) return;
  printf("UI_status %s\n",buf);
}
