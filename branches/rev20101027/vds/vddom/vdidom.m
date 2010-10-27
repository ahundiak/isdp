/* $Id: vdidom.m,v 1.4 2001/05/17 14:51:35 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdxml/vdidom.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdidom.m,v $
 *      Revision 1.4  2001/05/17 14:51:35  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/22 22:44:50  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/14 16:33:39  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
# Revision 1.3  2000/12/06  15:01:18  pinnacle
# ah
#
# Revision 1.2  2000/12/01  14:01:58  pinnacle
# ah
#
# Revision 1.1  2000/08/05  16:35:24  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/05/00  ah      Creation
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDdomOM.c
VDdomObj.c
VDdomAtr.c
VDdomXml.c
VDdomMgr.c
VDdomMisc.c
VDdomCreate.c

#if ISDP_MAKE_SP
#else
VDdomTreeF.c
#endif

#if 1

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdidom.o
#else
$VDS/lib/vdidom.o
#endif

#else
VDdomTest.c

EXEC
dom

LINKLIB
-lcurses
-lxc
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
$SPXV/lib/vdiahc.o
$SPXV/vdah/s/vdiahs.o
$SPXV/vdxml/VDxmlDom.o
$SPXV/vdxml/VDxmlParse.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
