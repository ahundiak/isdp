/*
/*  History :
/*	LLC :- 7_12_90	 + creation date
/*
/* */

class implementation ACheader;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grerr.h"

#define	AS_DEBUG

%safe

IGRint			ACScur_tf_foot = 0;
struct	tf_foot		ACSlist_tf_feet[MAX_NB_TF_FOOT];

%endsafe


/* ************ MSG ACstore_tf_foot () ********************************	*/

method ACstore_tf_foot( IGRlong *rc; struct tf_foot *temp_foot )

{
IGRint		i;

	/*| initialization */
	*rc	= OM_S_SUCCESS;

	for( i=0; i<ACScur_tf_foot; i++ )

		if( ACSlist_tf_feet[ACScur_tf_foot].tf_id.objid == 
						temp_foot->tf_id.objid ){

			ACSlist_tf_feet[ACScur_tf_foot].tf_id = temp_foot->tf_id;
			ACSlist_tf_feet[ACScur_tf_foot].foot = temp_foot->foot;
			strcpy( ACSlist_tf_feet[ACScur_tf_foot].tf_name, temp_foot->tf_name );
			break;
		}

	if( i == ACScur_tf_foot ) {

		ACSlist_tf_feet[ACScur_tf_foot].tf_id = temp_foot->tf_id;
		ACSlist_tf_feet[ACScur_tf_foot].foot = temp_foot->foot;
		strcpy( ACSlist_tf_feet[ACScur_tf_foot].tf_name, temp_foot->tf_name );
	}

	ACScur_tf_foot++;

	if( ACScur_tf_foot == MAX_NB_TF_FOOT )	ACScur_tf_foot = 0;

return	OM_S_SUCCESS;
}

/* ************ MSG ACget_name_of_tf_foot () **************************	*/

method ACget_name_of_tf_foot( IGRlong *rc; struct tf_foot *temp_foot )

{
IGRint		i;

	/* | initialization */
	*rc		= OM_S_SUCCESS;
	temp_foot->tf_name[0] = '\0';

	for( i=0; i<MAX_NB_TF_FOOT; i++ ){

		if( 	( ACSlist_tf_feet[i].tf_id.objid == 
						temp_foot->tf_id.objid ) &&
			( ACSlist_tf_feet[i].tf_id.osnum == 
						temp_foot->tf_id.osnum ) ) {

			/*" tf_feet %s already store \n", ACSlist_tf_feet[i].tf_name */

			temp_foot->foot	 = ACSlist_tf_feet[i].foot;
			strcpy( temp_foot->tf_name, ACSlist_tf_feet[i].tf_name );

			return	OM_S_SUCCESS;
		}
	}

	/*| do not find tf_foot */
	*rc	= OM_E_ABORT;

return	OM_S_SUCCESS;
}

/* ************ MSG ACmod_tf_foot () **************************	*/

method ACmod_tf_foot( IGRlong *rc; struct tf_foot *temp_foot )

{
IGRint		i;

	/* | initialization */
	*rc		= OM_S_SUCCESS;

	for( i=0; i<MAX_NB_TF_FOOT; i++ ){

		if( 	( ACSlist_tf_feet[i].tf_id.objid == 
						temp_foot->tf_id.objid ) &&
			( ACSlist_tf_feet[i].tf_id.osnum == 
						temp_foot->tf_id.osnum ) ) {

			/*" tf_feet %s already store \n", ACSlist_tf_feet[i].tf_name */

			strcpy( ACSlist_tf_feet[i].tf_name, temp_foot->tf_name );
			ACSlist_tf_feet[i].foot = temp_foot->foot;

			return	OM_S_SUCCESS;
		}
	}

	/*| do not find tf_foot */
	*rc	= OM_E_ABORT;

return	OM_S_SUCCESS;
}

/* ************** MSG ACclean_tf_foot () ******************************	*/

method	ACclean_tf_foot( IGRlong *rc; struct GRmd_env *md_env;
						IGRboolean del_flag )

{
IGRlong		sts;
GRobjid		tmp_id;


	/*| initialization */
	*rc			= OM_S_SUCCESS;
	tmp_id 			= md_env->md_id.objid;
	md_env->md_id.objid 	= NULL_OBJID;
	
	sts = om$send(	msg	 = message GRgraphics.GRdelete
					( rc, md_env ),
			p_chanselect = &AS_to_comp,
			from	 = 1,
			to	 = OM_K_MAXINT );
	as$status( sts = sts );	

	md_env->md_id.objid	= tmp_id;

return	OM_S_SUCCESS;
}

/* ***************** MSG NDsleep () ***********************************	*/

method	NDsleep( struct GRmd_env *md_env )

{
IGRlong		sts, msg;
GRobjid		tmp_id;

	/*| delete tf_foot */
	tmp_id 			= md_env->md_id.objid;
	md_env->md_id.objid 	= NULL_OBJID;
	sts = om$send(	msg	= message GRgraphics.GRdelete
					( &msg, md_env ),
			p_chanselect = &AS_to_comp,
			from	= 1,
			to	= OM_K_MAXINT );
	as$status( sts = sts );	
	md_env->md_id.objid	= tmp_id;

	/*| clean list counter */
	ACScur_tf_foot	= 0;

	/*| send normal sleep */
	sts = om$send(	msg	 = message ACconst.NDsleep( md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

return	OM_S_SUCCESS;
}

end implementation ACheader;

