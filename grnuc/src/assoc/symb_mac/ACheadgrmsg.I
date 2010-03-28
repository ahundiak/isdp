/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*      Sudha  06/28/94    fix TR# 119421725 - integrating the fix suggested 
/*			   by VDS group. Rolled back the same fix provided
/*			   for 4.0 for TR# 119418156.
/*
/*	collect override of graphic messages
/* */

class implementation ACheader;

#include "AS_status.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "ndmacros.h"
#include "grerr.h"
#include "bserr.h"
#include "grsymdef.h"
#include "ASmsg.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "DPdlist.h"

#define	AS_DEBUG

extern IGRboolean ASbroadcast_in_progress;

from	ACcpx_defn	import	ACgive_name;

from	ACmodel		import	ACdisconnect_head;


/* *************** MSG GRdrop () **************************************	*/

method	GRdrop( IGRlong *rc; struct GRmd_env *md_env )

{
IGRlong			sts, msg;
IGRint			nb_feet;
struct	GRid		*feet_list;
GRobjid			*copy_list;
struct	GRid		model;
struct	GRid		my_grid;
struct	GRid		loc_foot;
struct	GRmd_env	loc_env;
IGRint			i;
OM_S_OBJID 		objid;


	/*| initialization */
	*rc		= MSFAIL;
	feet_list	= NULL;
	copy_list	= NULL;
	my_grid.objid	= my_id,
	my_grid.osnum	= OM_Gw_current_OS;

	/*| clean header of tf_foot */
	sts = om$send(	msg	 = message ACheader.ACclean_tf_foot
					( &msg, md_env, TRUE ),
			targetid = my_id );

	/*| get share feet */
	sts = om$send(	msg	 = message ACheader.ACget_share_feet_list(
					&msg,
					0,
					NULL,
					&nb_feet ),
			targetid = my_id );
	as$status( sts = sts );
	/*" nb feet : %d\n", nb_feet */

	feet_list = (struct GRid *) malloc( sizeof( struct GRid ) * nb_feet );
	if( feet_list == NULL && nb_feet != 0 ){
		printf(" Error not enougth memory to allocate feet_list\n");
		sts	= OM_E_ABORT;
		goto	wrapup;
	}

	copy_list = (GRobjid *) malloc( sizeof( GRobjid ) * nb_feet );
	if( copy_list == NULL && nb_feet != 0 ){
		printf(" Error not enougth memory to allocate feet_list\n");
		sts	= OM_E_ABORT;
		goto	wrapup;
	}

	sts = om$send(	msg	 = message ACheader.ACget_share_feet_list(
					&msg,
					nb_feet,
					feet_list,
					&nb_feet ),
			targetid = my_id );
	as$status( sts = sts );

	/*| copy to env --> loc_env */
	loc_env	= *md_env;

	/*| build matrix */
	for( i=0; i<3; i++)	loc_env.md_env.matrix[i] = me->matrix[i];
	loc_env.md_env.matrix[3]	= me->origin[0];
	for( i=4; i<7; i++)	loc_env.md_env.matrix[i] = me->matrix[i-1];
	loc_env.md_env.matrix[i]	= me->origin[1];
	for( i=8; i<11; i++)	loc_env.md_env.matrix[i] = me->matrix[i-2];
	loc_env.md_env.matrix[11]	= me->origin[2];
	for( i=12; i<15; i++)	loc_env.md_env.matrix[i] = 0;
	loc_env.md_env.matrix[15]	= 1;

	MAtypemx( &msg, loc_env.md_env.matrix, &loc_env.md_env.matrix_type );

	/*| copy the share feet */
	for( i=0; i<nb_feet; i++ ){

		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&msg,
						&loc_env,
						md_env,
						&copy_list[i] ),
				targetid = feet_list[i].objid,
				targetos = feet_list[i].osnum );
		as$status( sts = sts );

		/*| up date symbology */
		loc_foot.objid	= copy_list[i];
		loc_foot.osnum	= OM_Gw_current_OS;
		ACSset_tf_foot_symb( &my_grid, &loc_foot );
	}

	/*| disconnect header */
	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message ACmodel.ACdisconnect_head(
					&msg,
					&my_grid,
					md_env ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

	/*| connect copy share feet */
	for( i=0; i<nb_feet; i++ ){

		sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						i,
						my_id,
						OM_Gw_current_OS,
						AS_to_comp,
						0 ),
				targetid = copy_list[i] );
		as$status( sts = sts );
	}

	/*| chg class header --> const */
	sts = om$change_class(	objid		= my_id,
				classname	= "ACconst",
				sd_override	= OM_K_change_class_sd_override );
	as$status( sts = sts, action  = RET_STATUS );

	/*| send drop to the ACconst */
	objid = my_id;
	sts = om$send(	msg	 = message GRowner.GRdrop
					( &msg, md_env ),
			targetid = objid );
	as$status( sts = sts );

	*rc	= MSSUCC;

