/* $Id: vdtblmgr.m,v 1.3 2001/10/12 14:33:55 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/vdtblmgr.m
 *
 * Description:
 *
 * Makefile template for vdtbl/mgr directory
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdtblmgr.m,v $
 *      Revision 1.3  2001/10/12 14:33:55  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/06/08 19:34:22  ylong
 *      TR5299
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/21  03:49:20  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/11/24  17:37:00  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m for:  by azuurhou for vds.240
#
# Revision 1.4  1995/08/25  15:19:28  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/30  20:52:14  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:36:04  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/05/25  21:49:32  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m by hverstee r#
#
# Revision 1.2  1995/04/25  22:35:06  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m by hverstee r#
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.4  1995/04/11  14:51:38  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m by hverstee r#
#
# Revision 1.3  1995/03/20  17:27:26  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m by hverstee r#
#
# Revision 1.2  1995/03/08  21:34:24  pinnacle
# Replaced: vdtbl/mgr/vdtblmgr.m by hverstee r#
#
# Revision 1.1  1995/03/06  16:43:12  pinnacle
# Created: vdtbl/mgr/vdtblmgr.m by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/03/95          HV            New
 *	13/10/97	Sundar		Added VDcrexp*[SI]
 * -------------------------------------------------------------------*/

LIB
$VDS_PATH/lib/vditblmgr.o

SOURCE
#if ISDP_MAKE_SP
VDadsym_fc.I
VDcrexp_fc.I
VDcrsrt_fc.I
VDcrsum_fc.I
VDdrwlo_fc.I
VDcrsum_post.I
#else
VDdrwlo.S
VDdrwlo_if.I
VDdrwlo_get.I
VDdrwlo_gfix.I
VDdrwlo_gdat.I
VDdrwlo_alg.I
VDdrwlo_col.I
VDdrwlo_htf.I
VDdrwlo_fld.I

VDdrwlo_occ.S
VDdrwlo_fcn.I
VDdrwlo_fc.I
VDdrwlo_post.I
VDdrwlo_over.I

VDSSC.S
VDSSC_gen.I
VDSSC_srt.I
VDSSC_sum.I

VDcrsrt.S
VDcrsrt_if.I 
VDcrsrt_over.I
VDcrsrt_post.I
VDcrsrt_fcn.I
VDcrsrt_fc.I

VDcrsum.S 
VDcrsum_if.I 
VDcrsum_over.I
VDcrsum_post.I
VDcrsum_fcn.I
VDcrsum_fc.I

VDADS.S
VDADS_gen.I

VDadsym.S
VDadsym_fcn.I
VDadsym_fc.I
VDadsym_fill.I
VDadsym_over.I
VDadsym_post.I

VDpost_func.I
VDAttrFun.I

VDcrexp.S
VDcrexp_gen.I
VDcrexp_if.I
VDcrexp_fcn.I
VDcrexp_fc.I 
VDcrexp_post.I 
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$BS/spec
$VDS/spec
$ROUTE/spec
./

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/include/prototypes
$SPXV/vdinclude
#endif
$EXNUC/include
$GRNUC/include
$BS/include
$PDM/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$ROUTE/include
$ROUTE/vrinclude
./

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

