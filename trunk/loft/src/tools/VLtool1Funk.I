/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/tools/VLtool1Funk.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/08/00        Rama Rao        Header Creation && 
					Added VLcreateMultipleInter();
 * -------------------------------------------------------------------*/

class implementation VLabstract;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "godef.h"
#include "msdef.h"
#include "AS_status.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "expmacros.h"
#include "asmacros.h"
#include "cotxmacros.h"
#include "fontdef.h"
#include "fontmacros.h"
#include "grmessage.h"
#include "csmacros.h"
#include "macro.h"
#include "parametric.h"
#include "bsdistptpt.h"
#include "bsarclen.h"
#include "bsdotp.h"
#include "bsmdistptcv.h"
#include "bsnorvec.h"
#include "bsptsdlcv.h"
#include "bscveval.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

#define EXP_DOUBLE 0

from	GRgencs		import	GRgetmatrix;
from	EMSplane	import	EMplane;
from	ci_macro	import	init;

extern	GRclassid	OPP_nci_macro_class_id, OPP_ASintpt_class_id,
			OPP_GRpoint_class_id, OPP_GR3dlineseg_class_id;

extern	struct	GRid	NULL_GRID;

/* ********************* FCT VLinitCnst () **************************	*/

long			VLcnst_msg;
struct	IGRdisplay	VLact_disp;
short			VLact_level;
struct	GRmd_env	VLmoduleInfo;

void VLinitCnst( usr_cnst )

/*d Set memory (buffer) and default values on the given construction list.
    The user havent any free to do.  */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

struct	GRvg_construct	*usr_cnst;	/*IO construction list */

{
long		msg,NumberOfBytes,BytesReceived;

 NumberOfBytes = sizeof( VLmoduleInfo );
 gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &VLmoduleInfo,
                nret = &BytesReceived);

 ASget_active_symb( &VLact_level, &VLact_disp );
 usr_cnst->msg = &VLcnst_msg;        
 usr_cnst->env_info = &VLmoduleInfo;
 usr_cnst->display = &VLact_disp;
 usr_cnst->geometry = NULL; 
 usr_cnst->newflag = FALSE;
 usr_cnst->level = VLact_level;
 usr_cnst->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 usr_cnst->class_attr = NULL;
 usr_cnst->name = NULL;

}


/* ******************** FCT VLcreateInter () ************************	*/

IGRlong	VLcreateInter (

IGRlong			*msg,		/*O  return message 		*/
struct	GRid		*input1,	/*I  input elemt 1 		*/
struct	GRmd_env	*env1,		/*I  env of elemt 1		*/
IGRshort		trim1,		/*I  trim option for elemt 1	*/
struct	GRid		*input2,	/*I  input elemt 2 		*/
struct	GRmd_env	*env2,		/*I  env of elemt 2		*/
IGRshort		trim2,		/*I  trim option for elemt 2 	*/
struct	GRid		*inter,		/*O  id of intersection		*/
struct	GRmd_env	*loc_env )	/*I  env of intersection	*/

/*d This function return the first intersection between 2 elements */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

{
IGRlong			sts, loc_msg, no_msg;
struct	GRid		temp_list[5];	// use static to initialize 2 3 4
IGRint			i;
IGRint			suc;
struct	GRid		mc_int, resi0;
struct	GRid		wk_input1, wk_input2;

	/*c initialization */
	inter->objid	= NULL_OBJID;
	inter->osnum	= loc_env->md_id.osnum;
	*msg		= MSSUCC;
	loc_msg		= MSFAIL;
	wk_input1.objid		= NULL_OBJID;
	wk_input2.objid		= NULL_OBJID;

	if( input1->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg = message GRgraphics.GRcopy(
					&loc_msg,
					env1,
					loc_env,
					&wk_input1.objid ),
				senderid = NULL_OBJID,
				targetid = input1->objid,
				targetos = input1->osnum );
		as$status( sts = sts );
		wk_input1.osnum = loc_env->md_id.osnum;

		sts = as$make_source(	go_grid	= wk_input1,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[0] );
		as$status( sts = sts );

	} else {

		sts = as$make_source(	go_grid	= *input1,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[0] );
		as$status( sts = sts );
	  }

	if( input2->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg = message GRgraphics.GRcopy(
					&loc_msg,
					env2,
					loc_env,
					&wk_input2.objid ),
				senderid = NULL_OBJID,
				targetid = input2->objid,
				targetos = input2->osnum );
		as$status( sts = sts );
		wk_input2.osnum = loc_env->md_id.osnum;

		sts = as$make_source(	go_grid	= wk_input2,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[1] );
		as$status( sts = sts );

	} else {

		sts = as$make_source(	go_grid	= *input2,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[1] );
		as$status( sts = sts );
	  }

	// create default expressions
	temp_list[2].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) trim1,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[2].objid,
	        	        p_osnum  = &temp_list[2].osnum );
	as$status( sts = sts );

	temp_list[3].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) trim2,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[3].objid,
	        	        p_osnum  = &temp_list[3].osnum );
	as$status( sts = sts );

	temp_list[4].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) 0.,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[4].objid,
	        	        p_osnum  = &temp_list[4].osnum );
	as$status( sts = sts );

	mc_int.objid	= NULL_OBJID;
	mc_int.osnum	= loc_env->md_id.osnum;
	sts = om$construct(	classid	= OPP_nci_macro_class_id,
				osnum	= mc_int.osnum,
				p_objid	= &mc_int.objid );
	as$status( sts = sts );
	sts = om$send(	msg	 = message ci_macro.init(
					&suc, AChdr_nodisplay ,
					"int_2_elem",
					5, temp_list,
					NULL, loc_env ),
			senderid = NULL_OBJID,
			mode	 = OM_e_wrt_message,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );
	if( ! (sts&suc&1)){ loc_msg = MSFAIL; goto wrapup; }
	else {

		// get base cv 
		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
						&loc_msg,
						"resi0",
						&resi0,
						NULL,
						NULL ),
				senderid = NULL_OBJID,
				targetid = mc_int.objid,
				targetos = mc_int.osnum );
		as$status( sts = sts );

		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&loc_msg,
						loc_env,
						loc_env,
						&inter->objid ),
				senderid = NULL_OBJID,
				targetid = resi0.objid,
				targetos = resi0.osnum );
		as$status( sts = sts );
	}

