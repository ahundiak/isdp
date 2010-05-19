/* $Id: VDos.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDos.I
 *
 * Description: Object Space Toolkit
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDos.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/02/17  20:15:02  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/17/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDos.h"

/* --------------------------------------------------------------
 * 1 If osnum is valid
 * 0 if not
 * Intended to be used when cycling through os's
 */
IGRstat VDosValidate(TVDosnum osnum)
{
  IGRstat retFlag = 0;
  IGRchar buf[1024];
  
  *buf = 0;
  om$os_number_to_name (osnum = osnum, osname = buf);
  if (*buf == 0) goto wrapup;
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------------
 * 1 If osnum is valid
 * 0 if not
 * Quick way to get the file name
 */
IGRstat VDosGetFileName(TVDosnum osnum, IGRchar *name)
{
  IGRstat retFlag = 0;
  IGRchar buf[1024];
  IGRchar *p;
  
  if (name) *name = 0;
  
  *buf = 0;
  om$os_number_to_name (osnum = osnum, osname = buf);
  if (*buf == 0) goto wrapup;

  p = strrchr(buf,'/');
  if (p) p++;
  else   p = buf;
  
  if (name) strcpy(name,p);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation Root;

