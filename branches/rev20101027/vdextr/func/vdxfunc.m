/* $Id: vdxfunc.m,v 1.1.1.1 2001/01/04 21:08:48 cvs Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdextr/func/vdxfunc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdxfunc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/04/19  14:00:10  pinnacle
# for dynapipe
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 * -------------------------------------------------------------------*/

SOURCE
VDXdatared.I
VDXobjIDlist.I
VDXclr_tbl.C
VDXdmrs.C
VDXf_tools.C
VDXsignal.C
VDXtools.C
VDXtype15.C
VDXtype18.C
VDXtype2.C
VDXtype23.C
VDXtype24.C
VDXtype46.C
VDXserver.C
VDXpost.C

LIB
$VDS/lib/vdixfunc.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
/usr2/ip32/pdudp/include
$GRNUC/unix/include
/usr/include
/usr/include/sys
$VDS/include
$VDS/vdinclude
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$UMS/include
$MODEL/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDM/include
$PDUDP/include
$NFMDP/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