wrapup :

	if( ! (loc_msg & 1))	*msg = MSFAIL;

	sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );

	if( wk_input1.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = wk_input1.objid,
				targetos = wk_input1.osnum );

	if( wk_input2.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = wk_input2.objid,
				targetos = wk_input2.osnum );

	for( i=2; i<5; i++ )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = temp_list[i].objid,
				targetos = temp_list[i].osnum );

return	*msg;
}

/* ******************** FCT VLcreateInter () ************************	*/

IGRlong	VLcreateMultiInter2Elem (

IGRlong			*msg,		/*O  return message 		*/
struct	GRid		*input1,	/*I  input elemt 1 		*/
struct	GRmd_env	*env1,		/*I  env of elemt 1		*/
IGRshort		trim1,		/*I  trim option for elemt 1	*/
struct	GRid		*input2,	/*I  input elemt 2 		*/
struct	GRmd_env	*env2,		/*I  env of elemt 2		*/
IGRshort		trim2,		/*I  trim option for elemt 2 	*/
IGRint			*num_inter,     /*I  Number of Intersections    */
struct	GRid		*inter,		/*O  id of intersection		*/
struct	GRmd_env	*loc_env )	/*I  env of intersection	*/

{
IGRlong			sts, loc_msg, no_msg;
struct	GRid		temp_list[5];	// use static to initialize 2 3 4
IGRint			i;
IGRint			suc;
IGRchar			name[40];
struct	GRid		mc_int, resi;
struct	GRid		wk_input1, wk_input2;

	/*c initialization */

	*num_inter      = 0;
	*msg		= MSSUCC;
	loc_msg		= MSFAIL;
	wk_input1.objid		= NULL_OBJID;
	wk_input2.objid		= NULL_OBJID;

	if( input1->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg = message GRgraphics.GRcopy(
					&loc_msg,
					env1,
					loc_env,
					&wk_input1.objid ),
				senderid = NULL_OBJID,
				targetid = input1->objid,
				targetos = input1->osnum );
		as$status( sts = sts );
		wk_input1.osnum = loc_env->md_id.osnum;

		sts = as$make_source(	go_grid	= wk_input1,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[0] );
		as$status( sts = sts );

	} else {

		sts = as$make_source(	go_grid	= *input1,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[0] );
		as$status( sts = sts );
	  }

	if( input2->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg = message GRgraphics.GRcopy(
					&loc_msg,
					env2,
					loc_env,
					&wk_input2.objid ),
				senderid = NULL_OBJID,
				targetid = input2->objid,
				targetos = input2->osnum );
		as$status( sts = sts );
		wk_input2.osnum = loc_env->md_id.osnum;

		sts = as$make_source(	go_grid	= wk_input2,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[1] );
		as$status( sts = sts );

	} else {

		sts = as$make_source(	go_grid	= *input2,
					as_os	= loc_env->md_id.osnum,
					as_grid	= &temp_list[1] );
		as$status( sts = sts );
	  }

	// create default expressions
	temp_list[2].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) trim1,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[2].objid,
	        	        p_osnum  = &temp_list[2].osnum );
	as$status( sts = sts );

	temp_list[3].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) trim2,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[3].objid,
	        	        p_osnum  = &temp_list[3].osnum );
	as$status( sts = sts );

	temp_list[4].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) 0.,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[4].objid,
	        	        p_osnum  = &temp_list[4].osnum );
	as$status( sts = sts );

	mc_int.objid	= NULL_OBJID;
	mc_int.osnum	= loc_env->md_id.osnum;
	sts = om$construct(	classid	= OPP_nci_macro_class_id,
				osnum	= mc_int.osnum,
				p_objid	= &mc_int.objid );
	as$status( sts = sts );
	sts = om$send(	msg	 = message ci_macro.init(
					&suc, AChdr_nodisplay ,
					"int_2_elem",
					5, temp_list,
					NULL, loc_env ),
			senderid = NULL_OBJID,
			mode	 = OM_e_wrt_message,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );
	if( ! (sts&suc&1)){ loc_msg = MSFAIL; goto wrapup; }
	else {
	     *num_inter = 0;
	     for( i=0; i<100; ++i )
	     {
		sprintf( name, "resi%d", i );
		// get base cv 
		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
						&loc_msg,
						name,
						&resi,
						NULL,
						NULL ),
				senderid = NULL_OBJID,
				targetid = mc_int.objid,
				targetos = mc_int.osnum );
		if( !(sts&1&loc_msg) )  break;

		inter[(*num_inter)].osnum    = loc_env->md_id.osnum;
		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&loc_msg,
						loc_env,
						loc_env,
						&inter[(*num_inter)].objid ),
				senderid = NULL_OBJID,
				targetid = resi.objid,
				targetos = resi.osnum );
		as$status( sts = sts );
		(*num_inter)++ ;
	     }
	     sts = loc_msg = MSSUCC;
	}

wrapup :

	if( ! (loc_msg & 1))	*msg = MSFAIL;

	sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );

	if( wk_input1.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = wk_input1.objid,
				targetos = wk_input1.osnum );

	if( wk_input2.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = wk_input2.objid,
				targetos = wk_input2.osnum );

	for( i=2; i<5; i++ )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = temp_list[i].objid,
				targetos = temp_list[i].osnum );

return	*msg;
}

/* ******************** FCT VLcreateSurface () **********************	*/

IGRlong	VLcreateSurface (

IGRlong			*msg,		/*O return message	*/
struct	GRid		in_obj,		/*I input object	*/
struct	GRmd_env	*in_env,	/*I input env.		*/
struct	GRid		*out_surf,	/*O output surf		*/
struct	GRmd_env	*loc_env,	/*O output env		*/
IGRboolean		*cr_state,	/*O creation state	*/
IGRdouble		*vector,	/*I working direction (optinal) */
IGRboolean		cs_flag )	/*I use active cs to convert vector */

