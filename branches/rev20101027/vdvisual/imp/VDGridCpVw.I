/* $Id: VDGridCpVw.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/imp / VDGridCpVw.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDGridCpVw.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
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

class implementation IGEgragad ;

/*
	Abstract :
	----------

	This function copy a view.

	Arguments :
	-----------

	OUT	long		 *msg			Completion code.
	IN	struct DPgra_gad *source_gragad_struct	Gragad struct of source
							window.
	IN	struct GRid	 *dest_gragad		ID of destination
							window.
*/

#include <stdio.h>
#include "AS_status.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "msdef.h"

#define AS_DEBUG 1

/*----------------------------------------------------------------------------*/
long VDcopyView( msg, source_gragad_struct, dest_gragad )

long			*msg ;
struct DPgra_gad	*source_gragad_struct ;

struct GRid		*dest_gragad ;

/*.VDcopyView*/ {

	long			sts,
				which_error,
				num_bytes ;
	int			gpipe_of_dest,
				gpipe_of_source ;
	struct var_list 	var_list[2] ;

	/*"Copy view to gragad : [%d,%d]\n", dest_gragad->osnum, dest_gragad->objid*/

	gpipe_of_source = source_gragad_struct->gpipe_id ;

	/*"Gpipe id of source : %d\n", gpipe_of_source*/

	/*
	 * Retrieve gpipe id of destination gragad.
	 */
	var_list[0].var 		= GPIPE_ID ;
	var_list[0].var_ptr		= (char *) &gpipe_of_dest ;
	var_list[0].num_bytes		= sizeof( int ) ;
	var_list[0].bytes_returned	= &num_bytes ;

	var_list[1].var 		= END_PARAM ;

	sts = om$send( msg	= message IGEgragad.DPinquire( msg,
							       &which_error,
							       var_list ),
		       senderid = NULL_OBJID,
		       targetid = dest_gragad->objid,
		       targetos = dest_gragad->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	/*"Gpipe id of destination : %d\n", gpipe_of_dest*/

	/*
	 * Set gragad structure of source to destination. The gpipe id
	 * should not change.
	 */
	source_gragad_struct->gpipe_id = gpipe_of_dest ;

	var_list[0].var 		= GRAGAD_STRUCT ;
	var_list[0].var_ptr		= (char *) source_gragad_struct ;
	var_list[0].num_bytes		= sizeof( struct DPgra_gad ) ;
	var_list[0].bytes_returned	= &num_bytes ;

	var_list[1].var 		= END_PARAM ;

	sts = om$send( msg	= message IGEgragad.DPset( msg,
							   &which_error,
							   var_list ),
		       senderid = NULL_OBJID,
		       targetid = dest_gragad->objid,
		       targetos = dest_gragad->osnum ) ;

	as$status( sts = sts,  action = GOTO_VALUE, value = wrapup ) ;
	as$status( sts = *msg, action = GOTO_VALUE, value = wrapup ) ;

	source_gragad_struct->gpipe_id = gpipe_of_source ;

	wrapup :
		*msg = ( *msg & sts & 1 ) ? MSSUCC : MSFAIL ;

	return sts ;

} /* VDcopyView */
/*----------------------------------------------------------------------------*/

end implementation IGEgragad ;
