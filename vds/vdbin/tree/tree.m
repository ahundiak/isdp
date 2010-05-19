/* $Id: tree.m,v 1.6 2002/04/24 14:34:37 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbin/tree.m
 *
 * Description: Little xml tree viewer
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: tree.m,v $
 *      Revision 1.6  2002/04/24 14:34:37  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/19 18:42:41  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/24/02  ah      creation
 ***************************************************************************/

SOURCE
main.c

EXEC
$VDS/bin/tree

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
-lgtk
-lgdk
-lgmodule
-lglib
-lxml2
-lxslt
-lz
$VDS_PATH/vdah/s/vdiahs.o
$VDS_PATH/lib/vdiahc.o
$VDS_PATH/lib/vdixml.o
$VDS_PATH/lib/vdixdom.o
$VDS_PATH/lib/vdictxc.o
$VDS_PATH/lib/vdigtk.o

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
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


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