/*d This function construct a surface corresponding to the input data */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

{
IGRlong			sts;
GRclassid		cid;
struct	IGRplane	ref_plane;
IGRdouble		pl_info[6];
struct	GRvg_construct	cnst;
IGRdouble		tmp_vect[4];
IGRdouble		loc_vect[4];
struct	GRid		ac_cs;
IGRdouble		mat[16], inv_mat[16];
IGRshort		four, one;


	/*c initialization */
	*msg	  = MSSUCC;
	*cr_state  = FALSE;
	*out_surf = in_obj;
	VLinitCnst( &cnst );
	cnst.env_info	= loc_env;

	if( (in_obj.objid == NULL_OBJID) && (vector != NULL) ){

		loc_vect[0]	= vector[0];
		loc_vect[1]	= vector[1];
		loc_vect[2]	= vector[2];

		if( cs_flag ){

			tmp_vect[0] = vector[0];
			tmp_vect[1] = vector[1];
			tmp_vect[2] = vector[2];
			tmp_vect[3] = 1.;
			// generate a plane with normal
			ac_cs.objid	= NULL_OBJID;
			ac_cs.osnum	= loc_env->md_id.osnum;
			sts = cs$get_active_info(	msg	= msg,
							osnum	= ac_cs.osnum,
							module	= loc_env->md_id.objid,
							objid	= &ac_cs.objid );
			as$status( sts = sts );
			as$status( sts = *msg );

			// get cs matrix
			sts = om$send(	msg	 = message GRgencs.GRgetmatrix
							( msg, mat ),
					senderid = NULL_OBJID,
					targetid = ac_cs.objid,
					targetos = ac_cs.osnum );
			as$status( sts = sts );

			four = 4; one = 1;
			MAinvmx( msg, &four, mat, inv_mat );
			MAmulmx( msg, &four, &four, &one, inv_mat, tmp_vect, loc_vect );
		}

		sts = VLcreatePlane( vector, loc_vect, loc_env, &cnst, 
							out_surf, msg );
		if( ! (sts & *msg & 1)){ *msg = MSFAIL; return FALSE; }

		*cr_state = TRUE;
		return	TRUE;
	}

	// check if valid
	om$get_classid( osnum     = in_obj.osnum,
			objid     = in_obj.objid,
			p_classid = &cid );

	sts = om$is_ancestry_valid(	subclassid     = cid,
				       	superclassname = "GRcurve" );
	if( sts == OM_S_SUCCESS ){

		if( vector ){
			printf(" create a surface of projection with vector \n");
			printf(" not yet implemented \n");
		}

		ref_plane.point  = &pl_info[0];
		ref_plane.normal = &pl_info[3];
		sts = om$send(	msg	 = message GRvg.GRdetplane(
						msg,
						&in_env->md_env.matrix_type,
						in_env->md_env.matrix,
						&ref_plane ),
				senderid = NULL_OBJID,
				targetid = in_obj.objid,
				targetos = in_obj.osnum );
		as$status( sts = sts );
		if( *msg != MSSUCC )	return	FALSE;

		/*| create object plane */
		sts = VLcreatePlane( ref_plane.point, ref_plane.normal, 
						loc_env, &cnst, out_surf, msg );
		*cr_state = TRUE;

	} else if( om$is_ancestry_valid(subclassid     = cid,
				       	superclassname = "EMSsubbs" )
			!= OM_S_SUCCESS ){

			*msg	= MSFAIL;
			return	FALSE;
		}

return	TRUE;
}

/* ******************* FCT VLcreatePtInter () **********************	*/

IGRlong	VLcreatePtInter( msg, input1, env1, input2, env2, inter, loc_env )

/*d Create intersection point between 2 elements */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

IGRlong			*msg;		/*O return message 	*/
struct	GRid		*input1;	/*I id of elemt 1	*/
struct	GRmd_env	*env1;		/*I env of elemt 1	*/
struct	GRid		*input2;	/*I id of elemt 2	*/
struct	GRmd_env	*env2;		/*I env of elemt2	*/
struct	GRid		*inter;		/*O id of intersection	*/
struct	GRmd_env	*loc_env;	/*I env of intersection	*/

{
IGRlong			sts, loc_msg, no_msg;
struct	GRid		temp_list[5];
struct	GRas		as_list;
struct	GRid		int_pt, rt_go;
struct	GRvg_construct	cnst;
IGRdouble		dbl[3];
struct	IGRplane	ref_plane;
IGRdouble		pl_info[6];
IGRint			ind_plane;
struct	GRid		plane;
GRclassid		cid;
struct	GRid		wk_input1, wk_input2;


	/*c initialization */
	inter->objid	= NULL_OBJID;
	int_pt.objid	= NULL_OBJID;
	inter->osnum	= loc_env->md_id.osnum;
	plane.objid	= NULL_OBJID;
	*msg		= MSFAIL;
	VLinitCnst( &cnst );
	cnst.env_info	= loc_env;
	dbl[0] = 0.; dbl[1] = 0.; dbl[2] = 0.;
	wk_input1.objid	= NULL_OBJID;
	wk_input2.objid	= NULL_OBJID;


	/*c check if one input can be modelised by a plane */
	ind_plane	= 1;
	ref_plane.point  = &pl_info[0];
	ref_plane.normal = &pl_info[3];
	sts = om$send(	msg	 = message GRvg.GRdetplane(
						&loc_msg,
						&env1->md_env.matrix_type,
						env1->md_env.matrix,
						&ref_plane ),
			senderid = NULL_OBJID,
			targetid = input1->objid,
			targetos = input1->osnum );
	if( ! (loc_msg & sts & 1)){

		ind_plane	= 2;
		sts = om$send(	msg	 = message GRvg.GRdetplane(
						&loc_msg,
						&env2->md_env.matrix_type,
						env2->md_env.matrix,
						&ref_plane ),
				senderid = NULL_OBJID,
				targetid = input2->objid,
				targetos = input2->osnum );
	} if( ! (loc_msg & sts & 1)) goto classic_way;

