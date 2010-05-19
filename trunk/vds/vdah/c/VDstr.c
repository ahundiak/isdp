/* $Id: VDstr.c,v 1.3 2001/01/11 16:34:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDstr.c
 *
 * Description:	String processing
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDstr.c,v $
 * Revision 1.3  2001/01/11 16:34:30  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:58  art
 * s merge
 *
 * Revision 1.1  2000/12/07  17:34:44  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/07/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

VDASSERT_FFN("vdah/VDstr.c");

void strupr(IGRchar *buf)
{
  IGRint  del = 'a' - 'A';
  IGRchar *p;
  
  if (buf == NULL) return;
  for(p = buf; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p = *p - del;
  }
  return;
}
void strlwr(IGRchar *buf)
{
  IGRint  del = 'a' - 'A';
  IGRchar *p;
  
  if (buf == NULL) return;
  for(p = buf; *p; p++) {
    if ((*p >= 'A') && (*p <= 'Z')) *p = *p + del;
  }
  return;
}