wrapup :

	/*| free memory */
	if( feet_list != NULL )		free( feet_list );
	if( copy_list != NULL )		free( copy_list );


return	OM_S_SUCCESS;
}
/* ************ MSG GRxform () ****************************************	*/

method GRxform( IGRlong *rc; struct GRmd_env *obj_dsenv; 
		IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )

{
IGRlong		sts, msg;
IGRint		i;
IGRshort	new_type;
IGRdouble	new_mat[16];

	/*| initialization */
	*rc	= OM_S_SUCCESS;
/*^
	printf(" obj_dsenv : id/os = (%d/%d)\n", obj_dsenv->md_id.objid, obj_dsenv->md_id.osnum ); 
	pr_mat(" obj_mat", 4, 4, obj_dsenv->md_env.matrix);
	printf(" MAIDMX = %d; matrix_type = %d\n", MAIDMX, *matrix_type );
	pr_mat(" x mat", 4, 4, matrix );
*/

	if( me->STATE & ncpx_root ){

		if( *matrix_type != MAIDMX ){

			sts = om$send(	msg	 = message GRowner.GRget_matrix(
							&msg,
							matrix_type,
							matrix,
							&new_type,
							new_mat ),
					targetid = my_id );
			as$status( sts = sts );

/*^			pr_mat(" new_mat ", 4, 4, new_mat ); */

			/*| set instance data */
			me->origin[0]	= new_mat[3];
			me->origin[1]	= new_mat[7];
			me->origin[2]	= new_mat[11];

			for( i=0; i<3; i++ ){

				me->matrix[i]	= new_mat[i];
				me->matrix[i+3]	= new_mat[i+4];
				me->matrix[i+6]	= new_mat[i+8];
			}

			if( obj_dsenv->md_id.objid != NULL_OBJID ) {

				/*| up date range */
				sts = om$send(	msg	 = message GRgraphics.GRremwrng
							( &msg, obj_dsenv ),
						targetid = my_id );
/*^				as$status( sts = sts ); */

				sts = om$send(	msg	 = message GRgraphics.GRaddwrng
							( &msg, obj_dsenv ),
						targetid = my_id );
				as$status( sts = sts );
			}

			/*| up date depencies */
			sts = om$send(	msg	 = message NDnode.NDchange_node
							( NULL ),
					targetid = my_id );
			as$status( sts = sts );

		}/*end diff MAIDMX*/

	} else {

		/*| send message */
		sts = om$send(	msg	 = message ACcpx.GRxform(
						rc,
						obj_dsenv,
						matrix_type,
						matrix,
						newobjid ),
				mode	 = OM_e_wrt_message,
				targetid = my_id );
		as$status( sts = sts );

	}/*end else root*/

	*newobjid = my_id;

return	OM_S_SUCCESS;
}

/* ************* MSG GRdisyourself () *********************************	*/

method	GRdisyourself( 	IGRlong	*rc; IGRshort *mx_type; IGRmatrix matrix;
			enum GRdpmode *mode; struct IGRaltdisplay *alt_symb; 
			struct DP_information *sp_info; 
			OM_p_KEY_DESC range_key )