	/*c create plane */
	sts = VLcreatePlane( ref_plane.point, ref_plane.normal, loc_env, 
						&cnst, &plane, &loc_msg );
	if( ! (sts&loc_msg&1)) { loc_msg = MSFAIL; goto wrapup; }

	/*c create pt inter between curve and plane */
	if( ind_plane == 1 )
		VLcreateInter( &loc_msg, input2, env2, 1, &plane, loc_env, 0,
							inter, loc_env );
	else 
		VLcreateInter( &loc_msg, input1, env1, 1, &plane, loc_env, 0, 
							inter, loc_env );
	if( loc_msg&1 ){

		/*c check result */
		om$get_classid( osnum = inter->osnum, 
				objid = inter->objid, 
				p_classid = &cid );
		if( om$is_ancestry_valid(subclassid	= cid,
					superclassid	= OPP_GRpoint_class_id )
				== OM_S_SUCCESS ) goto wrapup;
		else {
			inter->objid	= NULL_OBJID;
			inter->osnum	= loc_env->md_id.osnum;
		}
	}


classic_way :

	/*c classic way create an ASintpt */

	if( input1->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&loc_msg,
						env1,
						loc_env,
						&wk_input1.objid ),
				senderid = NULL_OBJID,
				targetid = input1->objid,
				targetos = input1->osnum );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
		wk_input1.osnum	= loc_env->md_id.osnum;

		as$make_source(	go_grid = wk_input1,
				as_os	= loc_env->md_id.osnum,
				as_grid = &temp_list[0] );

	} else {

		as$make_source( go_grid	= *input1,
				as_os	= loc_env->md_id.osnum,
				as_grid	= &temp_list[0] );
	  }

	if( input2->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&loc_msg,
						env2,
						loc_env,
						&wk_input2.objid ),
				senderid = NULL_OBJID,
				targetid = input2->objid,
				targetos = input2->osnum );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }
		wk_input2.osnum	= loc_env->md_id.osnum;

		as$make_source(	go_grid = wk_input2,
				as_os	= loc_env->md_id.osnum,
				as_grid = &temp_list[1] );

	} else {

		as$make_source( go_grid	= *input2,
				as_os	= loc_env->md_id.osnum,
				as_grid	= &temp_list[1] );
	  }

	as_list.num_parents	= 2;
	as_list.parents		= temp_list;
	as_list.context		= NULL;
	as_list.as_attr		= (IGRchar *) dbl;
	as_list.go_attr		= NULL;
	as_list.go_objid.objid	= NULL_OBJID;

	int_pt.objid	= NULL_OBJID;
	int_pt.osnum	= loc_env->md_id.osnum;
	sts = om$construct(	classid	= OPP_ASintpt_class_id,
				osnum	= int_pt.osnum,
				p_objid	= &int_pt.objid );
	if( ! (sts&1)){ loc_msg	= MSFAIL; goto wrapup; }

	sts = om$send(	msg	 = message NDnode.NDplace
					( &as_list, loc_env, (char *) &cnst ),
			senderid = NULL_OBJID,
			targetid = int_pt.objid,
			targetos = int_pt.osnum );
	loc_msg	= sts;
	if( sts&1 ){

		// get pt
		sts = om$send(	msg	 = message NDnode.ASreturn_go
					( &rt_go, NULL, NULL ),
				senderid = NULL_OBJID,
				targetid = int_pt.objid,
				targetos = int_pt.osnum );
		as$status( sts = sts );

		sts = om$send(	msg	 = message GRgraphics.GRcopy(
						&loc_msg,
						loc_env,
						loc_env,
						&inter->objid ),
				senderid = NULL_OBJID,
				targetid = rt_go.objid,
				targetos = rt_go.osnum );
		as$status( sts = sts );
	}

wrapup :

	if( loc_msg & 1 )	*msg	= MSSUCC;

	if( plane.objid != NULL_OBJID )
	    om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = plane.objid,
			targetos = plane.osnum );

	if( int_pt.objid != NULL_OBJID )
	    om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = int_pt.objid,
			targetos = int_pt.osnum );

	if( wk_input1.objid != NULL_OBJID )
	    om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = wk_input1.objid,
			targetos = wk_input1.osnum );

	if( wk_input2.objid != NULL_OBJID )
	    om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = wk_input2.objid,
			targetos = wk_input2.osnum );

return	*msg;
}

/* ******************* FCT VLcreateDblInter () *********************	*/

IGRlong	VLcreateDblInter( msg, input1, env1, input2, env2, dbl, loc_env )

/*d Get Coordinate of intersection point between 2 elements */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

IGRlong			*msg;		/*O return message 	*/
struct	GRid		*input1;	/*I id of elemt 1	*/
struct	GRmd_env	*env1;		/*I env of elemt 1	*/
struct	GRid		*input2;	/*I id of elemt 2	*/
struct	GRmd_env	*env2;		/*I env of elemt2	*/
IGRdouble		*dbl;		/*O Coordinate of pt inter	*/
struct	GRmd_env	*loc_env;	/*I env of intersection	*/

{
IGRlong		sts, no_msg;
struct	GRid	pt;

	pt.objid	= NULL_OBJID;

	sts = VLcreatePtInter( msg, input1, env1, input2, env2, 
								&pt, loc_env ); 
	if( ! (sts & *msg & 1)){ *msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( msg, pt, loc_env, dbl );
	if( ! (sts & *msg & 1)){ *msg = MSFAIL; goto wrapup; }

wrapup :

	if( pt.objid != NULL_OBJID )
	  om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = pt.objid,
			targetos = pt.osnum );

return	*msg;
}


/* ******************* FCT VLselectClosestCv () ********************	*/

IGRlong VLselectClosestCv( msg, nb_cv, list_cv, cv_env, select_pt, closest )

/*d This function return the closest curve in a list of a given point. */

/*h 01/01/93 : created by Ludovic LE CORVEC (ISDC) */

