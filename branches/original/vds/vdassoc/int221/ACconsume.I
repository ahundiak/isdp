/* $Id: ACconsume.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACconsume.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACconsume.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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
  ACncpxi.I
  robert patience
  1 sept 1989
*/
class implementation ACncpx;

#define AS_DEBUG

#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "gocmacros.h"
#include "ASmsg.h"
#include "msmacros.h"
#include <alloca.h>


from ACcpx_defn import 	ACgive_name, ACgive_temp_desc, ACgive_feet_desc;
from ACcpx_defn import 	ACintpt_foot,ACmax_graph_ft;
from ACmacro_defn import 	ACgive_upscan;
from ACpretend  import 	ACfind_parent;
from ACpretend  import 	ACrebind;
from ACconst  import 	ACget_foot_in_mac;

extern	GRclassid	OPP_VDrelat_hdr_class_id;

#define ACS_MDL_CONSUME		0x01	/* model will be consume	*/
#define ACS_MDL_UNCONSUME	0x02	/* model will be unconsume	*/
#define ACS_MDL_CMPT		0x04	/* model will be recompute	*/
#define ACS_MDL_DELETE		0x08	/* model will be delete		*/

/* ========================================================================= */
method ACntf_consume( IGRlong *msg )

{
IGRlong		sts, loc_msg;
struct	arg	{ IGRlong *msg; IGRint action; } arg;
OM_S_MESSAGE	ntf_msg;


	/* Implementation of method doesnt work through reference file */

	/*| initialization */
	*msg	= 1 ;
	loc_msg	= MSSUCC;

	// send ntf_symbol with consume operation
	arg.msg		= &loc_msg;
	arg.action	= ACS_MDL_CONSUME;

	sts = om$make_message(	classid		= OPP_VDrelat_hdr_class_id,
				methodname	= "ACntf_symbol",
				p_arglist	= &arg,
				size		= sizeof arg,
				p_msg		= &ntf_msg );
	if( sts & 1 ){

		// send message on channel children
		sts = om$send(	msg		= &ntf_msg,
				p_chanselect	= &ND_children );
	}

return	OM_S_SUCCESS;
}

/* ========================================================================= */
method ACntf_unconsume(IGRlong *msg)
{
IGRlong		sts, loc_msg;
struct	arg	{ IGRlong *msg; IGRint action; } arg;
OM_S_MESSAGE	ntf_msg;

	/* Implementation of method doesnt work through reference file */

	/*| initialization */
	*msg	= 1 ;
	loc_msg	= MSSUCC;

	// send ntf_symbol with unconsume operation
	arg.msg		= &loc_msg;
	arg.action	= ACS_MDL_UNCONSUME;

	sts = om$make_message(	classid		= OPP_VDrelat_hdr_class_id,
				methodname	= "ACntf_symbol",
				p_arglist	= &arg,
				size		= sizeof arg,
				p_msg		= &ntf_msg );
	if( sts & 1 ){

		// send message on channel children
		sts = om$send(	msg		= &ntf_msg,
				p_chanselect	= &ND_children );
	}

return	OM_S_SUCCESS;
}

end implementation ACncpx;

