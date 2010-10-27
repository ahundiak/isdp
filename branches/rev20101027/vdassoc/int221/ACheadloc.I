/* $Id: ACheadloc.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACheadloc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACheadloc.I,v $
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
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACheader;

#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "bserr.h"

#include "exdef.h"
#include "exmacros.h"

#define	AS_DEBUG
#define	ACS_CMP_LEAVE		0x3
#define	ACS_NO_VALID_PATH	'\007'

extern	GRclassid	OPP_ACcpx_class_id;
extern	GRclassid	OPP_ACheader_class_id;

struct	ACShandl_info
{
	IGRint			(*user_func)();
	IGRchar			*user_info;
};

struct	ACSdyn_info
{
	struct	GRid		feet_id;
	struct	GRid		header;
	struct	GRlc_info	obj_loc;
	struct	GRid		clone;
};



/* ******************* ACSget_part_path () ****************************	*/

ACSget_part_path( loc_foot, model )

struct	tf_foot		*loc_foot;
struct	GRid		*model;

/*.ACSget_part_path*/
{
IGRlong			sts, msg;
struct  GRid		as_own;
IGRchar                 tmp_path[path_MAX_CHAR];
IGRboolean		work_path;
struct  GRid		obj_base;
IGRint                  acs_save;
extern	IGRint		ACSloc_symb;
IGRboolean		path_created;
int			cr_ptr;

	/*| initialization */
	work_path	= TRUE;
	path_created	= FALSE;
	obj_base	= loc_foot->foot;
	as_own		= obj_base;
	cr_ptr		= 0;

	while( work_path ){

		/*" get_owner of obj_base : id/os = (%d/%d)\n", obj_base.objid, obj_base.osnum */
		as_own.objid	= NULL_OBJID;
//		ASget_as_owner( &obj_base, &as_own );
		ASget_mac_owner( &obj_base, &as_own, &cr_ptr );
//		printf(" as_own   : id/os = (%d/%d)\n", as_own.objid, as_own.osnum );

		if( as_own.objid == NULL_OBJID || 
				as_own.osnum != loc_foot->tf_id.osnum )	break;
		else {

			tmp_path[0] = '\0';
			sts = om$send(	msg	 = message ACcpx.ACgive_path(
							(IGRint *) &msg,
							&obj_base,
							tmp_path ),
					targetid = as_own.objid,
					targetos = as_own.osnum,
					senderid = NULL_OBJID );
			as$status( sts = sts );
			/*" tmp_path : %s\n", tmp_path */
		}

		if( tmp_path[0] == '\0' ) {

			work_path	= FALSE;
			path_created	= FALSE;

		} else {

			/*| store path */
			if( loc_foot->tf_name[0] == '\0' )
				strcpy( loc_foot->tf_name, tmp_path );

			else {

				sprintf( tmp_path, "%s:%s", tmp_path, 
							loc_foot->tf_name );
				strcpy( loc_foot->tf_name, tmp_path );
			}

			/*| set new value for while */
			obj_base	= as_own;
			path_created	= TRUE;
			/*" loc_foot->tf_name : %s\n", loc_foot->tf_name */

		  }
	}/*end while*/

	/*" path loc_foot->tf_name : %s\n", loc_foot->tf_name */

	if( ! path_created || as_own.osnum != loc_foot->tf_id.osnum ){
	
		/*| attach tf_id to a source with no path */
		loc_foot->tf_name[0] = ACS_NO_VALID_PATH;
		loc_foot->tf_name[1] = '\0';

		/*| construct attach a source */
		acs_save = ACSloc_symb;
		ACSloc_symb	= 0;
		as$make_source( go_grid	= loc_foot->tf_id,
				as_grid	= &loc_foot->foot,
				as_os   = loc_foot->tf_id.osnum );
		ACSloc_symb = acs_save;

		/*" transform support only as_grid : id/os = (%d/%d) \n", loc_foot->foot.objid, loc_foot->foot.osnum */
		sts = om$send(	msg	= message NDnode.NDchg_state
				( ND_DEL_NO_CH | ND_DONT_MVRT | ND_WAIT_DEL, 
				  ND_DEL_NO_CH | ND_DONT_MVRT | ND_WAIT_DEL),
				targetid = loc_foot->foot.objid,
				targetos = loc_foot->foot.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );
	}

return	OM_S_SUCCESS;
}

end implementation ACheader;
