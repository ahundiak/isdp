/* $Id: VDvlaInfo.c,v 1.3 2001/01/11 16:34:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDvlaInfo.C
 *
 * Description:	VLA Info Processing
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDvlaInfo.c,v $
 * Revision 1.3  2001/01/11 16:34:30  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:58  art
 * s merge
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:11:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/11  14:22:22  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/11/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDvlaInfo.h"

/* -----------------------------------------------
 * Grab the count
 */
IGRstat VDvlaGetInfoCnt(TVDvlaInfo *info, IGRint *cnt)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt == NULL) goto wrapup;

  // Get it
  if (info) *cnt = info->cnt;
  else      *cnt = 0;
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth data
 */
IGRstat VDvlaGetNthInfoData(TVDvlaInfo *info, IGRint nth, void **data)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (data == NULL) goto wrapup;
  *data = NULL;

  // Have something
  if (info == NULL) goto wrapup;
  if (info->data == NULL) goto wrapup;
  
  // Bound check
  if ((nth < 0) || (nth >= info->cnt)) goto wrapup;
  
  // get it
  *data = info->data[nth];
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Append data set, realloc list if required
 */
IGRstat VDvlaAppendInfo(TVDvlaInfo *info, void *data)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (info == NULL) goto wrapup;
  if (data == NULL) goto wrapup;
   
  // Allocate more room if required
  if (info->cnt >= info->max) {
    
    info->max += info->inc;
    info->data = realloc(info->data,info->max * sizeof(void*));
    if (info->data == NULL) {
      printf("*** Problem allocating VDvlaInfo structure\n");
      goto wrapup;
    }
  }
  
  // Append it
  if (info->cnt < info->max) {
    info->data[info->cnt] = data;
    info->cnt++;
    retFlag = 1;
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get things started
 */
IGRstat VDvlaInitInfo(TVDvlaInfo *info, IGRint size, IGRint max, IGRint inc)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (info == NULL) goto wrapup;
  
  // Clear
  memset(info,0,sizeof(TVDvlaInfo));
  
  // Setup
  info->size = size;
  info->max  = max;
  info->inc  = inc;
  
  // Allocate initial set of pointers
  if (info->max == 0) {
    retFlag = 1;
    goto wrapup;
  }
  info->data = malloc(info->max * sizeof(void *));
  if (info->data == NULL) {
    printf("Problem allocating VDvlaInfo structure\n");
    goto wrapup;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Free up memory
 */
IGRstat VDvlaFreeInfo(TVDvlaInfo *info)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  // Arg check
  if (info == NULL) goto wrapup;

  // Make sure have some data
  if (info->data == NULL) {
    memset(info,0,sizeof(TVDvlaInfo));
    retFlag = 1;
    goto wrapup;
  }
  
  // Free all the active information
  for(i = 0; i < info->cnt; i++) {
    if (info->data[i] != NULL) free(info->data[i]);
  }
  // Free the list
  free(info->data);
  
  // Reset and done
  memset(info,0,sizeof(TVDvlaInfo));
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


