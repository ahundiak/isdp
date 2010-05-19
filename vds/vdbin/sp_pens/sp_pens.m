/* $Id: sp_pens.m,v 1.9 2002/05/07 16:12:40 ahundiak Exp $  */

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
 *      $Log: sp_pens.m,v $
 *      Revision 1.9  2002/05/07 16:12:40  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/11/12 17:26:10  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/10/22 14:04:36  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/19 18:33:36  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/18 16:08:31  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/06/07 20:13:27  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/29 13:19:49  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:42:08  ahundiak
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

EXEC
$VDS_PATH/bin/sp_pens

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
/opt/ingr/lib/ris.a
/opt/ingr/lib/libUMS.a

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

CC
acc -ansi

