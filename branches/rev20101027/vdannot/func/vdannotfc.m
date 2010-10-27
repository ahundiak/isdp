/* $Id: vdannotfc.m,v 1.4 2001/08/02 16:13:31 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/func / vdannotfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdannotfc.m,v $
 *	Revision 1.4  2001/08/02 16:13:31  ad
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/07/30 17:14:32  ad
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/07/28 20:07:25  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/02/19  17:51:22  pinnacle
# tr179801788
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/12  22:09:32  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by yzhu for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.13  1996/01/10  17:06:30  pinnacle
# Replaced: vdannot/func/*.m for:  by jwfrosch for vds.240
#
# Revision 1.12  1995/09/11  20:43:38  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by jwfrosch for vds.240
#
# Revision 1.11  1995/08/29  21:12:48  pinnacle
# Replaced: vdannot/func/*.m for:  by jwfrosch for vds.240
#
# Revision 1.10  1995/07/30  19:11:46  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by hverstee for vds.240
#
# Revision 1.9  1995/07/25  22:42:44  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by jwfrosch for vds.240
#
# Revision 1.8  1995/07/25  15:51:18  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by hverstee for vds.240
#
# Revision 1.7  1995/07/21  14:01:22  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by tdumbach for vds.240
#
# Revision 1.6  1995/07/13  14:02:22  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/06/23  15:38:50  pinnacle
# Replaced: vdannot/func/vdannotfc.m for:  by yzhu for vds.240
#
# Revision 1.4  1995/06/09  21:59:44  pinnacle
# Replaced: vdannot/func/*.m for: update for rebuild by tdumbach for vds.240
#
# Revision 1.2  1995/05/26  16:18:54  pinnacle
# Replaced: vdannot/func/vdannotfc.m by yzhu r#
#
# Revision 1.3  1994/12/12  21:16:48  pinnacle
# Replaced:  vdannot/func/vdannotfc.m r#
#
# Revision 1.2  1994/12/12  16:14:20  pinnacle
# Replaced:  vdannot/func/vdannotfc.m* r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *	12/12/94	R. Manem	VDgetItemNo.I
 *	05/15/95	Y. Zhu	        VDTbl_Item.I
 *	06/22/95	Y. Zhu	        VDitemMisc.I
 *	07/21/95	T. Dumbacher	Deleted file VDitemMisc.I ( per TB ),so 
 *					had to modify vdannotfc.m.
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
 *	08/02/96	Y. Zhu	         add VDstrcaps.I
 *	02/19/99	ylong	         add VDdrw_orient.C for tr179801788
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDItemObj.I
#else
VDplace.I
VDAnnMacro.I
VDdrwMacro.I
VDgetItemNo.I
VDTbl_Item.I
VDItemObj.I
VDCmdFtxt_Fn.I
VDsrc_obj.I
VDlocate.I
VDItemSort.C
VDstrcaps.I
VDdrw_orient.C
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdannotfc.o
#else
$VDS/lib/vdannotfc.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
$VDS/include
$VDS/vdinclude
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
$VDS/vdinclude/dim.h
