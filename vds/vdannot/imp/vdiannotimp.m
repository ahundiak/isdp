/* $Id: vdiannotimp.m,v 1.2 2002/04/01 21:23:19 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / vdannotimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdiannotimp.m,v $
 *	Revision 1.2  2002/04/01 21:23:19  ahundiak
 *	ah
 *	
 *	Revision 1.1  2001/04/16 14:27:28  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/04/10 20:26:05  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/18  23:04:58  pinnacle
# Replaced: vdannot/imp/vdannotimp.m for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/05/09  22:33:26  pinnacle
# Replaced: vdannot/imp/vdannotimp.m for:  by yzhu for vds.240
#
# Revision 1.7  1996/01/10  17:06:18  pinnacle
# Replaced: vdannot/imp/*.m for:  by jwfrosch for vds.240
#
# Revision 1.6  1995/09/26  00:13:26  pinnacle
# Replaced: vdannot/imp/vdannotimp.m for:  by sundar for vds.240
#
# Revision 1.5  1995/07/30  19:12:54  pinnacle
# Replaced: vdannot/imp/vdannotimp.m for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/13  14:35:20  pinnacle
# Replaced: vdannot/imp/*.m for:  by jwfrosch for vds.240
#
# Revision 1.3  1994/12/12  21:31:56  pinnacle
# Replaced:  vdannot/imp/vdannotimp.m r#
#
# Revision 1.2  1994/12/07  16:15:52  pinnacle
# Replaced:  vdannot/imp/vdannotimp.m r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	12/07/94	R. Manem	New classes : VDitem, VDitemMgr, 
 *					VDitmPfxSet
 *
 *	6/15/95		tlb		New class: VDitemSet : replaces
 *						    VDitmPfxSet
 *					Merge VDmgr*.I into VDitemMgri.I
 *
 *	01/10/96          HF		The new Item Balloon functionality 
 *					requires extensions to the
 *					dim.h dimdef.h & dimanform.h header 
 *					files of GRNUC.
 *					Until this new functionality has been 
 *					integrated in
 *					EMS, these files have to remain in 
 *					vdinclude.
 *
 *					NOTE:
 *					ANY SOURCE FILE that uses ANY of the 
 *					NEW functionality
 *					HAS TO use THESE FILES in stead of the 
 *					GRNUC version.
 *					This means that $VDS/vdinclude needs 
 *					to preceed $GRNUC/include
 *					in the INCLUDE section of the <name>.m 
 *					file
 *       05/06/96       yzhu            New class: VDfrmtxt 
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDitemOver.I

#else
VDfrmtxt.S
VDfrmtxti.I
VDfrmattr.I
VDtextrot.I

VDtxbox.S
VDtxboxi.I

VDtxldr.S
VDtxldri.I

VDitbln.S
VDitblni.I
VDitblnCorr.I

VDitem.S
VDitemi.I
VDitemOver.I

VDitemMgr.S
VDitemMgri.I

VDitemSet.S
VDitemSeti.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiannotimp.o
#else
$VDS/lib/vdiannotimp.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
#endif
$VDS/include
$VDS/vdinclude
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
