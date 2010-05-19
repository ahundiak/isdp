/* $Id: vdvesh.m,v 1.5 2002/03/30 16:22:47 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vddraw/ve/make_sh/vdvesh.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdvesh.m,v $
 *      Revision 1.5  2002/03/30 16:22:47  ad
 *      *** empty log message ***
 *
 *      Revision 1.4  2002/03/30 16:10:51  ad
 *      *** empty log message ***
 *
 *      Revision 1.3  2002/03/30 16:03:44  ad
 *      *** empty log message ***
 *
 *      Revision 1.2  2002/02/26 16:26:07  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *      Initial import to CVS
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
# Revision 1.2  1995/07/30  19:41:50  pinnacle
# Replaced: vddraw/ve/make_sh/vdvesh.m for:  by hverstee for vds.240
#
# Revision 1.1  1995/03/16  21:24:30  pinnacle
# Created: vddraw/ve/make_sh/vdvesh.m by azuurhou r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE
VDve_global.C

LIB
$(VDS)/lib/vdidrawve_gl.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

DEPLIB
$(VDS)/vddraw/ve/lib/vdidrawve_sr.o

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/proto_priv
$GRNUC/src/assoc/include_priv
$MODEL/include
$MODEL/proto_include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

