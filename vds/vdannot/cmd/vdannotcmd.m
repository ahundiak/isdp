/* $Id: vdannotcmd.m,v 1.4 2001/11/08 16:13:59 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / vdannotcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdannotcmd.m,v $
 *	Revision 1.4  2001/11/08 16:13:59  hans
 *	Fix for TR# MP5641
 *	
 *	Revision 1.3  2001/09/14 15:06:16  ylong
 *	highlight selected table
 *	
 *	Revision 1.2  2001/01/19 23:10:07  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/01/10  17:06:06  pinnacle
# Replaced: vdannot/cmd/*.m for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/09/25  23:53:46  pinnacle
# Replaced: vdannot/cmd/vdannotcmd.m for:  by sundar for vds.240
#
# Revision 1.6  1995/07/30  19:10:42  pinnacle
# Replaced: vdannot/cmd/vdannotcmd.m for:  by hverstee for vds.240
#
# Revision 1.5  1995/07/25  15:51:38  pinnacle
# Replaced: vdannot/cmd/vdannotcmd.m for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/13  18:44:24  pinnacle
# Replaced: vdannot/cmd/vdannotcmd.m for:  by yzhu for vds.240
#
# Revision 1.3  1995/01/06  19:48:26  pinnacle
# Replaced:  vdannot/cmd/vdannotcmd.m r#
#
# Revision 1.2  1994/12/20  17:18:00  pinnacle
# Replaced:  vdannot/cmd/vdannotcmd.m r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.2  1994/11/11  19:58:28  pinnacle
# version 2.3.2 integrated
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	12/20/94	R. Manem	Added VDRvItmUpd.I and VDRvItmForm.I
 *					to support new form of command for
 *					"Review elements with item numbers"
 *	06/30/95	Y.Zhu	        Added VDCmdDeItPr.S and VDCmdDeItPri.I 
 *                                      and VDDeItmPrFrm.I for "Define Item 
 *                                      Prefix Definition" command
 *
 *	01/10/96          HF		The new Item Balloon functionality requires extensions to the
 *					dim.h dimdef.h & dimanform.h header files of GRNUC.
 *					Until this new functionality has been integrated in
 *					EMS, these files have to remain in vdinclude.
 *
 *					NOTE:
 *					ANY SOURCE FILE that uses ANY of the NEW functionality
 *					HAS TO use THESE FILES in stead of the GRNUC version.
 *					This means that $VDS/vdinclude needs to preceed $GRNUC/include
 *					in the INCLUDE section of the <name>.m file
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDCmditemi.I
VDCmditemEx.I
VDCmdtxldrEx.I
#else
VDCmdAnnot.S
VDCmdAnnoti.I
VDCmdAnnotEx.I

VDCmdtxldr.S
VDCmdtxldri.I
VDCmdtxldrEx.I

VDCmditem.S
VDCmditemi.I
VDCmditemEx.I

VDCmdAutxt.S
VDCmdAutxti.I


VDCmdFtxt.S
VDCmdFtxti.I
VDCmdFtxt_Pr.I
VDCmdFtxt_Ms.I
VDCmdFtxt_Nt.I
VDCmdFtxt_IO.I

VDCmdRvItem.S
VDCmdRvItemi.I
VDRvItmForm.I
VDRvItmUpd.I
VDCmdRvIt_Fn.I

VDgtedit.I		# Control command "Edit Annotation Text"

VDCmdDeItPr.S
VDCmdDeItPri.I
VDDeItmPrFrm.I

VDCmdAutxtf.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdcannotcmd.o
#else
$VDS/lib/vdcannotcmd.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$VDS/include
$VDS/vdinclude
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
