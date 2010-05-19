#/* $Id: vdiatspec.m,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

#/***************************************************************************
# * I/VDS
# *
# * File:	vdat/spec/vdiatspec.o
# *
# * Description:
# *
# * Dependencies:
# *
# * Revision History:
# *	$Log: vdiatspec.m,v $
# *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
# *	Initial import to CVS
# *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/03/29  14:21:14  pinnacle
# AssyTree
#
# *
# * History:
# * MM/DD/YY  AUTHOR  DESCRIPTION
# * 11/25/97  ah      creation
# *
# ***************************************************************************/

SOURCE
VDatSetMgr.S
VDatFrmMgr.S
VDatPdmMgr.S
VDatStages.S
VDatStage.S
VDatTables.S
VDatTable.S
VDatSets.S
VDatSet.S
VDatNodes.S
VDatNode.S
VDatTrees.S
VDatTree.S
VDatRoot.S
VDatLeafs.S
VDatLeaf.S
VDatPieces.S
VDatPlates.S
VDatBeams.S
VDatOthers.S
VDatRDBCache.S
VDatRDBTran.S
VDatRDBSets.S
VDatRDBSet.S
VDatRDBNodes.S
VDatRDBNode.S
VDatRDBPosts.S
VDatRDBPost.S
VDatRDBAttrs.S
VDatRDBAttr.S
VDatRDBMacs.S
VDatRDBMac.S
VDatNB.S
VDatDynMgr.S
VDatDynTbls.S
VDatDynTbl.S
VDatDynRecs.S
VDatDynRec.S

LIB
$VDS/lib/vdiatspec.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
