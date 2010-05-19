/* $Id: VDref.I,v 1.1 2002/01/03 14:44:41 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdah/om/VDref.I
 *
 * Description: Reference File Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDref.I,v $
 *      Revision 1.1  2002/01/03 14:44:41  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/30/01  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDdir.h"
#include "VDos.h"
#include "VDobj2.h"

VDASSERT_FFN("VDref.I");

static void getFileName(IGRchar *buf)
{
  IGRint len = strlen(buf);
  IGRchar *p;
  
  // Drop trailing :
  if (len < 1) goto wrapup;
  if (*(buf+len-1) == DIR_G_car_dir) *(buf + len - 1) = 0;
  
  // Drop begging
  p = strrchr(buf,DIR_G_car_dir);
  if (p) strcpy(buf,p+1);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Return a list of reference file os's
 * The current os is always the first os in the list
 * Uses the :ref: directory
 * Caller must free the list
 */
void VDrefGetOSs(IGRint *a_cnt, VDosnum **a_osnums)
{
  VDASSERT_FN("VDrefGetOSs");
  
  VDosnum  curOS;
  VDosnum  osnum;
  VDosnum *osnums;
  
  IGRchar path[DI_PATH_MAX];
  
  IGRint i,j,diCnt,osCnt;
  
  IGRchar buf[128];

  // Arg check
  VDASSERTW(a_cnt);    *a_cnt = 0;
  VDASSERTW(a_osnums); *a_osnums = NULL;
  
  // Current os
  VDosGetCurrentOS(&curOS);
  
  // Query ref directory
  *path = 0;
  di$give_pathname(osnum = curOS, pathname = path);
  if (*path == 0) goto wrapup;
  DIstrcat(path,"ref");
  DIstrcat(path,"*");
  diCnt = 0;
  di$start_dump(regexp = path, ptr = &diCnt);

  // Alloc (accept that we usually allocate 1 too many)
  osnums = malloc((diCnt + 1) * sizeof(VDosnum));
  VDASSERTW(osnums);
  osnums[0] = curOS;
  osCnt = 1;
  
  // Cycle and add
  for(i = 0; i < diCnt; i++) {

    di$fetch_dump(index = i, line = buf);
    getFileName(buf);    
    VDosGetFileNameOS(buf,&osnum);

    if (osnum != OM_K_NOT_AN_OS) {

      // Prevent dups
      for(j = 0; (j < osCnt) && (osnums[j] != osnum); j++);
      if (j == osCnt) {
	osnums[osCnt] = osnum;
	osCnt++;
      }
    }
  }
  
  // Results
  *a_cnt = osCnt;
  *a_osnums = osnums;
    
 wrapup:
  
  return;
}
end implementation Root;
