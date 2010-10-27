/* $Id: VDrelat_hdri.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDrelat_hdri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrelat_hdri.I,v $
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
# Revision 1.2  1995/12/29  09:21:26  pinnacle
# Replaced: vdrelhdr/VDrelat_hdri.I for:  by svkadamb for vds.240
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
/*	LLC :- march 92	 + creation date
/*
/* */

class implementation VDrelat_hdr;

#include "OMmacros.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asmacros.h"

#include "DIdef.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grerr.h"
#include "exmacros.h"

#include "acrepdef.h"
#include "acrepmacros.h"

#include "grsymdef.h"
#include "nddef.h"

#define	AS_DEBUG

extern	GRclassid	OPP_VDlink_class_id;
extern	GRclassid	OPP_EMSsubbs_class_id;
extern  GRclassid	OPP_GRgencs_class_id;

from	ACcpx_defn	import	ACgive_name;
from	VDlink		import	ACdisconnect_head;
from	VDlink		import	ACget_model_list;
from	ACpretend	import	ACfind_parent;

#define	ACS_TRANS_TYPE		0x3f

#define ACS_CONSUME_PROPS_MASK	0xc0
#define ACS_PERSISTANT		0x40
#define ACS_MODEL_CONSUME	0x80

#define ACS_MDL_CONSUME		0x01	/* model will be consume	*/
#define ACS_MDL_UNCONSUME	0x02	/* model will be unconsume	*/
#define ACS_MDL_CMPT		0x04	/* model will be recompute	*/
#define ACS_MDL_DELETE		0x08	/* model will be delete		*/

/* ********************************************************************	*/

#define acfail() \
    status = om$send(msg = message ACncpx.NDdelete(&emp_env), \
		       targetid = my_id ); \
    as$status(action = RET_STATUS); \
    return(1);

/* *************** MSG ACmplace_from_def () ***************************	*/
/* The graphics model must be on the first position of parent's list	*/


