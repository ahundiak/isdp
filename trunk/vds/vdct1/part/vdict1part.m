/* $Id: vdict1part.m,v 1.1 2001/01/12 14:35:59 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/vdict1part.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1part.m,v $
 *      Revision 1.1  2001/01/12 14:35:59  art
 *      sp merge
 *
# Revision 1.6  2000/12/07  17:40:02  pinnacle
# ah
#
# Revision 1.5  2000/08/23  14:50:00  pinnacle
# ah
#
# Revision 1.4  2000/07/13  12:28:40  pinnacle
# Replaced: vds/vdct1/part/vdict1part.m for:  by jdsauby for Service Pack
#
# Revision 1.3  2000/06/30  17:28:24  pinnacle
# ah
#
# Revision 1.2  2000/06/02  14:35:42  pinnacle
# ah
#
# Revision 1.1  2000/05/31  21:04:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/31/00  ah      creation
 * 01/12/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDct1IOC.c
VDct1Fld.c
VDct1Upd.c
VDct1Ris.c
VDct1Load.c
VDct1Misc.c
VDct1Read.c
VDct1Data.c
VDct1Delim.c

#if 1
LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1part.o
#else
$VDS/lib/vdict1part.o
#endif

#else

main.c
EXEC
ptest

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
#if ISDP_MAKE_SP
$SPXV/lib/vdiahc.o
$SPXV/vdah/s/vdiahs.o
$SPXV/vdris/blobs/vdiblob.o
#else
$VDS/lib/vdiahc.o
$VDS/vdah/s/vdiahs.o
$VDS/vdris/blobs/vdiblob.o
#endif
$RIS/risdp/lib/Soli/ris.a
-lUMS
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
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
