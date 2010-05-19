/* $Id: vdtblimp.m,v 1.6 2002/06/06 17:27:48 ylong Exp $  */

/* I/VDS
 *
 * File:	vdtbl/imp/vdtblimp.m
 *
 * Description:
 *
 * Dependencies:
 *	$Log: vdtblimp.m,v $
 *	Revision 1.6  2002/06/06 17:27:48  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.5  2002/05/15 12:57:15  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.4  2002/04/04 21:00:50  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/05/03 14:25:22  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/02/07 18:19:55  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
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
# Revision 1.2  1995/07/30  20:50:58  pinnacle
# Replaced: vdtbl/imp/vdtblimp.m for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:13:28  pinnacle
# Created: vdtbl/imp/* by tdumbach for vds.240
#
# Revision 1.2  1995/04/14  19:08:20  pinnacle
# Replaced: vdtbl/imp/vdtblimp.m by rmanem r#
#
# Revision 1.1  1995/04/14  16:10:00  pinnacle
# Created: vdtbl/imp/vdtblimp.m by tdumbach r#
# rno
#
# Revision 1.1  1995/03/08  22:00:36  pinnacle
# Created: vdtbl/imp/vdtblimp.m by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/08/95	mf		creation date
 *	04/14/95	rmn		Added source files for tables
 *	05/02/01	ylong		SP262_12
 */

SOURCE
#if ISDP_MAKE_SP
VDhdrGetPut.I
VDrowAttrVal.I
VDrowOver2.I

#else
VDdrwgrFunk.I

VDdrwTbl.S
VDtblInfo.I
VDtblInit.I
VDtblManip.I
VDtblOver.I

VDdrwTblHdr.S
VDhdrGetPut.I
VDhdrManip.I
VDhdrUpd.I
VDhdrOver1.I
VDhdrOver2.I
VDhdrOver3.I

VDdrwTblRow.S
VDrowAttrVal.I
VDrowInitNbs.I
VDrowManip.I
VDrowConstr.I
VDrowSet.I
VDrowOver1.I
VDrowOver2.I
VDtblExecPpl.I
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
/usr/ip32/forms/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$MODEL/include
$VDS/include
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vditblimp.o
#else
$VDS/lib/vditblimp.o
#endif

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc

COPT
$COMPOPT
