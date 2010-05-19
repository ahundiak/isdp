/* $Id: vddrawcmd.m,v 1.4 2002/05/20 15:19:56 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddraw/cmd/vddrawcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddrawcmd.m,v $
 *	Revision 1.4  2002/05/20 15:19:56  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2002/02/26 16:01:10  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/10/08 22:37:32  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
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
# Revision 1.12  1995/09/26  15:16:12  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m for:  by sundar for vds.240
#
# Revision 1.11  1995/09/18  16:30:08  pinnacle
# Replaced: vddraw/cmd/*.m for:  by jwfrosch for vds.240
#
# Revision 1.10  1995/08/21  21:14:32  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m for:  by azuurhou for vds.240
#
# Revision 1.9  1995/08/21  16:52:26  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m for:  by azuurhou for vds.240
#
# Revision 1.8  1995/07/30  19:31:52  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m for:  by hverstee for vds.240
#
# Revision 1.7  1995/07/28  20:47:52  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m for:  by hverstee for vds.240
#
# Revision 1.6  1995/06/27  18:25:36  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m for:  by azuurhou for vds.240
#
# Revision 1.5  1995/03/16  19:13:40  pinnacle
# Replaced: vddraw/cmd/vddrawcmd.m by azuurhou r#
#
# Revision 1.4  1995/01/20  20:55:16  pinnacle
# Replaced:  vddraw/cmd/vddrawcmd.m r#
#
# Revision 1.3  1995/01/10  00:29:00  pinnacle
# Replaced: vddraw/cmd by azuurhou r#
#
# Revision 1.1  1994/12/22  22:10:26  pinnacle
# OPE
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/02/94	adz		creation date.
 *	01/20/95	rmn		Files for section cut command
 *	08/21/95	adz		Delete alt. section-cut command.
 *
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDCmdExDri.I
VDCmdDfDwLoi.I

#else
VDCmdExDr.S
VDCmdExDri.I
VDCmdExLoc.I

VDCmdSctCts.S
VDCmdSctCtsi.I

VDCmdDrwVw.S
VDCmdDrwVwi.I
VDCmdItmSti.I

VDCmdDfDwLo.S
VDCmdDfDwLoi.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdcdrawcmd.o
#else
$VDS/lib/vdcdrawcmd.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#ifdef ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
