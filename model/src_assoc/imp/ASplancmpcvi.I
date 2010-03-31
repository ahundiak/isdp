/*
/*  History :
/*	LLC :- 10_dec_91	 + creation date
/*	Sudha	06/01/93	modified to handle BSprototypes
/*
/* */

class implementation ASplancompcv;

#include "dpdef.h"
#include "dpmacros.h"
#include "AS_status.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bscrossp.h"

#define	AS_DEBUG

#define AS_DISP_ALL		0x00
#define	AS_DISP_PARA		0x01
#define	AS_DISP_EXCEPT_ORTHO	0x02

from	IGEgragad	import	DPinrot;

/* *********************** MSG GRchgprops () **************************	*/

method GRchgprops( IGRlong *msg; IGRshort *action, *props )

{
IGRlong		sts;

	sts = om$send(	msg	 = message GRvg.GRchgprops
					( msg, action, props ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message GRgraphics.GRchgprops
					( msg, action, props ),
			p_chanselect = &AS_to_comp );
	as$status( sts = sts );

return	sts;
}

/* ****************** MSG GRownaddwrng () *****************************	*/

method GRownaddwrng (IGRlong *msg; struct GRmd_env *mod_evn;
                     GRobjid *objid; GRrange range)
{
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
}

/* ****************** MSG GRownremwrng () *****************************	*/

method GRownremwrng (IGRlong *msg; struct GRmd_env *mod_env;
                     GRobjid *objid; GRrange range)
{
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
}

/* ************ MSG ASget_selector () *********************************	*/

method ASget_selector( IGRlong *msg; IGRint *selector )
{
	*msg		= MSSUCC;
	*selector	= (IGRint) me->select_behav;

return	OM_S_SUCCESS;
}

/* ************ MSG ASset_selector () *********************************	*/

method ASset_selector( IGRlong *msg; IGRint selector )
{
	*msg		 = MSSUCC;
	me->select_behav = (IGRchar) selector;

return	OM_S_SUCCESS;
}

/* ************ MSG GRlocate () ***************************************	*/

method GRlocate( struct	GRlc_cvl *cvl; OM_p_KEY_DESC range_key )

{
IGRlong		sts;

	/*| send locate for this level */
	sts = om$send(	msg	 = message GRvg.GRlocate(
					cvl,
					range_key ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg GRlocate" );

return	sts;
}

/* ************* MSG GRdisyourself () *********************************	*/

method	GRdisyourself( 	IGRlong	*rc; IGRshort *mx_type; IGRmatrix matrix;
			enum GRdpmode *mode; struct IGRaltdisplay *alt_symb; 
			struct DP_information *sp_info; 
			OM_p_KEY_DESC range_key )

{
IGRlong			sts, msg;

/* This has been copied from exec_node */

IGRint			batch_mode;
struct	GRid		my_grid;
extern	IGRboolean 	dynamics_in_progress;
extern	IGRboolean	ASbroadcast_in_progress;
IGRboolean		save_br;
IGRdouble		view_mat[16];
IGRint			disp_state;


	/*| initialization */
	disp_state	= 1;
	*rc		= MSSUCC;

	/*" selector : %d, window : %d/%d\n", me->select_behav, sp_info->view_objid, sp_info->view_osnum */
	/*" prop (x) : %x\n", me->properties */

	/*| get z vector for window */
	sts = om$send( msg	 = message IGEgragad.DPinrot
					( &msg, view_mat ),
			targetid = sp_info->view_objid,
			targetos = sp_info->view_osnum );
	if( sts&1 ){

		sts = om$send(	msg	 = message ASplancompcv.ASis_visible(
						&msg,
						mx_type,
						matrix,
						&view_mat[8],
						&disp_state ),
				targetid = my_id );
		as$status( sts = sts );
	}

	if( ! (disp_state&1))	return OM_S_SUCCESS;

	/*| initialization */
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	if( ! ASbroadcast_in_progress ){
		/* compute if necessary and display sub graph */

		nd$mod_batch(	request		= ND_INQ,
				p_ret_mode 	= &batch_mode );

		if( dynamics_in_progress && *mode == GRhd && 
					batch_mode == ND_IMMEDIATE ){
			nd$exec_batch();
		        GRabsg_del_all();
			nd$broadcast_graph(	
				p_msg	 = message GRowner.GRdisyourself( 
							rc, 
							mx_type,
							matrix, 
							mode,
							alt_symb, 
							sp_info, 
							range_key)
/*		,		mode = OM_e_wrt_message */);

		} else if( ! dynamics_in_progress && 
				( batch_mode == ND_IMMEDIATE ||
   				      batch_mode == ND_TRANSACTION  ) )
			nd$exec_batch(mode = ND_DISP_BODY);

	}/*end broadcast*/

	/*| initialization */
	/*" prop (x) : %x\n", me->properties */

	/*| test to be sure for display action */

	if(	(me->properties & GRIS_DISPLAYABLE )	||
		(*mode == GRhdo)			||
		(*mode == GRhhdo)			||
		(*mode == GRheo)	){

		save_br = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE;
		sts = om$send(	msg	 = message GRgraphics.GRdisyourself(
		 				rc,
						mx_type,
						matrix,
						mode,
						alt_symb,
						sp_info,
						range_key ),
				p_chanselect = &AS_to_comp );
		ASbroadcast_in_progress = save_br;
		as$status( sts = sts, msg = "Error in msg GRdisyourself" );
	}

return	OM_S_SUCCESS;
}

/* ************************** MSG NDplace () **************************	*/

method	NDplace( struct GRas *assoc_list; struct GRmd_env *md_env; 
				char *go_cnst_list )
{
IGRlong		sts;
IGRlong		msg;
struct	GRid	loc_id;
struct	GRvg_construct	*loc_str;

	loc_str	= (struct GRvg_construct *) go_cnst_list;

	loc_id	= md_env->md_id;
	md_env->md_id.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message AScompcurve.NDplace
					( assoc_list, md_env, go_cnst_list ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );
	md_env->md_id	= loc_id;

	/*| add elmt in Rtree */
	sts = om$send(	msg	 = message GRvg.GRaddwrng( &msg, md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
	as$status( sts = sts );

	/*" add props to elmt prop (x) : %x\n", loc_str->properties */
	me->properties	= loc_str->properties;

return	sts;
}

/* ******************** MSG ASis_visible () ***************************	*/

method ASis_visible( IGRlong *rc; IGRshort *mx_type; IGRdouble *matrix;
					IGRdouble *view_vect; IGRint *state )

{
IGRlong			sts, msg;
IGRdouble		view_mat[16];
IGRdouble		pt_info[6];
IGRdouble		loc_vect[3], res_vec[3];
IGRdouble		dist;
struct	IGRplane	my_plane;
BSrc			bs;
IGRint			i;


	/*| initialization */
	*rc	= MSSUCC;
	*state	= 1;
	for( i=0; i<3; i++)	loc_vect[i] = view_vect[i];

	/*| get normal vector for ccv */
	my_plane.point	= &pt_info[0];
	my_plane.normal	= &pt_info[3];
	sts = om$send(	msg	 = message GRvg.GRdetplane(
					&msg,
					mx_type,
					matrix,
					&my_plane ),
			targetid = my_id );
	if( ! (sts & msg & 1)){

		*rc	= MSFAIL;
		return	OM_S_SUCCESS;
	}

	/*" selector : %d\n", me->select_behav */
	if( me->select_behav & AS_DISP_PARA ){

		BSnorvec( &bs, loc_vect );
		BSnorvec( &bs, my_plane.normal );
		BScrossp( &bs, loc_vect, my_plane.normal, res_vec );
		dist = BSlenvec( &bs, res_vec );
		if( (dist * dist) > 0.0001 )	*state = 0;
		/*" dist para : %f\n", dist */

	} else if( me->select_behav & AS_DISP_EXCEPT_ORTHO ){

		BSnorvec( &bs, loc_vect );
		BSnorvec( &bs, my_plane.normal );
		dist = BSdotp( &bs, loc_vect, my_plane.normal );
		if( (dist * dist) < 0.0001 )	*state = 0;
		/*" dist ortho : %f\n", dist */
	  }

	/*" disp state : %d\n", *state */

return	OM_S_SUCCESS;
}

end implementation ASplancompcv;