method ACmplace_from_def(int *rc, prop; char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
IGRlong			msg, sts, status;
struct	GRmd_env	emp_env;
struct	GRsymbology	symb;
struct	GRid		link_model;
IGRint			cn_type;
IGRint			i;
IGRchar			*macro_name;
struct	GRid		mac_id;
IGRint			int_msg;
struct	GRid		master;


	/*| initialization */
	*rc		= MSSUCC;
	emp_env		= *md_env;

	if( ! ( prop & AChdr_noprotect )){

		/*" num_temp : %d\n", num_temp */
		if( num_temp < 2 ){

			printf(" not enougth template for create an ACrelat_hdr\n");
			acfail();
		}
	}

	sts = om$send(	msg	 = message NDnode.NDconnect( 
					num_temp,
					temp_list,
					NULL_GRID, 
					ND_NEW),
			targetid = my_id);
	as$status( sts = sts, msg = "Error in msg NDconnect" );

	/*| get my master */
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					"",
					&master,
					NULL,
					NULL ),
			targetid = temp_list[0].objid,
			targetos = temp_list[0].osnum );
	as$status( sts = sts );
	/*" master : %d/%d\n", master.objid, master.osnum */

	/*| get model macro definition */
	sts = om$send(	msg	 = message ACcpx.find_macro
					( &mac_id ),
			targetid = master.objid,
			targetos = master.osnum );
	as$status( sts = sts );

	sts = om$send(	msg	 = message ACcpx_defn.ACgive_name
					( &macro_name ),
			targetid = mac_id.objid,
			targetos = mac_id.osnum );
	as$status( sts = sts );
	/*" macro_name : %s\n", macro_name */

	/* find macro definition */
	sts = om$send(	msg	 = message ACncpx.ACattach
					( &int_msg, macro_name ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS);

	/*| create VDlink */
	link_model.osnum	= OM_Gw_current_OS;
	link_model.objid	= NULL_OBJID;
	
	sts = om$construct(	classid	= OPP_VDlink_class_id,
				p_objid	= &link_model.objid );
	as$status( sts = sts );
	/*" link_model : %d/%d\n", link_model.objid, link_model.osnum */

	/*| connect : link_model component of header */
	sts = om$send(	msg	= message Root.connect(
						AS_to_owner,
						0,
						my_id,
						OM_Gw_current_OS,
						AS_to_comp,
						OM_K_MAXINT ),
			targetid = link_model.objid,
			targetos = link_model.osnum );
	as$status( sts = sts, msg = "Error in msg connect", action = RET_STATUS );

	/*| connect : link_model depend of graphic model */
	sts = om$send(	msg	 = message NDnode.NDconnect( 
					1,
					&temp_list[0],
					NULL_GRID, 
					ND_NEW ),
			targetid = link_model.objid,
			targetos = link_model.osnum );
	as$status( sts = sts, msg = "Error in msg NDconnect" );

	/*| set model symbology */
	sts = om$send(	msg	 = message GRvg.GRgetsymb
					( &msg, &symb ),
			targetid = master.objid,
			targetos = master.osnum );
	as$status( sts = sts, msg = "Error in msg getsymb" );

	sts = om$send(	msg	 = message GRvg.GRputsymb
					( &msg, &symb ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg GRputsymb" );

	/*| set instance data */
	me->owner_properties	= 0;
	me->properties		= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	me->origin[0] = 0.;
	me->origin[1] = 0.;
	me->origin[2] = 0.;

	for( i=1; i<8; i++ )	me->matrix[i]   = 0.;
	me->matrix[0]	= 1.;
	me->matrix[4]	= 1.;
	me->matrix[8]	= 1.;

	if( prop & AChdr_nocompute )	return	OM_S_SUCCESS;
	/*| NDs_compute set internal matrix */
	cn_type = ND_COMP;
	sts = om$send(	msg	 = message ACncpx.NDcompute_node(
						&msg,
						cn_type,
						num_temp,
						temp_list,
						&emp_env ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );

	if( prop & AChdr_norange )	return	OM_S_SUCCESS;
	/*| addwrng */
	sts = om$send(	msg 	 = message GRgraphics.GRaddwrng( &msg, md_env ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg GRaddwrng" );

	if( prop & AChdr_nodisplay )	return	OM_S_SUCCESS;
	/*| display */
	sts = om$send(	msg 	 = message NDnode.NDdisplay
					( 0, GRbd, md_env ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );

return	OM_S_SUCCESS;
}

/* ****************** MSG ACfind_model () **************************	*/

method	ACfind_model( IGRlong *rc; struct GRid *model )

{

IGRlong		sts;
GRclassid	cid;
struct	GRid	lk_model;

	/*| initialization */
	*rc		= MSFAIL;
	model->objid	= NULL_OBJID;
	lk_model.objid	= NULL_OBJID;

	/*| get model */
        sts = om$get_objid_at_index(    object          = me,
                                        p_chanselect    = &AS_to_comp,
                                        index           = 0,
                                        objidaddr       = &lk_model.objid,
                                        osnumaddr       = &lk_model.osnum );
        as$status( sts = sts, msg = "Error in mc get_objid_at_index" );
	if ( lk_model.objid == NULL_OBJID ) goto wrapup;

	sts = om$get_classid(	objid	  = lk_model.objid,
				osnum	  = lk_model.osnum,
				p_classid = &cid );
	as$status( sts = sts );

	if( om$is_ancestry_valid(	subclassid	= cid,
					superclassid	= OPP_VDlink_class_id ) 
		== OM_S_SUCCESS ){	
		*model	= lk_model;
		*rc	= MSSUCC;
	}

wrapup :
	;

	/*" model : id/os = (%d/%d)\n", model->objid, model->osnum */

return	OM_S_SUCCESS;
}

/* ************ MSG GRget_components () *******************************	*/

method GRget_components( IGRlong *rc; struct GRmd_env *mod_env;
                          struct GRid objects[]; IGRint number_objects;
                          IGRint *count; IGRint from_obj; IGRint to_obj )
{
IGRlong		sts, msg;
struct	GRid	cur_model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		*rc	= MSFAIL;
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

return	om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );
}

/* *************** MSG GRget_number_components () *********************	*/

method GRget_number_components( IGRlong *rc; IGRint *count )

{
IGRlong		sts, msg;
struct	GRid	cur_model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		*rc 	= MSFAIL;
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

return	om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );
}

/* ************ MSG ACget_share_feet_list () ************************* */

method ACget_share_feet_list( 	IGRlong *rc; IGRint size_list; 
				struct GRid *feet_list; IGRint *count_feet )
{
IGRlong			sts, msg;
IGRint			loc_count;
struct	GRid		cur_model;


	/*| initialization */
	*rc		= OM_S_SUCCESS;
	*count_feet	= 0;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf("Warning no model connected\n");
		*rc = OM_E_ABORT;
		goto	wrapup;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

	sts = om$send(	msg	 = message GRowner.GRget_number_components
					( &msg, count_feet ),
			targetid = cur_model.objid,
			targetos = cur_model.osnum );
	as$status( sts = sts );
	/*" count_feet : %d\n", *count_feet */

	if( feet_list != NULL && size_list > 0 ){

		sts = om$send(	msg	 = message GRowner.GRget_components(
						rc,
						NULL,
						feet_list,
						size_list,
						&loc_count,
						0,
						size_list ),
			targetid = cur_model.objid,
			targetos = cur_model.osnum );
		as$status( sts = sts );

	}/*end feet_list*/

wrapup :
	;

return	OM_S_SUCCESS;
}

/* *************** MSG NDdelete () ************************************	*/

method NDdelete( struct GRmd_env *md_env )

{
IGRlong		sts, msg;
struct	GRid	my_grid;
struct	GRid	model;
OM_S_OBJID	save_id;


	/*| initialization */
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts );

	if( msg & 1 ) {

		/*" disconnect header (%d/%d) from models (%d/%d)\n", my_id, OM_Gw_current_OS, model.objid, model.osnum */
		sts = om$send(	msg	 = message VDlink.ACdisconnect_head(
						&msg,
						&my_grid,
						md_env ),
				targetid = model.objid,
				targetos = model.osnum );
		as$status( sts = sts, msg = "Error in msg ACdisconnect_head" );
	}

	/*| put header out R-tree */
	if( md_env->md_id.objid != NULL_OBJID ) {

		/*| take off header of range */
		sts = om$send(	msg	 = message GRgraphics.GRremwrng
						( &msg, md_env ),
				targetid = my_id );
/*^		as$status( sts = sts ); */
	}

	/*| delete header */
	save_id 	= md_env->md_id.objid;
	md_env->md_id.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message ACconst.NDdelete( md_env ),
			mode 	 = OM_e_wrt_message,
			targetid = my_id );
	md_env->md_id.objid = save_id;
	as$status( sts = sts, msg = "Error in msg NDdelete" );

return	OM_S_SUCCESS;
}

/* ************* MSG ACget_model_mgr () *******************************	*/

method ACget_model_mgr( IGRlong *rc; struct GRid *model_mgr )

{

	/*| initialization */
	*rc	= MSSUCC;
	model_mgr->objid	= my_id;
	model_mgr->osnum	= OM_Gw_current_OS;

return OM_S_SUCCESS;
}


/* ************* MSG NDcompute_node () ********************************	*/

method NDcompute_node( IGRlong *rc; IGRint cn_type; IGRint num_temp; 
			struct GRid temp_list[]; struct GRmd_env *md_env )

{
IGRlong			sts, msg;
IGRint			i;
struct	ret_struct	ref_st;
IGRdouble		inv_mat[16];
IGRdouble		trans_mat[16];
IGRdouble		symm_mat[16];
IGRdouble		tmp_mat[16];
struct	GRid		gr_model;
IGRdouble		mat[16];
IGRshort		mat_type;
IGRshort		four;
IGRint			trans_type;


//	*rc	= ND_COMP_SUCC;		not in 143
	*rc	= MSSUCC;

	if( me->state & ND_DEGRADED ){

		as$status( sts = 0, string =("element %d not updated because degraded\n",my_id));
		return	OM_W_ABORT;
	}
	if( me->STATE & ncpx_root ){

		/*| object STATE is ncpx_root */
		return	OM_S_SUCCESS;
	}

	/*| initialization */
	four	= 4;

	/*| get matrix os matrix for graphic model */
	mat_type	= MAIDMX;
	MAidmx( &msg, mat );

	sts = om$send(	msg	 = message ACpretend.ACfind_parent(
					&gr_model,
					&mat_type,
					mat ),
			targetid = temp_list[0].objid,
			targetos = temp_list[0].osnum );
	if( sts == OM_W_UNKNOWN_MSG )	sts = OM_S_SUCCESS;
	as$status( sts = sts );

/*
	sts = om$send(	msg	 = message VDrelat_hdr.ACreturn_foot(
					&msg,
					"",
					&gr_model,
					&mat_type,
					mat ),
			mode = OM_e_wrt_message,
			targetid = temp_list[0].objid,
			targetos = temp_list[0].osnum );
	if( sts == OM_W_UNKNOWN_MSG )	sts = OM_S_SUCCESS;
	as$status( sts = sts );
*/
	/*| create the transformation matrix with parents */
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( rc, &ref_st, md_env ),
			targetid = temp_list[1].objid,
			targetos = temp_list[1].osnum );
	as$status( sts = sts );

	/*| -------- Calculate transformation ------------------ */
	/*" me->xtype : %d\n", me->xtype */

	trans_type = (IGRint) (me->xtype & ACS_TRANS_TYPE);

/*^
	switch( trans_type ){

	case 0 :	printf(" symetric to YZ plane \n");
			break;
	case 1 :	printf(" symetric to XZ plane \n");
			break;
	case 2 :	printf(" symetric to XY plane \n");
			break;
	case 3 :	printf(" use Cs matrix \n");
			break;
	default :
		printf(" %d unknown case \n", trans_type );
	}
*/

	/* transformation is T = P * Msym * (P-1)  (cf cpymir ) */

	sts = MAinvmx( &msg, &four, ref_st.var.ref_st.t, inv_mat );
	MAidmx( &msg, symm_mat );

	switch( trans_type ){

	case 0 :	symm_mat[0]	= -1.;
			break;
	case 1 :	symm_mat[5]	= -1.;
			break;
	case 2 :	symm_mat[10]	= -1.;
			break;
	case 3 :
		/*| set instance data */
		me->origin[0] = ref_st.var.ref_st.t[3];
		me->origin[1] = ref_st.var.ref_st.t[7];
		me->origin[2] = ref_st.var.ref_st.t[11];

		for( i=0; i<3; i++ ){
			me->matrix[i]   = ref_st.var.ref_st.t[i];
			me->matrix[i+3] = ref_st.var.ref_st.t[i+4];
			me->matrix[i+6] = ref_st.var.ref_st.t[i+8];
		}

		*rc	= MSSUCC;
		return	OM_S_SUCCESS;

	default :
		printf(" %d unknown case set symetric to YX plane by default\n", 
			trans_type );
		symm_mat[0]	= -1.;
	}

	MAmulmx( &msg, &four, &four, &four, 
				ref_st.var.ref_st.t, symm_mat, tmp_mat );

	MAmulmx( &msg, &four, &four, &four, tmp_mat, inv_mat, trans_mat );

	if( mat_type != MAIDMX ){
		MAmulmx( &msg, &four, &four, &four, 
					trans_mat, mat, tmp_mat );

		for( i=0; i<16; i++ )	trans_mat[i] = tmp_mat[i];
	}

	/*| set instance data */
	me->origin[0] = trans_mat[3];
	me->origin[1] = trans_mat[7];
	me->origin[2] = trans_mat[11];

	for( i=0; i<3; i++ ){
		me->matrix[i]   = trans_mat[i];
		me->matrix[i+3] = trans_mat[i+4];
		me->matrix[i+6] = trans_mat[i+8];
	}

//	*rc	= ND_COMP_SUCC;		not in 143
	*rc	= MSSUCC;

return	OM_S_SUCCESS;
}

/* ********************** MSG NDupdate () *****************************	*/

method NDupdate( int *msg, cn_type, count; struct GRid *parents; 
			int *parent_state; struct GRid *context, *new_objid;
				struct GRmd_env *md_env )
{
IGRlong		sts, loc_msg;

	// delete tf_feet	
	
	sts = om$send(	msg	 = message ACheader.ACclean_tf_foot
					( &loc_msg, md_env, TRUE ),
			targetid = my_id );

	sts = om$send(	msg	 = message ACheader.NDupdate( 
					msg, cn_type, count,
					parents, parent_state,
					context, new_objid, md_env ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );

return	sts;
}


/* ========================================================================= */

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
  *msg = MSSUCC;
  *properties = GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
	/*	GR_LC_CMP_READ 	   |     */
/* To test change color on a macro component  jla 06-oct-89 */
	  	GR_LC_CMP_READ 	   | GR_LC_CMP_WRITE |
		GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
		GR_LC_RIGID | GR_LC_FLEXIBLE;
 
  return(OM_S_SUCCESS);
}

/* ***************** MSG NDcopy() *************************************	*/

method NDcopy( IGRlong *rc; IGRint cp_type; 
		struct GRmd_env *obj_env, *new_env; struct GRid *new_obj )

{
IGRlong			sts, msg;
struct	GRid		new_model;
struct	GRid		*temp;
IGRchar			def_name[DI_PATH_MAX];
IGRint			i;
struct	GRpost_info	info;
struct	IGRlbsys	lbs;
IGRshort		new_type;

	/*| initialization */
	*rc	= MSFAIL;
	temp	= NULL;
	def_name[0]	= '\0';
	new_obj->objid	= NULL_OBJID;	
	new_obj->osnum	= new_env->md_id.osnum;

/*^
	printf(" obj_env : id/os = (%d/%d)\n", obj_env->md_id.objid, obj_env->md_id.osnum ); 
	pr_mat(" obj_mat", 4, 4, obj_env->md_env.matrix);

	printf(" new_env : id/os = (%d/%d)\n", new_env->md_id.objid, new_env->md_id.osnum ); 
	pr_mat(" new_mat", 4, 4, new_env->md_env.matrix);
*/

	if( OM_Gw_current_OS != new_env->md_id.osnum ){
		struct	GRid		gr_model;
		IGRint			nb_model;
		struct	GRmd_env	model_env;
		struct	GRid		my_grid;

		sts = om$send(	msg	 = message ACheader.ACfind_model
						( &msg, &new_model ),
				targetid = my_id );
		as$status( sts = sts, action = RET_STATUS );

		/*| get graphics model */
		sts = om$send(	msg	= message VDlink.ACget_model_list(
					&msg,
					1,
					&gr_model,
					&nb_model ),
			targetid = new_model.objid,
			targetos = new_model.osnum );
		as$status( sts = sts, action = RET_STATUS );

		model_env	= *obj_env;
		sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					&obj_env->md_env.matrix_type,
					obj_env->md_env.matrix,
					&model_env.md_env.matrix_type,
					model_env.md_env.matrix ),
			targetid = my_id );
		as$status( sts = sts );

		/*| NDcopy of model */
		sts = om$send(	msg	 = message NDnode.NDcopy_to_root(
						rc,
						cp_type,
						&model_env,
						new_env,
						new_obj ),
				targetid = gr_model.objid,
				targetos = gr_model.osnum );
		as$status( sts = sts, action = RET_STATUS );
		/*" my_obj : %d/%d\n", my_obj.objid, my_obj.osnum */

		/*| transfert symbology */
		my_grid.objid	= my_id;
		my_grid.osnum	= OM_Gw_current_OS;
		ACSset_tf_foot_symb( &my_grid, new_obj );

	} else {
		sts = om$construct_and_copy(	object	= me,
						osnum	= new_obj->osnum,
						p_objid	= &new_obj->objid );
		as$status( sts = sts, msg = "Error in mc construct_and_copy", 
					action	= RET_STATUS );
		/*" new_obj : id/os = (%d/%d)\n", new_obj->objid, new_obj->osnum */

		/*| get old geom */
		sts = om$send(	msg	 = message GRowner.GRget_matrix(
					&msg,
					&obj_env->md_env.matrix_type,
					obj_env->md_env.matrix,
					&new_type,
					lbs.matrix ),
				targetid = my_id );
		as$status( sts = sts );
		/*^	pr_mat(" old geom ", 4, 4, lbs.matrix ); */ 

		/*| set geometry */
		for( i=0; i<3; i++ ) {
			lbs.diag_pt1[i]	= 0.;
			lbs.diag_pt2[i]	= 0.;
		}

		/*| modify geometry --> postabs to the copy  no more xform */
		info.construct_flag	= TRUE;
		sts = om$send(	msg	= message ACheader.GRpostabsg(
					&msg,
					new_env,
					&info,
					(IGRchar *) &lbs,
					&new_obj->objid ),
			targetid = new_obj->objid,
			targetos = new_obj->osnum );
		as$status( sts = sts );
		/*| connect copy to model */
		sts = om$send(	msg	 = message ACheader.ACfind_model
						( &msg, &new_model ),
				targetid = my_id );
		as$status( sts = sts );

	}

	*rc	= MSSUCC;

