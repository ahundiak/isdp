/* $Id: vdict1cop.m,v 1.5 2002/04/25 15:45:04 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdbin/vdbin.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdict1cop.m,v $
 *	Revision 1.5  2002/04/25 15:45:04  ahundiak
 *	ah
 *	
 *	Revision 1.4  2002/02/26 15:33:03  ahundiak
 *	ah
 *	
 *	Revision 1.3  2001/02/23 13:18:51  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/02/20 15:22:35  ahundiak
 *	ah
 *	
 *	Revision 1.1  2001/01/11 22:16:23  art
 *	sp merge
 *	
# Revision 1.4  2000/12/07  19:40:10  pinnacle
# js
#
# Revision 1.3  2000/10/24  14:04:20  pinnacle
# js
#
# Revision 1.2  2000/10/11  20:22:34  pinnacle
# js
#
# Revision 1.1  2000/07/17  19:21:40  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/25/95  adz     creation date
 * 01/11/01  ah      sp merge
 * 02/20/01  ah      Latest XML Changes
 * -------------------------------------------------------------------*/

SOURCE
VDct1Pal.C
VDct1PalX.C
VDct1Assy.C
VDct1PartX.C
VDct1AssyX.C
VDct1CopCmd.C
VDct1EngAssyX.C
VDct1StdAssyX.C

#if 0
LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1cop.o
#else
$VDS/lib/vdict1cop.o
#endif

#else
main.C

EXEC
#if ISDP_MAKE_SP
$SP/bin/cop
#else
$VDS/bin/cop
#endif

#endif

SPEC
$EXNUC/spec

LINKLIB

#if ISDP_MAKE_SP
$SPXV/vdah/c/VDvlaInfo.o
$SPXV/vdxml/VDxml.o
$SPXV/vdxml/VDxmlParse.o
$SPXV/vdxml/VDxmlParseS.o
$SPXV/vdxml/VDxmlDom.o
#else
$VDS/vdah/c/VDvlaInfo.o
$VDS/vdah/c/VDassert.o
$VDS/vdah/c/VDgbl.o
$VDS/vdah/c/VDlog.o
$VDS/vdah/c/VDsys.o
$VDS/vdah/s/vdiahs.o
$VDS/vdxml/VDxml.o
$VDS/vdxml/VDxmlParse.o
$VDS/vdxml/VDxmlParseS.o
$VDS/vdxml/VDxmlDom.o

#endif
-lcurses
-lxc
#ifdef ENV5
-lbsd
-lPW
-lgpipe_s
-linc
-lnsl_s
-lforms
-ltools_s
-lc_s
#else
-lXFI
-lXFS
-lm
-ldl
-lnsl
-lXt
-lX11
-lXext
-lsocket
-lnsl
#endif


INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
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

$(EXNUC)/include
OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

