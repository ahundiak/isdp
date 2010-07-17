/* $Id: vsmkrdbfile.m,v 1.2 2001/01/08 19:52:15 art Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	vsmkrdbfile/vsmkrdbfile.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsmkrdbfile.m,v $
 *	Revision 1.2  2001/01/08 19:52:15  art
 *	ah
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1995/12/04  22:53:40  pinnacle
# Replaced: ./vsmkrdbfile/vsmkrdbfile.m for:  by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/25/95	adz		creation date
 *      01/05/01        ah              Removed unnecessary hlib
 * -------------------------------------------------------------------*/

SOURCE
VSlogname.c
VSridata.c
VSrifamform.c
VSriio.c
VSrimain.c
VSrimatform.c
VSrimsg.c
VSriselform.c
VSritimform.c


EXEC
$STRUCT/bin/Mkrdbfile

SPEC
$EXNUC/spec

LINKLIB
-lcurses
-lUMS
-lxc
#ifdef ENV5
$EXNUC/lib/libexnuc.a
-lbsd
-lPW
-lgpipe_s
-linc
-lnsl_s
-lforms
-ltools_s
-lc_s
#else
$EXNUC/lib/libXexnuc.a
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
#endif
-lm

INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude
$(STRUCT)/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi

