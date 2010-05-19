/* $Id: vddb_c400.m,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source/vddb_c400.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddb_c400.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/09/27  19:34:08  pinnacle
# Debug Flags
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1996/05/27  19:25:18  pinnacle
# New
#
 *
 * History:
 * 	11/05/95	tlb	EMS 3.2 - drop missing NFMDP libs: 
 *					alter.a, libnfmftr.a
 *				Change RIS lib path.
 *	04/10/96	tlb	Add includes for VDS memory checking,
 *				VDS prototype include
 *	04/22/96	tlb	Use MEM to use dbgalloc libraries
 *				Use NFM_LIB, BS_DBG_LIB environment variables 
 *					from startup
 *				Remove vdlogname.c, VDSdbstr.c, VDSFreeID.C
 *				Add VDSbarmenu.c, VDSnfmstubs.c
 *	05/20/96	tlb	Add VDSdbstr.c for AddPart.rc compilation
 *	09/27/99        ah      Add VDdbgFlags.c for linking
 *				
 * -------------------------------------------------------------------*/

SOURCE
VDSbarmenu.c
VDSload.C
VDSwindow.C
VDSmenuops.C
VDSdblink.C
VDSdbpdm.c
VDSdbdbg.c
VDSdbstr.c
VDSdbstring.c
VDSdbbuf.C
VDSdblog.C
VDSdbdbase.c
VDSdbfamcat.c
VDSdbparcat.c
VDSdbgettab.c
VDSdbdelpart.C
VDSdbdelcat.c
VDSdbpath.c
VDSdbreadris.c
VDSdbrisload.C
VDSnfmstubs.c
VDdbgFlags.c

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$NFMDP/include
$PDUDP/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

LINKLIB
$VDS/vdris/lib/ForExec.o
$VDS/vdmisc/VDdbgFile.o
#ifndef VD_RUNTIME
$VDS/vdmisc/VDmem.o
#endif
$NFM_LIB/libnfmmem.a
$NFM_LIB/libnfma.a
$NFM_LIB/libnfmu.a
$NFM_LIB/libnfmlists.a
$NFM_LIB/libnfmwf.a
$NFM_LIB/libcmdtools.a
$NFM_LIB/libdbtools.a
$NFM_LIB/libnfmtools.a
$NFM_LIB/libfilexfer.a
$NFM_LIB/libnfmsql.a
$NFM_LIB/libsystools.a
$NFM_LIB/libnfmerr.a
$NFM_LIB/libnfmsac.a
$NFM_LIB/libnfmmem.a
$NFM_LIB/libnfmnet.a
$NFM_LIB/libtli.a
$RIS/risdp/lib/$(CPUTYPE)/ris.a
#ifdef MEM
#  ifndef VD_RUNTIME
    $BS_DBG_LIB/bsinit20.o
#  else
    $BS_DBG_LIB/bsinit.o
#  endif
$BS_DBG_LIB/mallocg.o
$BS_DBG_LIB/malloc.o 
$BS_DBG_LIB/blkalloc.o
$BS_DBG_LIB/blkinfo.o 
$BS_DBG_LIB/bsdbgalloc.o 
$BS_DBG_LIB/bsdbgfree.o 
$BS_DBG_LIB/bsdbgralloc.o 
$BS_DBG_LIB/bsdbgsalloc.o 
$BS_DBG_LIB/bsdbgsfree.o 
$BS_DBG_LIB/bspoisonmem.o 
$BS_DBG_LIB/bslockmem.o
#endif
$BS/lib/$(CPUTYPE)/bsmd_ap4.a
-lcurses
-lUMS
-lbsd
-lPW
-lgpipe_s
-linc
-lnsl_s

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

EXEC
$VDS/vddb/bin/VDSloaddata

CC
acc -ansi
