/* $Id: vdictytest.m,v 1.1 2001/01/14 16:01:22 art Exp $  */

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
 *	$Log: vdictytest.m,v $
 *	Revision 1.1  2001/01/14 16:01:22  art
 *	sp merge
 *	
# Revision 1.1  2000/12/06  15:14:48  pinnacle
# ah
#
# Revision 1.1  2000/12/01  14:07:52  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/29/00  ah      Creation
 *
 * -------------------------------------------------------------------*/

SOURCE
main.c
VDct1Root.c
VDct1Test.c
VDct1Mgr.c
VDct1Set.c
VDct1Box.c

EXEC
test1

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
$SPXV/lib/vdidom.o
$SPXV/lib/vdict1part.o
$SPXV/lib/vdictxc.o
$SPXV/lib/vdictybase.o
$SPXV/vdxml/VDxmlParse.o
$SPXV/vdxml/VDxmlDom.o
$SPXV/vdah/s/vdiahs.o
$SPXV/vdris/blobs/vdiblob.o
$RIS/risdp/lib/Soli/ris.a
-lUMS


INCLUDE
$SPXV/include
$SPXV/vdinclude
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
$RIS/risdp/include


