/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdio/vdio.m
 *
 * Description:  The source files listed in vdio.m are files utilized
 *		 to help input data from ascii files for display on a
 *		 form. The files create subforms.
 *
 * Dependencies:
 *
 * Revision History:
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *      06/12/97	ejm	CR179527294: Add "Read from file" capability
 *				for user attributes, "Modify User Attributes"
 *				command. With a new directory (vds/vdio) 
 *				created, it was necessary to create this .m
 *				file to compile files residing in the new
 *				directory.
 *
 * -------------------------------------------------------------------*/

SOURCE
VDdfltvalsfm.C
VDdefltvalue.C
VDfileform.C
VDformUtil.C
VDfunc.I

LIB
$VDS/lib/vdiio.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

