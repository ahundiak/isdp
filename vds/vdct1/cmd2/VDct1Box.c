/* $Id: VDct1Box.c,v 1.1 2001/01/14 16:21:13 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/cmd/Vct1Box.C
 *
 * Description: Message Box Routines
 *              Just use system boxes for now but
 *              Later implement custom version
 *              Also handles test mode
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Box.c,v $
 *      Revision 1.1  2001/01/14 16:21:13  art
 *      sp merge
 *
 * Revision 1.3  2000/12/07  13:41:14  pinnacle
 * ah
 *
 * Revision 1.2  2000/08/17  11:31:40  pinnacle
 * js
 *
 * Revision 1.1  2000/08/08  16:35:04  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/08/00  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDfrmc.h"
#include "VDassert.h"

#include "VDct1Cmdx.h"
#include "VDct1Forms.h"

#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Trace.h"


VDASSERT_FFN("vdct1/cmd/VDct1Box.c");

/* -----------------------------------------------
 * Stick with the idea of using static local data for now
 */
static TVDct1CmdInfo *cmdInfo;

/* -----------------------------------------------
 * Pops up yes or no box
 * Yes during testing
 */
IGRstat VDct1CmdBoxYesOrNo(IGRchar *msg, IGRint *yesFlag)
{
  
  VDASSERT_FN("VDct1CmdBoxMsg");
  IGRstat retFlag = 1;
  IGRstat sts;
  
  // Arg check
  VDASSERTW(yesFlag); *yesFlag = 0;
  VDASSERTW(msg);
  
  // running a test?
  if (cmdInfo->isTest) {
    printf("YES %s\n",msg);
    *yesFlag = 1;
    goto wrapup;
  }
  
  // Use standard until custom is ready
  sts = GRconfirm_box(msg);
  if (!(sts & 1)) *yesFlag = 1;
  
  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pops up message box
 */
IGRstat VDct1CmdBoxMsg(IGRchar *msg)
{
  VDASSERT_FN("VDct1CmdBoxMsg");
  IGRstat retFlag = 1;
  
  // Arg check
  VDASSERTW(msg);
  
  // running a test?
  if (cmdInfo->isTest) {
    printf("MSG %s\n",msg);
    goto wrapup;
  }
  
  // Use standard until custom is ready
  VDnotify_box(msg);   

  // Done
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Master init routine
 */
IGRstat VDct1CmdInitBoxCmdInfo(TVDct1CmdInfo *a_cmdInfo)
{
  VDASSERT_FN("VDct1CmdInitBoxCmdInfo");
  IGRstat retFlag = 0;
  IGRstat sts;

  TVDct1CmdFormInfo *formInfo;
  
  // Arg check
  VDASSERTW(a_cmdInfo);
  
  // Say Hi
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_COM);

  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  // Set the statics
  cmdInfo =  a_cmdInfo;

  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %d\n",ffn(),fn,retFlag);
  }
  return retFlag;
}
