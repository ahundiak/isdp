/* $Id: vdtblpar.m,v 1.2 2001/07/27 22:29:41 ylong Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtbl/parser / vdtblpar.m
 *
 * Description:
 *	control file for grmake
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdtblpar.m,v $
 *	Revision 1.2  2001/07/27 22:29:41  ylong
 *	TR5473
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/06/07  23:47:52  pinnacle
# Replaced: vdtbl/parser/vdtblpar.m for:  by tlbriggs for vds.240
#
# Revision 1.7  1995/10/13  08:52:56  pinnacle
# Replaced: vdtbl/parser/vdtblpar.m for:  by tlbriggs for vds.240
#
# Revision 1.6  1995/08/30  20:04:30  pinnacle
# Replaced: vdtbl/parser/*.m for:  by tlbriggs for vds.240
#
# Revision 1.5  1995/08/30  19:48:04  pinnacle
# Replaced: vdtbl/parser/*m for:  by tlbriggs for vds.240
#
# Revision 1.4  1995/08/21  18:52:34  pinnacle
# Replaced: vdtbl/parser/*.m for:  by tlbriggs for vds.240
#
# Revision 1.3  1995/07/30  20:53:50  pinnacle
# Replaced: vdtbl/parser/vdtblpar.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/27  23:34:40  pinnacle
# Replaced: vdtbl/parser/*.m for:  by tlbriggs for vds.240
#
# Revision 1.1  1995/07/21  21:06:40  pinnacle
# Created: vdtbl/parser/vdtblpar.m by tlbriggs for vds.240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	07/21/95   tlb		created
 *	07/25/95   tlb		Added VDexpFunc.C
 *	08/19/95   tlb		Added VDexpObj.I
 *	08/26/95   tlb		Added PDU include
 *	08/30/95   tlb		Remove VDppl - should be in vdmisc
 *	10/12/95   tlb		Added VDexpKeyWord.C, VDexpMisc.C
 *	05/30/96   tlb 		Added VDexpDb.C
 *
 *************************************************************************/
SOURCE
#if ISDP_MAKE_SP
VDexpObj.I
#else
VDexpParser.C
VDexpLex.C
VDexpError.C
VDexpPrint.C
VDexpFunc.C
VDexpDb.C
VDexpMisc.C
VDexpOp.C
VDexpKeyWord.C
VDexpObj.I
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
$(SPXV)/vdinclude
#endif
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(MODEL)/include
$(PDU)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vditblpar.o
#else
$(VDS)/lib/vditblpar.o 
#endif

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__ _INGR_EXTENSIONS

CC
acc -ansi -O3
