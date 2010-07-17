class implementation VLgenLine;

#include "AS_status.h"
#include "vlglinedef.h"
#include "bserr.h"
#include "bstypes.h"
#include "expmacros.h"
#include "expression.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "asmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h" 
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "vldbgmacros.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#define	MaxInDir	9999999.
#define MinInDir	-9999999.

extern  void            BSdirfitcv();

extern	GRclassid	OPP_GR3dlinestr_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;
extern	GRclassid	OPP_GRbcsubbc_class_id;
extern	GRclassid	OPP_ACrg_collect_class_id;

from	EMSsubbs	import	EMproject_curve_along_surface_normals;
from	EMSsubbs	import	EMproject_curve_onto_surface;
from	ACrg_collect	import	ACadd_list_attribute;
from	GRbcsubbc	import	EMcurve_by_poles;

extern	struct	GRid	NULL_GRID;

/* ********************* FCT VLgetVectDir () *************************	*/

IGRlong VLgetVectDir( msg, in_id, md_env, def_dir, vect_dir )

IGRlong			*msg;
struct	GRid		*in_id;
struct	GRmd_env	*md_env;
IGRdouble		*def_dir, *vect_dir;

{
IGRlong			sts;
struct	ret_struct	str;
IGRint			i;
IGRint			int_test;
BSrc			bs_rc;

	// Initialization
	*msg	= MSSUCC;

	// get type of CS
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( msg, &str, md_env ),
			senderid = NULL_OBJID,
			targetid = in_id->objid,
			targetos = in_id->osnum );
	if( ! (sts & *msg & 1)){ *msg = MSFAIL; return *msg; }

	switch( str.type ){

	case ref_generic :
		vect_dir[0] = str.var.ref_st.t[0];
		vect_dir[1] = str.var.ref_st.t[4];
		vect_dir[2] = str.var.ref_st.t[8];
		break;

	case point_generic :
		vect_dir[0] = str.var.point_st.pt[0];
		vect_dir[1] = str.var.point_st.pt[1];
		vect_dir[2] = str.var.point_st.pt[2];
		break;

	case line_generic :
		vect_dir[0] = str.var.line_st.p1[0] - str.var.line_st.p0[0];
		vect_dir[1] = str.var.line_st.p1[1] - str.var.line_st.p0[1];
		vect_dir[2] = str.var.line_st.p1[2] - str.var.line_st.p0[2];
		break;

	case double_type :
		int_test = (IGRint) str.var.root_pm_st.value;
		for( i=0; i<3; i++ )	vect_dir[i] = 0.;

		switch( int_test ){
		case 1  : vect_dir[0] =  1; break; // X
		case -1 : vect_dir[0] = -1; break; // -X
		case 2  : vect_dir[1] =  1; break; // Y
		case -2 : vect_dir[1] = -1; break; // -Y
		case 3  : vect_dir[2] =  1; break; // Z
		case -3 : vect_dir[2] = -1; break; // -Z
		default :
			for( i=0; i<3; i++ )	vect_dir[i] = def_dir[i];
		}
		break;

	default :
		// set y/z direction
		for( i=0; i<3; i++ )	vect_dir[i] = def_dir[i];
	}

	BSnorvec( &bs_rc, vect_dir );

return *msg;
}

/* ******************** FCT VLgetAllMaxDist () ********************	*/

IGRlong VLgetAllMaxDist( msg, count, list, md_env, len, ldist, cdist )

IGRlong			*msg;
IGRint			count;
struct	GRid		*list;
struct	GRmd_env	*md_env;
IGRint			len;
IGRdouble		*ldist;
IGRint			*cdist;

{
IGRlong			sts, sts1, loc_msg;
IGRint			int_msg;
struct	ret_struct	ret_st, al_str;
IGRdouble		loc_dist;
IGRdouble		def_dir[3], vect_dir[3];
IGRdouble		res, al_cs[3];
IGRchar			*al_name;
IGRint			loc_count;
struct	GRmd_env	prev_env;
struct	GRid		prev, p_cs_al, p_box;
BSrc			bs_rc;
IGRdouble		main_dist;


	*msg	= MSFAIL;
	*cdist	= 0;

	sts = om$send(	msg = message NDmacro.ACgive_structure(
				&int_msg,
				NULL,
				N_ATT_LEN_ALONG,
				&ret_st,
				md_env ),
			senderid = NULL_OBJID,
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( !(int_msg&sts&1)){ loc_msg = MSFAIL; goto wrapup; }
	main_dist	= ret_st.var.root_pm_st.value;
	loc_dist 	= ret_st.var.root_pm_st.value;

	// get vect of propagation
	def_dir[0] = 1.; def_dir[1] = 1.; def_dir[2] = 1.; 
	sts = VLgetVectDir( &loc_msg, &list[INDEX_CS], md_env, 
							def_dir, vect_dir );
	if( ! (loc_msg&sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get allowance on current genLine
	// if vect prop . allow_dir < 0 --> reduce loc_dist
	sts = VLgetVectDir( &loc_msg, &list[INDEX_AL_CS], md_env, 
							def_dir, al_cs );
	if( (sts&loc_msg&1) && ((al_cs[0] != def_dir[0]) ||
		(al_cs[1] != def_dir[1]) || (al_cs[2] != def_dir[2])) ){

		res = BSdotp( &bs_rc, vect_dir, al_cs );
		if( bs_rc == BSSUCC ){

			if( res < 0 )	al_name	= N_ATT_AL_VAL;
			else		al_name	= N_ATT_EXTRA_AL;

			sts = om$send(	msg = message NDmacro.ACgive_structure(
					&int_msg,
					NULL,
					al_name,
					&al_str,
					md_env ),
				senderid = NULL_OBJID,
				targetid = list[INDEX_ATT_BOX].objid,
				targetos = list[INDEX_ATT_BOX].osnum );
			if( int_msg&sts&1 )
				loc_dist -= al_str.var.root_pm_st.value;
		}
	}

	// get previous element
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					"",
					&prev,
					&prev_env.md_env.matrix_type,
					prev_env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	prev_env.md_id.objid	= md_env->md_id.objid;
	prev_env.md_id.osnum	= prev.osnum;
	if((sts&loc_msg&1)){

		// get cs id
		sts = om$send(	msg	 = message NDnode.NDget_objects(
						ND_ROOT,
						&p_cs_al,
						1,
						NULL,
						INDEX_AL_CS,
						INDEX_AL_CS,
						&loc_count ),
			senderid = NULL_OBJID,
			targetid = prev.objid,
			targetos = prev.osnum );
		sts1 = om$send(	msg	 = message NDnode.NDget_objects(
						ND_ROOT,
						&p_box,
						1,
						NULL,
						INDEX_ATT_BOX,
						INDEX_ATT_BOX,
						&loc_count ),
			senderid = NULL_OBJID,
			targetid = prev.objid,
			targetos = prev.osnum );
		if( sts&sts1&1 ){

			sts = VLgetVectDir( &loc_msg, &p_cs_al, &prev_env, 
							def_dir, al_cs );
			if( (sts&loc_msg&1) && ((al_cs[0] != def_dir[0]) ||
						(al_cs[1] != def_dir[1]) ||
						(al_cs[2] != def_dir[2])) ){

				res = BSdotp( &bs_rc, vect_dir, al_cs );
				if( bs_rc == BSSUCC ){

				  if( res > 0 )	al_name	= N_ATT_AL_VAL;
				  else		al_name	= N_ATT_EXTRA_AL;

				  sts = om$send(msg = message NDmacro.ACgive_structure(
							&int_msg,
							NULL,
							al_name,
							&al_str,
							&prev_env ),
						senderid = NULL_OBJID,
					targetid = p_box.objid,
					targetos = p_box.osnum );
					if( int_msg&sts&1 )
						loc_dist -= 
						al_str.var.root_pm_st.value;
				}
			}
		}
	}

	loc_msg = MSSUCC;

	if( len > 0 ){	ldist[0] = loc_dist; *cdist = 1; }

	sts = om$send(	msg = message NDmacro.ACgive_structure(
				&int_msg,
				NULL,
				N_ATT_LEN_ALONG2,
				&ret_st,
				md_env ),
			senderid = NULL_OBJID,
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( int_msg&sts&1 ){ 
			(*cdist)++;
			if( len > 1 )
				ldist[1] = ret_st.var.root_pm_st.value -
							main_dist + loc_dist;
	}

wrapup :
	
	if( loc_msg & 1)	*msg	= MSSUCC;
	else			*msg	= MSFAIL;

return	*msg;
}

/* ******************** FCT VLgetMaxDist () ************************	*/

IGRlong VLgetMaxDist( msg, count, list, md_env, maxDist, distExp )

IGRlong			*msg;
IGRint			count;
struct	GRid		*list;
struct	GRmd_env	*md_env;
IGRdouble		*maxDist;
struct	GRid		*distExp;

{
IGRlong			sts, sts1, loc_msg;
IGRint			int_msg;
struct	ret_struct	ret_st, al_str;
IGRdouble		loc_dist;
IGRdouble		def_dir[3], vect_dir[3];
IGRdouble		res, al_cs[3];
IGRchar			*al_name;
IGRint			loc_count;
struct	GRmd_env	prev_env;
struct	GRid		prev, p_cs_al, p_box;
BSrc			bs_rc;


	*msg	= MSFAIL;

	sts = om$send(	msg = message NDmacro.ACgive_structure(
				&int_msg,
				NULL,
				N_ATT_LEN_ALONG,
				&ret_st,
				md_env ),
			senderid = NULL_OBJID,
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( !(int_msg&sts&1)){ loc_msg = MSFAIL; goto wrapup; }
	loc_dist = ret_st.var.root_pm_st.value;

	// get vect of propagation
	def_dir[0] = 1.; def_dir[1] = 1.; def_dir[2] = 1.; 
	sts = VLgetVectDir( &loc_msg, &list[INDEX_CS], md_env, 
							def_dir, vect_dir );
	if( ! (loc_msg&sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get allowance on current genLine
	// if vect prop . allow_dir < 0 --> reduce loc_dist
	sts = VLgetVectDir( &loc_msg, &list[INDEX_AL_CS], md_env, 
							def_dir, al_cs );
	if( (sts&loc_msg&1) && ((al_cs[0] != def_dir[0]) ||
		(al_cs[1] != def_dir[1]) || (al_cs[2] != def_dir[2])) ){

		res = BSdotp( &bs_rc, vect_dir, al_cs );
		if( bs_rc == BSSUCC ){

			if( res < 0 )	al_name	= N_ATT_AL_VAL;
			else		al_name	= N_ATT_EXTRA_AL;

			sts = om$send(	msg = message NDmacro.ACgive_structure(
					&int_msg,
					NULL,
					al_name,
					&al_str,
					md_env ),
				senderid = NULL_OBJID,
				targetid = list[INDEX_ATT_BOX].objid,
				targetos = list[INDEX_ATT_BOX].osnum );
			if( int_msg&sts&1 )
				loc_dist -= al_str.var.root_pm_st.value;
		}
	}

	// get previous element
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					"",
					&prev,
					&prev_env.md_env.matrix_type,
					prev_env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	prev_env.md_id.objid	= md_env->md_id.objid;
	prev_env.md_id.osnum	= prev.osnum;
	if((sts&loc_msg&1)){

		// get cs id
		sts = om$send(	msg	 = message NDnode.NDget_objects(
						ND_ROOT,
						&p_cs_al,
						1,
						NULL,
						INDEX_AL_CS,
						INDEX_AL_CS,
						&loc_count ),
			senderid = NULL_OBJID,
			targetid = prev.objid,
			targetos = prev.osnum );
		sts1 = om$send(	msg	 = message NDnode.NDget_objects(
						ND_ROOT,
						&p_box,
						1,
						NULL,
						INDEX_ATT_BOX,
						INDEX_ATT_BOX,
						&loc_count ),
			senderid = NULL_OBJID,
			targetid = prev.objid,
			targetos = prev.osnum );
		if( sts&sts1&1 ){

			sts = VLgetVectDir( &loc_msg, &p_cs_al, &prev_env, 
							def_dir, al_cs );
			if( (sts&loc_msg&1) && ((al_cs[0] != def_dir[0]) ||
						(al_cs[1] != def_dir[1]) ||
						(al_cs[2] != def_dir[2])) ){

				res = BSdotp( &bs_rc, vect_dir, al_cs );
				if( bs_rc == BSSUCC ){

				  if( res > 0 )	al_name	= N_ATT_AL_VAL;
				  else		al_name	= N_ATT_EXTRA_AL;

				  sts = om$send(msg = message NDmacro.ACgive_structure(
							&int_msg,
							NULL,
							al_name,
							&al_str,
							&prev_env ),
						senderid = NULL_OBJID,
					targetid = p_box.objid,
					targetos = p_box.osnum );
					if( int_msg&sts&1 )
						loc_dist -= 
						al_str.var.root_pm_st.value;
				}
			}
		}
	}

	loc_msg = MSSUCC;

	if( maxDist )	*maxDist = loc_dist;

	if( distExp ){

		sts = exp$create(	exp_name  = NULL,
					exp_value = loc_dist,
					osnum 	  = md_env->md_id.osnum,
					p_exp_id  = &distExp->objid,
	        	        	p_osnum   = &distExp->osnum );
		as$status( sts = sts );
	}

wrapup :
	
	if( loc_msg & 1) 	*msg	= MSSUCC;
	else			*msg	= MSFAIL;

return	*msg;
}

IGRint  VLlinestrToCurve (
	struct GRid           *	inLineString,	// IN :	lineString id
	struct GRmd_env	      * ls_env,   	// IN : linestring GRmd_env
	struct GRvg_construct * cst_info,	// IN : B-spline cnst info
	struct GRid 	      *	bsplineCrv	// OUT: B-spline curve
			)

{

	BSrc		retbs = BSFAIL;
	IGRint		ret0  = OM_E_INVARG;

	IGRuchar	buffer; // for EMSdpb functions
	IGRboolean	u_periodic;

	IGRlong 	u_order = 0, // was short
			n_poles = 0,
			l_ret	= MSFAIL;

	IGRpoint      *	poles	=	NULL;	// list of poles for curve
	struct GRlc_info lineString,		// linestring to create curve
		      *	LSptr	=	NULL;	// linestring ptr to above
struct GRvg_construct	cnst_list ;		// for construct of curve


	if ( !inLineString || !ls_env || !cst_info) goto ret_error_exit;

	ret0= EMdpb_get(
			&l_ret,
			EMSdpb_props,
			&buffer);
	__CheckRC(ret0, l_ret, "EMSdpb_props:u_period",ret_error_exit);

	if ((buffer & EMDPB_U_PERIODIC) && (u_order > 2))
			u_periodic = TRUE;
	else
			u_periodic = FALSE;

	bsplineCrv->osnum = cst_info->env_info->md_id.osnum;
	bsplineCrv->objid = NULL_OBJID;

        ret0= om$construct(
                                classname       = "GRbcsubbc",
                                osnum           = bsplineCrv->osnum,
                                p_objid         = &bsplineCrv->objid ) ;

        __DBGpr_obj( "ConGeom constructed curv ", bsplineCrv );
        __CheckRC(ret0, 1, "OMconstruct curv", ret_error_exit ) ;

	lineString.located_obj	= *inLineString;
	lineString.module_info	= *ls_env;
	LSptr			= &lineString;

	cnst_list		= *cst_info;
	cnst_list.geometry	= NULL;
	u_order			= 3 ;
	ret0 = om$send(msg = message GRbcsubbc.EMcurve_by_poles(
								u_order,
								u_periodic,
								n_poles,
								poles,
								LSptr,
								&cnst_list ),
			senderid = NULL_OBJID,
                       targetid = bsplineCrv->objid,
                       targetos = bsplineCrv->osnum);
	__CheckRC( ret0, *cnst_list.msg , "EMcurve_by_poles:", ret_error_exit );

	ret0 = OM_S_SUCCESS;

ret_error_exit:

	return ( ret0 );

}	// end FCT VLlinestrToCurve

/* ******************* MSG ACconstruct_feet () ************************	*/

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg;
IGRshort		level;
GRclassid		cid;
IGRchar			txt_mess[40];
OM_S_MESSAGE		mess;
GRname			dataName;
struct	ACrg_coll	attr;
char			*p;
char			*strrchr();
struct	GRid		grId, macOwn;
int			ptr;

	// check level of cmpt
	sts = om$send(	msg	 = message VLgenLine.NDcheck_cmpt_level( 
					msg, 
					count, 
					list, 
					md_env, 
					&level,
					NULL,
					TRUE ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );
	as$status( sts = *msg, action = RET_STATUS );

	// create message and send it
	om$get_classid(	objid	= my_id,
			osnum	= OM_Gw_current_OS,
			p_classid = &cid );

	sprintf( txt_mess, "ACconstruct_feet%d", level );
	sts = om$make_message(	classid	= cid,
				methodname	= txt_mess,
				p_arglist	= OPPmargs->p_arglist,
				size		= OPPmargs->size,
				p_msg		= &mess );

	sts = om$send(	msg	= &mess,
			targetid = my_id,
			targetos = OM_Gw_current_OS );
	__CheckRC(sts, 1, "ACconstruct_feet", wrapup);
//	as$status( sts = sts );

	if( ! (sts&1))	goto wrapup;

	// add data name into the contents collection
	if( feet_list[I_MF_CONTENTS].objid == NULL_OBJID ){

		feet_list[I_MF_CONTENTS].osnum	= OM_Gw_current_OS;
		sts = om$construct(	
				classid	= OPP_ACrg_collect_class_id,
				osnum	= feet_list[I_MF_CONTENTS].osnum,
				p_objid	= &feet_list[I_MF_CONTENTS].objid );
		as$status( sts = sts );
		if( ! (sts&1))	goto wrapup;
	}

	// get graphic element - and as owner 
	sts = om$send(	msg	 = message NDnode.ASreturn_go
					( &grId, NULL, NULL ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	as$status( sts = sts );
	if( ! (sts&1))	goto wrapup;

	macOwn	= grId;
	sts = ASget_mac_owner( &grId, &macOwn, &ptr );
//	as$status( sts = sts );

	if( (macOwn.objid == NULL_OBJID) || ! (sts&1) )	macOwn	= grId;

	dataName[0] = '\0';
	sts = om$send(	msg	 = message GRgraphics.GRgetname
					( &loc_msg, dataName ),
			targetid = macOwn.objid,
			targetos = macOwn.osnum );
//	as$status( sts = sts );

	if( dataName[0] == '\0' )	strcpy( dataName, "unknown" );
	strcpy( attr.name, N_ATT_DATA_NAME );
	attr.desc.type = AC_ATTRIB_TEXT;
	p = strrchr( dataName, ':' );
	p ? strcpy( attr.desc.value.att_txt, p + 1 ) : 
				strcpy( attr.desc.value.att_txt, dataName );

	sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute
					( &loc_msg, 1, &attr ),
			targetid = feet_list[I_MF_CONTENTS].objid,
			targetos = feet_list[I_MF_CONTENTS].osnum );
	as$status( sts = sts );

wrapup :

return	sts;
}

/* ****************** MSG NDcheck_cmpt_level () ***********************	*/

method	NDcheck_cmpt_level( IGRlong *msg; IGRshort count; struct GRid list[];
			struct GRmd_env *md_env; 
			IGRshort *level; IGRchar *def_name; IGRboolean load )
{
IGRlong		sts, int_msg;

	*msg	= MSSUCC;
	if( level != NULL )	*level	= 1;

	if( count < INDEX_START_CL + 1 ){
		if( level != NULL )	*level	= 1;

	} else if( level != NULL )	*level	= 2;

	if( def_name != NULL ){
		printf(" find macro_name \n");
		def_name[0]	= '\0';
		load	= FALSE;
	}

/*
	if( load & def_name ){

		sts = om$send(	msg = message ACcpx.ACattach
					( &int_msg, def_name ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = int_msg );
	}
*/
return	OM_S_SUCCESS;
}

/* ******************* MSG ACconstruct_feet1 () ***********************	*/

method ACconstruct_feet1( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg, stup_msg;
IGRdouble		vect[3];
IGRdouble		*ptr_vect;
struct	GRid		gr_info;
struct	GRmd_env	gr_env;
struct	ret_struct	str, str_pt;
IGRboolean		const_gr_sf;
struct	GRid		hull;
struct	GRmd_env	hull_env;
struct	GRid		line_cv;
IGRint			sa_fcount;
IGRdouble		def_dir[3], dir_vect[3];
IGRint			i;
struct	GRlc_info	sf_info, cv_info;
IGRdouble		p1[3], FromTo[9];
struct	GRvg_construct	cnst;
struct	GRid		pj_sf;
IGRlong			nb_obj;
OM_S_OBJID		*obj;
IGRint			nb_int;
struct	GRid		*list_int, inter;
IGRint			l_ind;

	/*| initialization */
	sa_fcount	= *fcount;
	*fcount		= 0;
	ptr_vect	= NULL;
	gr_env		= *md_env;
	hull_env	= *md_env;
	VLinitCnst( &cnst );
	nb_obj		= 0;
	obj		= NULL;
	list_int	= NULL;

	def_dir[0] = 1.; def_dir[1] = 1.; def_dir[2] = 1.;
	sts = VLgetVectDir( &loc_msg, &list[INDEX_CS], md_env, 
							def_dir, dir_vect );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get pt selector
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str_pt, md_env ),
			targetid = list[INDEX_PT_SELECT].objid,
			targetos = list[INDEX_PT_SELECT].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// place base line
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str, md_env ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	switch( str.type ){

	case double_type :
		for( i=0; i<3; i++ ) vect[i] = dir_vect[i] * 
						str.var.root_pm_st.value;
		gr_info.objid = NULL_OBJID;
		ptr_vect = vect;
		break;

	case other_generic :
	case curve_generic :
	case circle_type :
	case debug_type :
	case debug_type | macro_generic :
	case arc_type :

		ptr_vect = NULL;
		sts = om$send(	msg	 = message NDnode.ASreturn_go(
						&gr_info, 
						&gr_env.md_env.matrix_type,
						gr_env.md_env.matrix ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
		gr_env.md_id.osnum	= gr_info.osnum;
		break;

	case macro_generic :

		ptr_vect = NULL;
		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
						&loc_msg,
						MAN_GR_FEET,
						&gr_info,
						&gr_env.md_env.matrix_type,
						gr_env.md_env.matrix ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
		if( sts&loc_msg&1 ){

			sts = om$send(	msg	 = message NDnode.NDgive_structure
							( &loc_msg, &str, md_env ),
					targetid = list[INDEX_GR_INFO].objid,
					targetos = list[INDEX_GR_INFO].osnum );
		} else {

			sts = om$send(	msg	 = message NDnode.ASreturn_go( 
						&gr_info, 
						&gr_env.md_env.matrix_type,
						gr_env.md_env.matrix ),
				targetid = list[INDEX_GR_INFO].objid,
				targetos = list[INDEX_GR_INFO].osnum );
		  }

		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
		gr_env.md_id.osnum	= gr_info.osnum;
		break;

	default :
		printf(" Cant get graphic data \n");
		{ loc_msg = MSFAIL; goto wrapup; }
	}

	sts = om$send(	msg	 = message NDnode.ASreturn_go(
						&hull, 
						&hull_env.md_env.matrix_type,
						hull_env.md_env.matrix ),
			targetid = list[INDEX_HULL].objid,
			targetos = list[INDEX_HULL].osnum );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
	hull_env.md_id.osnum	= hull.osnum;

	sf_info.located_obj	= hull;
	sf_info.module_info	= hull_env;
	cv_info.located_obj	= gr_info;
	cv_info.module_info	= gr_env;

	sts = VLcreateSurface( &loc_msg, gr_info, &gr_env, 
				&gr_info, md_env, &const_gr_sf, ptr_vect, 0 );
	if( sts & loc_msg & 1 ){

		if( str_pt.type == point_generic ){

			sts = VLcreateAllInter( &loc_msg, &hull, &hull_env, 1,
					&gr_info, &gr_env, 0,
					&nb_int, &list_int, md_env );

			sts = VLselectClosestCv( &loc_msg, nb_int, list_int,
					md_env, str_pt.var.point_st.pt,
					&inter );

			sts = om$send(	msg	 = message GRgraphics.GRcopy(
							&loc_msg,
							md_env,
							md_env,
							&line_cv.objid ),
					targetid = inter.objid,
					targetos = inter.osnum );
			line_cv.osnum	= OM_Gw_current_OS;

		} else sts = VLcreateInter( &loc_msg, &hull, &hull_env, 1, 
					&gr_info, &gr_env, 0,
 					&line_cv, md_env );

	} else if( str.type == curve_generic ){

		// check if cs
		sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str, md_env ),
			targetid = list[INDEX_CS].objid,
			targetos = list[INDEX_CS].osnum );

		if( str.type == text_type ){

			// project curve on surface along normal
			nb_obj	= 0;
			sts = om$send(	msg	 = message 
				EMSsubbs.EMproject_curve_along_surface_normals(
					&cv_info,
					&sf_info,
					&cnst,
					FALSE,
					FALSE, // triming
					&nb_obj,
					&obj,
					&loc_msg ),
				targetid = sf_info.located_obj.objid,
				targetos = sf_info.located_obj.osnum );

			if( (sts&loc_msg&1) && nb_obj ){

				if( str_pt.type == point_generic && nb_obj > 1){

					nb_int	= nb_obj;
					list_int = (struct GRid *) malloc
					   ( sizeof(struct GRid) * nb_int );

					for( l_ind=0; l_ind<nb_int; l_ind++ ){
						list_int[l_ind].objid = obj[l_ind];
						list_int[l_ind].osnum = OM_Gw_current_OS;
					}

					sts = VLselectClosestCv( &loc_msg, 
						nb_int, list_int, md_env, 
						str_pt.var.point_st.pt,
						&inter );
				} else {

					inter.objid = obj[0];
					inter.osnum = OM_Gw_current_OS;
				  }

				sts = om$send(	msg	 = message GRgraphics.GRcopy(
								&loc_msg,
								md_env,
								md_env,
								&line_cv.objid ),
						targetid = inter.objid,
						targetos = inter.osnum );
				line_cv.osnum	= OM_Gw_current_OS;
			}

		} else {

			// create a surface of projection and inter
			p1[0] = 0.; p1[1] = 0.; p1[2] = 0.;

			EvalFromTo( &sf_info, &cv_info, p1, dir_vect,
						FromTo, &loc_msg );
			if( ! (loc_msg&1))	goto wrapup;
			pj_sf.objid	= NULL_OBJID;
			BuildSrf( &cv_info, FromTo, &cnst, &pj_sf, &loc_msg );
			if( ! (loc_msg&1))	goto wrapup;

			gr_info		= pj_sf;
			const_gr_sf	= TRUE;

			// intersection 
			if( str_pt.type == point_generic ){

				sts = VLcreateAllInter( &loc_msg, 
						&hull, &hull_env, 1,
						&gr_info, &gr_env, 0,
						&nb_int, &list_int, md_env );

				sts = VLselectClosestCv( &loc_msg, 
						nb_int, list_int, md_env, 
						str_pt.var.point_st.pt,
						&inter );

				sts = om$send(	msg	 = message GRgraphics.GRcopy(
								&loc_msg,
								md_env,
								md_env,
								&line_cv.objid ),
						targetid = inter.objid,
						targetos = inter.osnum );
				line_cv.osnum	= OM_Gw_current_OS;

			} else sts = VLcreateInter( &loc_msg, 
						&hull, &hull_env, 1, 
						&gr_info, &gr_env, 0,
						&line_cv, md_env );
		  }
	  } 

	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	loc_msg	= MSSUCC;

wrapup :

	if( const_gr_sf ){
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, md_env ),
				targetid = gr_info.objid,
				targetos = gr_info.osnum );
		as$status( sts = sts );
	}

	if( list_int ){
		for( i=0; i<nb_obj; i++ )
			om$send(msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
					targetid = list_int[i].objid,
					targetos = list_int[i].osnum );
		free( obj );
	}

	if( obj ) {
		for( i=0; i<nb_obj; i++ )
			om$send(msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
					targetid = obj[i] );
		free( obj );
	}

	// set value in feet_list
	if( *msg & 1 ){ 
		*fcount	= MAX_BASE_FEET;
		feet_list[I_MF_CV] = line_cv;
		feet_list[I_MF_CONTENTS].objid = NULL_OBJID;
		feet_list[I_MF_CONTENTS].osnum = OM_Gw_current_OS;
	}
	else *fcount	= 0; 

	if( ! (loc_msg&1)){ *msg = MSFAIL; return OM_W_ABORT; }

	*msg	= MSSUCC;

return	OM_S_SUCCESS;
}

/* ******************* MSG ACconstruct_feet2 () ***********************	*/

method ACconstruct_feet2( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg, no_msg;
struct	GRid		loc_tmp[5];
IGRint			nbInt;
IGRint			i, k;
IGRint			sa_fcount;
IGRdouble		*ptr_dbl;
struct	GRvg_construct	cnst;
struct	IGRpolyline	lstr_geom;
struct	GRid		lstr;
struct	GRlc_info	cv_info, sf_info;
IGRlong			nb_obj;
OM_S_OBJID		*obj;
IGRdouble		Dist;
IGRdouble		direct[3];
IGRdouble		pt_int[3], pt_on[3], dev[3];
IGRdouble		res;
IGRdouble		lim_pt[3], tangent[3];
struct	GRid		LIM_PT, TANG;
struct	ret_struct	str_pt, str_law;
BSrc			bs_rc;
IGRdouble		len_max;
IGRdouble		def_dir[3];
struct	GRid		*list_int, line_cv, inter;
IGRint			nb_int, l_ind;
IGRdouble		ldist[2];
IGRint			nb_dist;
IGRdouble		ext_pt[6];
IGRdouble		pt_pj[3];
struct	GRid		seg;
struct	IGRpolyline	line_geom;
IGRshort		law;
IGRdouble		param;
IGRint			int_msg;
IGRdouble		seg_len=0;
struct	IGRbsp_curve	ft_cv;
IGRshort		order;
IGRshort		smooth_fl, proj_fl;
GRclassid		cid;

	/*| initialization */
	*msg	 	= MSSUCC;
	sa_fcount	= *fcount;
	ptr_dbl		= NULL;
	obj		= NULL;
	list_int	= NULL;
	seg.objid	= NULL_OBJID;
	seg.osnum	= md_env->md_id.osnum;
	nb_dist		= 0;
	ft_cv.poles	= NULL;
	ft_cv.knots	= NULL;
	order		= 3;
	law		= 0;
	smooth_fl	= 1;
	proj_fl		= 0;

	// get pt selector
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str_pt, md_env ),
			targetid = list[INDEX_PT_SELECT].objid,
			targetos = list[INDEX_PT_SELECT].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sf_info.module_info.md_id	 = md_env->md_id;
	sts = om$send(	msg	 = message NDnode.ASreturn_go(
					&sf_info.located_obj,
					&sf_info.module_info.md_env.matrix_type,
					sf_info.module_info.md_env.matrix ),
			targetid = list[INDEX_HULL].objid,
			targetos = list[INDEX_HULL].osnum );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					MAN_GR_FEET,
					&loc_tmp[0],
					NULL, NULL ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetAllMaxDist( &loc_msg, count, list, md_env, 
						2, ldist, &nb_dist );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	Dist = ldist[0];

	// get law and properties
	sts = om$send(	msg	 = message NDmacro.ACgive_structure( 
						&int_msg, 
						NULL,
						N_ATT_LAW,
						&str_law,
						md_env ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( sts&int_msg&1 ){
		law	= ((IGRshort) str_law.var.root_pm_st.value) &
							V_ATT_LAW_MASK;
		smooth_fl = ((IGRshort) str_law.var.root_pm_st.value) &
					V_ATT_S_PROP_MASK & V_ATT_S_LISS;
		proj_fl = ((IGRshort) str_law.var.root_pm_st.value) &
					V_ATT_S_PROP_MASK & V_ATT_S_PROJ;
	}

	def_dir[0] = 0.; def_dir[1] = Dist * 0.2; def_dir[2] = Dist * 0.2;
	sts = VLgetVectDir( &loc_msg, &list[INDEX_CS], md_env, 
							def_dir, direct );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	ptr_dbl = (IGRdouble *) malloc( sizeof( IGRdouble ) * 
					(count - INDEX_START_CL) * 3 );
	if( ptr_dbl == NULL && (count - INDEX_START_CL) ){
		printf(" Error not enougth to allocate ptr_dbl\n");
		loc_msg	= MSFAIL;
		goto	wrapup;
	}


	if( nb_dist > 1 && (count - INDEX_START_CL) > 2 ){

		// find interval
		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					MAN_GR_FEET,
					&loc_tmp[1],
					NULL, NULL ),
				targetid = list[INDEX_START_CL].objid,
				targetos = list[INDEX_START_CL].osnum );
		if( ! (sts&loc_msg&1)){

			sts = om$send(	msg	 = message NDnode.ASreturn_go
						( &loc_tmp[1], NULL, NULL ),
					targetid = list[INDEX_START_CL].objid,
					targetos = list[INDEX_START_CL].osnum );
			if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
		}

		sts = VLcreateDblInter( &loc_msg, &loc_tmp[0], md_env,
						&loc_tmp[1], md_env,
						ext_pt, md_env );
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					MAN_GR_FEET,
					&loc_tmp[1],
					NULL, NULL ),
				targetid = list[count - 1].objid,
				targetos = list[count - 1].osnum );
		if( ! (sts&loc_msg&1)){

			sts = om$send(	msg	 = message NDnode.ASreturn_go
						( &loc_tmp[1], NULL, NULL ),
					targetid = list[count - 1].objid,
					targetos = list[count - 1].osnum );
			if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
		}

		sts = VLcreateDblInter( &loc_msg, &loc_tmp[0], md_env,
						&loc_tmp[1], md_env,
						&ext_pt[3], md_env );
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

		// create a segment
		VLinitCnst( &cnst );
		cnst.geometry	= (IGRchar *)	&line_geom;
		line_geom.num_points	= 2;
		line_geom.points	= ext_pt;

		sts = om$construct(	classid	= OPP_GR3dlinestr_class_id,
					osnum	= seg.osnum,
					p_objid	= &seg.objid );
		as$status( sts = sts );
		sts = om$send(	msg	 = message GRgraphics.GRaltconstruct
					( &cnst ),
			targetid = seg.objid,
			targetos = seg.osnum );
		cnst.geometry	= NULL;
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

		seg_len = BSdistptpt( &bs_rc, ext_pt, &ext_pt[3] );
	}

	for( i=INDEX_START_CL, nbInt = 0, len_max=MinInDir; i<count; i++ ){

		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					MAN_GR_FEET,
					&loc_tmp[1],
					NULL, NULL ),
				targetid = list[i].objid,
				targetos = list[i].osnum );
		if( ! (sts&loc_msg&1)){

			sts = om$send(	msg	 = message NDnode.ASreturn_go
						( &loc_tmp[1], NULL, NULL ),
					targetid = list[i].objid,
					targetos = list[i].osnum );
			if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
		}

		if( nb_dist > 1 && i != INDEX_START_CL && i != count -1  ){

			// Create intersection between segment and cntr_line
			sts = VLcreateDblInter( &loc_msg, 
						&loc_tmp[1], md_env,
						&seg, md_env,
						pt_pj, md_env );
			// Evaluate parametre
			param = BSdistptpt( &bs_rc, ext_pt, pt_pj ) / seg_len;
				
			POapplaw2val( (IGRint) law, ldist[0], ldist[1], 
						0., 1., param,
						&Dist, &loc_msg );

		} 
		if( i == INDEX_START_CL )	Dist = ldist[0];
		if( i == count - 1 && nb_dist > 1 )	Dist = ldist[1];

		if( Dist < 0.0 ) { loc_msg = MSFAIL; goto wrapup; }

		sts = VLinterPtAlong( &loc_msg, &loc_tmp[0], md_env, 
				&loc_tmp[1], md_env, 2, md_env, 
				direct, &Dist, pt_int, pt_on, dev );
		if( ! ( sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		for( k=0; k<3; k++ ) ptr_dbl[(nbInt*3)+k] = pt_on[k];
		nbInt++;

		res = BSdotp( &bs_rc, direct, pt_on );
		if( res > len_max ){
			len_max = res;
			for( k=0; k<3; k++ ){
				lim_pt[k]  = pt_on[k];
				tangent[k] = dev[k];
			}
		}
	}

	if( nbInt < 2 || nbInt < (count - INDEX_START_CL))
		{ loc_msg = MSFAIL; goto wrapup; }

	// create pt_lim and tang
	VLinitCnst( &cnst );
	cnst.env_info	= md_env;
	cnst.properties	= cnst.properties & ~(GRIS_DISPLAYABLE| GRIS_LOCATABLE);
	LIM_PT.objid	= NULL_OBJID;
	LIM_PT.osnum	= md_env->md_id.osnum;
	TANG.objid	= NULL_OBJID;
	TANG.osnum	= md_env->md_id.osnum;

	sts = VLplPt( &loc_msg, lim_pt, &LIM_PT, md_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	for( i=0; i<3; i++ ) tangent[i] += (direct[i] / 2 );
	BSnorvec( &bs_rc, tangent );
	sts = VLplPt( &loc_msg, tangent, &TANG, md_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// init cnst
	VLinitCnst( &cnst );
	cnst.env_info	= md_env;
	if( smooth_fl && (nbInt > (order - 1)) ){
		
		// fit set of point
		ft_cv.poles = (IGRdouble *) malloc
			( sizeof(IGRdouble) * (nbInt + order - 1 ) * 3 );
		ft_cv.knots = (IGRdouble *) malloc
			(  sizeof(IGRdouble) * (nbInt + (order * 2) ));
				
		BSdirfitcv( nbInt, ptr_dbl, order, 0, 0, 0, NULL, NULL, 
							&ft_cv, &bs_rc );
		lstr.objid	= NULL_OBJID;
		lstr.osnum	= md_env->md_id.osnum;
		sts = om$construct(	classid	= OPP_GRbcsubbc_class_id,
					osnum	= lstr.osnum,
					p_objid	= &lstr.objid );
		as$status( sts = sts );

		cnst.geometry = (IGRchar *) &ft_cv;
		sts = om$send(	msg	 = message GRgraphics.GRconstruct
						( &cnst ),
				targetid = lstr.objid,
				targetos = lstr.osnum );
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	} else {

		lstr.objid	= NULL_OBJID;
		lstr.osnum	= md_env->md_id.osnum;
		sts = om$construct(	classid	= OPP_GR3dlinestr_class_id,
					osnum	= lstr.osnum,
					p_objid	= &lstr.objid );
		as$status( sts = sts );

		cnst.geometry = (IGRchar *) &lstr_geom;
		lstr_geom.num_points	= nbInt;
		lstr_geom.points	= ptr_dbl;
		sts = om$send(	msg	 = message GRgraphics.GRaltconstruct
						( &cnst ),
				targetid = lstr.objid,
				targetos = lstr.osnum );
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	  }

	inter	= lstr;
	cv_info.module_info = *md_env;
	cv_info.located_obj	= lstr;

	// project line string on surface
	cnst.geometry	= NULL;
	nb_obj	= 0;
	sts = om$send(	msg	 = message 
			EMSsubbs.EMproject_curve_along_surface_normals(
					&cv_info,
					&sf_info,
					&cnst,
					FALSE,
					FALSE, // triming
					&nb_obj,
					&obj,
					&loc_msg ),
			targetid = sf_info.located_obj.objid,
			targetos = sf_info.located_obj.osnum );
	if( (! (sts&loc_msg&1)) || (! nb_obj)){loc_msg = MSFAIL; goto wrapup;}

	if( str_pt.type == point_generic && nb_obj > 1){

		nb_int	= nb_obj;
		list_int = (struct GRid *) malloc
					( sizeof(struct GRid) * nb_int );
		if( list_int == NULL && nb_int ){
			printf(" Error not enough memory to allocate list_int\n");
			loc_msg	= MSFAIL;
			goto	wrapup;
		}

		for( l_ind=0; l_ind<nb_int; l_ind++ ){
			list_int[l_ind].objid = obj[l_ind];
			list_int[l_ind].osnum = OM_Gw_current_OS;
		}

		sts = VLselectClosestCv( &loc_msg, nb_int, list_int, md_env, 
					str_pt.var.point_st.pt, &inter );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	} else { inter.objid = obj[0]; inter.osnum = OM_Gw_current_OS; }

	sts = om$get_classid(	objid	  = inter.objid,
				osnum	  = inter.osnum,
				p_classid = &cid );

	if( smooth_fl && 
	    (om$is_ancestry_valid(subclassid   = cid,
                     superclassid = OPP_GR3dlinestr_class_id) == OM_S_SUCCESS))

	{
		VLlinestrToCurve ( &inter, md_env, &cnst, &line_cv ); 
	}

	else {
	sts = om$send(	msg	 = message GRgraphics.GRcopy(
					&loc_msg,
					md_env,
					md_env,
					&line_cv.objid ),
			targetid = inter.objid,
			targetos = inter.osnum );
	line_cv.osnum	= OM_Gw_current_OS;
	}
	if( (sts&loc_msg&1) ){
		*fcount	= MAX_NEXT_FEET;
		feet_list[I_MF_CV]		= line_cv;
		feet_list[I_MF_CONTENTS].objid	= NULL_OBJID;
		feet_list[I_MF_CONTENTS].osnum	= OM_Gw_current_OS;
		feet_list[I_MF_PT_LIM]		= LIM_PT;
		feet_list[I_MF_TG]		= TANG;
	}

	loc_msg	= MSSUCC;

wrapup :

	if( seg.objid != NULL_OBJID )
		om$send(msg	 = message GRgraphics.GRdelete
					( &no_msg, md_env ),
			targetid = seg.objid,
			targetos = seg.osnum );

	if( lstr.objid != NULL_OBJID )
		om$send(msg	 = message GRgraphics.GRdelete
					( &no_msg, md_env ),
			targetid = lstr.objid,
			targetos = lstr.osnum );

	if( obj ){

		for( i=0; i<nb_obj; i++ )
			om$send(msg	 = message GRgraphics.GRdelete
					( &no_msg, md_env ),
				targetid = obj[i] );
		free( obj );
	}

	if( list_int )		free( list_int );
	if( ptr_dbl )		free( ptr_dbl );
	if( ft_cv.poles )	free( ft_cv.poles );
	if( ft_cv.knots )	free( ft_cv.knots );

	if( !(loc_msg&1)){ *msg = MSFAIL; return OM_W_ABORT; }

	*msg	= MSSUCC;

return	OM_S_SUCCESS;
}

/* ******************* MSG ACconstruct_feet3 () ***********************	*/

method ACconstruct_feet3( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg;
struct	GRid		loc_tmp[INDEX_START_CL];
IGRdouble		len_min;
IGRint			IndWater;
IGRint			i, k;
IGRint			sa_fcount;
IGRdouble		Dist;
IGRdouble		direct[3];
IGRdouble		def_dir[3];
IGRdouble		pt_int[3], pt_on[3], dev[3];
IGRdouble		lim_pt[3], tangent[3];
struct	GRid		LIM_PT, TANG;
struct	GRvg_construct	cnst;
struct	IGRpolyline	lstr_geom;
IGRint			nb_feet;
struct	GRid		loc_feet[MAX_BASE_FEET];
IGRdouble		res;
BSrc			bs_rc;

	/*| initialization */
	*msg	 = MSSUCC;
	IndWater = -1;
	sa_fcount	= *fcount;

	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					MAN_GR_FEET,
					&loc_tmp[0],
					NULL, NULL ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetMaxDist( &loc_msg, count, list, md_env, &Dist, (struct GRid *) NULL );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	def_dir[0] = Dist * 0.2; def_dir[1] = 0.; def_dir[1] = 0.;
	sts = VLgetVectDir( &loc_msg, &list[INDEX_CS], md_env, 
							def_dir, direct );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	for( i=INDEX_START_CL, len_min = MaxInDir; i<count; i++ ){

		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&loc_msg,
					MAN_GR_FEET,
					&loc_tmp[1],
					NULL, NULL ),
				targetid = list[i].objid,
				targetos = list[i].osnum );
		as$status( sts = sts );
		if( ! (sts&loc_msg&1))	continue;

		sts = VLinterPtAlong( &loc_msg, &loc_tmp[0], md_env, 
				&loc_tmp[1], md_env, 1, md_env, 
				direct, &Dist, pt_int, pt_on, dev );
		if( ! (sts&loc_msg&1))	continue;

		res = BSdotp( &bs_rc, direct, pt_on );
		if( res < len_min ){
			IndWater = i;
			len_min  = res;
			for( k=0; k<3; k++ ){
				lim_pt[k]  = pt_on[k];
				tangent[k] = dev[k];
			}
		}
	}

	if( IndWater == -1 ){ loc_msg = MSFAIL; goto wrapup; }

	// create pt_lim and tang
	VLinitCnst( &cnst );
	cnst.env_info	= md_env;
	cnst.properties	= cnst.properties & ~(GRIS_DISPLAYABLE| GRIS_LOCATABLE);
	LIM_PT.objid	= NULL_OBJID;
	LIM_PT.osnum	= md_env->md_id.osnum;
	TANG.objid	= NULL_OBJID;
	TANG.osnum	= md_env->md_id.osnum;
	cnst.geometry	= (IGRchar *) &lstr_geom;

	sts = VLplPt( &loc_msg, lim_pt, &LIM_PT, md_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	for( i=0; i<3; i++ ) tangent[i] += (direct[i] / 2 );
	BSnorvec( &bs_rc, tangent );
	sts = VLplPt( &loc_msg, tangent, &TANG, md_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// place butt at min dist
	for( i=0; i<INDEX_START_CL; i++ ) loc_tmp[i] = list[i];

	sts = exp$create(	exp_name   = NULL,
				exp_value  = len_min,
				osnum      = md_env->md_id.osnum,
			     	p_exp_id = &loc_tmp[INDEX_GR_INFO].objid,
	        	        p_osnum  = &loc_tmp[INDEX_GR_INFO].osnum );
	as$status( sts = sts );

	// construct feet like basic butt
	nb_feet = MAX_BASE_FEET;
	sts = om$send(	msg	= message VLgenLine.ACconstruct_feet1(
					&loc_msg, cn_type,
					INDEX_START_CL, loc_tmp,
					md_env,
					&nb_feet, loc_feet ),
			targetid = my_id );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// set feet list
	*fcount	= MAX_NEXT_FEET;
	feet_list[I_MF_CV]	= loc_feet[I_MF_CV];
	feet_list[I_MF_CONTENTS].objid	= NULL_OBJID;
	feet_list[I_MF_CONTENTS].osnum	= OM_Gw_current_OS;
	feet_list[I_MF_PT_LIM]	= LIM_PT;
	feet_list[I_MF_TG]	= TANG;

wrapup :

	if( ! (loc_msg & 1)){ *msg = MSFAIL; return OM_W_ABORT; }

	else 	*msg = MSSUCC;

return	OM_S_SUCCESS;
}

/* ******************* MSG ACconstruct_feet4 () ***********************	*/

method ACconstruct_feet4( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list )
{
IGRlong			sts, loc_msg, stup_msg;
IGRint			suc;
IGRdouble		vect[3];
IGRdouble		*ptr_vect;
struct	GRid		gr_info;
struct	GRmd_env	gr_env;
struct	ret_struct	str, str_pt;
IGRboolean		const_gr_sf;
struct	GRid		hull;
struct	GRmd_env	hull_env;
struct	GRid		line_cv;
IGRint			sa_fcount;
IGRdouble		def_dir[3], dir_vect[3];
IGRint			i;
struct	GRlc_info	sf_info, cv_info;
IGRdouble		p1[3], FromTo[9];
struct	GRvg_construct	cnst;
struct	GRid		pj_sf;
IGRlong			nb_obj;
OM_S_OBJID		*obj;
GRclassid		cid;
struct	GRid		*list_int, inter;
IGRint			nb_int, l_ind;


	/*| initialization */
	sa_fcount	= *fcount;
	*fcount		= 0;
	ptr_vect	= NULL;
	gr_env		= *md_env;
	hull_env	= *md_env;
	VLinitCnst( &cnst );
	nb_obj		= 0;
	obj		= NULL;
	gr_info.objid	= NULL_OBJID;
	list_int	= NULL;
	const_gr_sf	= FALSE;

	// get pt selector
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str_pt, md_env ),
			targetid = list[INDEX_PT_SELECT].objid,
			targetos = list[INDEX_PT_SELECT].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str, md_env ),
			targetid = list[INDEX_CS].objid,
			targetos = list[INDEX_CS].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	ptr_vect = NULL;
	if( str.type != text_type && str.type != plug_generic ){

		def_dir[0] = 1.; def_dir[1] = 1.; def_dir[2] = 1.;
		sts = VLgetVectDir( &loc_msg, &list[INDEX_CS], md_env, 
							def_dir, dir_vect );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
		ptr_vect = dir_vect;
	}

	// get type of graphic info
	sts = om$send(	msg	 = message NDnode.NDgive_structure
					( &loc_msg, &str, md_env ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	if( str.type == macro_generic ){

		sts = om$get_classid(	osnum	= list[INDEX_GR_INFO].osnum,
					objid	= list[INDEX_GR_INFO].objid,
					p_classid = &cid );

		if( om$is_ancestry_valid(	subclassid   = cid,
						superclassid = OPP_VLgenLine_class_id )
				== OM_S_SUCCESS ){

			sts = om$send(	msg	 = message NDmacro.ACgive_structure(
							&suc,
							(IGRint *) NULL,
							MAN_GR_FEET,
							&str,
							md_env ),
					targetid = list[INDEX_GR_INFO].objid,
					targetos = list[INDEX_GR_INFO].osnum );
			if( ! (sts&suc&1)){ loc_msg = MSFAIL; goto wrapup; }

			sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
							&loc_msg,
							MAN_GR_FEET,
							&gr_info,
							&gr_env.md_env.matrix_type,
							gr_env.md_env.matrix ),
					targetid = list[INDEX_GR_INFO].objid,
					targetos = list[INDEX_GR_INFO].osnum );
			if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
			gr_env.md_id.osnum	= gr_info.osnum;
		}
	}

	if( gr_info.objid == NULL_OBJID ){

		sts = om$send(	msg	 = message NDnode.ASreturn_go(
						&gr_info, 
						&gr_env.md_env.matrix_type,
						gr_env.md_env.matrix ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
		if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
		gr_env.md_id.osnum	= gr_info.osnum;
	}

	sts = om$send(	msg	 = message NDnode.ASreturn_go(
						&hull, 
						&hull_env.md_env.matrix_type,
						hull_env.md_env.matrix ),
			targetid = list[INDEX_HULL].objid,
			targetos = list[INDEX_HULL].osnum );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
	hull_env.md_id.osnum	= hull.osnum;

	sf_info.located_obj	= hull;
	sf_info.module_info	= hull_env;
	cv_info.located_obj	= gr_info;
	cv_info.module_info	= gr_env;


	switch( str.type ){

	case double_type :
		for( i=0; i<3; i++ ) vect[i] = ptr_vect[i] * 
						str.var.root_pm_st.value;
		gr_info.objid = NULL_OBJID;
		ptr_vect = vect;

	case macro_generic :
	case other_generic :
	case debug_type :
	case debug_type | macro_generic :

		// create surface 
		sts = VLcreateSurface( &loc_msg, gr_info, &gr_env, 
				&gr_info, md_env, &const_gr_sf, ptr_vect, 0 );
		if( sts & loc_msg & 1 )

			if( str_pt.type == point_generic ){

				sts = VLcreateAllInter( &loc_msg, 
						&hull, &hull_env, 1,
						&gr_info, &gr_env, 0,
						&nb_int, &list_int, md_env );

				sts = VLselectClosestCv( &loc_msg, 
						nb_int, list_int, md_env, 
						str_pt.var.point_st.pt,
						&inter );

				sts = om$send(	msg	 = message GRgraphics.GRcopy(
								&loc_msg,
								md_env,
								md_env,
								&line_cv.objid ),
						targetid = inter.objid,
						targetos = inter.osnum );
				line_cv.osnum	= OM_Gw_current_OS;

			} else sts = VLcreateInter( &loc_msg, 
						&hull, &hull_env, 1, 
						&gr_info, &gr_env, 0,
						&line_cv, md_env );
		break;

	case curve_generic :
	case arc_type :
	case circle_type :
	case line_generic :

		if( ptr_vect == NULL ){
			// project curve on surface along normal
			nb_obj	= 0;
			sts = om$send(	msg	 = message 
				EMSsubbs.EMproject_curve_along_surface_normals(
					&cv_info,
					&sf_info,
					&cnst,
					FALSE,
					FALSE, // triming
					&nb_obj,
					&obj,
					&loc_msg ),
				targetid = sf_info.located_obj.objid,
				targetos = sf_info.located_obj.osnum );
			if( (sts&loc_msg&1) && nb_obj ){

				if( str_pt.type == point_generic && nb_obj > 1){

					nb_int	= nb_obj;
					list_int = (struct GRid *) malloc
					   ( sizeof(struct GRid) * nb_int );

					for( l_ind=0; l_ind<nb_int; l_ind++ ){
						list_int[l_ind].objid = obj[l_ind];
						list_int[l_ind].osnum = OM_Gw_current_OS;
					}

					sts = VLselectClosestCv( &loc_msg, 
						nb_int, list_int, md_env, 
						str_pt.var.point_st.pt,
						&inter );
				} else {

					inter.objid = obj[0];
					inter.osnum = OM_Gw_current_OS;
				  }

				sts = om$send(	msg	 = message GRgraphics.GRcopy(
								&loc_msg,
								md_env,
								md_env,
								&line_cv.objid ),
						targetid = inter.objid,
						targetos = inter.osnum );
				line_cv.osnum	= OM_Gw_current_OS;
			}

		} else {

			// create a surface of projection and inter
			p1[0] = 0.; p1[1] = 0.; p1[2] = 0.;

			EvalFromTo( &sf_info, &cv_info, p1, dir_vect,
						FromTo, &loc_msg );
			if( ! (loc_msg&1))	goto wrapup;
			pj_sf.objid	= NULL_OBJID;
			BuildSrf( &cv_info, FromTo, &cnst, &pj_sf, &loc_msg );
			if( ! (loc_msg&1))	goto wrapup;

			gr_info		= pj_sf;
			const_gr_sf	= TRUE;

			if( str_pt.type == point_generic ){

				sts = VLcreateAllInter( &loc_msg, 
						&hull, &hull_env, 1,
						&gr_info, &gr_env, 0,
						&nb_int, &list_int, md_env );

				sts = VLselectClosestCv( &loc_msg, 
						nb_int, list_int, md_env, 
						str_pt.var.point_st.pt,
						&inter );

				sts = om$send(	msg	 = message GRgraphics.GRcopy(
								&loc_msg,
								md_env,
								md_env,
								&line_cv.objid ),
						targetid = inter.objid,
						targetos = inter.osnum );
				line_cv.osnum	= OM_Gw_current_OS;

			} else sts = VLcreateInter( &loc_msg, 
						&hull, &hull_env, 1, 
						&gr_info, &gr_env, 0,
						&line_cv, md_env );
		  }

		break;

	}// end switch

	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	loc_msg	= MSSUCC;

wrapup :

	if( const_gr_sf ){
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, md_env ),
				targetid = gr_info.objid,
				targetos = gr_info.osnum );
		as$status( sts = sts );
	}

	if( obj ) {
		for( i=0; i<nb_obj; i++ )
			om$send(msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
					targetid = obj[i] );
		free( obj );
	}

	if( list_int ){
		for( i=0; i<nb_int; i++ )
			om$send(msg	 = message GRgraphics.GRdelete
						( &stup_msg, md_env ),
					targetid = list_int[i].objid );
		free( list_int );
	}

	// set value in feet_list
	if( loc_msg & 1 ){ 
		*fcount	= MAX_BASE_FEET; 
		feet_list[I_MF_CV] = line_cv;
		feet_list[I_MF_CONTENTS].objid = NULL_OBJID;
		feet_list[I_MF_CONTENTS].osnum = OM_Gw_current_OS;

	} else *fcount	= 0; 

	if( ! (loc_msg&1)){ *msg = MSFAIL; return OM_W_ABORT; }

	*msg	= MSSUCC;

return	OM_S_SUCCESS;
}

/* **************** MSG VLgetLoftProps () *********************	*/

method  VLgetLoftProps( long *props )
{
	*props	= 0;

return	OM_S_SUCCESS;
}

end implementation VLgenLine;
