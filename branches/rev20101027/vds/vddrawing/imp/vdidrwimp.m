/* $Id: vdidrwimp.m,v 1.2 2001/05/24 20:24:34 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp / vddrwimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdidrwimp.m,v $
 *	Revision 1.2  2001/05/24 20:24:34  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.1  2001/04/16 18:53:16  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/04/16 14:01:39  jayadev
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/04/13 15:52:03  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/04/13 15:40:05  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/04/09  17:13:26  pinnacle
# Added VDmisc.I
#
# Revision 1.2  1999/02/12  19:04:42  pinnacle
# Replaced: vddrawing/imp/vddrwimp.m for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/01/29  22:11:20  pinnacle
# ah
#
# Revision 1.2  1997/12/10  16:57:14  pinnacle
# Replaced: vddrawing/imp/vddrwimp.m for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/04/22  19:14:20  pinnacle
# Replaced: vddrawing/imp/vddrwimp.m for:  by azuurhou for vds.240
#
# Revision 1.4  1995/07/30  19:47:10  pinnacle
# Replaced: vddrawing/imp/vddrwimp.m for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/24  22:22:26  pinnacle
# Replaced: vddrawing/imp/vddrwimp.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/03/19  22:18:58  pinnacle
# Replaced: vddrawing/imp/vddrwimp.m by azuurhou r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *
 * 12/10/97  HF	     Moved GRrfxform.I & GRctxupdatec.I
 *    		     from emsfixes/grnuc to here
 * 01/29/98  ah	     Added vds/include/prototypes
 * 02/12/99  Ming    Added VDdrwfrm_iso.I
 * 04/09/99  ah      Added VDmisc.I for assorted cmd functions
 * -------------------------------------------------------------------*/

SOURCE
#if ISDP_MAKE_SP
VDdrawingi.I
VDdrwfrm_iso.I
#else

GRrfxform.I		/* enhancement for move drawing view    */
GRctxupdatec.I          /* commands				*/

VDcontext.S
VDcontexti.I
VDgrcontext.I

VDdrawing.S
VDdrawingi.I

VDgeom.S
VDgeomi.I

VDdrwFunc.I
VDdrwfrm_iso.I
VDmisc.I
#endif

LIB
#if ISDP_MAKE_SP
$(SPXV)/lib/vdidrwimp.o
#else
$VDS/lib/vdidrwimp.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$(SPXV)/include
$(SPXV)/include/prototypes
#endif

$BS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
