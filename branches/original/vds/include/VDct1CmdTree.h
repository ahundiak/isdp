/* $Id: VDct1CmdTree.h,v 1.2 2001/01/09 22:17:07 art Exp $  */

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
 *      $Log: VDct1CmdTree.h,v $
 *      Revision 1.2  2001/01/09 22:17:07  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.4  2000/09/25  20:21:32  pinnacle
 * js
 *
 * Revision 1.3  2000/09/20  21:09:34  pinnacle
 * js
 *
 * Revision 1.2  2000/07/27  15:11:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/21  19:04:36  pinnacle
 * Created: vds/include/VDct1CmdTree.h by pnoel for Service Pack
 *
 * Revision 1.3  2000/01/11  22:23:12  pinnacle
 * ah
 *
 * Revision 1.2  1999/10/26  17:50:08  pinnacle
 * ah
 *
 * Revision 1.1  1999/06/29  18:16:56  pinnacle
 * ct
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
 * 10/26/99  ah      Misc Changes
 * 01/09/01  ah      sp merge
 ***************************************************************************/

#ifndef VDct1CmdTree_include
#define VDct1CmdTree_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDfrmMacros_include
#include "VDfrmMacros.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* --------------------------------------
 * working to have a list of all nodes
 * in a particular tree.  This struct will
 * be of a node.  TVDct1NodeInfo.
 */
typedef struct
{
  TVDct1JD      parentJD;
  TVDct1JD      nodeJD;
  TVDctBaseInfo info;
} TVDct1NodeInfo;

/* -------------------------------------
 * NodeInfo list of all nodes in tree
 */
typedef struct
{
  IGRint         max;
  IGRint         inc;
  IGRint         cnt;
  TVDct1NodeInfo *nodes;
} TVDct1NodeInfos;

// init and free functions
extern IGRstat VDct1InitNodeInfos __((TVDct1NodeInfos *infos));
extern IGRstat VDct1FreeNodeInfos __((TVDct1NodeInfos *infos));

/* ---------------------------------------
 * User Info struct for setting user info
 * at node creation
 */
typedef struct 
{

  TGRobj_env   *objOE;
  TGRid        *windowID;
  TGRsymbology *symb;
  
} TVDct1UserInfo;



extern IGRstat VDct1FormFillTree        __((Form form, IGRint gadget, TGRid *setID));
extern IGRstat VDct1FormNotifyTree      __((Form form, IGRint gadget, TGRid *nodeID));
extern IGRstat VDct1FormUpdateTreeRow   __((Form form, IGRint gadget, TGRid *rowID));
extern IGRstat VDct1FormDeleteTreeRowID __((Form form, IGRint gadget, TGRid *rowID));

// The user has clicked on the expand column in a tree form
// Just a wrapper to the ppl ~pn

extern IGRstat VDct1PreExpandContractNode 
                        __((TGRid *nodeID, 
			    IGRchar *op));
#omdef vdct1$PreExpandContractNode(nodeID,
				   op)
VDct1PreExpandContractNode((nodeID),(op))
#endomdef

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif




