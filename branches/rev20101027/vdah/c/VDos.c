/* $Id: VDos.c,v 1.5 2001/02/22 22:51:30 ahundiak Exp $  */

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
 *      $Log: VDos.c,v $
 *      Revision 1.5  2001/02/22 22:51:30  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/02/17 13:58:14  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/11 16:34:30  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
# Revision 1.1  2000/02/17  20:15:02  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/17/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDos.h"

VDASSERT_FFN("VDos.c");

/* ------------------------------------------------
 * Find os for a given name
 * The real name to number requires a full path I think
 */  
void VDosGetFileNameOS(IGRchar *name, TVDosnum *osnum)
{
  VDASSERT_FN("VDosGetFileNameOS");

  IGRchar buf[1024];
  IGRchar *p;

  VDosnum i;
  
  // Arg check
  VDASSERTW(osnum); *osnum = OM_K_NOT_AN_OS;
  VDASSERTW(name);
  
  // Cycle through
  for(i = 0; 1; i++) {
    
    *buf = 0;
    som_convert_os_number_to_name(i, buf);
    if (*buf == 0) goto wrapup;

    p = strrchr(buf,'/');
    if (p) p++;
    else   p = buf;
  
    if (!strcmp(name,p)) {
      *osnum  = i;
      goto wrapup;
    }
  }
  
wrapup:
  return;
}

/* --------------------------------------------------------------
 * Save the current file
 */
void VDosSaveFile(IGRint flag)
{
  VDosnum osnum;
  
  IGRchar fileName[256];

  // Current os
  VDosGetCurrentOS(&osnum);
  
  // Need the file name
  VDosGetFileName(osnum,fileName);
  
  // Save it
  EX_save1(fileName);

  // Done
  return;
}

/* --------------------------------------------------------------
 * Test and exit
 */
void VDexit(IGRint flag)
{
  IGRchar *p;
  
  if (flag == 0) {
    p = getenv("ISDP_EXIT");
    if (p) flag = atoi(p);
  }
  if (flag == 0) return;

  IGEExit();
}

void VDosExitFile(IGRint flag)
{
  IGRchar *p;
  
  if (flag == 0) {
    p = getenv("ISDP_EXIT");
    if (p) flag = atoi(p);
  }
  if (flag == 0) return;

  IGEExit();
}

/* --------------------------------------------------------------
 * Get the current osnum
 */
void VDosGetCurrentOS(VDosnum *osnum)
{
  EX_findmod(NULL,osnum);
}

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
  som_convert_os_number_to_name(osnum, buf);
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
  som_convert_os_number_to_name(osnum, buf);
  if (*buf == 0) goto wrapup;

  p = strrchr(buf,'/');
  if (p) p++;
  else   p = buf;
  
  if (name) strcpy(name,p);
  
  retFlag = 1;
  
wrapup:
  return retFlag;
}


