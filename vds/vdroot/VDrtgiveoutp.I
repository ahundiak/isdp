/* $Id: VDrtgiveoutp.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdroot / VDrtgiveoutp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrtgiveoutp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
*/
class implementation VDSroot ;

/* #define	DEBUG	1 */

#include <string.h>
/*
 * Includes of function prototypes.
 */
extern	char * VDmsgkey2string __(( long msgkey )) ;
/*----------------------------------------------------------------------------*/
method DIgive_output( char *output ) {

	long		sts,
			msg ;
	VDobjDef	objDef ;
	/*
	 * Pretty-print yourself in "Display Directory Command" form.
	 */

	sts = om$send(	msg 	= message VDSroot.VDgetObjDef( &msg, &objDef ),
			targetid= my_id ) ;

#ifdef	DEBUG
	printf(" OBJ: %d %d(sts) %d(msg)\n", my_id, sts, msg );
#endif
	if( sts & 1 & msg ) {
		strcat( output, "[" ) ;
		strcat( output, VDmsgkey2string( objDef.info ) ) ;
		strcat( output, "]" );
	} else {
		/*
		 * Just in case the messages failed ...
		 */
		strcat( output, "()" ) ;
	}

	return OM_S_SUCCESS ;

} /* method DIgive_output */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

