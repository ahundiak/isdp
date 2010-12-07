/***************************************************************************
 * I/AIM
 *
 * File:        sir2/VDPaimDelete.I
 *
 * Description: Some usefule delete routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimDelete.I,v $
 *      Revision 1.1.2.2  2004/02/27 15:00:07  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/09/03  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDobj.h"
#include "VDobj2.h"
#include "VDtest.h"
#include "VDdom2.h"

#include "VDos.h"
#include "VDdir.h"
#include "VDpdm.h"
#include "VDrisc.h"

#include "VDPaimUtil.h"

/* ----------------------------------------------
 * Clear out the item cache
 * Copied from Jeff's ppl.
 */
void VDPaimDeleteItemCache()
{
  VDosnum osnum;
  char    filename[1024];
  char    path[1024];
  DIgrid *grids = NULL;
  int     i, cnt;
  IGRlong sts;

  /* Get current os */
  VDosGetCurrentOS(&osnum);
    
  /* Get the active filename */
  VDosGetFileName(osnum,filename);
  if (*filename == 0) goto wrapup;

  /* Build the directory path */
  sprintf(path,":%s:itemdb",filename);

  /* list items */
  sts = di$find(start_dir = path,
	        regexp    = "*",
	        grids     = &grids,
	        ptr       = &cnt);
  if (sts != DIR_S_SUCCESS) goto wrapup;

  /* And delete */
  for (i = 0; i < cnt; i = i + 1) 
  {
    gr$delete_object(msg = &sts,
                     object_id    = &grids[i],
                     display_flag = 0);
  }
    
wrapup:
  if (grids) free( grids);
  return;
}

/* ----------------------------------------------
 * Delete local copies of the FSI expressions
 */
void VDPaimDeleteFSIExpressions()
{
  IGRstat msg;
  VDosnum osnum;

  /* Get current os */
  VDosGetCurrentOS(&osnum);

  /* Easy */
  VDtbl_exp_del(&msg,osnum,"FSI_equip");
  VDtbl_exp_del(&msg,osnum,"FSI_pipe");
  VDtbl_exp_del(&msg,osnum,"FSI_hvac");
  VDtbl_exp_del(&msg,osnum,"FSI_rway");

  /* Done */
  return;
}
   
end implementation Root;

