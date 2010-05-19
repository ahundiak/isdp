/* $Id: vdiatpoc.m,v 1.8 2001/07/20 18:51:48 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdat/pocket/vdiatpoc.m
 *
 * Description:	makemake file for Select Assembly Component command
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdiatpoc.m,v $
 *	Revision 1.8  2001/07/20 18:51:48  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.7  2001/06/04 17:04:35  paul_noel
 *	*** empty log message ***
 *	
 *	Revision 1.6  2001/05/25 22:25:52  ylong
 *	CR3986
 *	
 *	Revision 1.5  2001/05/25 17:05:02  ylong
 *	CR5067 and CR3986
 *	
 *	Revision 1.4  2001/02/09 23:43:10  ylong
 *	Renamed source files
 *	
 *	Revision 1.3  2001/02/09 18:25:27  ylong
 *	Add VDct1TreeF.I
 *	
 *	Revision 1.2  2001/02/09 16:58:39  ylong
 *	Added VDatTreeF.I
 *	
 *	Revision 1.1  2001/01/11 21:01:17  art
 *	sp merge
 *	
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
# Revision 1.3  1999/04/09  14:22:26  pinnacle
# Deleted VDatSearch.I
#
# Revision 1.2  1999/01/25  21:55:16  pinnacle
# Replaced: vdat/pocket/vdccomp.m for:  by vsrivast for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/18  21:03:58  pinnacle
# Assembly Tree: makemake file for Select Assembly Component command, new
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/16/97  ejm     Created this file.
 * 01/25/99  vinit   Added VDatSearch.I for search 
 * 04/09/99  ah      Moved VDatSearch.I to cmd (load issue)
 * 04/03/00  ah      Renamed library to vdiatpoc to prevent load issues
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDCSlAsCpi.I
VDatPktTreeF.I
VDct1PktTreeF.I
VDatPktSave.I
VDatPktState.I
VDtreeSaveSet.I
#else
VDCSlAsCp.S
VDCSlAsCpi.I
VDatPktSearch.I
VDatPktState.I
VDatPktSave.I
VDatPktLines.I
VDatPktTreeF.I
VDct1PktTreeF.I
VDtreeSaveSet.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatpoc.o
#else
$VDS/lib/vdiatpoc.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$VDS/vdinclude/prototypes
$FORMS/include
$UMS/include

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

