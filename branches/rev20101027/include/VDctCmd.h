/* $Id: VDctCmd.h,v 1.2 2001/01/09 22:25:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDctCmd.h
 *
 * Description: Command Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctCmd.h,v $
 *      Revision 1.2  2001/01/09 22:25:31  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/04/21  19:05:22  pinnacle
 * Created: vds/include/VDctCmd.h by pnoel for Service Pack
 *
 * Revision 1.2  1999/05/30  14:16:46  pinnacle
 * ah
 *
 * Revision 1.1  1999/05/28  12:43:54  pinnacle
 * ct
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 * 01/09/01  ah      sp merge
 ***************************************************************************/

#ifndef VDctCmd_include
#define VDctCmd_include

#ifndef   VDahFrm_include
#include "VDahFrm.h"
#endif

// For hilites
#ifndef   dpdef_include
#include "dpdef.h"
#endif

#ifndef   dpmacros_include
#include "dpmacros.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

typedef struct {
  struct 
  {
    Form   form;
    IGRint displayed;
  } mgr,set,leaf,tree,stage,rep,attr,pcmk,rpt;
  
  // Selected by user
  Form    form;
  IGRint  gadget;
  
  // Misc
  IGRint         inittedOK;
  IGRint         shutdown;
 
  VDclassid      classIDs[16];
  OM_S_CLASSLIST classList;
  
} TVDctCmdInfo;

#endif






