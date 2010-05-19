/* $Id: vdroot.m,v 1.3 2001/10/23 16:28:26 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / vdroot.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdroot.m,v $
 *	Revision 1.3  2001/10/23 16:28:26  ahundiak
 *	Added Synonym attribute check.
 *	
 *	Revision 1.2  2001/01/26 00:11:45  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/12  23:48:54  pinnacle
# Replaced: vdroot/vdroot.m for:  by yzhu for vds
#
# Revision 1.3  1997/11/20  04:58:50  pinnacle
# Replaced: vdroot/vdroot.m for:  by rchennup for vds
#
# Revision 1.2  1997/10/23  21:45:06  pinnacle
# Replaced: vdroot/vdroot.m for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.4  1997/02/28  10:54:22  pinnacle
# Replaced: vdroot/vdroot.m for:  by ksundar for vds.241
#
# Revision 1.3  1997/02/28  10:24:52  pinnacle
# Replaced: vdroot/vdroot.m for:  by ksundar for vds.241
#
# Revision 1.2  1996/09/09  15:41:24  pinnacle
# Replaced: vdroot/vdroot.m for:  by v241_int for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1996/03/23  00:04:10  pinnacle
# Replaced: vdroot/vdroot.m for:  by v240_int for vds.240
#
# Revision 1.10  1995/07/30  20:37:30  pinnacle
# Replaced: vdroot/vdroot.m for:  by hverstee for vds.240
#
# Revision 1.9  1995/07/24  16:40:30  pinnacle
# Replaced: vdroot/vdroot.m for:  by hverstee for vds.240
#
# Revision 1.8  1995/07/11  20:19:02  pinnacle
# Replaced: vdroot/vdroot.m for:  by azuurhou for vds.240
#
# Revision 1.7  1995/03/02  22:52:04  pinnacle
# Replaced: vdroot by azuurhou r#
#
# Revision 1.6  1995/02/22  21:05:22  pinnacle
# Replaced: vdroot/vdroot.m by rmanem r#
#
# Revision 1.5  1995/01/10  14:45:22  pinnacle
# Replaced: vdroot by azuurhou r#
#
# Revision 1.4  1994/12/23  19:01:24  pinnacle
# Replaced: vdroot/vdroot.m by tdumbach r#
#
# Revision 1.3  1994/12/22  22:02:48  pinnacle
# Replaced: vdroot/vdroot.m by azuurhou r#
#
# Revision 1.2  1994/12/22  00:22:12  pinnacle
# Replaced: vdroot/vdroot.m by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/21/94	adz		add num class.
 *	02/14/95	rmn		Added VDrtParams.I
 *	03/02/95	adz		Add VRrtcompute/VDrtcreate.
 *	03/22/96	adz		Add VDrtgivestr.
 *	09/09/96	adz/slj		Add VDgenOver.I for PME posting.
 *	02/28/97	sundar		Add VDattrsymb.I for CR:179700254
 *	10/23/97	adz		Add VDdescribeOutput;
 *	11/20/97	Rama Rao	Add VDExecutePpl;
 *	12/09/97	Yzhu		Add VDprocAttr.I;
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDrtgivestr.I
#else
VDSroot.S
VDcongraph.I
VDsymbfrtrta.I
VDrtpostdb.I
VDrtgiveoutp.I
VDrtGetObj.I
VDrtParams.I
VDrtcreate.I
VDrtcompute.I
VDrtfindmacr.I
VDrtgivestr.I
VDgenOver.I
VDattrsymb.I
VDrtdescfoot.I
VDrtPplExec.I
VDSnode.S
VDprocAttr.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiroot.o
#else
$VDS/lib/vdiroot.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
