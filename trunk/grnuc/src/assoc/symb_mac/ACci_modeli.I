/*
/*  History :
/*	LLC :- 15_9_91	 + creation date
/*
/* */

class implementation ACci_model;

#include "AS_status.h"
#include "asbox.h"


/* ************************* NDdelete () ******************************	*/

method NDdelete( struct GRmd_env *md_env )
{
IGRlong			sts;
struct	GRid		my_grid;
OM_S_CHANSELECT		*to_father, *to_children ;


	sts = om$send(	msg	 = message nci_macro.NDdelete( md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );

	/*| send myself notify_disconnect because i am not in rtree */
	NDget_channel(&to_father,&to_children);

	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;

	sts = om$send(	msg	 = message NDnode.NDnotify_disconnect
					( my_grid ),
			p_chanselect = to_father );
	as$status( sts = sts );

return	sts;
}

/* *********************** MSG NDsleep () *****************************	*/

method NDsleep( struct GRmd_env *md_env )
{
IGRlong		sts;
OMuint		nb_head;
OM_S_OBJID 	md_id;

	/*| send normal sleep */
	sts = om$send(	msg	 = message nci_macro.NDsleep( md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

	/*| look number of connected header */
	nb_head = 0;
	sts = om$get_channel_count(	objid 	= my_id,
					p_chanselect = &AS_to_owner,
					count	= &nb_head );
	as$status( sts = sts, msg = "Error in mc get_channel_count" );
	/*" nb_head : %d\n", nb_head */

	if( nb_head < 2 ){

		/* | kill model because no header connect */
		md_id = md_env->md_id.objid;
		md_env->md_id.objid = NULL_OBJID; /* because out of R-Tree  */
		sts = om$send(	msg	 = message NDnode.NDdelete( md_env ),
				targetid = my_id );
		md_env->md_id.objid = md_id;
		as$status( sts = sts, msg = "Error in msg NDdelete" );
	}

return	sts;
}

end implementation ACci_model;

