/* $Id: replaceOS.m,v 1.2 2002/04/15 14:35:21 ahundiak Exp $  */

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
 *      $Log: replaceOS.m,v $
 *      Revision 1.2  2002/04/15 14:35:21  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/02/28 22:07:24  ahundiak
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

EXEC
$VDS/bin/replaceOS

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
-lz

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

