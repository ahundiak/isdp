/* $Id: sp_val.m,v 1.7 2001/11/12 17:29:17 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbin/sp_pens/sp_pens.m
 *
 * Description: Spades Penetration Report
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: sp_val.m,v $
 *      Revision 1.7  2001/11/12 17:29:17  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/19 18:41:14  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/18 16:11:39  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/22 19:50:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/03 14:45:06  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/29 13:16:38  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 19:02:09  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/12 14:49:41  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/12/01  ah      creation
 ***************************************************************************/

SOURCE
main.c
test.c

EXEC
sp_val

LINKLIB
-lcurses
-lsocket
-lnsl
-lUMS
-lm
-lIGbspmath
-lX11
-lXFS
-lXFI
-lglib
-lxml2
-lxslt
-lz
$VDS_PATH/vdah/s/vdiahs.o
$VDS_PATH/lib/vdiahc.o
$VDS_PATH/lib/vdixml.o
$VDS_PATH/lib/vdixdom.o
$VDS_PATH/lib/vdictxc.o
$VDS_PATH/lib/vdirisc.o
$VDS_PATH/lib/vdirisrc.o
$VDS_PATH/lib/vdivalx1.o
$VDS_PATH/lib/vdivalx2.o
$VDS_PATH/lib/vdigeom2.o


INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$LOCAL/include/glib-1.2
$LOCAL/include
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
