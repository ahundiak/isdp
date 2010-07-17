/* $Id: sms.m,v 1.1 2001/09/14 13:45:30 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbin/tree2/tree2.m
 *
 * Description: XML Tree Viewer
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: sms.m,v $
 *      Revision 1.1  2001/09/14 13:45:30  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/29 13:14:29  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/24 20:24:06  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/05/17 15:17:37  ahundiak
 *      *** empty log message ***
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
diff.c

EXEC
sms

LINKLIB
-lcurses
-lsocket
-lnsl
-lUMS
-lm
-lIGbspmath
-ldl 
-lXext 
-lX11
-lXFS
-lXFI
-lxml2
$VDS_PATH/vdah/s/vdiahs.o
$VDS_PATH/lib/vdiahc.o
$VDS_PATH/lib/vdidom.o
$VDS_PATH/lib/vdixml.o
$VDS_PATH/lib/vdicdom.o
$VDS_PATH/lib/vdixdom.o
$VDS_PATH/lib/vdictxc.o
$VDS_PATH/lib/vdirisrc.o
$VDS_PATH/lib/vdigeom2.o
$VDS_PATH/lib/vdivalx1.o
../VLsmsPdf.o
../VLsmsLog.o
$LOCAL/lib/libgtk.a
$LOCAL/lib/libgdk.a
$LOCAL/lib/libgmodule.a
$LOCAL/lib/libglib.a
$LOCAL/lib/libz.a
/opt/ingr/lib/ris.a
/opt/ingr/lib/libUMS.a

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXL/include
#endif
$LOCAL/include/gtk-1.2
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
$LOFT/include


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