IGRlong			*msg;		/*O return message		*/
IGRint			nb_cv;		/*I number of cv in list	*/
struct	GRid		*list_cv;	/*I list of cv			*/
struct	GRmd_env	*cv_env;	/*I module enviroment of cvs	*/
IGRdouble		*select_pt;	/*I point of selection		*/
struct	GRid		*closest;	/*O selected element		*/

{
IGRlong			sts, loc_msg;
IGRint			i;
IGRdouble		proj_pt[3];
struct	GRparms		pj_par;
IGRdouble		dist, mdist;
BSrc			bs_rc;

	/*c initialization */
	closest->objid	= NULL_OBJID;
	mdist		= 100000000;

	for( i=0; i<nb_cv; i++ ){
				
		sts = om$send(	msg	 = message GRgraphics.GRptproject(
						&loc_msg,
						&cv_env->md_env.matrix_type,
						cv_env->md_env.matrix,
						select_pt,
						proj_pt,
						&pj_par ),
				senderid = NULL_OBJID,
				targetid = list_cv[i].objid,
				targetos = list_cv[i].osnum );
		if( ! (sts&loc_msg&1))	continue;

		dist	= BSdistptpt( &bs_rc, select_pt, proj_pt );
		if( bs_rc != BSSUCC )	continue;

		if( dist < mdist ){ mdist = dist; *closest = list_cv[i]; }
	}

	if( closest->objid == NULL_OBJID ) *msg = MSFAIL;
	else 	*msg = MSSUCC;

return	*msg;
}

/* **************** FCT VLcreateAllInter () ************************	*/
IGRlong	VLcreateAllInter (

IGRlong			*msg,		/*O  return message 		*/
struct	GRid		*input1,	/*I  input elemt 1 		*/
struct	GRmd_env	*env1,		/*I  env of elemt 1		*/
IGRshort		trim1,		/*I  trim option for elemt 1	*/
struct	GRid		*input2,	/*I  input elemt 2 		*/
struct	GRmd_env	*env2,		/*I  env of elemt 2		*/
IGRshort		trim2,		/*I  trim option for elemt 2 	*/
IGRint			*nb_inter,	/*O  number of intersection	*/
struct	GRid		**inter,	/*O  list of intersection	*/
struct	GRmd_env	*loc_env )	/*I  env of intersection	*/

/*d This function return the of intersection between 2 elements */

/*h 01/01/93 : created by Ludovic LE CORVEC (ISDC) */

