class implementation VLbutLine;
/*f
	File VLbutLinei.I contains 2 methods :

		NDcheck_cmpt_level : uses to select butt recompute method
		ACconstruct_feet10 : Create a new butt and develop surface
			around water lines to control the 2d length.
*/

#include <math.h>
#include "vlstructure.h"
#include "vlglinedef.h"
#include "AS_status.h"
#include "expmacros.h"
#include "asmacros.h"
#include "expression.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "nddef.h"
#include "vlgrdef.h"
#include "vlgrmacros.h"
#include "vlmsg.h"

#define BUTT_MAN_ITER	10

extern	GRclassid	OPP_EMScompsurf_class_id;
extern	GRclassid	OPP_ACrg_collect_class_id;
extern	struct	GRid	NULL_GRID;

extern	IGRboolean	IGEstop();

from	expression	import	modify;
from	ci_macro	import	init;

from	ACrg_collect	import	ACmod_list_attribute;
from	ACrg_collect	import	ACset_list_attribute;
from	ACrg_collect	import	ACget_named_attribute;


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
		ptr_def_name	= BUTT_DEF_1;
		break;

	case V_ATT_CURVED :
		loc_level	= 4;
		ptr_def_name	= BUTT_DEF_4;
		break;

	case V_ATT_NEXT :
		loc_level	= 3;
		ptr_def_name	= BUTT_DEF_2;
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
			loc_level	= 3;
			ptr_def_name	= BUTT_DEF_2;

		} else {

			loc_level	= 10;
			ptr_def_name	= BUTT_DEF_3;
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
IGRlong			sts, loc_msg, stup_msg, no_msg;
struct	GRid		go_hull;
struct	GRmd_env	hull_env;
IGRdouble		usrVal[2];
struct	GRvg_construct	cnst;
IGRint			nb_feet;
IGRdouble		MaxLen;
IGRdouble		Dist;
IGRdouble		fabs();
IGRint			sa_fcount;
IGRint			i, k;
struct	GRid		const3_list[50];
struct	GRid		box_b, box_s;
struct	GRid		seam_tmp[50];
IGRdouble		DistL;
struct	GRid		loc_butt[MAX_NEXT_FEET];
struct	GRid		sf_3d, sf_2d;
IGRint			nb_tmp3;
struct	GRid		cv[2];
struct	GRmd_env	cv_env[2];
struct	GRid		first_block;
struct	GRid		loc_seam[MAX_NEXT_FEET];
IGRdouble		area[3];
IGRint			l_ind;
struct	GRobj_env	cv_ov;
struct	IGRbsp_curve	*cvgeom;
struct	GRid		as_vect;
struct	ret_struct	str;
struct	GRid		prev_b;
struct	GRmd_env	prev_b_env;
IGRdouble		dist, direct[3], pt_int[3], pt_on[3], dev[3];
struct	GRid		pt_id;
IGRdouble		vect_mat[3];
IGRdouble		tst_w;
IGRdouble		activ_cht;
IGRint			size, size_buf;
struct	VLctrlSurf	*ctrl_3d;
IGRint			nb_ctrl_3d;
IGRint			ind_ctrl;
IGRdouble		Dmax, Dmin;
struct	ACrg_coll	att_list[10], att_3d_l, att_iter;
IGRdouble		allow;
IGRint			max_iter;
struct	GRid		contents;
IGRint			fl_go;


	/*| initialization */
	*msg	= MSSUCC;
	sa_fcount	= *fcount;
	hull_env	= *md_env;
	first_block.objid = NULL_OBJID;
	cvgeom		= NULL;
	VLinitCnst( &cnst );
	ctrl_3d		= NULL;
	nb_ctrl_3d	= 0;
	Dmin		= 0.;
	Dmax		= 10000000.;
	fl_go		= 0;

	// get cht
	size_buf = sizeof( IGRdouble );
	gr$get_chord_height_tolerance(	msg 	= &loc_msg,
					sizbuf	= &size_buf,
					buffer	= &activ_cht,
					nret	= &size );

	// get dist with allowance
	sts = VLgetMaxDist( &loc_msg, count, list, md_env, &MaxLen, NULL );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get info on hull
	sts = om$send(	msg	 = message NDnode.ASreturn_go(
					&go_hull,
					&hull_env.md_env.matrix_type,
					hull_env.md_env.matrix ),
			targetid = list[INDEX_HULL].objid,
			targetos = list[INDEX_HULL].osnum );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }
	hull_env.md_id.osnum	= go_hull.osnum;

	// create attribute box for butt
	box_b.osnum	= OM_Gw_current_OS;
	box_b.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message NDnode.NDcopy( 
						&loc_msg, 
						0, 
						md_env,
						md_env, 
						&box_b ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	strcpy( att_list[0].name, N_ATT_SELECTOR );
	att_list[0].desc.type = AC_ATTRIB_DOUBLE;
	att_list[0].desc.value.att_exp	= V_ATT_NEXT;

	sts = om$send(	msg	 = message ACrg_collect.ACmod_list_attribute
					( &loc_msg, 1, &att_list[0] ),
			targetid = box_b.objid,
			targetos = box_b.osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	strcpy( att_3d_l.name, N_ATT_LEN_ALONG );
	att_3d_l.desc.type = AC_ATTRIB_DOUBLE;
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
					( &loc_msg, &att_3d_l ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	allow = MaxLen - att_3d_l.desc.value.att_exp;

	// set next butt templates
	for( i=0; i<count; i++ )	const3_list[i] = list[i];
	const3_list[INDEX_ATT_BOX]	= box_b;
	nb_tmp3	= count;

	// create attribute box for seam
	box_s.osnum	= OM_Gw_current_OS;
	sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
				osnum	= box_s.osnum,
				p_objid	= &box_s.objid );
	if( ! (sts&1)){ loc_msg = MSFAIL; goto wrapup; }

	strcpy( att_list[0].name, N_ATT_SELECTOR );
	att_list[0].desc.type = AC_ATTRIB_DOUBLE;
	att_list[0].desc.value.att_exp	= V_ATT_NEXT;

	strcpy( att_list[1].name, N_ATT_TST_W );
	att_list[1].desc.type = AC_ATTRIB_DOUBLE;
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
					( &loc_msg, &att_list[1] ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
	strcpy( att_list[1].name, N_ATT_LEN_ALONG );

	tst_w = att_list[1].desc.value.att_exp / 3;

	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
					( &loc_msg, 2, att_list ),
			targetid = box_s.objid,
			targetos = box_s.osnum );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// set seam templates
	for( i=0; i<INDEX_START_CL; i++ ) seam_tmp[i]	= list[i];
	seam_tmp[INDEX_ATT_BOX]		= box_s;
	seam_tmp[INDEX_START_CL]	= list[INDEX_GR_INFO];

	// info on previous butt
	prev_b_env	= *md_env;
	sts = om$send(	msg	 = message NDnode.ASreturn_go( 
					&prev_b, 
					&prev_b_env.md_env.matrix_type,
					prev_b_env.md_env.matrix ),
			targetid = list[INDEX_GR_INFO].objid,
			targetos = list[INDEX_GR_INFO].osnum );
	prev_b_env.md_id.osnum	= prev_b.osnum;

	cv_ov.obj_id	= prev_b;
	cv_ov.mod_env	= prev_b_env;
	VLgetGeometry( &cv_ov, FALSE, NULL_OBJID, &cvgeom, &loc_msg );

	// alloc space for ctrl_3d_srf
	nb_ctrl_3d = count - INDEX_START_CL;
	ctrl_3d = (struct VLctrlSurf *) malloc( sizeof( struct VLctrlSurf ) *
				nb_ctrl_3d );
	if( (ctrl_3d == NULL) && nb_ctrl_3d ){

		printf(" Error not enough memory to allocate ctrl_3d\n");
		loc_msg	= MSFAIL;
		goto	wrapup;
	}
	for( ind_ctrl=0; ind_ctrl<nb_ctrl_3d; ind_ctrl++ )
		ctrl_3d[ind_ctrl].sf_3d.objid = NULL_OBJID;

	strcpy( att_iter.name, N_ATT_ITERATION );
	sts = om$send(	msg	 = message ACrg_collect.ACget_named_attribute
					( &loc_msg, &att_iter ),
			targetid = list[INDEX_ATT_BOX].objid,
			targetos = list[INDEX_ATT_BOX].osnum );
	if( ! (sts&loc_msg&1)) max_iter =  BUTT_MAN_ITER;
	else	max_iter = (IGRint) att_iter.desc.value.att_exp + 1;

	for( Dist = MaxLen, k=0; k<max_iter && ! IGEstop(); k++ ){

		fl_go	= 1;
		// calcul new butt
		nb_feet	= MAX_NEXT_FEET;
		sts = om$send(	msg	 = message VLgenLine.ACconstruct_feet3(
					&loc_msg, cn_type,
					nb_tmp3, const3_list,
					md_env,
					&nb_feet, loc_butt ),
				targetid = my_id );
		as$status( sts = sts );
		as$status( sts = loc_msg );
		if( ! (sts & loc_msg & 1)){ loc_msg = MSFAIL; goto wrapup; }

		// extract block
		if( k==0 ){

			as$make_source( go_grid	= loc_butt[I_MF_CV],
					as_os	= md_env->md_id.osnum,
					as_grid	= &seam_tmp[INDEX_START_CL+1]);

			cv[0]		= prev_b;
			cv_env[0]	= prev_b_env;
			cv[1]		= loc_butt[I_MF_CV];
			cv_env[1]	= *md_env;

			// first iteration
			as$make_source( go_grid	= loc_butt[I_MF_TG],
				as_os	= md_env->md_id.osnum,
				as_grid	= &as_vect );

			sts = om$send(	msg	 = message NDnode.NDgive_structure
						( &loc_msg, &str, md_env ),
					targetid = as_vect.objid,
					targetos = as_vect.osnum );
			BSnorvec( &loc_msg, str.var.point_st.pt );

			for( l_ind=0; l_ind<3; l_ind++ ){
				vect_mat[l_ind] = str.var.point_st.pt[l_ind];
				area[l_ind] = cvgeom->poles[3+l_ind] +
					(vect_mat[l_ind] * MaxLen / 3);
			}

			sts = VLextractSurface( &loc_msg, &go_hull, &hull_env,
				2, cv, cv_env, area, &first_block, md_env );
			if( ! (sts&loc_msg&1))
				{ loc_msg = MSFAIL; goto wrapup; }
			as$make_source( go_grid	= first_block,
					as_os	= md_env->md_id.osnum,
					as_grid	= &seam_tmp[INDEX_HULL] );

		}//end extract block

		// place seams around water lines
		for( i=INDEX_START_CL, DistL=0., ind_ctrl=0; 
					i<count; i++, ind_ctrl++ ){

		   if( ctrl_3d[ind_ctrl].sf_3d.objid == NULL_OBJID ){

			seam_tmp[INDEX_GR_INFO] = list[i];

			cv_env[0]	= *md_env;
			sts = om$send(	msg	 = message NDnode.ASreturn_go( 
						&cv[0],
						&cv_env[0].md_env.matrix_type,
						cv_env[0].md_env.matrix ),
				targetid = list[i].objid,
				targetos = list[i].osnum );
			cv_env[0].md_id.osnum	= cv[0].osnum;

			// create vector of construction
			dist = tst_w;
			direct[0] = 0.; direct[1] = 0.707; direct[2] = 0.707;
			sts = VLinterPtAlong( &loc_msg, &cv[0], &cv_env[0],
					&prev_b, &prev_b_env, 2,
					md_env, direct, &dist, 
					pt_int, pt_on, dev );
			if( ! (sts&loc_msg&1))	continue;

			// create vector
			BSnorvec( &loc_msg, dev );
			sts = VLplPt( &loc_msg, dev, &pt_id, md_env );
			if( ! (sts&loc_msg&1))	continue;

			as$make_source( go_grid	= pt_id,
					as_os	= md_env->md_id.osnum,
					as_grid	= &seam_tmp[INDEX_CS] );

			nb_feet	= MAX_NEXT_FEET;
			sts = om$send(	msg	 = message VLgenLine.ACconstruct_feet2(
						&loc_msg, cn_type,
						INDEX_START_CL+2, seam_tmp,
						md_env,
						&nb_feet, loc_seam ),
					targetid = my_id );
			if( ! (sts&loc_msg&1 ))	continue;

			cv[1]		= loc_seam[0];
			cv_env[1]	= *md_env;

			for( l_ind=0; l_ind<3; l_ind++ )
				ctrl_3d[ind_ctrl].area[l_ind] = pt_int[l_ind] +
					((vect_mat[l_ind] + dev[l_ind]) * dist);

			sts = VLextractSurface( &loc_msg, &first_block, md_env,
					2, cv, cv_env, ctrl_3d[ind_ctrl].area,
					&ctrl_3d[ind_ctrl].sf_3d, md_env );

			// delete seam
			for( l_ind=0; l_ind<MAX_NEXT_FEET; l_ind++ ){
			   om$send(msg	 = message GRgraphics.GRdelete
							( &stup_msg, md_env ),
					targetid = loc_seam[l_ind].objid,
					targetos = loc_seam[l_ind].osnum );
			   loc_seam[l_ind].objid = NULL_OBJID;
			}

			om$send(msg	 = message GRgraphics.GRdelete
							( &stup_msg, md_env ),
					targetid = pt_id.objid,
					targetos = pt_id.osnum );
			pt_id.objid = NULL_OBJID;

			if( (k!=0) && (sts&loc_msg&1) )

				sts = VLextractSurface( &loc_msg, 
						&ctrl_3d[ind_ctrl].sf_3d, md_env,
						1, &loc_butt[0], md_env, 
						ctrl_3d[ind_ctrl].area, 
						&sf_3d, md_env );

			else	sf_3d = ctrl_3d[ind_ctrl].sf_3d;

		   } else 

			sts = VLextractSurface( &loc_msg, 
					&ctrl_3d[ind_ctrl].sf_3d, md_env,
					1, &loc_butt[0], md_env, 
					ctrl_3d[ind_ctrl].area, 
					&sf_3d, md_env );

		   if( ! (sts&loc_msg&1))	continue;

		    sts = VLdevExtLoop( &sf_3d, md_env, &sf_2d, md_env );
		    if( sts&1 ){
				sts = vl$minrect ( curve   = &sf_2d,
						   environ = md_env,
						   cst     = &cnst,
						   option  = B_INERTI,
						   length  = &usrVal[0],
						   width   = &usrVal[1],
						   msg     = &loc_msg );
				if( (sts&loc_msg&1) && (DistL < usrVal[0]) )
					DistL =  usrVal[0];
		    }

		    if( sf_3d.objid != ctrl_3d[ind_ctrl].sf_3d.objid ){

				sts = om$send(	msg	 = message GRgraphics.GRdelete
							( &loc_msg, md_env ),
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

		}//end place ctrl surf

		// check development result
		printf(" MaxLen : %.2f, 3D_len : %.2f, 2D_len : %.2f\n", 
							MaxLen, Dist, DistL );

		if( fabs( MaxLen - DistL) < activ_cht ){
			loc_msg = MSSUCC;
			break;
		}

		if( DistL > MaxLen )	
			Dmax	= ( Dist < Dmax ) ? Dist : Dmax;
		else	Dmin	= ( Dist > Dmin ) ? Dist : Dmin;

//		printf(" 3D[min,max] = [%.2f, %.2f]\n", Dmin, Dmax );

		// delete loc_butt
		if( (! IGEstop()) && (k<BUTT_MAN_ITER - 1) )
			for( l_ind=0; l_ind < MAX_NEXT_FEET; l_ind++ )
				  sts = om$send(msg	 = 
						message GRgraphics.GRdelete
							( &no_msg, md_env ),
						targetid = loc_butt[l_ind].objid,
						targetos = loc_butt[l_ind].osnum );

		if( DistL < 0.00001 || MaxLen < fabs( DistL - MaxLen) ){
			printf(" No butt can be found \n");
			loc_msg	= MSFAIL;
			goto	wrapup;
		} 

		Dist = Dist - (DistL - MaxLen);

		if( Dist < Dmin || Dist > Dmax ) Dist = (Dmax + Dmin) / 2.;

		printf("\t\t\t\tDist3D = %.2f\n", Dist );

		att_3d_l.desc.value.att_exp	= Dist - allow;
		sts = om$send(	msg	 = message ACrg_collect.ACmod_list_attribute
						( &loc_msg, 1, &att_3d_l ),
				targetid = box_b.objid,
				targetos = box_b.osnum );
		as$status(  sts = sts );

	}// end for

	if( fl_go == 0 ){ loc_msg = MSFAIL; goto wrapup; }

	if( k == BUTT_MAN_ITER ) 
		printf("Warning : Iteration Process stopped after %d steps\n", 
							BUTT_MAN_ITER );

	if( IGEstop() )
		printf("Warning : Iteration Process stopped after %d steps\n", 
							k );

	// create contents
	contents.osnum	= OM_Gw_current_OS;
	sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
				osnum	= contents.osnum,
				p_objid	= &contents.objid );

	strcpy( att_list[0].name, N_ATT_3D_LEN );
	att_list[0].desc.type = AC_ATTRIB_DOUBLE;
	att_list[0].desc.value.att_exp	= Dist - allow;

	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
					( &loc_msg, 1, att_list ),
			targetid = contents.objid,
			targetos = contents.osnum );
	loc_butt[I_MF_CONTENTS] = contents;

	*fcount	=  MAX_NEXT_FEET;
	for( l_ind=0; l_ind<*fcount; l_ind++ )
		feet_list[l_ind] = loc_butt[l_ind];

wrapup :

	if( first_block.objid != NULL_OBJID ){

		sts = om$send(msg	 = message GRgraphics.GRdelete
						( &no_msg, md_env ),
				targetid = first_block.objid,
				targetos = first_block.osnum );
		as$status( sts = sts );
	}

	for( i=0; i<nb_ctrl_3d && ctrl_3d; i++ ){

		if( ctrl_3d[i].sf_3d.objid != NULL_OBJID )
			sts = om$send(msg	 = message GRgraphics.GRdelete
							( &no_msg, md_env ),
					targetid = ctrl_3d[i].sf_3d.objid,
					targetos = ctrl_3d[i].sf_3d.osnum );
	}

	if( box_b.objid != NULL_OBJID )
		sts = om$send(msg	 = message GRgraphics.GRdelete
						( &no_msg, md_env ),
				targetid = box_b.objid,
				targetos = box_b.osnum );

	if( box_s.objid != NULL_OBJID )
		sts = om$send(msg	 = message GRgraphics.GRdelete
						( &no_msg, md_env ),
				targetid = box_s.objid,
				targetos = box_s.osnum );

	if( cvgeom )	free( cvgeom );
	if( ctrl_3d )	free( ctrl_3d );

	if( ! (loc_msg&1)){
		*msg	= MSFAIL;
		*fcount	= 0;
		return	OM_W_ABORT;
	}

	*msg	= MSSUCC;

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
	struct GRmd_env		md_env;
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
	        myDef->info             = VL_I_ObjBaseButt;
		break;

	case V_ATT_CURVED :
		myDef->info             = VL_I_ObjCurvedButt;
		break;

	case V_ATT_DEV  :
	case V_ATT_NEXT :
		myDef->info             = VL_I_ObjNextButt;
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

end implementation VLbutLine;