{
IGRint                  EFmake_pointers();

IGRlong			sts, msg;
IGRint			i;
IGRdouble		new_mat[16];
IGRshort		new_type;
struct	IGRaltdisplay	new_alt_symb;
IGRint			save_layers[DP_NUM_OF_LEVELS/32 + 1];
IGRint			all_layers[DP_NUM_OF_LEVELS/32 + 1];
struct	DPviewinfo 	view_info;
struct	GRsymbology	symb;
IGRboolean		use_new_alt_symb;
struct	GRid		model,
                        my_grid;
extern IGRboolean 	ASbroadcast_in_progress;
IGRboolean		save_br,
                        create_ptrs;
int                     old_is_update;

	/*| initialization */
	use_new_alt_symb	= FALSE;

        /* create a pointer for each component if they don't already exist
         * and the flag indicating pointers are to be created is set
         * WBC 06/15/93
         */

        gr$get_assoc_ro_reffile(buffer = &create_ptrs);

        if (create_ptrs)
        {
          my_grid.objid = my_id;
          my_grid.osnum = OM_Gw_current_OS;

          EFmake_pointers(&msg, &my_grid, FALSE);
        }

	/*| test to be sure for display action */
	if( ((me->properties & GRIS_DISPLAYABLE )	||
		(*mode == GRhdo)			||
		(*mode == GRhhdo)			||
		(*mode == GRheo))			&&
		(DPlevel_on( me->level, sp_info )) ) {

		/*| convert matrix */
		sts = om$send(	msg	 = message GRowner.GRget_matrix(
						&msg,
						mx_type,
						matrix,
						&new_type,
						new_mat ),
				targetid = my_id );
		as$status( sts = sts );

		if( me->owner_properties & 
			(GR_SYM_COLOR | GR_SYM_WEIGHT | GR_SYM_STYLE )){

			/*| modif of alt_symb */
			use_new_alt_symb	= TRUE;


			sts = om$send(	msg	 = message GRvg.GRgetsymb
							( &msg, &symb ),
					targetid = my_id );
			as$status( sts = sts, msg = "Error in msg GRgetsymb" );



			if( alt_symb )	new_alt_symb	= *alt_symb;
			else {
				new_alt_symb.color	= NULL;
				new_alt_symb.weight	= NULL;
				new_alt_symb.style	= NULL;
			}

			if( (me->owner_properties & GR_SYM_COLOR) &&
						(!new_alt_symb.color) ){
				new_alt_symb.color 	= &symb.display_attr.color;
			}

			if( (me->owner_properties & GR_SYM_WEIGHT) && 
						(!new_alt_symb.weight) ){
				new_alt_symb.weight 	= &symb.display_attr.weight;
			}

			if( (me->owner_properties & GR_SYM_STYLE) && 
						(!new_alt_symb.style) ){
				new_alt_symb.style	= &symb.display_attr.style;
			}

		}/*end use disp*/

		/*| level */
		for( i=0; i < (DP_NUM_OF_LEVELS/32 + 1); i++ )
			all_layers[i] = ~0;

		DPset_levels(save_layers, all_layers, sp_info);

		if( me->properties & GRIS_VIEW_INDEP )
			dp$set_view_ind (	type = 0, point = me->origin, 
						dp_info = sp_info,
						old	= &view_info );

		sts = om$send(	msg	 = message ACheader.ACfind_model
						( &msg,	&model ),
				targetid = my_id );
		as$status( sts = sts );

	save_br = ASbroadcast_in_progress;
	ASbroadcast_in_progress = TRUE;


        /* Due to the problem with nested macros, try not to add
           macros to display lists 
        */

                old_is_update = sp_info->is_update;
                sp_info->is_update = 0;
/*
                DPdlist_enter_reference_file( sp_info, new_type, new_mat );  
*/

		sts = om$send(	msg	 = message GRgraphics.GRdisyourself(
		 					rc,
							&new_type,
							new_mat,
							mode,
							(use_new_alt_symb) ? 
								&new_alt_symb : 
								alt_symb,
							sp_info,
							range_key ),
				targetid = model.objid,
				targetos = model.osnum );

        sp_info->is_update = old_is_update;
/*
                DPdlist_enter_reference_file( sp_info, mx_type, matrix );  
*/

	ASbroadcast_in_progress = save_br;
		as$status( sts = sts, msg = "Error in msg GRdisyourself" );

		if( me->properties & GRIS_VIEW_INDEP )
			dp$reset_view_ind (dp_info = sp_info, old = &view_info);

		/*| restore layer */
		DPreset_levels(save_layers, sp_info);

	}/*end test level*/

return	OM_S_SUCCESS;
}

/* ********** MSG GRgetobjinfo () **************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
IGRlong		sts;
IGRchar		*mac_name;
struct	GRid	mac_def;
IGRchar		temp_buf[100];
IGRchar		i;


	sts = om$send(	msg	 = message ACcpx.find_macro( &mac_def ),
			targetid = my_id );

	if( sts & 1 )
		sts = om$send(	msg	 = message ACcpx_defn.ACgive_name( &mac_name ),
			targetid = mac_def.objid, 
			targetos = mac_def.osnum );

	*rc	= 1;

	if( sts & 1 ){
		char msg[20];
		if( me->STATE & ncpx_root ) {
		  ex$message(buff=msg,msgnumb=AS_I_RootNHeadN);
		  sprintf( temp_buf, "%s%s",msg, mac_name ); }
		else {
		  ex$message(buff=msg,msgnumb=AS_I_Header);
		  sprintf( temp_buf, "%s%s",msg, mac_name );}

		/*| nothing for rep wait jla */

	} else	ex$message(buff=temp_buf,msgnumb=AS_I_HeaderN);

	for( i=0; i<29; i++ )
		info->type[i] = temp_buf[i];
	info->type[29] = '\0';

	/*" info->type : %s\n", info->type */

return	OM_S_SUCCESS;
}

/* ************** MSG GRptproject () **********************************	*/

method GRptproject( IGRlong *rc; IGRshort *matrix_type; IGRmatrix matrix; 
			IGRpoint point, proj_pt; 
			struct GRparms *proj_parms )
{

IGRlong		sts;
IGRlong		msg;
IGRdouble	new_mat[16];
IGRshort	new_type;
struct	GRid	model;


