/* $Id: isvarp.m,v 1.1.2.1 2003/12/11 14:16:42 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdnfm/dat/dat.m
 *
 * Description: NFM Env DAT Utility
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: isvarp.m,v $
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/21/05  ah      creation
 ***************************************************************************/

SOURCE
main.c

EXEC
nfmx_pass

LINKLIB
-lcurses
-lsocket
-lnsl
-lUMS
-lm
-lX11
-lXFS
-lXFI
-lglib
-lxml2
-lxslt
-lz
$VDS_PATH/vdah/s/vdiahs.o
$VDS/lib/vdiahc.o
$VDS/lib/vdixml.o
$VDS/lib/vdixdom.o
$VDS/lib/vdictxc.o
$VDS/lib/vdirisc.o
$VDS/lib/vdirisrc.o
//opt/ingr/lib/ris.a
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