return	OM_S_SUCCESS;
}


method unknown(OM_S_MESSAGE *msg)
{
IGRlong		sts, rc;
struct	GRid	model;

	sts = om$send(	msg	= message ACheader.ACfind_model
					( &rc, &model ),
			targetid = my_id );
	if( ! (sts & rc & 1) || model.objid == NULL_OBJID )
		return	OM_W_ABORT;
return	om$send( msg = msg, targetid = model.objid, targetos = model.osnum );
}

/* ******************** MSG ACreturn_foot () **************************	*/

method ACreturn_foot(IGRlong *msg;char *footname;
                struct GRid *foot_obj;IGRshort *mat_type;IGRdouble *matrix)

{
IGRlong			sts, loc_msg;
IGRint			i;
struct	GRmd_env	id_env, to_env;
GRclassid		cid;
struct	GRid		tf_go;

	/*| initialization */
	*msg	= MSSUCC;

	if( footname[0]	== '\0' ){
		foot_obj->objid	= my_id;
		foot_obj->osnum	= OM_Gw_current_OS;

		if( mat_type )	*mat_type = MAIDMX;
		if( matrix )	MAidmx( &loc_msg, matrix );

		sts = OM_S_SUCCESS;

	} else {

		sts = om$send(	msg	 = message ACheader.ACreturn_foot(
						msg,
						footname,
						foot_obj,
						&to_env.md_env.matrix_type,
						to_env.md_env.matrix ),
				mode	 = OM_e_wrt_message,
				targetid = my_id );
		as$status( sts = sts );

		if( mat_type )	*mat_type = to_env.md_env.matrix_type;
		if( matrix ) for( i=0; i<16; i++ ) 
					matrix[i] = to_env.md_env.matrix[i];

		// if surface create a tf_foot
		sts = om$get_classid(	osnum	= foot_obj->osnum, 
					objid	= foot_obj->objid, 
					p_classid = &cid );

		if( om$is_ancestry_valid(
				subclassid	= cid,
				superclassid	= OPP_EMSsubbs_class_id )
			== OM_S_SUCCESS ){

			id_env.md_id.objid	= NULL_OBJID;
			id_env.md_id.osnum	= foot_obj->osnum;
			id_env.md_env.matrix_type = MAIDMX;
			MAidmx( &loc_msg, id_env.md_env.matrix );

			to_env.md_id.objid	= NULL_OBJID;
			to_env.md_id.osnum	= OM_Gw_current_OS;

			sts = om$send(	msg	= message GRgraphics.GRcopy(
						&loc_msg,
						&id_env,
						&to_env,
						&tf_go.objid ),
					targetid = foot_obj->objid,
					targetos = foot_obj->osnum );
			as$status( sts = sts );
			tf_go.osnum	= OM_Gw_current_OS;

			// connect tf_go to header
			sts = om$send(	msg	 = message Root.connect(
						AS_to_owner,
						OM_K_MAXINT,
						my_id,
						OM_Gw_current_OS,
						AS_to_comp,
						OM_K_MAXINT ),
					targetid = tf_go.objid,
					targetos = tf_go.osnum );
			as$status( sts = sts );

			*foot_obj	= tf_go;
			if( mat_type )	*mat_type = MAIDMX;
			if( matrix )	MAidmx( &loc_msg, matrix );

		}/* end surface */
	  }

return	sts;
}