	/*| initialization */

	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					matrix_type,
					matrix,
					&new_type,
					new_mat ),
			targetid = my_id );
	as$status( sts = sts );
	
	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = message GRgraphics.GRptproject(
					rc,
					&new_type,
					new_mat,
					point,
					proj_pt,
					proj_parms ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

/* ************** MSG GRptproject () **********************************	*/

method GRptprocess( IGRlong *rc; IGRshort *matrix_type; IGRmatrix matrix; 
			IGRpoint point, proj_pt; 
			IGRdouble *acc_tolerance;
			struct GRparms *proj_parms )
{

IGRlong		sts;
IGRlong		msg;
IGRdouble	new_mat[16];
IGRshort	new_type;
struct	GRid	model;


	/*| initialization */

	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					matrix_type,
					matrix,
					&new_type,
					new_mat ),
			targetid = my_id );
	as$status( sts = sts );
	
	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = message GRgraphics.GRptprocess(
					rc,
					&new_type,
					new_mat,
					acc_tolerance,
					point,
					proj_pt,
					proj_parms ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

/* ************** MSG GRlnproject () **********************************	*/

method GRlnproject( IGRlong *rc; IGRshort *matrix_type; IGRmatrix matrix; 
			struct IGRline *line; 
			IGRpoint ln_pt, proj_pt; IGRdouble *t;
			struct GRparms *proj_parms )

{
IGRlong		sts;
IGRlong		msg;
IGRdouble	new_mat[16];
IGRshort	new_type;
struct	GRid	model;


	/*| initialization */

	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					matrix_type,
					matrix,
					&new_type,
					new_mat ),
			targetid = my_id );
	as$status( sts = sts );
	
	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = message GRgraphics.GRlnproject(
					rc,
					&new_type,
					new_mat,
					line,
					ln_pt,
					proj_pt,
					t,
					proj_parms ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

/* ************** MSG GRlnprocess () **********************************	*/

method GRlnprocess( IGRlong *rc; IGRshort *matrix_type; IGRmatrix matrix; 
			double *acc_tolerance;
			struct IGRline *line; 
			IGRpoint ln_pt, proj_pt; IGRdouble *t;
			struct GRparms *proj_parms )

{
IGRlong		sts;
IGRlong		msg;
IGRdouble	new_mat[16];
IGRshort	new_type;
struct	GRid	model;


	/*| initialization */

	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					matrix_type,
					matrix,
					&new_type,
					new_mat ),
			targetid = my_id );
	as$status( sts = sts );
	
	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = message GRgraphics.GRlnprocess(
					rc,
					&new_type,
					new_mat,
					acc_tolerance,
					line,
					ln_pt,
					proj_pt,
					t,
					proj_parms ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

/* ************** MSG GRdelete () **********************************	*/

method GRdelete (IGRlong	*msg; struct GRmd_env	*mod_env)
{
	IGRint		status = OM_S_SUCCESS;
	struct GRid	my_grid;

	*msg = MSSUCC;
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	/* If this isn't a delete of a dynamic copy ...	*/
	if (mod_env->md_id.objid != NULL_OBJID)
		/* Make sure it's ok with PDM to delete this macro */
		if (!PDMpre_delete (&my_grid, mod_env))
			status = OM_E_ABORT;

	if ( status & 1)
    	{
		/*A delete the macro */
		/* put the deleted element in the batch queue   */
		if(!ASbroadcast_in_progress)
 		{
		   IGRshort	nAction;
		   IGRint	BatchMode;
		   IGRshort	nMask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

			nd$wait_batch(type = GR_DELETED,
				nb_obj = 1,
				l_object = &my_grid);

			/* If the batch mode is defer, I don't need to go
			   and the go properties of the model because i am
			   not only the one that will be connected to
			   ACmodel */

			 /* If batch mode is deffer, change go properties
			    to non locatable and non displayable */

			nd$mod_batch(request = ND_INQ,
				p_ret_mode = &BatchMode);

			if( BatchMode == ND_DEFER)
			{
				/* Change the properties if necessary  */
				nAction=0;
				status =
				om$send(msg      = message GRvg.GRchgprops(
					msg,&nAction,&nMask),
					targetid = my_id );
				as$status();
			}

		} else {
			status =
			om$send( msg = message NDnode.NDdelete( mod_env),
				targetid = my_id);
			as$status();
  		}

		/* if this isn't a delete of a dynamic copy ... */
		if (mod_env->md_id.objid != NULL_OBJID)
			/* Notify PDM that the macro has been deleted */
			PDMpost_delete (&my_grid, mod_env);
	}
    
	return status;
}

end implementation ACheader;
