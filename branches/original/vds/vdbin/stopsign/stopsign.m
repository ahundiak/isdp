/* $Id: stopsign.m,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/stopsign/ imp.m	
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: stopsign.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/11/04  21:11:24  pinnacle
# vinit
#
# Revision 1.1  1998/11/04  09:38:42  pinnacle
# Created: vddb/stopsign/imp.m by vsrivast for vds
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/03/98  vinit   Creation 
 * -------------------------------------------------------------------*/
SOURCE
stopsign.c

SRC
.

EXEC
$(VDS)/bin/stopsign


CC
cc

COPT 
-DX11

#ifdef INTEL

LINKLIB
-lXFI -lXFS /usr/openwin/lib/libX11.so -lm -lnsl -lsocket -lw -ldl

#elif XGL

LINKLIB
-lXFI -lXFS /usr/openwin/lib/libX11.so -lm -lnsl -lsocket -lw -ldl

#else

LINKLIB
-lXFI -lXFS /usr/openwin/lib/libX11.a -lm -lnsl -lsocket -lw -ldl

#endif

INCLUDE
$(INGRHOME)/include
/usr/include
$(GRNUC)/include
$(FORMS)/include





