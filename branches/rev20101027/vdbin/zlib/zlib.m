/* $Id: zlib.m,v 1.1 2001/05/17 15:19:11 ahundiak Exp $  */

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
 *      $Log: zlib.m,v $
 *      Revision 1.1  2001/05/17 15:19:11  ahundiak
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
zz

LINKLIB
-lcurses
-lsocket
-lnsl
-lUMS
-lm
-lIGbspmath
-lglib
-lz

INCLUDE
$LOCAL/include/glib-1.2
$SPXV/include
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