{
IGRlong			sts, loc_msg, no_msg;
struct	GRid		temp_list[5];	// use static to initialize 2 3 4
IGRint			i, j;
IGRint			suc;
struct	GRid		mc_int;
IGRint			nb_loc, nb_cmp;
struct	GRid		loc_cmp[5];
struct	GRid		*my_inter;
struct	GRid		wk_input1, wk_input2;


	/*| initialization */
	*inter		= NULL;
	*nb_inter	= 0;
	my_inter	= NULL;
	*msg		= MSSUCC;
	loc_msg		= MSFAIL;
	wk_input1.objid		= NULL_OBJID;
	wk_input2.objid		= NULL_OBJID;

	if( input1->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg = message GRgraphics.GRcopy(
					&loc_msg,
					env1,
					loc_env,
					&wk_input1.objid ),
				senderid = NULL_OBJID,
				targetid = input1->objid,
				targetos = input1->osnum );
		as$status( sts = sts );
		wk_input1.osnum = loc_env->md_id.osnum;

		as$make_source( go_grid	= wk_input1,
				as_os	= loc_env->md_id.osnum,
				as_grid	= &temp_list[0] );

	} else {

		as$make_source( go_grid	= *input1,
				as_os	= loc_env->md_id.osnum,
				as_grid	= &temp_list[0] );
	  }

	if( input2->osnum != loc_env->md_id.osnum ){

		sts = om$send(	msg = message GRgraphics.GRcopy(
					&loc_msg,
					env2,
					loc_env,
					&wk_input2.objid ),
				senderid = NULL_OBJID,
				targetid = input2->objid,
				targetos = input2->osnum );
		as$status( sts = sts );
		wk_input2.osnum = loc_env->md_id.osnum;

		as$make_source( go_grid	= wk_input2,
				as_os	= loc_env->md_id.osnum,
				as_grid	= &temp_list[1] );

	} else {

		as$make_source( go_grid	= *input2,
				as_os	= loc_env->md_id.osnum,
				as_grid	= &temp_list[1] );
	  }

	// create default expressions
	temp_list[2].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) trim1,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[2].objid,
	        	        p_osnum  = &temp_list[2].osnum );
	as$status( sts = sts );

	temp_list[3].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) trim2,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[3].objid,
	        	        p_osnum  = &temp_list[3].osnum );
	as$status( sts = sts );

	temp_list[4].objid = NULL_OBJID;
	sts = exp$create(	exp_name   = NULL,
				exp_value  = (IGRdouble) 0.,
				osnum      = loc_env->md_id.osnum,
			     	p_exp_id = &temp_list[4].objid,
	        	        p_osnum  = &temp_list[4].osnum );
	as$status( sts = sts );

	mc_int.objid	= NULL_OBJID;
	mc_int.osnum	= loc_env->md_id.osnum;
	sts = om$construct(	classid	= OPP_nci_macro_class_id,
				osnum	= mc_int.osnum,
				p_objid	= &mc_int.objid );
	as$status( sts = sts );
	sts = om$send(	msg	 = message ci_macro.init(
					&suc, AChdr_nodisplay ,
					"int_2_elem",
					5, temp_list,
					NULL, loc_env ),
			senderid = NULL_OBJID,
			mode	 = OM_e_wrt_message,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );
	if( ! (sts&suc&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get components
	sts = om$send(	msg	 = message GRowner.GRget_number_components
					( &loc_msg, nb_inter ),
			senderid = NULL_OBJID,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );
	if( !(sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	my_inter = (struct GRid *) malloc( sizeof(struct GRid) * (*nb_inter) );
	if( my_inter == NULL && *nb_inter ){

		printf(" Error not enough memory to allocate inter\n");
		*nb_inter = 0;
		loc_msg	= MSFAIL;
		goto	wrapup;
	}

	for( i=0, nb_loc=5; i<*nb_inter; i +=nb_loc ){

		sts = om$send(	msg	 = message GRowner.GRget_components(
							&loc_msg,
							loc_env,
							loc_cmp,
							nb_loc,
							&nb_cmp,
							i,
							i+nb_loc ),
				senderid = NULL_OBJID,
				targetid = mc_int.objid,
				targetos = mc_int.osnum );
		if( !(sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		for( j=0; j<nb_cmp; j++ ){

			sts = om$send(msg	 = message GRgraphics.GRcopy(
							&loc_msg,
							loc_env,
							loc_env,
							&my_inter[i+j].objid ),
				senderid = NULL_OBJID,
				targetid = loc_cmp[j].objid,
				targetos = loc_cmp[j].osnum );
			as$status( sts = sts );
			as$status( sts = loc_msg );
			my_inter[i+j].osnum = loc_env->md_id.osnum;

		}/*end for j*/

	}/*end for i*/

wrapup :

	if( ! (loc_msg & 1)){
		if( my_inter )	free( my_inter ); 
		*msg = MSFAIL;
	} else 	*inter = my_inter;

	sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
			senderid = NULL_OBJID,
			targetid = mc_int.objid,
			targetos = mc_int.osnum );

	if( wk_input1.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = wk_input1.objid,
				targetos = wk_input1.osnum );

	if( wk_input2.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = wk_input2.objid,
				targetos = wk_input2.osnum );

	for( i=2; i<5; i++ )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, loc_env ),
				senderid = NULL_OBJID,
				targetid = temp_list[i].objid,
				targetos = temp_list[i].osnum );

return	*msg;
}

/* ****************** FCT VLlengthAlongCv () ***********************	*/

IGRlong VLlengthAlongCv( msg, cv, cv_env, pt1, pt1_env, pt2, pt2_env, length )

/*d This function return the length along a curve between two points */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

IGRlong			*msg;		/*O  return message	*/
struct	GRid		*cv;		/*I  id of cv support	*/
struct	GRmd_env	*cv_env;	/*I  env of cv support	*/
struct	GRid		*pt1;		/*I  id of point 1	*/
struct	GRmd_env	*pt1_env;	/*I  env of pt 1	*/
struct	GRid		*pt2;		/*I  id of point 1	*/
struct	GRmd_env	*pt2_env;	/*I  env of pt 1	*/
IGRdouble		*length;	/*O  length along curve */

{
IGRlong			sts, loc_msg;
IGRchar			*ptr_geom;
IGRdouble		dbl[3], pt[3];
struct	IGRbsp_curve	*cv_geom;
struct	GRparms		parm[2];
IGRdouble		mid;
IGRint			i;
BSrc			bs_rc;
IGRboolean		stat;


	/*c initialization */
	*msg	= MSFAIL;
	*length	= 0.;

	// get start index on cv
	sts = om$send(	msg	 = message GRvg.GRgenabsg(
					&loc_msg,
					&pt1_env->md_env.matrix_type,
					pt1_env->md_env.matrix,
					&ptr_geom ),
			senderid = NULL_OBJID,
			targetid = pt1->objid,
			targetos = pt1->osnum );
	as$status( sts = sts, action = RET_STATUS );

	cv_geom = (struct IGRbsp_curve *) ptr_geom;
	for( i=0; i<3; i++ ) dbl[i] = cv_geom->poles[i];

	sts = om$send(	msg	 = message GRgraphics.GRptproject(
					&loc_msg,
					&cv_env->md_env.matrix_type,
					cv_env->md_env.matrix,
					dbl,
					pt,
					&parm[0] ),
			senderid = NULL_OBJID,
			targetid = cv->objid,
			targetos = cv->osnum );
	as$status( sts = sts, action = RET_STATUS );

	// get end index on cv
	sts = om$send(	msg	 = message GRvg.GRgenabsg(
					&loc_msg,
					&pt2_env->md_env.matrix_type,
					pt2_env->md_env.matrix,
					&ptr_geom ),
			senderid = NULL_OBJID,
			targetid = pt2->objid,
			targetos = pt2->osnum );
	as$status( sts = sts, action = RET_STATUS );

	cv_geom = (struct IGRbsp_curve *) ptr_geom;
	for( i=0; i<3; i++ ) dbl[i] = cv_geom->poles[i];

	sts = om$send(	msg	 = message GRgraphics.GRptproject(
					&loc_msg,
					&cv_env->md_env.matrix_type,
					cv_env->md_env.matrix,
					dbl,
					pt,
					&parm[1] ),
			senderid = NULL_OBJID,
			targetid = cv->objid,
			targetos = cv->osnum );
	as$status( sts = sts, action = RET_STATUS );

	// compute length
	sts = om$send(	msg	 = message GRvg.GRgenabsg(
					&loc_msg,
					&cv_env->md_env.matrix_type,
					cv_env->md_env.matrix,
					&ptr_geom ),
			senderid = NULL_OBJID,
			targetid = cv->objid,
			targetos = cv->osnum );
	as$status( sts = sts, action = RET_STATUS );
	cv_geom = (struct IGRbsp_curve *) ptr_geom;

	mid = (parm[0].u + parm[1].u) / 2;
	sts = BSarclen( &bs_rc, &stat, cv_geom, &parm[0].u, &parm[1].u, 
								&mid, length );
	if( bs_rc != BSSUCC ){ printf(" error arclen \n");
			*msg = MSFAIL; return 0; }

	else *msg = MSSUCC;

return	1;
}

/* *********************** FCT VLfillText () ***********************	*/

IGRlong VLfillText( msg, txt, txt_size, index, nb_char, field )

/*d This function fill a text in a row | ..... | */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

IGRlong		*msg;		/*O  return message	*/
IGRchar		*txt;		/*IO full line (row)	*/
IGRint		txt_size;	/*I  max length of test	*/
IGRint		*index;		/*IO working index	*/
IGRint		nb_char;	/*I  max field length	*/
IGRchar		*field;		/*I  field to insert	*/
{
IGRint		length, i;

	if( (*index + nb_char + 1) > txt_size ){ *msg = MSFAIL; return 0; }
	else *msg	= MSSUCC;

	/*c preparation at start row */
	if( field[0] == '\n' ){
		txt[*index] 	= '\033';
		txt[*index+1] 	= '\012';
		txt[*index+2]	= '\0';
		*index  = *index + 2;
		return	1;
	}

	/*c insert field */
	length = strlen( field );
	for( i=0; i<nb_char; i++ )
		if( i < length ){
			if( field[i] >= 'a' && field[i] <= 'z' )
				txt[*index+i] = field[i] - 32;

			else	txt[*index+i] = field[i];
		}
		else 		txt[*index+i] = ' ';

	txt[*index + nb_char] = '|';
	txt[*index + nb_char + 1] = '\0';
	*index = *index + nb_char + 1;

return	1;
}

/* ********************* FCT VLinterPtAlong () *********************	*/

IGRlong VLinterPtAlong (

IGRlong			*msg,		/*O  return message 	*/
struct	GRid		*input1,	/*I  element 1		*/
struct	GRmd_env	*env1,		/*I  env of element 1	*/
struct	GRid		*input2,	/*I  element 2		*/
struct	GRmd_env	*env2,		/*I  env of element 2	*/
IGRshort		inter_way,	/*I  algorithm selector for intersection */
struct	GRmd_env	*out_env,	/*I  out environment 		 */
IGRdouble		*direct,	/*I  direction of pt along	 */
IGRdouble		*dist,		/*I  distance along curve 2	 */
IGRdouble		*pt_int,	/*O  coordonne of inter point	 */
IGRdouble		*pt_on,		/*O  coordonne of pt along	 */
IGRdouble		*dev )		/*O  first derivative a pt along */

/*d This function evaluate the intersection point between 2 curves and place
	a point along curve 2 at given distance in a given way */

/*h 01/12/92 : created by Ludovic LE CORVEC (ISDC) */

{
IGRlong			sts, loc_msg, no_msg;
BSrc			bs_rc;
struct	GRid		inter;
struct	IGRbsp_curve	*bs_cv;
IGRint			size;
IGRint			i;
IGRdouble		res_vec[3];
IGRdouble		dir_sol[3];
IGRdouble		res;
IGRshort		nb_int, nb_par;
IGRdouble		*pars, mdist, *intpars;
IGRint			size_buf;
IGRdouble		activ_cht;
IGRdouble		cv_eval[6];
IGRdouble		fact;
struct	GRobj_env	cv2_ov;


	// Initialization
	*msg		= MSSUCC;
	bs_cv		= NULL;
	inter.objid	= NULL_OBJID;
	pars		= NULL;
	intpars		= NULL;
	activ_cht	= 0.;
	cv2_ov.obj_id	= *input2;
	cv2_ov.mod_env	= *env2;

	if( inter_way == 2 )
		sts = VLcreatePtInter( &loc_msg, input2, env2, input1, env1,
							&inter, out_env );

	else	sts = VLcreatePtInter( &loc_msg, input1, env1, input2, env2,
							&inter, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter, out_env, pt_int );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get bs geom of cv 2
	VLgetGeometry( &cv2_ov, (IGRboolean) FALSE, NULL_OBJID,
			(IGRchar **) &bs_cv, &loc_msg );
	if( ! (loc_msg&1) ){
		printf(" Error not enougth memory to allocate bs_cv\n");
		loc_msg	= MSFAIL;
		goto	wrapup;
	}

	// get cht
	size_buf = sizeof( IGRdouble );
	gr$get_chord_height_tolerance(	msg 	= &loc_msg,
					sizbuf	= &size_buf,
					buffer	= &activ_cht,
					nret	= &size );
	activ_cht *= 10;

	// check distance between point intersection and cv 
	BSmdistptcv( bs_cv, pt_int, &nb_int, &nb_par, &pars, 
						&mdist, &intpars, &bs_rc );
	if( bs_rc != BSSUCC || mdist > activ_cht )
		{ loc_msg = MSFAIL; goto wrapup; }

	// get first derivative 
	BScveval( bs_cv, pars[0], 1, (IGRpoint *)cv_eval, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }
	BSnorvec( &bs_rc, &cv_eval[3] );
	if( direct ){

		res = BSdotp( &bs_rc, direct, &cv_eval[3] );
		if( res > 0. )	fact = (*dist) * 0.05;
		else		fact = (*dist) * 0.05 * (-1);

	} else	fact = (*dist) * 0.05;

	for( i=0; i<3; i++ ) dir_sol[i] = pt_int[i] + (cv_eval[3+i] * fact);

	BSptsdlcv( &bs_rc, bs_cv, &pars[0], dir_sol, dist, pt_on );
	if( bs_rc != BSSUCC ) { loc_msg = MSFAIL; goto wrapup; }

	// check if pt is in rigth way
	for( i=0; i<3; i++ ) res_vec[i] = pt_on[i] - pt_int[i];

	res = BSdotp( &bs_rc, direct, res_vec );
	if( bs_rc != BSSUCC || res < 0. )
		{ loc_msg = MSFAIL; goto wrapup; }

	// check distance pt_along and curve
	BSmdistptcv( bs_cv, pt_on, &nb_int, &nb_par, &pars, &mdist, 
							&intpars, &bs_rc );
	if( bs_rc != BSSUCC || mdist > activ_cht )
		{ loc_msg = MSFAIL; goto wrapup; }

	// get exact position on cv
	BScveval( bs_cv, pars[0], 1, (IGRpoint *)cv_eval, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }
	for( i=0; i<3; i++ )	pt_on[i] = cv_eval[i];

	// check derivative direction
	res = BSdotp( &bs_rc, direct, &cv_eval[3] );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

	if( res < 0. )	for( i=0; i<3; i++ )	dev[i] = (-1) * cv_eval[3+i];
	else		for( i=0; i<3; i++ )	dev[i] = cv_eval[3+i];

wrapup :

	if( bs_cv != NULL )	free( bs_cv );
	if( pars != NULL )	free( pars );
	if( intpars != NULL )	free( intpars );
	if( ! (loc_msg & 1))	*msg	 = MSFAIL;

	sts = om$send(	msg	 = message GRgraphics.GRdelete
					( &no_msg, out_env ),
			senderid = NULL_OBJID,
			targetid = inter.objid,
			targetos = inter.osnum );

return	*msg;
}

IGRlong		VLcreateMultipleInter(	IGRlong			*msg,
					IGRint			num_pl,
					struct GRobj_env	*pltOE,
					IGRchar			*side,
					struct GRobj_env	*surface,
					struct GRvg_construct	*cst,
					IGRboolean		trim,
					struct GRid		*crvID )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, j, nint=0, nvtx=0, ncmp, num_inter=0;
IGRdouble		cht, bastol, xpt[6], *Vrtx=NULL;
IGRboolean              adj, clo;
IGRpoint		spt1, spt2, ept1, ept2;
IGRshort                *inv=NULL;
struct GRid		SrfID, inters[100];
struct GRobj_env        footOE, *Icrv=NULL, *Ocrv=NULL;
struct GRlc_info        *Entr=NULL;
struct IGRpolyline      geom;

   SetProc( VLcreateMultipleInter ); Begin

   if( !num_pl || !pltOE || !side || !surface || !cst || !crvID )
	return OM_E_INVARG;

   __DBGpr_int("Number of Input Plates ", num_pl );
   __DBGpr_str("Plate Side ", side );
   __DBGpr_obj("Intersecting Surface/Plane ", surface->obj_id );

   if( !( Icrv = _MALLOC( 2*num_pl, struct GRobj_env ) ) ) vd_$mem_fail();
   nint=0;
   for( i=0; i<num_pl; ++i )
   {
      __DBGpr_obj("Plate ", pltOE[i].obj_id );
      Icrv[nint].mod_env      = *(cst->env_info) ;

      vdobj$GetFoot( objOE     = &pltOE[i],
                     footName  = side,
                     footOE    = &footOE );

      vd_$grCopy( msg   = msg,
                  frEnv = &footOE.mod_env,
                  frObj = &footOE.obj_id,
                  toEnv = cst->env_info,
                  toObj = &SrfID );

      num_inter = 0;
      sts = VLcreateMultiInter2Elem( msg, &SrfID, cst->env_info, trim,
                           &surface->obj_id, &surface->mod_env, trim,
                           &num_inter, inters, &Icrv[nint].mod_env );
      vd_$bulk_delete( grids = &SrfID, theEnv = cst->env_info );
      if( !(sts&1&(*msg)) ) continue;
      for( j=0; j<num_inter; ++j )
      {
	 Icrv[nint+j].obj_id  = inters[j];
	 Icrv[nint+j].mod_env = *(cst->env_info) ;
      }
      nint += num_inter;
   }

   if( !nint ) { sts = *msg = MSFAIL; goto wrapup; }

   if( !( Ocrv = _MALLOC( 2*nint, struct GRobj_env ) ) ) vd_$mem_fail();
   if( !( inv  = _MALLOC( nint, IGRshort ) ) ) vd_$mem_fail();

   vdgeom$GetTolerance( cht = &cht );
   vdgeom$GetTolerance( basis = &bastol );
   sts = OrderCrv( Icrv, nint, 20.0, bastol, Ocrv, inv, &adj, &clo, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   /* Extract ordered vertices of the future composite curve */
   sts = VLextractVertices( msg, nint, Ocrv, inv, &nvtx, &Vrtx);
   __CheckRC( sts, *msg, "VLextractVertices", wrapup ) ;

   /* Try to close the gap */
   ncmp = nint;
   if( nint > 1 )
   {
       *msg = MSSUCC;
       cst->geometry    = (IGRchar *) &geom;
       geom.num_points = 2;
       for( i=1; i<nint; i++ )
       {
          VLendpts( msg, &Ocrv[i-1].obj_id, &Ocrv[i-1].mod_env, spt1, ept1 );
          if( inv[i-1] == 1 )   dblcpy ( &xpt[0], ept1, 3);
          else                  dblcpy ( &xpt[0], spt1, 3);

          VLendpts( msg, &Ocrv[i].obj_id, &Ocrv[i].mod_env, spt2, ept2 );
          if( inv[i] == 1 )     dblcpy ( &xpt[3], spt2, 3);
          else                  dblcpy ( &xpt[3], ept2, 3);

          if( BSdistptpt( &rc, &xpt[0], &xpt[3] ) > bastol )
          {
             geom.points = (IGRdouble *) xpt;
             Ocrv[ncmp].obj_id.objid = NULL_OBJID;
             Ocrv[ncmp].obj_id.osnum = cst->env_info->md_id.osnum;
             Ocrv[ncmp].mod_env      = *(cst->env_info);

             sts = om$construct( classid = OPP_GR3dlineseg_class_id,
                                 osnum   = Ocrv[ncmp].obj_id.osnum,
                                 p_objid = &Ocrv[ncmp].obj_id.objid,
                                 msg = message GRgraphics.GRaltconstruct(cst));
             __CheckRC( sts, *msg, "GRaltconstruct: GR3dlineseg", wrapup ) ;
             ncmp++;
          }
       }
   }

   sts = OrderCrv( Ocrv, ncmp, 5*cht, bastol, Icrv, inv, &adj, &clo, msg);
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   if( !( Entr = _MALLOC( ncmp, struct GRlc_info ) ) ) vd_$mem_fail();
   for( i=0; i<ncmp; i++ )
   {
        Entr[i].module_info = Icrv[i].mod_env;
        Entr[i].located_obj = Icrv[i].obj_id;
   }

   BuildCrv( 1, Icrv, ncmp, inv, adj, clo, Entr, cst, crvID, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "BuildCrv", wrapup ) ;

wrapup:
   _FREE( Vrtx );
   _FREE( Icrv );
   _FREE( Ocrv );
   _FREE( Entr );
   _FREE( inv  );
   End
   return sts;
}

end implementation VLabstract;

