class implementation VLseaLine;

#include <math.h>
#include "vlstructure.h"
#include "vlglinedef.h"
#include "AS_status.h"
#include "expmacros.h"
#include "asmacros.h"
#include "expression.h"
#include "nddef.h"
#include "bserr.h"
#include "vsgeommacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vlgrdef.h"
#include "vlgrmacros.h"
#include "vlmsg.h"

#define	SEAM_MAN_ITER	10
#define MAN_MAX_DIV	50

extern	GRclassid	OPP_VLvirButt_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;
extern	GRclassid	OPP_ACrg_collect_class_id;
extern	GRclassid	OPP_EMScompsurf_class_id;

extern	struct	GRid	NULL_GRID;

from	ci_macro	import	init;
from	expression	import	modify;
from	GRlinear	import	GRgetpolyline;
from	EMSsurface	import	EMgetactiveid;
from	EMSsubbs	import	EMpartolbasis;
from	ACrg_collect	import	ACset_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;
from	ACrg_collect	import	ACmod_list_attribute;


/* ****************** MSG NDcheck_cmpt_level () ***********************	*/

method	NDcheck_cmpt_level( IGRlong *msg; IGRshort count; struct GRid list[];
			struct GRmd_env *md_env; IGRshort *level;
			IGRchar	*def_name; IGRboolean load )
{
IGRlong		sts;
IGRint		int_msg;
GRclassid	cid;
struct	GRid	hull;
IGRshort	loc_level;
IGRchar		*ptr_def_name;
struct	ret_struct	str;
IGRint			cmpt_type;


	*msg	= MSSUCC;
	if( level )	*level		= 1;
	if( def_name )	def_name[0]	= '\0';

	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					&int_msg,
					NULL,
					N_ATT_SELECTOR,
					&str,
					md_env ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&int_msg&1)){

		*msg	= MSFAIL;
		return	OM_W_ABORT;
	}
	cmpt_type = (IGRint) str.var.root_pm_st.value;

	switch( cmpt_type & V_ATT_TYPE_MASK ){

	case V_ATT_BASE :
		loc_level	= 1;
		ptr_def_name	= SEAM_DEF_1;
		break;

	case V_ATT_CURVED :
		loc_level	= 4;
		ptr_def_name	= SEAM_DEF_4;
		break;

	case V_ATT_NEXT :
		loc_level	= 10;
		ptr_def_name	= SEAM_DEF_2;
		break;

	case V_ATT_DEV :

		// check class of hull get graphic obj
		sts = om$send(	msg	 = message NDnode.ASreturn_go(
					&hull,
					NULL,
					NULL ),
				targetid = list[INDEX_HULL].objid,
				targetos = list[INDEX_HULL].osnum );
		as$status( sts = sts );

		om$get_classid(	osnum	= hull.osnum, 
				objid	= hull.objid, 
				p_classid = &cid );

		if( om$is_ancestry_valid(
				subclassid     = cid,
				superclassid = OPP_EMScompsurf_class_id )
							== OM_S_SUCCESS ){
			loc_level	= 10;
			ptr_def_name	= SEAM_DEF_2;

		} else {

			loc_level	= 11;
			ptr_def_name	= SEAM_DEF_3;
		  }

		break;

	default :
		*msg	= MSFAIL;
		return	OM_W_ABORT;
	}


	if( level )	*level = loc_level;
	if( def_name )	strcpy( def_name, ptr_def_name );
	if( load ){
		sts = om$send(	msg = message ACcpx.ACattach
						( &int_msg, ptr_def_name ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = int_msg );
	}

return	OM_S_SUCCESS;
}

/* ******************* MSG ACconstruct_feet10 () **********************	*/