/* **************** MSG NDdrawing_copy_geom () ********************	*/

method NDdrawing_copy_geom
                (struct GRid *selected_elements;
                 int    nb_elements;
                 struct GRid **drawing_elements;
                 int    *nb_drawing_elem;
                 double *vector,*point;
                 int *level; struct IGRlbsys *lbsys;
                 struct GRmd_env *from_env,*to_env)

{
IGRlong			sts, msg;
struct	GRid		model;
struct	GRmd_env	loc_env;


	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = message GRowner.GRget_context(
					&msg,
					from_env,
					&loc_env ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message NDnode.NDdrawing_copy_geom(
					selected_elements,
					nb_elements,
					drawing_elements,
					nb_drawing_elem,
					vector, point,
					level,
					lbsys,
					&loc_env, to_env ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

/* ***************** MSG NDdrawing_copy_attr () ***********************	*/

method NDdrawing_copy_attr
              (struct myfeet *attr_name; int nb_attr; struct GRid *drawing_attr;
                 struct GRmd_env *from_env,*to_env )

{
IGRlong			sts, msg;
struct	GRid		model;
struct	GRmd_env	loc_env;


	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = message GRowner.GRget_context(
					&msg,
					from_env,
					&loc_env ),
			targetid = my_id );
	as$status( sts = sts );

	sts = om$send(	msg	 = message NDnode.NDdrawing_copy_attr(
					attr_name,
					nb_attr,
					drawing_attr,
					&loc_env, to_env ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

/* ******************* MSG ACbubble_up () *****************************	*/

method ACbubble_up(long *msg;char *footname;
                     int up_index;OM_p_MESSAGE Condition,Action;
                     enum OM_e_wrt_flag delAction)

{
IGRlong			sts, msg;
struct	GRid		model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &model ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );
	as$status( sts = msg, action = RET_STATUS );

	sts = om$send(	msg	 = OPPmargs,
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

return	sts;
}

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
struct	GRid		src_id;


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

	sts = om$send(	msg	 = message VDlink.ACdisconnect_head(
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

	/*| send move to root */
	sts = om$send(	msg	 = message NDnode.NDmove_to_root
					( &msg, &src_id, md_env ),
			targetid = my_id );
	as$status( sts = sts );

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

/* ******************* MSG ACget_NV_rep () ****************************	*/

method ACget_NV_rep( unsigned char *rep )
{
IGRlong		sts, msg;
struct	GRid	cur_model;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( &msg, &cur_model ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg ACfind_model", action = RET_STATUS );	
	if( ( ! (msg&1 )) || cur_model.objid == NULL_OBJID ) {

		printf(" Warning no model connected\n");
		return	OM_W_ABORT;
	}
	/*" cur_model : id/os = (%d/%d)\n", cur_model.objid, cur_model.osnum */

return	om$send(	msg	 = OPPmargs, 
			targetid = cur_model.objid,
			targetos = cur_model.osnum );
}

/* ************************ FCT ACSconst_hdr () ***********************	*/

IGRlong	ACSconst_hdr( gr_model, md_env, rel_hdr )

struct	GRid		gr_model;
struct	GRmd_env	*md_env;
struct	GRid		*rel_hdr;

{
IGRlong		sts;
GRclassid	cid, mo_cid;
struct	arg { GRclassid *hdr_cid; } arg;
OM_S_MESSAGE	msg;

	cid	= OPP_VDrelat_hdr_class_id;

	om$get_classid(	objid		= gr_model.objid,
			osnum		= gr_model.osnum,
			p_classid	= &mo_cid );

	arg.hdr_cid	= &cid;

	sts = om$make_message(	classid		= mo_cid,
				methodname	= "NDgetHeaderClassid",
				p_arglist	= &arg,
				size		= sizeof arg,
				p_msg		= &msg );
	if( sts & 1 ){
		sts = om$send(	msg	 = &msg,
				targetid = gr_model.objid,
				targetos = gr_model.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );

	}

	/*" cid	: %d\n", cid */
	rel_hdr->osnum	= md_env->md_id.osnum;
	sts = om$construct(	classid	= cid,
				p_objid	= &rel_hdr->objid,
				osnum	= rel_hdr->osnum );
	as$status( sts = sts );
	/*" rel_hdr : %d/%d\n", rel_hdr->objid, rel_hdr->osnum */

return	sts;
}

/* ******************** MSG GRpass_messg () ***************************	*/

method GRpass_messg (IGRlong *msg; IGRushort opts;
                      OM_E_WRT_FLAG wrt_flag;
                      OM_p_MESSAGE messg;
                      struct GRmdenv_info *my_mdenv_info;
                      OM_p_CLASSLIST yes_classes, no_classes;
                      IGRboolean (*eligfunc)(); IGRchar *eligfunc_args;
                      IGRint depth)

{
IGRlong			sts;
struct	GRid		model;
struct	GRmdenv_info	loc_env;
struct	GRmdenv_info	sa_env;

	sts = om$send(	msg	 = message ACheader.ACfind_model
					( msg, &model ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );
	as$status( sts = *msg, action = RET_STATUS );

	sa_env	= *my_mdenv_info;

	sts = om$send(	msg	 = message GRowner.GRget_matrix(
					msg,
					&my_mdenv_info->matrix_type,
					my_mdenv_info->matrix,			
					&loc_env.matrix_type,
					loc_env.matrix ),
			targetid = my_id );
	as$status( sts = sts );

	*my_mdenv_info = loc_env;

	sts = om$send(	msg	 = message GRowner.GRpass_messg(
					msg,
					opts,
					wrt_flag,
					messg,
			 		my_mdenv_info,
					yes_classes,
					no_classes,
					eligfunc,
					eligfunc_args,
					depth ),
			targetid = model.objid,
			targetos = model.osnum );
	as$status( sts = sts );

	*my_mdenv_info = sa_env ;

return	sts;
}

/* ********************* MSG ACtransform_type () *********************	*/

method ACtransform_type( IGRint action; IGRint *xtype )
{
	switch( action ){

	case 0 :	// output transformation type
		*xtype	= (IGRint) ( me->xtype & ACS_TRANS_TYPE );
		break;

	case 1 :	// input transformation type
		me->xtype = (IGRchar) ((me->xtype & ~ACS_TRANS_TYPE) |
						(*xtype & ACS_TRANS_TYPE));
		break;

	case 2 :	// output consume properties
		*xtype	= (IGRint) ( me->xtype & ACS_CONSUME_PROPS_MASK );
		break;

	case 3 :	// input consume properties
		me->xtype = (IGRchar)
				((me->xtype & ~ACS_CONSUME_PROPS_MASK) |
					(*xtype & ACS_CONSUME_PROPS_MASK));
		break;

	default :
		printf(" unknown action \n"); 
	}

return	OM_S_SUCCESS;
}

/* *************** MSG ACshow_data () ************************	*/

method ACshow_data( IGRlong *rc )

{
	*rc	= MSSUCC;
	om$send(	msg	 = OPPmargs,
			mode	 = OM_e_wrt_parent,
			targetid = my_id );

	printf(" xtype	: %d\n", (IGRint) (me->xtype & ACS_TRANS_TYPE) );

	if( me->xtype & ACS_MODEL_CONSUME )
		printf(" header consumed with its model\n");

	else	printf(" model not consumed \n");

return	OM_S_SUCCESS;
}

/* ******************** MSG ACntf_symbol () ***************************	*/

method ACntf_symbol( IGRlong *msg; IGRint action_type )
{
IGRlong			sts, loc_msg;
IGRshort		action, mask;
struct	GRmd_env	md_env;


	/*| initialization */
	*msg	= MSSUCC;
	gr$get_module_env( buffer = &md_env );
	md_env.md_id.osnum	= OM_Gw_current_OS;

	switch( action_type ){

	case ACS_MDL_CONSUME :
		if( me->xtype & ACS_PERSISTANT )
			return	OM_S_SUCCESS;

		me->xtype	|= ACS_MODEL_CONSUME;
		action	= 0;
		mask	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
		sts = om$send(	msg	 = message GRgraphics.GRchgprops
						( &loc_msg, &action, &mask ),
				targetid = my_id );
		break;

	case ACS_MDL_UNCONSUME :
		me->xtype	&= ~ACS_MODEL_CONSUME;
		loc_msg		= MSFAIL;
		sts = om$send(	msg	 = message NDmacro.ACtest_consumed
						( &loc_msg ),
				targetid = my_id );
		if( ! (sts&loc_msg&1)){

			action	= 1;
			mask	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
			sts = om$send(	msg	 = message GRgraphics.GRchgprops
						( &loc_msg, &action, &mask ),
					targetid = my_id );
		}

		break;

	case ACS_MDL_CMPT :
		/*| compute */
		break;

	default :

		printf(" unkwown action : %d\n", action_type );
	}

	// send message on channel children
	sts = om$send(	msg		= OPPmargs,
			p_chanselect	= &ND_children );

return	OM_S_SUCCESS;
}

/* ********************* MSG ACtest_consumed () ***********************	*/

method ACtest_consumed( IGRlong *msg )
{
IGRlong		sts;

	sts = om$send(	msg	 = message ACheader.ACtest_consumed( msg ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );

	// test model consume bit
	if( me->xtype & ACS_MODEL_CONSUME ) *msg = TRUE;

return	sts;
}

/* *********************** MSG NDchange_connect () ********************	*/

method NDchange_connect( int nb_change; struct GRid *old, *new )

{
IGRlong			sts, loc_msg;
IGRint			count;
struct	GRid		list_tmp[20];
IGRint			i;
IGRboolean		fl_model, fl_cs;
IGRdouble		vect[4], wld[10];
IGRint			ret_int;
struct	GRmd_env	md_env;
struct	GRid		cur_dep, img_id, my_grid;
IGRboolean		save_br;
struct GRid 		lk_model;
GRclassid 		cid;
GRclassid		clid ;
struct GRid		gr_obj;
IGRshort		mat_type;
IGRdouble		matrix[16];

extern	IGRboolean	ASbroadcast_in_progress;

	/*| initialization */
	fl_model	= FALSE;
	fl_cs		= FALSE;
	count		= 0;
	gr$get_module_env( buffer = &md_env );
	md_env.md_id.osnum	= OM_Gw_current_OS;
	my_grid.objid	= my_id;
	my_grid.osnum	= OM_Gw_current_OS;

	sts = om$send(	msg	 = message NDnode.NDget_objects(
					ND_ROOT,
					list_tmp, 20, NULL,
					0, 1, &count ),
			targetid = my_id );
	as$status( sts = sts );

	for( i=0; i<nb_change && i<count; i++ ){

		if(	old[i].objid == list_tmp[0].objid && 
			old[i].osnum == list_tmp[0].osnum )
				list_tmp[0] = new[i];

		if(	old[i].objid == list_tmp[1].objid && 
			old[i].osnum == list_tmp[1].osnum )
				list_tmp[1] = new[i];
	}

	// check if image was already placed
	vect[0]	= 0.; vect[1]= 0.; vect[2] = 0.; vect[3] = 1.;
	VDSconvert_coord( vect, &wld[0], 0, &list_tmp[1], 
							md_env.md_env.matrix );

	vect[0]	= 1.; vect[1]= 0.; vect[2] = 0.; vect[3] = 1.;
	VDSconvert_coord( vect, &wld[3], 0, &list_tmp[1], 
							md_env.md_env.matrix );

	vect[0]	= 0.; vect[1]= 0.; vect[2] = 1.; vect[3] = 1.;
	VDSconvert_coord( vect, &wld[6], 0, &list_tmp[1], 
							md_env.md_env.matrix );

	ret_int = VDSis_there_image( &list_tmp[0], &md_env, wld, 
						OM_Gw_current_OS, &img_id );

	if( (ret_int & 1) && 
		img_id.objid != my_id && img_id.osnum != OM_Gw_current_OS ){

		/*| Image is detected */
		for( i=0; ; i++ ){

			count = 0;
			cur_dep.objid	= NULL_OBJID;
			sts = om$send(	msg	 = message NDnode.NDget_objects(
						ND_CHILDREN,
						&cur_dep, 1, NULL,
						i, i, &count ),
					targetid = my_id );
			if( ! (sts&1))	break;
			if( count == 0 || cur_dep.objid	== NULL_OBJID ) break;

			sts = om$send(	msg	 = message NDnode.NDchange_connect(
							1,
							&my_grid,
							&img_id ),
						targetid = cur_dep.objid,
						targetos = cur_dep.osnum );
			as$status( sts = sts );
		}

		save_br = ASbroadcast_in_progress;
		ASbroadcast_in_progress	= FALSE;
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, &md_env ),
				targetid = my_id );
		ASbroadcast_in_progress = save_br;

	}  /* found image */
	else 
	{
	 	/*| no image */

		/* 
		 * Fix for TR#179527283.
		 * When 'move graph' command is invoked with a new
		 * model, then VDlink should be connected to new model.
		 *
		 * Suresh/Raju -- Sep 05, 1995
		 */

		if ( nb_change )
		{
		   for ( i = 0; i < nb_change; i++ )
		   {
		     /*
		      * Check if the object changed is model. If yes
		      * connect VDlink to model.
		      */

		     /* Get the graphic object */
		     sts = om$send ( msg = message NDnode.ASreturn_go (
							      &gr_obj,
							      &mat_type,
							      matrix ),
					targetid = old[i].objid,
					targetos = old[i].osnum ) ;
		     as$status ( sts = sts ) ;

		     /*
		      * Check if the graphic object is a co-ordinate system.
		      * If yes do nothing.
		      */	
		     om$get_classid (  objid     = gr_obj.objid ,
				       osnum     = gr_obj.osnum ,
				       p_classid = &clid );  
		     if ( om$is_ancestry_valid ( 
					subclassid   = clid,
					superclassid = OPP_GRgencs_class_id )
				!= OM_S_SUCCESS )
			
		     {
			/*
			 * Get the model and check if it is VDlink.
			 */
		        lk_model.osnum        = OM_Gw_current_OS;
        		lk_model.objid        = NULL_OBJID;

	        	sts = om$get_objid_at_index(   
					object          = me,
        	        	        p_chanselect    = &AS_to_comp,
                	        	index           = 0,
                        	        objidaddr       = &lk_model.objid,
                                	osnumaddr       = &lk_model.osnum );
		        as$status( sts = sts, 
				   msg = "Error in mc get_objid_at_index" );

			sts = om$get_classid(   objid   = lk_model.objid,
                		                osnum   = lk_model.osnum,
                        		        p_classid = &cid );
		        as$status( sts = sts );

        		if( om$is_ancestry_valid(
				       subclassid      = cid,
                		       superclassid    = OPP_VDlink_class_id )
	                	== OM_S_SUCCESS )
			{
		       	   /* 
			    *connect:link_model depend of graphic model 
			    */

			   sts = om$send(msg = message NDnode.NDconnect( 
								1,
								&new[i],
								NULL_GRID, 
								ND_FULL ),
					  targetid = lk_model.objid,
					  targetos = lk_model.osnum );
			   as$status( sts = sts, 
				      msg = "Error in msg NDconnect" );

			}  /* component is VDlink */

		     }  /* changed parent is not CS */

		   } /* for ( i = 0; i < 2; i++ ) */

		}/*  if ( nb_change ) */

		sts = om$send(msg = message ACheader.NDchange_connect
					( nb_change, old, new ),
				mode	 = OM_e_wrt_message,
				targetid = my_id );
	 } /* no image */

  return  sts;
}

/* *********************** MSG NDconnect () **************************	*/

method NDconnect( int nb_root; struct GRid *root; struct GRid original;
		  IGRint type  )
{
struct GRid 		old_model, lk_model;
IGRlong			sts, msg;

	/*
	 * Fix for TR TR179527283
	 * When 'copy graph' is executed, after copying the node control
	 * comes here. If this message is invoked from copy graph 
	 * ( i.e., original.objid != NULL_OBJID ), then it is checked if new model
	 * is different from old model. 
	 * If yes i) a new VDlink is constructed and is attached as a component to me.
	 *       ii) Model is attached as root to VDlink object.
	 * If no, nothing needs to be done.
	 *
	 * Suresh/Raju Sep 05, 1995.
	 */

	if (original.objid != NULL_OBJID )
	{
		/* 
		 * get old model from original 
		 */

		sts = om$send ( msg = message ACheader.ACfind_model 
					(&msg, &old_model),
				targetid = original.objid,
				targetos = original.osnum ) ;
		as$status ( sts = sts ) ;

		/*
		 * see if new and old models are same
		 */
		if ( ( old_model.objid != root[0].objid ) || 
			( old_model.osnum != root[0].osnum ) )
		{
		   /*
		    * new and old model are not same
		    * construct new VDlink,  Connect new VDlink and my_id
		    */

		    lk_model.objid = NULL_OBJID ;
		    lk_model.osnum = OM_Gw_current_OS ;
		
		    sts = om$construct (  p_objid = &lk_model.objid,
					  classid = OPP_VDlink_class_id ) ;
 		    as$status ( sts = sts ) ;
		    sts = om$send ( msg = message Root.connect (
							AS_to_owner ,
							0,
							my_id ,
							OM_Gw_current_OS ,
							AS_to_comp ,
							OM_K_MAXINT ) ,
					targetid = lk_model.objid ,
					targetos = lk_model.osnum ) ;
		    as$status ( sts = sts ) ;

		    /* 
		     * connect link and model
		     */

		    sts = om$send( msg = message NDnode.NDconnect( 
							1,
							&root[0],
							NULL_GRID, 
							ND_NEW ),
				   targetid = lk_model.objid,
				   targetos = lk_model.osnum );
		    as$status( sts = sts, msg = "Error in msg NDconnect" );

		} /* old and new models are not same */

	} /* if (original.objid != NULL_OBJID ) */

	sts = om$send ( msg = message NDnodein.NDconnect (
						nb_root,
						root,
						original,
						type ),
				mode = OM_e_wrt_message ,
				targetid = my_id ) ;
	as$status ( sts = sts ) ;

	return ( sts ) ;
}

end implementation VDrelat_hdr;

