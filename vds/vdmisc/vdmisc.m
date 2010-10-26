/* $Id: vdmisc.m,v 1.15 2002/06/07 14:40:29 ramarao Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:	vdmisc / vdmisc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmisc.m,v $
 *	Revision 1.15  2002/06/07 14:40:29  ramarao
 *	Implemented To Do List.
 *	
 *	Revision 1.14  2002/05/16 16:12:30  anand
 *	*** empty log message ***
 *	
 *	Revision 1.13  2002/02/26 16:33:33  ahundiak
 *	ah
 *	
 *	Revision 1.12  2002/02/01 16:32:06  ramarao
 *	Fixed TR# 5883.
 *	
 *	Revision 1.11  2001/10/22 16:59:41  ramarao
 *	Moved struct/vsmisc/VSvalidate.I file to vds/vdmisc/VDvalidate.I.
 *	
 *	Revision 1.10  2001/09/27 15:54:22  ramarao
 *	Created VDrngLocate.I file.
 *	
 *	Revision 1.9  2001/08/31 22:14:19  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.8  2001/06/22 15:10:45  ramarao
 *	Fixed TR# 5324.
 *	
 *	Revision 1.7  2001/06/09 16:22:16  ramarao
 *	Implemented CR# 5302.
 *	
 *	Revision 1.6  2001/03/07 00:47:46  ramarao
 *	New PPL functionality.
 *	
 *	Revision 1.5  2001/03/06 16:22:11  ramarao
 *	Created a new function VDdgnGetActiveMacros();
 *	
 *	Revision 1.4  2001/02/19 20:31:12  ylong
 *	move VDdrwTblUp.I, VDdrw_tblfunc.I, VDdrw_tblcheck.I to vdtbl/func
 *	
 *	Revision 1.3  2001/01/18 23:36:56  hans
 *	SP16 modifications
 *	
 *	Revision 1.2  2001/01/18 16:31:32  art
 *	ah
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/01/28  21:40:54  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by impd for vds
#
# Revision 1.3  1998/01/22  20:05:44  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by impd for vds
#
# Revision 1.2  1997/10/29  14:50:48  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by rchennup for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1997/02/27  16:45:34  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by mdong for vds.241
#
# Revision 1.2  1997/01/08  23:01:34  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by kddinov for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.16  1996/05/31  23:27:52  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by kddinov for vds.240
#
# Revision 1.15  1996/05/15  23:15:04  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by tlbriggs for vds.240
#
# Revision 1.14  1996/05/03  14:52:06  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by kddinov for vds.240
#
# Revision 1.13  1996/03/21  22:55:14  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by yzhu for vds.240
#
# Revision 1.12  1995/10/31  15:17:04  pinnacle
# Replaced: vdmisc/vdmisc.m for:  by sundar for vds.240
#
# Revision 1.11  1995/09/29  14:00:40  pinnacle
# Replaced: vdmisc/*.m for:  by tlbriggs for vds.240
#
# Revision 1.8  1995/08/16  23:39:24  pinnacle
# Replaced: vdmisc/*.m for:  by tlbriggs for vds.240
#
 *
 * History:
 *	08/16/95   tlb		Added VDmem.C
 *	08/31/95   tlb		Added VDppl.I
 *	09/18/95   ad		Added VDprocesinfo.I
 *	03/21/96   yz		Added VDreturnfoot.I
 *	04/30/96   kdd		Added VDcomplist.I
 *	05/13/96   tlb		Added VDdbgFile.C, NFMDP include
 *      01/18/01   ah           Added dbl.c and clock.c from vdcppl
 *                              Because of load order problems
 *      01/18/01   HF           Merged SP16 additions/modifications
 *************************************************************************/
SOURCE
#if ISDP_MAKE_SP
VDdgnactmac.I
VDchanCheck.I
VDrngLocate.I
VDgtcmpobj.I
VDvalidate.I
VDchkmacupd.I
#else
VDrngLocate.I
VDcvonsf.I
VDcvcsp.I
VDmem.C
VDdbgFile.C
VDcopybc.C
VDdocvsovlap.C
VDgetUnit.C
VDgetchanobj.C
VDgetgscntnt.C
VDgetpath.C
VDglobals.C
VDisancestry.C
VDisobjofcls.C
VDisosninlst.C
VDmemdup.C
VDmxalgebra.C
VDocgrleaves.C
VDplclppngcv.C
VDprcssfence.C
VDregexp.C
VDseterrmsg.C
/* VDsltable.C */
VDsloprtn.C
VDspxtcvtosf.C
VDstringUtil.C
VDsys2unit.C
VDtoltests.C
VDunit2sys.C
VDunixUtil.C
VDvcalgebra.C
VDxformcurve.C
VDxtcvthrusf.C
VDGetFile.C

VDppl.I
VDdebug.I
VDprocesinfo.I
VDallocBScv.I
VDbulkdel.I
VDbulkdsp.I
VDchgsymb.I
VDchkobjrep.I
VDchkrngrng.I
VDconfirm.I
VDconsume.I
VDexpvalue.I
VDfndslsinmc.I
VDfndftinmc.I
VDgetcomp.I
VDgetgeom.I
VDgetmacinfo.I
VDgetsfedges.I
VDgetsfrange.I
VDgetvolints.I
VDgtcmpobj.I
VDintgrprops.I
VDisptonsrf.I
VDmakecvcomp.I
VDmkbooldiff.I
VDmkboolints.I
VDmknatbdry.I
VDmsgGRvg.I
VDobjgarbage.I
VDplcmacro.I
VDsfnorm.I
VDslexecsend.I
VDspltcvbysd.I
VDtestgeom.I
VDvirtinfo.I
VDreturnfoot.I
VDcomplist.I
VDsurftest.I
VDdgnactmac.I
VDchkmacupd.I

clock.c
dbl.c
/* SP16 additions/modifications */
VDatmacroi.I
VDgetownobj.I
VDSmacro.I
VDchanCheck.I
VDvalidate.I
VDtoDoList.I
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
#endif
$(BS)/include
$(BS)/include/prototypes
$(FORMS)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/proto_priv
$(GRNUC)/ingrsys
$GRNUC/src/assoc/include_priv
$(MODEL)/include
$(PDUDP)/include
$(NFMDP)/include
$(VDS)/include
$(VDS)/include/prototypes
$(VDS)/vdinclude

OMCPP
$(EXNUC)/bin/omcpp

OPP
$(EXNUC)/bin/opp

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdmisc.o
#else
$(VDS)/lib/vdmisc.o
#endif

DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN __APGE__ _INGR_EXTENSIONS