method ACconstruct_feet10( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg, no_msg;
struct	GRid		go_seam, go_st_butt, go_end_butt;
struct	GRmd_env	seam_env, st_butt_env, end_butt_env;
struct	GRobj_env	hull;
IGRint			div;
struct	GRid		*vir_butt;
IGRint			nb_vir=0;
struct	GRid		loc_tmp[100];	// use malloc
IGRint			nb_tmp;
IGRint			int_msg;
IGRint			i, j, k;
struct	ret_struct	ret_st;
struct	GRid		*n_tmp;
struct	GRid		box_vir, box_s;
IGRdouble		fabs();
struct	ACrg_coll	att_list[10];
IGRdouble		pars[MAN_MAX_DIV];
IGRdouble		pt_on[MAN_MAX_DIV*3];
IGRdouble		pt_on_n[MAN_MAX_DIV*3];
IGRdouble		u[3], n[3];
struct	GRvg_construct	cnst;
struct	GRid		pla[MAN_MAX_DIV];
struct	GRid		go_n_seam;
struct	GRmd_env	seam_n_env;
BSrc			rc;
struct	ACrg_coll	seam_prop;
IGRint			sa_prop=0;
struct	IGRbsp_surface	*sf_geom;
IGRdouble		usf, vsf, ptsfd;
IGRdouble		pt_sf[3], nor_sf[3];


	/*| initialization */
	*msg		= MSSUCC;
	vir_butt	= NULL;
	box_vir.objid	= NULL_OBJID;
	box_vir.osnum	= OM_Gw_current_OS;
	box_s.objid	= NULL_OBJID;
	box_s.osnum	= OM_Gw_current_OS;
	sf_geom		= NULL;
	n_tmp		= NULL;

	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					&int_msg,
					NULL,
					N_ATT_DIVISOR,
					&ret_st,
					md_env ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&int_msg&1))	div = 1;
	else			div = (IGRint) ret_st.var.root_pm_st.value;
	if( div < 1 )	div = 1;

	if( div > MAN_MAX_DIV -1 )	div = MAN_MAX_DIV -1;

	pars[0] = 1./div;
	for( i=1; i<div-1; i++ )
		pars[i] = pars[i-1] + (1./div);

	// place seam
	sts = om$send(	msg	 = message VLgenLine.ACconstruct_feet2(
					msg, cn_type,
					count, list,
					md_env,
					fcount, feet_list ),
			targetid = my_id );

	if( ! (sts&(*msg)&1) || div == 1 )	return sts;

	// get hull geometrie
	sts = om$send(	msg	 = message NDnode.ASreturn_go( 
					&hull.obj_id, 
					&hull.mod_env.md_env.matrix_type, 
					hull.mod_env.md_env.matrix ),
			targetid = list[INDEX_HULL].objid,
			targetos = list[INDEX_HULL].osnum );
	as$status( sts = sts );
	hull.mod_env.md_id.osnum	= hull.obj_id.osnum;
	hull.mod_env.md_id.objid	= md_env->md_id.objid;

	sts = VLgetGeometry( &hull, 0, NULL_OBJID, &sf_geom, &loc_msg );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	/*| initialization */
	VLinitCnst( &cnst );
	cnst.env_info	= md_env;

	sts = om$send(	msg	 = message NDnode.ASreturn_go( 
					&go_seam, 
					&seam_env.md_env.matrix_type, 
					seam_env.md_env.matrix ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	as$status( sts = sts );
	seam_env.md_id.osnum	= go_seam.osnum;
	seam_env.md_id.objid	= md_env->md_id.objid;

	go_n_seam	= feet_list[I_MF_CV];
	seam_n_env	= *md_env;

	// allocate space fo virtual butt
	nb_vir	= div * (count - INDEX_START_CL - 1 ) + INDEX_START_CL + 1;
	n_tmp = (struct GRid *) malloc( sizeof( struct GRid ) * nb_vir );
	if( n_tmp == NULL && nb_vir ){

		printf(" Error not enougth memory to allocate vir_butt\n");
		*msg	= MSFAIL;
		goto	wrapup;
	}

	for( i=0; i<INDEX_START_CL; i++ )	n_tmp[i] = list[i];
	vir_butt = n_tmp + INDEX_START_CL;

	for( i=0; i<INDEX_START_CL; i++ )	loc_tmp[i] = list[i];

	// create attribute box for virtual butt
	sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
				osnum	= box_vir.osnum,
				p_objid	= &box_vir.objid );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	loc_tmp[INDEX_ATT_BOX]	= box_vir;

	// set attribut in box vir
	strcpy( att_list[0].name, N_ATT_SELECTOR );
	att_list[0].desc.type = AC_ATTRIB_DOUBLE;
	att_list[0].desc.value.att_exp	= V_ATT_BASE;

	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
					( &loc_msg, 1, att_list ),
			targetid = loc_tmp[INDEX_ATT_BOX].objid,
			targetos = loc_tmp[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

//	loc_tmp[INDEX_START_CL]	= list[INDEX_GR_INFO];
	nb_tmp	= INDEX_START_CL;

	// create virtual butt
	for( i=INDEX_START_CL, k=0; i<count - 1; i++, k++ ){

		vir_butt[k*div]	= list[INDEX_START_CL+k];

		sts = om$send(	msg	 = message NDnode.ASreturn_go( 
						&go_st_butt, 
						&st_butt_env.md_env.matrix_type, 
						st_butt_env.md_env.matrix ),
				targetid = list[i].objid,
				targetos = list[i].osnum );
		as$status( sts = sts );
		st_butt_env.md_id.osnum	= go_st_butt.osnum;
		st_butt_env.md_id.objid	= md_env->md_id.objid;

		sts = om$send(	msg	 = message NDnode.ASreturn_go( 
						&go_end_butt, 
						&end_butt_env.md_env.matrix_type, 
						end_butt_env.md_env.matrix ),
				targetid = list[i+1].objid,
				targetos = list[i+1].osnum );
		as$status( sts = sts );
		end_butt_env.md_id.osnum	= go_end_butt.osnum;
		end_butt_env.md_id.objid	= md_env->md_id.osnum;

		// get set of pts on prev_seam
		sts = VLgetPtsOnPartAtParsLen( 
					&loc_msg,
					&go_seam,
					&seam_env,
					&go_st_butt,
					&st_butt_env,
					&go_end_butt,
					&end_butt_env,
					2,
					md_env,
					div - 1,
					pars,
					pt_on,
					NULL );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		// get set of pts on new seam
		sts = VLgetPtsOnPartAtParsLen( 
					&loc_msg,
					&go_n_seam,
					&seam_n_env,
					&go_st_butt,
					&st_butt_env,
					&go_end_butt,
					&end_butt_env,
					2,
					md_env,
					div - 1,
					pars,
					pt_on_n,
					NULL );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		for( j=0; j<div-1; j++ ){

			BSmdistptsf( &rc, sf_geom, &pt_on[j*3], 
						&usf, &vsf, pt_sf, &ptsfd );

			BSsfarrevn( &rc, sf_geom, 1, &usf, 1, &vsf,
							pt_sf, nor_sf );

			BSmkvec( &rc, u, &pt_on[j*3], &pt_on_n[j*3] );

			BSnorvec( &rc, u );
			BSnorvec( &rc, nor_sf );

			BScrossp( &rc, u, nor_sf, n );

			// create a plane
			sts = VLcreatePlane( &pt_on[j*3], n, md_env, 
					     &cnst, &pla[j], &loc_msg );
		}

		for( j=1; j<div; j++ ){

			as$make_source( go_grid	= pla[j-1],
					as_os	= md_env->md_id.osnum,
					as_grid	= &loc_tmp[INDEX_GR_INFO] );

			sts = om$construct(	classid	= OPP_VLvirButt_class_id,
						osnum	= md_env->md_id.osnum,
				p_objid	= &vir_butt[(div*k)+j].objid );
			as$status( sts = sts );
			vir_butt[(div*k)+j].osnum = md_env->md_id.osnum;

			sts = om$send(	msg	 = message VLgenLine.ACmplace(
							&int_msg, 
							AChdr_noprotect | AChdr_nodisplay, 
							0,
							BUTT_DEF_1,
							nb_tmp, loc_tmp,
							md_env ),
					targetid = vir_butt[(div*k)+j].objid,
					targetos = vir_butt[(div*k)+j].osnum );
			as$status( sts = sts );

			om$send(msg	 = message GRgraphics.GRdelete
						( &no_msg, md_env ),
				targetid = pla[j-1].objid,
				targetos = pla[j-1].osnum );
		}

	}// end create virtual

	// last virtual
	n_tmp[nb_vir-1] = list[count-1];

	// delete old feet
	for( i=0; i<*fcount; i++ ){

		om$send(msg	 = message GRgraphics.GRdelete
					( &no_msg, md_env ),
			targetid = feet_list[i].objid,
			targetos = feet_list[i].osnum );
		feet_list[i].objid = NULL_OBJID;
	}

	// place seam
	sts = om$send(	msg	 = message VLgenLine.ACconstruct_feet2(
					msg, cn_type,
					nb_vir, n_tmp,
					md_env,
					fcount, feet_list ),
			targetid = my_id );

wrapup :

	// delete virtual butt
	if( n_tmp ){

		// delete virtual butt
		for( i=INDEX_START_CL; i<nb_vir; i += div )
			for( j=1; j<div; j++ )
			  sts = om$send(msg	 = message GRgraphics.GRdelete
							( &no_msg, md_env ),
					targetid = n_tmp[i+j].objid,
					targetos = n_tmp[i+j].osnum );
		free( n_tmp );
	}

	// delete vir box
	om$send(msg	 = message GRgraphics.GRdelete
					( &no_msg, md_env ),
			targetid = box_vir.objid,
			targetos = box_vir.osnum );

	if( sf_geom )	free( sf_geom );

	if( ! (*msg & 1)){ *msg = MSFAIL; return OM_W_ABORT; }

return	OM_S_SUCCESS;
}

/* ******************* MSG ACconstruct_feet11 () **********************	*/

method ACconstruct_feet11( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg, stup_msg;
struct	GRid		go_seam, go_b_start, go_b_end;
struct	GRmd_env	seam_env, b_start_env, b_end_env;
struct	GRid		go_hull;
struct	GRmd_env	hull_env;
IGRint			i, k;
struct	GRid		cv[10];
struct	GRmd_env	cv_env[10];
struct	GRid		sf_3d, sf_2d;
IGRdouble		usrVal[2];
struct	GRvg_construct	cnst;
IGRdouble		maxW;
IGRdouble		distW, distL;
IGRint			nb_feet;
IGRdouble		Dist;
IGRdouble		fabs();
IGRdouble		seam_dir[3];
struct	VLctrlSurf	*cntrl_3d;
IGRdouble		activ_cht;
IGRint			size, size_buf;
struct	GRid		*loc_seam_tmpl, loc_seam[MAX_NEXT_FEET];
IGRint			nb_cntrl_3d=0;
IGRdouble		pt_on[3];
struct	GRid		as_vect;
struct	ret_struct	str;
IGRint			loc_ind;
IGRdouble		area[3];
struct	GRid		first_slice, f_block;
IGRint			ind_ctrl;
IGRdouble		Dmax, Dmin, allow;
IGRint			nb_cv;
struct	ACrg_coll	att_list[10], att_width, att_width2, att_iter;
struct	GRid		box_ite;
IGRdouble		ldist[2];
IGRint			nb_dist;
IGRint			dist_ind;
IGRint			max_iter;
struct	GRid		contents;


	/*| initialization */
	*msg		= MSSUCC;
	loc_seam_tmpl	= NULL;
	cntrl_3d	= NULL;
	first_slice.objid	= NULL_OBJID;
	f_block.objid		= NULL_OBJID;
	Dmin		= 0.;
	Dmax		= 10000000.;
	box_ite.objid	= NULL_OBJID;
	box_ite.osnum	= OM_Gw_current_OS;
	VLinitCnst( &cnst );
	cnst.env_info	= md_env;

	// placement de la premiere seam --> send ACconstruct_feet10
		// creation d'une expression pour la longueur

	// decoupage des plaques entre previous et next seam et 2 butts
		// definition du point interieur

	// mise a plat et controle de la largeur

	// iteration 
		// --> creation d'une nouvelle seam 
		// --> decoupage des plaques avec la seam
		// mise a plat


	// get cht
	size_buf = sizeof( IGRdouble );
	gr$get_chord_height_tolerance(	msg 	= &loc_msg,
					sizbuf	= &size_buf,
					buffer	= &activ_cht,
					nret	= &size );

	// get info on hull
	sts = om$send(	msg	 = message NDnode.ASreturn_go(
					&go_hull,
					&hull_env.md_env.matrix_type,
					hull_env.md_env.matrix ),
			targetid = list[INDEX_HULL].objid,
			targetos = list[INDEX_HULL].osnum );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
	hull_env.md_id.osnum	= go_hull.osnum;
	hull_env.md_id.objid	= md_env->md_id.objid;

	// modify list template
	loc_seam_tmpl = (struct GRid *) malloc
					( sizeof( struct GRid ) * count );
	if( loc_seam_tmpl == NULL && count ){
		printf(" Error not enough memory to allocate loc_seam_tmpl\n");
		goto wrapup;
	}

	for( i=0; i<count; i++ )	loc_seam_tmpl[i] = list[i];

	// create box whith int value
	sts = om$send(	msg	 = message NDnode.NDcopy( 
						&loc_msg, 
						0, 
						md_env,
						md_env, 
						&box_ite ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	strcpy( att_list[0].name, N_ATT_SELECTOR );
	att_list[0].desc.type = AC_ATTRIB_DOUBLE;
	att_list[0].desc.value.att_exp	= V_ATT_NEXT;

	sts = om$send(	msg	 = message ACrg_collect.ACmod_list_attribute
					( &loc_msg, 1, &att_list[0] ),
			targetid = box_ite.objid,
			targetos = box_ite.osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	loc_seam_tmpl[INDEX_ATT_BOX]	= box_ite;

	// get dist with allowance
	sts = VLgetAllMaxDist( &loc_msg, count, list, md_env, 
						2, ldist, &nb_dist );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	maxW	= ldist[0]; dist_ind = 0;
	if( nb_dist > 1 && ldist[0] < ldist[1] )
		{ maxW = ldist[1]; dist_ind = 1; }

	if( dist_ind )	strcpy( att_width.name, N_ATT_LEN_ALONG2 );
	else		strcpy( att_width.name, N_ATT_LEN_ALONG );
	att_width.desc.type = AC_ATTRIB_DOUBLE;
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
					( &loc_msg, &att_width ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	allow = att_width.desc.value.att_exp - maxW;

	sts = om$send(	msg	 = message NDnode.ASreturn_go( 
					&go_seam, 
					&seam_env.md_env.matrix_type, 
					seam_env.md_env.matrix ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	as$status( sts = sts );
	seam_env.md_id.osnum	= go_seam.osnum;
	seam_env.md_id.objid	= md_env->md_id.objid;

	// alloc cntrl_3d
	nb_cntrl_3d	= count - INDEX_START_CL - 1;
	cntrl_3d = (struct VLctrlSurf *) malloc
				( sizeof(struct VLctrlSurf) * nb_cntrl_3d );
	if( cntrl_3d == NULL && nb_cntrl_3d ){
		printf(" Error not enough memory to allocate cntrl_3d\n");
		loc_msg	= MSFAIL;
		goto	wrapup;
	}
	for( i=0; i<nb_cntrl_3d; i++ )
		cntrl_3d[i].sf_3d.objid	= NULL_OBJID;

	strcpy( att_iter.name, N_ATT_ITERATION );
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
					( &loc_msg, &att_iter ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)) max_iter = SEAM_MAN_ITER;
	else	max_iter = (IGRint) att_iter.desc.value.att_exp + 1;

	// start iteration
	for( distW = 0., distL = 0., Dist = maxW, k=0; k<max_iter; k++ ){

		distW	= 0.;
		distL	= 0.;

		nb_feet = MAX_NEXT_FEET;
		sts = om$send(	msg	 = message VLseaLine.ACconstruct_feet10(
					&loc_msg, cn_type, count, 
					loc_seam_tmpl,
					md_env, &nb_feet, loc_seam ),
				targetid = my_id );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		if( k==0 ){

			sts = om$send(	msg	 = message NDmacro.ACreturn_foot( 
						&loc_msg,
						MAN_GR_FEET,
						&go_b_start, 
						&b_start_env.md_env.matrix_type, 
						b_start_env.md_env.matrix ),
					targetid = list[INDEX_START_CL].objid,
					targetos = list[INDEX_START_CL].osnum );
			as$status( sts = sts );
			b_start_env.md_id.osnum	= go_b_start.osnum;
			b_start_env.md_id.objid	= md_env->md_id.objid;

			sts = om$send(	msg	 = message NDmacro.ACreturn_foot( 
						&loc_msg,
						MAN_GR_FEET,
						&go_b_end,
						&b_end_env.md_env.matrix_type, 
						b_end_env.md_env.matrix ),
					targetid = list[count - 1].objid,
					targetos = list[count - 1].osnum );
			as$status( sts = sts );
			b_end_env.md_id.osnum	= go_b_end.osnum;
			b_end_env.md_id.objid	= md_env->md_id.objid;

			// get pt on midle of prev seam
			sts = VLgetPtOnCvInInter( &loc_msg, 
					&go_seam, &seam_env,
					&go_b_start, &b_start_env,
					&go_b_end, &b_end_env,
					2, md_env, 0.5, pt_on );
			if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

			// get vector
			as$make_source( go_grid	= loc_seam[I_MF_TG],
					as_os	= md_env->md_id.osnum,
					as_grid	= &as_vect );

			sts = om$send(	msg	 = message NDnode.NDgive_structure
						( &loc_msg, &str, md_env ),
					targetid = as_vect.objid,
					targetos = as_vect.osnum );
			BSnorvec( &loc_msg, str.var.point_st.pt );
			for( loc_ind=0; loc_ind<3; loc_ind++ )
			   seam_dir[loc_ind] = str.var.point_st.pt[loc_ind] 
								* maxW / 3;

			for( loc_ind=0; loc_ind<3; loc_ind++ )
			  area[loc_ind] = pt_on[loc_ind] + seam_dir[loc_ind];
 
			// extract f_block
			cv[0]		= go_b_start;
			cv_env[0]	= b_start_env;
			cv[1]		= go_b_end;
			cv_env[1]	= b_end_env;

			sts = VLextractSurface( &loc_msg, &go_hull, &hull_env,
				2, cv, cv_env, area, &f_block, md_env );
			if( ! (sts&loc_msg&1))
				{ loc_msg = MSFAIL; goto wrapup; }

			// extract slice
			cv[0]		= go_seam;
			cv_env[0]	= seam_env;
			cv[1]		= loc_seam[I_MF_CV];
			cv_env[1]	= *md_env;

			sts = VLextractSurface( &loc_msg, &f_block, md_env,
				2, cv, cv_env, area, &first_slice, md_env );
			if( ! (sts&loc_msg&1))
				{ loc_msg = MSFAIL; goto wrapup; }

			// gerenate all surface of control
			if( nb_cntrl_3d == 1 ){
				for( loc_ind=0; loc_ind<3; loc_ind++ )
				   cntrl_3d[0].area[loc_ind] = area[loc_ind];
				cntrl_3d[0].sf_3d	= first_slice;

			} else for( i=INDEX_START_CL, ind_ctrl=0; i<count-1;
					i++, ind_ctrl++ ){

				sts = om$send(	msg	 = message NDmacro.ACreturn_foot( 
							&loc_msg,
							MAN_GR_FEET,
							&go_b_start, 
							&b_start_env.md_env.matrix_type, 
							b_start_env.md_env.matrix ),
						targetid = list[i].objid,
						targetos = list[i].osnum );
				as$status( sts = sts );
				b_start_env.md_id.osnum	= go_b_start.osnum;
				b_start_env.md_id.objid	= md_env->md_id.objid;

				sts = om$send(	msg	 = message NDmacro.ACreturn_foot( 
							&loc_msg,
							MAN_GR_FEET,
							&go_b_end,
							&b_end_env.md_env.matrix_type, 
							b_end_env.md_env.matrix ),
						targetid = list[i+1].objid,
						targetos = list[i+1].osnum );
				as$status( sts = sts );
				b_end_env.md_id.osnum	= go_b_end.osnum;
				b_end_env.md_id.objid	= md_env->md_id.objid;

				// get pt on midle of prev seam
				sts = VLgetPtOnCvInInter( &loc_msg, 
						&go_seam, &seam_env,
						&go_b_start, &b_start_env,
						&go_b_end, &b_end_env,
						2, md_env, 0.5, pt_on );
				if( ! (sts&loc_msg&1))
					{ loc_msg = MSFAIL; goto wrapup; }

				for( loc_ind=0; loc_ind<3; loc_ind++ )
					cntrl_3d[ind_ctrl].area[loc_ind] = 
					   pt_on[loc_ind] + seam_dir[loc_ind];

				// extract cntrl surf
				if( i == INDEX_START_CL ){
					nb_cv		= 1;
					cv[0]		= go_b_end;
					cv_env[0]	= b_end_env;
				} else if( i == count - 2 ){
					nb_cv		= 1; 
					cv[0]		= go_b_start;
					cv_env[0]	= b_start_env;

				  } else {
					nb_cv	= 2;
					cv[0]		= go_b_start;
					cv_env[0]	= b_start_env;
					cv[1]		= go_b_end;
					cv_env[1]	= b_end_env;
				    }

				sts = VLextractSurface( &loc_msg, 
					&first_slice, md_env,
					nb_cv, cv, cv_env, 
					cntrl_3d[ind_ctrl].area, 
					&cntrl_3d[ind_ctrl].sf_3d, 
					md_env );
				if( ! (sts&loc_msg&1))
					{ loc_msg = MSFAIL; goto wrapup; }

			  }// end generate control
		}

		for( i=INDEX_START_CL, ind_ctrl=0, distW=0.; 
				i<count-1; i++, ind_ctrl++ ){

			// unwrap surface
			if( k==0 )	sf_3d = cntrl_3d[ind_ctrl].sf_3d;

			else {

				cv[0]		= loc_seam[I_MF_CV];
				cv_env[0]	= *md_env;
				sts = VLextractSurface( &loc_msg, 
					&cntrl_3d[ind_ctrl].sf_3d, md_env,
					1, cv, cv_env, 
					cntrl_3d[ind_ctrl].area, 
					&sf_3d, 
					md_env );
				if( ! (sts&loc_msg&1))
					{ loc_msg = MSFAIL; goto wrapup; }

			}

			// unwrap loc_sf
			sts = VLdevExtLoop( &sf_3d, md_env, &sf_2d, md_env );
			if( !(sts&1)){ loc_msg = MSFAIL; goto wrapup; }

			sts = vl$minrect ( curve   = &sf_2d,
                                           environ = md_env,
                                           cst     = &cnst,
                                           option  = B_INERTI,
                                           length  = &usrVal[0],
                                           width   = &usrVal[1],
                                           msg     = &loc_msg );
			if( !(sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

			if( distL < usrVal[0] ) distL = usrVal[0];
			if( distW < usrVal[1] )	distW = usrVal[1];

			if( sf_3d.objid != cntrl_3d[ind_ctrl].sf_3d.objid ){

				sts = om$send(	msg	 = message GRgraphics.GRdelete
							( &stup_msg, md_env ),
						targetid = sf_3d.objid,
						targetos = sf_3d.osnum );
				sf_3d.objid = NULL_OBJID;
			}

			// delete sf_2d
			sts = om$send(	msg	 = message GRgraphics.GRdelete
							( &loc_msg, md_env ),
					targetid = sf_2d.objid,
					targetos = sf_2d.osnum );
			sf_2d.objid = NULL_OBJID;
		}

		// compare 2d width (distW) et maxW

		printf(" MaxW : %.2f, 3D_width : %.2f, 2D_width : %.2f\n",
							maxW, Dist, distW );

		if( fabs( maxW - distW) < activ_cht ){
			loc_msg	= MSSUCC;
			break;
		}

		if( distW > maxW )	
			Dmax	= ( Dist < Dmax ) ? Dist : Dmax;
		else	Dmin	= ( Dist > Dmin ) ? Dist : Dmin;

		// delete loc_butt
		for( loc_ind=0; loc_ind<MAX_NEXT_FEET &&  
						k<max_iter - 1; loc_ind++ )
			sts = om$send(msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
					targetid = loc_seam[loc_ind].objid,
					targetos = loc_seam[loc_ind].osnum );

		if( distW < 0.00001 || maxW < fabs( distW - maxW) ){
			printf(" No seam can be create \n");
			loc_msg	= MSFAIL;
			goto	wrapup;
		} 

		Dist = Dist - distW + maxW;

		if( Dist < Dmin || Dist > Dmax ) Dist = (Dmax + Dmin) / 2;

		att_width.desc.value.att_exp	= Dist + allow;
		sts = om$send(	msg	 = message ACrg_collect.ACmod_list_attribute
						( &loc_msg, 1, &att_width ),
				targetid = box_ite.objid,
				targetos = box_ite.osnum );

		if( nb_dist > 1 ){

			if( dist_ind )	strcpy( att_width2.name, 
							N_ATT_LEN_ALONG );
			else		strcpy( att_width2.name, 
							N_ATT_LEN_ALONG2 );
			att_width2.desc.type = AC_ATTRIB_DOUBLE;
			sts = om$send(	msg	 = message 
					ACrg_collect.ACget_named_attribute
						( &loc_msg, &att_width2 ),
					targetid = box_ite.objid,
					targetos = box_ite.osnum );
			if( (sts&loc_msg&1) && 
			    (att_width2.desc.value.att_exp > (Dist + allow)) ){

				att_width2.desc.value.att_exp	= Dist + allow;
				om$send(msg	 = message ACrg_collect.ACmod_list_attribute
						( &loc_msg, 1, &att_width2 ),
					targetid = box_ite.objid,
					targetos = box_ite.osnum );
			}
		}

	}//end iteration

	if( k == SEAM_MAN_ITER ) 
		printf("Warning : Iteration Process stopped after %d steps\n", 
							SEAM_MAN_ITER );

	// create contents
	contents.osnum	= OM_Gw_current_OS;
	sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
				osnum	= contents.osnum,
				p_objid	= &contents.objid );

	strcpy( att_list[0].name, N_ATT_MR_LEN );
	att_list[0].desc.type = AC_ATTRIB_DOUBLE;
	att_list[0].desc.value.att_exp	= distL;

	strcpy( att_list[1].name, N_ATT_MR_WID );
	att_list[1].desc.type = AC_ATTRIB_DOUBLE;
	att_list[1].desc.value.att_exp	= distW;

	strcpy( att_list[2].name, N_ATT_3D_LEN );
	att_list[2].desc.type = AC_ATTRIB_DOUBLE;
	att_list[2].desc.value.att_exp	= Dist + allow;

	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
					( &loc_msg, 3, att_list ),
			targetid = contents.objid,
			targetos = contents.osnum );
	loc_seam[I_MF_CONTENTS] = contents;

wrapup :

	/*| free memory */
	if( cntrl_3d ){

		for( i=0; i<nb_cntrl_3d; i++ )
			  sts = om$send(msg	 = message GRgraphics.GRdelete
							( &stup_msg, md_env ),
					targetid = cntrl_3d[i].sf_3d.objid,
					targetos = cntrl_3d[i].sf_3d.osnum );
		free( cntrl_3d );
	}

	if( f_block.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
				targetid = f_block.objid,
				targetos = f_block.osnum );

	if( first_slice.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
				targetid = first_slice.objid,
				targetos = first_slice.osnum );

	if( box_ite.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
				targetid = loc_seam_tmpl[INDEX_ATT_BOX].objid,
				targetos = loc_seam_tmpl[INDEX_ATT_BOX].osnum );

	if( loc_seam_tmpl )	free( loc_seam_tmpl );


	if( !(loc_msg&1)){
		*msg	= MSFAIL;
		*fcount	= 0;
		return	OM_W_ABORT;

	} else {
		*msg	= MSSUCC;
		*fcount	= MAX_NEXT_FEET;
		for( i=0; i<MAX_NEXT_FEET; i++ ) feet_list[i] = loc_seam[i];
	  }

return	OM_S_SUCCESS;
}

/* *********************** MSG VLgetLoftProps () *************	*/
method VLgetLoftProps( long *props )
{
	*props = V_PROP_CUT;
return	OM_S_SUCCESS;
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            	sts ;   /* OM return code       */
	struct GRid		list[100];
	struct GRmd_env 	md_env;
	int			suc, count, cmpt_type;
	struct  ret_struct      str;
	long            	NumberOfBytes,BytesReceived;

  	sts = om$send(msg = message NDnode.NDget_objects(ND_ROOT,list,100,
                                                      NULL, NULL,
                                                      OM_K_MAXINT, &count),
                                targetid = my_id );
     if (!(sts&1)) {
        goto quit;
      }

     NumberOfBytes = sizeof( md_env );
     gr$get_module_env(
                msg = msg,
                sizbuf = &NumberOfBytes,
                buffer = &md_env,
                nret = &BytesReceived);

        sts = om$send(  msg      = message NDmacro.ACgive_structure(
                                        &suc,
                                        NULL,
                                        N_ATT_SELECTOR,
                                        &str,
                                        &md_env ),
                        targetid = list[INDEX_ATT_BOX].objid,
                        targetos = list[INDEX_ATT_BOX].osnum );
        if( ! (sts&*msg&1)){

                *msg    = MSFAIL;
                goto quit;
        }
        cmpt_type = (IGRint) str.var.root_pm_st.value;

        /*
         * name.
         */
       switch( cmpt_type & V_ATT_TYPE_MASK ){
        case V_ATT_BASE :
	        myDef->info             = VL_I_ObjBaseSeam;
		break;

	case V_ATT_CURVED :
		myDef->info             = VL_I_ObjCurvedSeam;
		break;

	case V_ATT_DEV  :
	case V_ATT_NEXT :
		myDef->info             = VL_I_ObjNextSeam;
		break;

	default :
                *msg    = MSFAIL;
		sts	= OM_E_ABORT;
		goto quit; 
	}
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;
quit :
        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLseaLine;

