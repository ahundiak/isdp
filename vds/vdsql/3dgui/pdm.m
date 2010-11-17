/* $Id: pdm.m,v 1.1.2.1 2004/03/29 16:06:27 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        aim/src/isvarp/isvarp.m
 *
 * Description: SIR Posting Utility
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: pdm.m,v $
 *      Revision 1.1.2.1  2004/03/29 16:06:27  ahundiak
 *      ah
 *
 *      Revision 1.1.2.1  2003/12/11 14:16:42  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/03  ah      creation
 ***************************************************************************/

SOURCE
main.c
db.c
part.c
extr.c
extr_ftp.c
pedigree.c
batch.c
ftp.c
log.c
ris.c
encode.c

EXEC
pdm

LINKLIB
-lcurses
-lsocket
-lnsl
-lUMS
-lm
-lIGbspmath
-lsqlite
-lX11
-lXFS
-lXFI
-lglib
-lxml2
-lxslt
-lz
$VDS_PATH/vdah/s/vdiahs.o
$VDS_PATH/vdah/c/VDdom2.o
$VDS/lib/vdiahc.o
$VDS/lib/vdixml.o
$VDS/lib/vdixdom.o
$VDS/lib/vdictxc.o
$VDS/lib/vdirisc.o
$VDS/lib/vdirisrc.o
$VDS/lib/vdivalx1.o
$VDS/lib/vdivalx2.o
$VDS/lib/vdivalx3.o
$VDS/lib/vdigeom2.o
/opt/ingr/lib/ris.a
/opt/ingr/lib/libUMS.a

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXA/include
$SPX/local/include
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
