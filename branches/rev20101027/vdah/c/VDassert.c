/* $Id: VDassert.c,v 1.4 2001/02/22 22:51:30 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDassert.c
 *
 * Description:	Assert Routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDassert.c,v $
 * Revision 1.4  2001/02/22 22:51:30  ahundiak
 * *** empty log message ***
 *
 * Revision 1.3  2001/01/11 16:34:30  art
 * sp merge
 *
 * Revision 1.1  2001/01/11 16:20:57  art
 * s merge
 *
 * Revision 1.1  2000/12/06  14:51:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:11:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/24  20:46:26  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/21/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"

/* -----------------------------------------------
 * Small stack of asserts
 */
static TVDassertInfo *assertStack;
static IGRint         assertCnt;
static IGRint         assertMax;

/* -----------------------------------------------
 * Capture assert print messages
 * Redirects to log
 */
int VDassertPrint(int type, int level, char *ffn, char *fn, int line, char *msg)
{
  // printf("VDASSERT at %s %s %d",ffn,fn,line);

  VDlogPrintFmt(VDLOG_ERROR,1,"VDASSERT at %s %s %d",ffn,fn,line);
  return 1;
}

#if 0
/* -----------------------------------------------
 * Capture assert print messages
 */
int VDassertPrint(int type, int level, char *ffn, char *fn, int line, char *msg)
{
  IGRchar typec[32];
  IGRchar buf[128];
  
  // Message is optional
  if (msg == NULL) msg = "";
  
  // Decode type
  switch(type) {
  case 0:  strcpy(typec,"NULL"); break;
  default: strcpy(typec,"UNKNOWN");
  }
 
  // Print It
  fflush (stdout);
  sprintf(buf,"ASSERT *%d* %s %s %s %d %s\n",level,typec,ffn,fn,line,msg);
  fputs  (buf,stderr);
  fflush (stderr);
  
  // Stack it
  if ((assertStack) && (assertCnt < assertMax)) {
    assertStack[assertCnt].type  = type;
    assertStack[assertCnt].level = level;
    strcpy(assertStack[assertCnt].desc,buf);
  }
  
  // Done
  return 1;
}
#endif

/* -----------------------------------------------
 * Clears the stack counter
 */
IGRstat VDassertClearStack()
{
  assertCnt = 0;
  return 1;
}

/* -----------------------------------------------
 * true if any asserts have been generated since
 * the last clear
 */
IGRstat VDassertHaveAssert()
{
  if (assertCnt) return 1;
  return 0;
}

/* -----------------------------------------------
 * Givess access to the assert stack
 */
IGRstat VDassertGetStack(IGRint *cnt, TVDassertInfo **info)
{
  if (cnt)  *cnt  = assertCnt;
  if (info) *info = assertStack;
  return 1;
}

/* -----------------------------------------------
 * Print stack history
 */
IGRstat VDassertPrintStack()
{
  IGRint i;
  
  fprintf(stderr,"---------- Begin Assert Stack ----------\n");
  for(i = 0; i < assertCnt; i++) {
    printf("%2d %s\n",i,assertStack[i].desc);
  }
  fprintf(stderr,"---------- End   Assert Stack ----------\n");
  return 1;
}

/* -----------------------------------------------
 * Inits the assert stacking
 */
IGRstat VDassertInitStack(IGRint max) 
{
  // See if already created
  if (assertStack) return 1;
  
  // Alloc
  assertStack = malloc(max * sizeof(TVDassertInfo));
  if (assertStack == NULL) return 1;
  
  // Setup
  assertMax = max;
  assertCnt = 0;
  
  // Done
  return 1;
}

/* -----------------------------------------------
 * Frees the assert stacking
 */
IGRstat VDassertFreeStack() 
{
  // Clear
  assertCnt = 0;
  assertMax = 0;
  
  // Free
  if (assertStack) free(assertStack);
  assertStack = NULL;
  
  // Done
  return 1;
}






