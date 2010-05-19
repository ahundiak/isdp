/* $Id: VDhdr_db.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDhdr_db.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDhdr_db.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
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
/*	LLC & MF :- march 93	 + creation date
/*
/* */

class implementation VDrelat_hdr;

#include "AS_status.h"
#define ACS_MODEL_CONSUME	0x80

/* ******************* MSG ACcheckin_candidate () *********************	*/

method ACcheckin_candidate( IGRint CheckinType, *p_CheckinCandidate )

{
IGRlong		sts, msg;
struct	GRid	cur_model;

	*p_CheckinCandidate	= FALSE;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

	sts = om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );

	sts = om$send(	msg	 = message NDmacro.ACtest_consumed( &msg ),
			targetid = my_id );

	if( (sts&1) && (msg&1) ) *p_CheckinCandidate = FALSE;

return	OM_S_SUCCESS;
} 

/* *********************** MSG ACadd_to_list () ***********************	*/

method ACadd_to_list( struct ACobj_info *p_obj_info; IGRint size, *p_count )

{
IGRlong		sts, msg;
struct	GRid	cur_model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

	sts = om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );

	if( p_count && *p_count && (*p_count <= size) && size && p_obj_info ){
		p_obj_info[*p_count-1].serial_no	= my_id;
		p_obj_info[*p_count-1].obj.objid	= my_id;
		p_obj_info[*p_count-1].obj.osnum	= OM_Gw_current_OS;
	}

return	sts;
} 

/* *********************** MSG ACadd_to_list_1 () *********************	*/

method ACadd_to_list_1( struct ACobj_info_1 *p_obj_info_1;
						IGRint size, *p_count )
{
IGRlong		sts, msg;
struct	GRid	cur_model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

	sts = om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );

	if( p_count && *p_count && (*p_count <= size) && size && p_obj_info_1 ){
		p_obj_info_1[*p_count-1].serial_no	= my_id;
		p_obj_info_1[*p_count-1].obj.objid	= my_id;
		p_obj_info_1[*p_count-1].obj.osnum	= OM_Gw_current_OS;
	}

return	sts;
} 

/* ************************* MSG  ACget_db_info () ********************	*/

method ACget_db_info( IGRlong *rc; struct ACdb_info *db_info )

{
IGRlong		sts, msg;
struct	GRid	cur_model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		*rc	= msg;
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

return	om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );
} 


end implementation VDrelat_hdr;

