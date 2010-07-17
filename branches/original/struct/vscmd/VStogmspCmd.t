/* $Id: VStogmspCmd.t,v 1.1.1.1 2001/01/04 21:10:28 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VStogmspCmd.t
 *
 * Description:
 *		Command objet to perform the Mass Properties.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VStogmspCmd.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.5  1995/12/27  20:42:52  pinnacle
# Replaced: vscmd/VStogmspCmd.t for:  by s240_int for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	12/27/95	adz		Delete VScmd.h for state table cntl.
 *
 ***************************************************************************/

command_string	VSC_M_VSTgMPEv,0,VSTgMPEv
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VStogmspCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "vscmddef.h"
#include "VSmsg.h"

state start

	execute warningMessage( &me->ret )

        on ELSE state terminate

at init do message_key VS_M_VSTgMPEv
/*----------------------------------------------------------------------------*/
