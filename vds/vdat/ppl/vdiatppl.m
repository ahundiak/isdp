/* $Id: vdiatppl.m,v 1.2 2001/01/11 20:41:59 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/ppl/vdiatppl.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatppl.m,v $
 *      Revision 1.2  2001/01/11 20:41:59  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.8  2000/01/10  17:12:02  pinnacle
# Posting and pcmk
#
# Revision 1.7  1999/01/25  22:51:06  pinnacle
# Replaced: vdat/ppl/vdiatppl.m for:  by vsrivast for vds
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/09/98  ah      Created
 * 01/25/99  vinit   Added VDatLocate.u
 * 01/10/00  ah      Added COatPost,COatStd,pcmk
 ***************************************************************************/

CCIOPT        -Xnoargchk -m -q

COatMgr.u
COatMgrDel.u
COatMgrShow.u
COatPost.u
COatStd.u

VDatNode.u
VDatSets.u
VDatLocate.u

StagingTree.u
StepTree.u
PipeTree.u
FabData.u

FIstatus.u


