class implementation VLabstract;

#include <stdio.h>
#include "vlprototype.h"
#include "OMerrordef.h"
#include "godef.h"
#include "msdef.h"
#include "AS_status.h"
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
#include "ciexecmacros.h"
#include "madef.h"
#include "vsgeommacros.h"
#include "EMSmsgdef.h"
#include "bsdistptpt.h"

from	EMSsurface	import	EMgetactiveid;
from	GRlinear	import	GRgetpolyline;

extern	GRclassid	OPP_GR3dpoint_class_id;

/* ********************* FCT VLdevExtLoop () ***********************	*/
VLdevExtLoop( SF, SF_ENV, RDV, RDV_ENV )

struct	GRid		*SF, *RDV;
struct	GRmd_env	*SF_ENV, *RDV_ENV;

{
IGRlong			loc_msg, no_msg;
struct	mise_a_plat	dev;
IGRshort		opt;
IGRdouble		MeshTol;
struct	GRvg_construct	cnst;
IGRint			NumID;
struct	GRobj_env	*ID;
IGRboolean		IsGraGrp;
IGRint			i;


	/*| Initialization */
	VLinitDev(&dev);
	VLinitCnst( &cnst );
	cnst.env_info = RDV_ENV;
	NumID	= 0;
	ID	= NULL;
	MeshTol	= 50;
	opt	= 0;
	dev.type	 = 4;
	dev.developpable = FALSE;

	dev.epaisseur		= 0.;
	dev.surf_id.obj_id	= *SF;
	dev.surf_id.mod_env	= *SF_ENV;
	VLgetGeometry( &dev.surf_id, (IGRboolean) TRUE, NULL_OBJID,
					(IGRchar ** ) &dev.surface, &loc_msg );

	loc_msg = VLgetPtsNorms( &dev, opt, MeshTol );
	if( ! (loc_msg&1))	goto wrapup;

	loc_msg = VLmaplatNDevel( &dev );
	if( ! (loc_msg&1))	goto wrapup;

	loc_msg = VLcreBoundaries( &dev, &cnst, (IGRboolean) FALSE, &IsGraGrp,
				&NumID, &ID );
	if( ! (loc_msg&1))	goto wrapup;

	*RDV	= ID[0].obj_id;

wrapup :

	VLfreeDev( &dev );

	for( i=1; i<NumID && ID; i++ )
		om$send(msg	 = message GRgraphics.GRdelete
					( &no_msg, RDV_ENV ),
			senderid = NULL_OBJID,
			targetid = ID[i].obj_id.objid,
			targetos = ID[i].obj_id.osnum );

	if( ID )	om$dealloc( ptr = ID );

	if( ! (loc_msg&1))	return	MSFAIL;

return	MSSUCC;
}
/* **************** FCT VLextractSurface () *************************	*/

IGRlong VLextractSurface( msg, in_sf, in_env, nb_cv, cv, cv_env, area, 
							out_sf, out_env )

IGRlong			*msg;
struct	GRid		*in_sf;
struct	GRmd_env	*in_env;
IGRint			nb_cv;
struct	GRid		*cv;
struct	GRmd_env	*cv_env;
IGRdouble		*area;
struct	GRid		*out_sf;
struct	GRmd_env	*out_env;

{
IGRlong			sts, loc_msg, no_msg;
IGRint			i;
struct	GRid		act_sf;
struct	GRid		w_surf;
struct	GRid		res_list[2];
struct	GRsymbology	symb;
struct	GRmd_env	id_env;
IGRdouble		pt_proj[3];
struct	GRparms		proj_param;
IGRint			ind_del;
IGRdouble		dist, activ_cht;
IGRint			size, size_buf;
BSrc			rc;
IGRdouble		pt_on[3];


	// place ci_macro
	*msg		= MSSUCC;
	out_sf->objid	= NULL_OBJID;
	id_env.md_env.matrix_type	= MAIDMX;
	MAidmx( &loc_msg, id_env.md_env.matrix );
	id_env.md_id	= out_env->md_id;

	if( in_sf->objid == NULL_OBJID ){ loc_msg = MSFAIL; goto wrapup; }

	act_sf = *in_sf;

	// get working surface
	sts = om$send(	msg	 = message GRgraphics.GRcopy(
					&loc_msg,
					in_env,
					out_env,
					&w_surf.objid ),
			senderid = NULL_OBJID,
			targetid = act_sf.objid,
			targetos = act_sf.osnum );
	as$status( sts = sts );
	if( ! (sts & loc_msg & 1)){ loc_msg = MSFAIL; goto wrapup; }
	w_surf.osnum	= out_env->md_id.osnum;

	// set symbology
	sts = om$send(	msg	 = message GRvg.GRgetsymb( &loc_msg, &symb ),
			senderid = NULL_OBJID,
			targetid = w_surf.objid,
			targetos = w_surf.osnum );
	if( ! (sts & loc_msg & 1)){ loc_msg = MSFAIL; goto wrapup; }

	// project area on w_surface
	sts = om$send(	msg	 = message GRgraphics.GRptproject(
						&loc_msg,
						&in_env->md_env.matrix_type,
						in_env->md_env.matrix,
						area,
						pt_proj,
						&proj_param ),
			senderid = NULL_OBJID,
			targetid = w_surf.objid,
			targetos = w_surf.osnum );
	as$status( sts = sts );

	// get cht 
	size_buf = sizeof( IGRdouble );
	gr$get_chord_height_tolerance(	msg 	= &loc_msg,
					sizbuf	= &size_buf,
					buffer	= &activ_cht,
					nret	= &size );

	for( i=0; i<nb_cv; i++ ){

		// split w_surf
		sts = vs$split_surface_with_curve(
					msg	= &loc_msg,
					surfId	= &w_surf,
					surfEnv	= out_env,
					curveId	= &cv[i],
					curveEnv	= &cv_env[i],
					resultSymb	= &symb,
					resultList	= res_list );
		/* CORRECTION for LLC by MF */
                if ( (sts&1) && (loc_msg == EMS_E_NoValidBnd) ) loc_msg = 1;

		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		sts = om$send(	msg	 = message GRgraphics.GRptproject(
						&loc_msg,
						&id_env.md_env.matrix_type,
						id_env.md_env.matrix,
						pt_proj,
						pt_on,
						&proj_param ),
				senderid = NULL_OBJID,
				targetid = res_list[0].objid,
				targetos = res_list[0].osnum );
		if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

		dist = BSdistptpt( &rc, pt_proj, pt_on );
		if( rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }
		if( dist > activ_cht )
			{ ind_del = 0; w_surf = res_list[1]; }
		else	{ ind_del = 1; w_surf = res_list[0]; }

		// delete hole part
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
			senderid = NULL_OBJID,
			targetid = res_list[ind_del].objid,
			targetos = res_list[ind_del].osnum );
	}

wrapup :

	if( ! (loc_msg&1)){ *msg = MSFAIL; return *msg; }

	*out_sf = w_surf;

return	*msg;
}

/* *********************** FCT VLplPt () ****************************	*/

IGRlong	VLplPt( msg, pt, pt_id, md_env )


IGRlong			*msg;
IGRdouble		*pt;
struct	GRid		*pt_id;
struct	GRmd_env	*md_env;

{
IGRlong			sts, loc_msg;
struct	GRvg_construct	cnst;
struct	IGRpolyline	lstr_geom;

	*msg	= MSSUCC;

	VLinitCnst( &cnst );
	cnst.env_info	= md_env;
        cnst.properties = cnst.properties & ~(GRIS_DISPLAYABLE|GRIS_LOCATABLE);
	pt_id->objid	= NULL_OBJID;
	pt_id->osnum	= md_env->md_id.osnum;
	cnst.geometry	= (IGRchar *) &lstr_geom;
	
	sts = om$construct(	classid	= OPP_GR3dpoint_class_id,
				osnum	= pt_id->osnum,
				p_objid	= &pt_id->objid );
	if( sts & 1 ){
		lstr_geom.num_points	= 1;
		lstr_geom.points	= pt;
		sts = om$send(	msg	 = message GRgraphics.GRaltconstruct
						( &cnst ),
				senderid = NULL_OBJID,
				targetid = pt_id->objid,
				targetos = pt_id->osnum );
	}

	if( ! (sts&1)){

		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &loc_msg, md_env ),
				senderid = NULL_OBJID,
				targetid = pt_id->objid,
				targetos = pt_id->osnum );
		pt_id->objid = NULL_OBJID;
		*msg	= MSFAIL;
	}

return	*msg;
}

/* ******************* FCT VLgetPtCoord () *************************	*/

IGRlong VLgetPtCoord( msg, pt_id, loc_env, coord )

/*d fill in 3 doubles the coordinate of point */

/*h 26/02/93 :	Creation Date 	MOI JE (ISDC) */

IGRlong			*msg;		/*O return message		*/
struct	GRid		pt_id;		/*I id of the point		*/
struct	GRmd_env	*loc_env;	/*I environment of point	*/
IGRdouble		*coord;		/*O point coordinate 		*/

{
IGRlong			sts;
struct	IGRpolyline	polyline;
IGRint			action;

	/* initialisation */
	action  = 1;
	polyline.points = coord;

	sts = om$send(	msg	 = message GRlinear.GRgetpolyline(
					msg,
					&loc_env->md_env.matrix_type,
					loc_env->md_env.matrix,
					&action,
					&polyline ),
			senderid = NULL_OBJID,
			targetid = pt_id.objid,
			targetos = pt_id.osnum );

return	sts;
}

/* ******************** FCT VLgetPtOnCvInInter () ***************	*/
/* get coordinate of pt on restricted part of curve */

IGRlong	VLgetPtOnCvInInter (		IGRlong	  *msg,
				  struct	GRid	  *cv_base,
				  struct	GRmd_env  *b_env,
				  struct	GRid	  *cv_1,
				  struct	GRmd_env  *env_1,
				  struct	GRid	  *cv_2,
				  struct	GRmd_env  *env_2,
				  		IGRshort  int_way,
				  struct	GRmd_env  *out_env,
				  		IGRdouble par_in_int,
						IGRdouble *pt_on  )
{
IGRlong			loc_msg, sts, no_msg;
struct	GRid		inter1, inter2;
IGRdouble		pt_int1[3], pt_int2[3];
struct	GRobj_env	base_ov;
struct	IGRbsp_curve	*base_geom;
IGRshort		nb_int1, nb_pars1, nb_int2, nb_pars2;
IGRdouble		*pars1, *intpars1, *pars2, *intpars2, mdist;
IGRdouble		b_par;
BSrc			bs_rc;

	/*| initialization */
	base_geom	= NULL;
	pars1		= NULL;
	intpars1	= NULL;
	pars2		= NULL;
	intpars2	= NULL;
	inter1.objid	= NULL_OBJID;
	inter2.objid	= NULL_OBJID;

	// create first pt inter
	if( int_way == 2 )
		sts = VLcreatePtInter( &loc_msg, cv_1, env_1, 
					cv_base, b_env, &inter1, out_env );
	else 
		sts = VLcreatePtInter( &loc_msg, cv_base, b_env,
					cv_1, env_1, &inter1, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter1, out_env, pt_int1 );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// create second pt inter
	if( int_way == 2 )
		sts = VLcreatePtInter( &loc_msg, cv_2, env_2,
					cv_base, b_env, &inter2, out_env );
	else 
		sts = VLcreatePtInter( &loc_msg, cv_base, b_env,
					cv_2, env_2, &inter2, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter2, out_env, pt_int2 );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get parameter of pt inter on base cv
	base_ov.obj_id  = *cv_base;
	base_ov.mod_env = *b_env;
	VLgetGeometry( &base_ov, FALSE, NULL_OBJID, (IGRchar **) &base_geom,
			&loc_msg );
	if( ! (loc_msg&1))	goto wrapup;

	BSmdistptcv( base_geom, pt_int1, &nb_int1, &nb_pars1, &pars1, 
						&mdist, &intpars1, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

	BSmdistptcv( base_geom, pt_int2, &nb_int2, &nb_pars2, &pars2, 
						&mdist, &intpars2, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

	b_par = pars1[0] + ((pars2[0] - pars1[0]) * par_in_int);

	BScveval( base_geom, b_par, 0, pt_on, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }
	
	loc_msg	= MSSUCC;

wrapup :

	/*| free memory */
	if( pars1 )	free( pars1 );
	if( intpars1 )	free( intpars1 );
	if( pars2 )	free( pars2 );
	if( intpars2 )	free( intpars2 );
	if( base_geom )	free( base_geom );

	if( inter1.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
				senderid = NULL_OBJID,
				targetid = inter1.objid,
				targetos = inter1.osnum );

	if( inter2.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
				senderid = NULL_OBJID,
				targetid = inter2.objid,
				targetos = inter2.osnum );

	if( !(loc_msg&1))	*msg	= MSFAIL;
	else			*msg	= MSSUCC;

return	*msg;
}

/* ******************* FCT VLgetPtsOnPartAtPars () **************	*/
/* get points and tangent on restricted part of curve at given parameters */

IGRlong	VLgetPtsOnPartAtPars (		IGRlong	  *msg,
				    struct	GRid	  *cv_base,
				    struct	GRmd_env  *b_env,
				    struct	GRid	  *cv_1,
				    struct	GRmd_env  *env_1,
				    struct	GRid	  *cv_2,
				    struct	GRmd_env  *env_2,
				  		IGRshort  int_way,
				    struct	GRmd_env  *out_env,
				  		IGRdouble nb_par,
				  		IGRdouble *pars,
						IGRdouble *pt_on,
						IGRdouble *tang )
{
IGRlong			loc_msg, sts, no_msg;
struct	GRid		inter1, inter2;
IGRdouble		pt_int1[3], pt_int2[3];
struct	GRobj_env	base_ov;
struct	IGRbsp_curve	*base_geom;
IGRshort		nb_int1, nb_pars1, nb_int2, nb_pars2;
IGRdouble		*pars1, *intpars1, *pars2, *intpars2, mdist;
IGRdouble		b_par;
IGRint			i, k;
BSrc			bs_rc;
IGRint			nb_deriv;
IGRdouble		eval[6];

	/*| initialization */
	base_geom	= NULL;
	pars1		= NULL;
	intpars1	= NULL;
	pars2		= NULL;
	intpars2	= NULL;
	inter1.objid	= NULL_OBJID;
	inter2.objid	= NULL_OBJID;

	// create first pt inter
	if( int_way == 2 )
		sts = VLcreatePtInter( &loc_msg, cv_1, env_1, 
					cv_base, b_env, &inter1, out_env );
	else 
		sts = VLcreatePtInter( &loc_msg, cv_base, b_env,
					cv_1, env_1, &inter1, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter1, out_env, pt_int1 );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// create second pt inter
	if( int_way == 2 )
		sts = VLcreatePtInter( &loc_msg, cv_2, env_2,
					cv_base, b_env, &inter2, out_env );
	else 
		sts = VLcreatePtInter( &loc_msg, cv_base, b_env,
					cv_2, env_2, &inter2, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter2, out_env, pt_int2 );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get parameter of pt inter on base cv
	base_ov.obj_id  = *cv_base;
	base_ov.mod_env = *b_env;
	VLgetGeometry( &base_ov, FALSE, NULL_OBJID, (IGRchar **) &base_geom,
			&loc_msg );
	if( ! (loc_msg&1))	goto wrapup;

	BSmdistptcv( base_geom, pt_int1, &nb_int1, &nb_pars1, &pars1, 
						&mdist, &intpars1, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

	BSmdistptcv( base_geom, pt_int2, &nb_int2, &nb_pars2, &pars2, 
						&mdist, &intpars2, &bs_rc );
	if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

	if( tang )	nb_deriv = 1;
	else		nb_deriv = 0;

	for( i=0; i<nb_par; i++ ){

		b_par = pars1[0] + ((pars2[0] - pars1[0]) * pars[i]);

		BScveval( base_geom, b_par, nb_deriv, eval, &bs_rc );
		if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

		if( pt_on ) for( k=0; k<3; k++) pt_on[(i*3)+k] = eval[k];
		if( tang )  for( k=0; k<3; k++) tang[(i*3)+k] = eval[3+k];
	}

	loc_msg	= MSSUCC;

wrapup :

	/*| free memory */
	if( pars1 )	free( pars1 );
	if( intpars1 )	free( intpars1 );
	if( pars2 )	free( pars2 );
	if( intpars2 )	free( intpars2 );
	if( base_geom )	free( base_geom );

	if( inter1.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
				senderid = NULL_OBJID,
				targetid = inter1.objid,
				targetos = inter1.osnum );

	if( inter2.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
				senderid = NULL_OBJID,
				targetid = inter2.objid,
				targetos = inter2.osnum );

	if( !(loc_msg&1))	*msg	= MSFAIL;
	else			*msg	= MSSUCC;

return	*msg;
}

/* ******************* FCT VLgetPtsOnPartAtParsLen () **********	*/
/* get points and tangent on restricted part of curve at given parameters */

IGRlong	VLgetPtsOnPartAtParsLen (	IGRlong	  *msg,
					struct	GRid	  *cv_base,
					struct	GRmd_env  *b_env,
					struct	GRid	  *cv_1,
					struct	GRmd_env  *env_1,
					struct	GRid	  *cv_2,
					struct	GRmd_env  *env_2,
						IGRshort  int_way,
					struct	GRmd_env  *out_env,
						IGRint	  nb_par,
						IGRdouble *pars,
						IGRdouble *pt_on,
						IGRdouble *tang )

{
IGRlong			loc_msg, sts, no_msg;
struct	GRid		inter1, inter2;
IGRdouble		pt_int1[3], pt_int2[3];
struct	GRobj_env	base_ov;
struct	IGRbsp_curve	*base_geom;
IGRshort		nb_int1, nb_pars1;
IGRdouble		*pars1, *intpars1, mdist;
IGRint			i, k;
BSrc			bs_rc;
IGRint			nb_deriv;
IGRdouble		eval[6], pt_cal[3], dir_vect[3];

	/*| initialization */
	base_geom	= NULL;
	pars1		= NULL;
	intpars1	= NULL;
	inter1.objid	= NULL_OBJID;
	inter2.objid	= NULL_OBJID;

	// create first pt inter
	if( int_way == 2 )
		sts = VLcreatePtInter( &loc_msg, cv_1, env_1, 
					cv_base, b_env, &inter1, out_env );
	else 
		sts = VLcreatePtInter( &loc_msg, cv_base, b_env,
					cv_1, env_1, &inter1, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter1, out_env, pt_int1 );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// create second pt inter
	if( int_way == 2 )
		sts = VLcreatePtInter( &loc_msg, cv_2, env_2,
					cv_base, b_env, &inter2, out_env );
	else 
		sts = VLcreatePtInter( &loc_msg, cv_base, b_env,
					cv_2, env_2, &inter2, out_env );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	sts = VLgetPtCoord( &loc_msg, inter2, out_env, pt_int2 );
	if( ! (sts&loc_msg&1)){ loc_msg = MSFAIL; goto wrapup; }

	// get parameter of pt inter on base cv
	base_ov.obj_id  = *cv_base;
	base_ov.mod_env = *b_env;
	VLgetGeometry( &base_ov, FALSE, NULL_OBJID, (IGRchar **) &base_geom,
			&loc_msg );
	if( ! (loc_msg&1))	goto wrapup;

	if( tang )	nb_deriv = 1;
	else		nb_deriv = 0;

	BSmkvec( &bs_rc, dir_vect, pt_int1, pt_int2 );

	for( i=0; i<nb_par; i++ ){

		for( k=0; k<3; k++ )
			pt_cal[k] = pt_int1[k] + (dir_vect[k] * pars[i]);

		BSmdistptcv( base_geom, pt_cal, &nb_int1, &nb_pars1, &pars1, 
						&mdist, &intpars1, &bs_rc );

		BScveval( base_geom, pars1[0], nb_deriv, eval, &bs_rc );
		if( bs_rc != BSSUCC ){ loc_msg = MSFAIL; goto wrapup; }

		if( pt_on ) for( k=0; k<3; k++) pt_on[(i*3)+k] = eval[k];
		if( tang )  for( k=0; k<3; k++) tang[(i*3)+k] = eval[3+k];	

	}

	loc_msg	= MSSUCC;

wrapup :

	/*| free memory */
	if( pars1 )	free( pars1 );
	if( intpars1 )	free( intpars1 );
	if( base_geom )	free( base_geom );

	if( inter1.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
				senderid = NULL_OBJID,
				targetid = inter1.objid,
				targetos = inter1.osnum );

	if( inter2.objid != NULL_OBJID )
		sts = om$send(	msg	 = message GRgraphics.GRdelete
						( &no_msg, out_env ),
				senderid = NULL_OBJID,
				targetid = inter2.objid,
				targetos = inter2.osnum );

	if( !(loc_msg&1))	*msg	= MSFAIL;
	else			*msg	= MSSUCC;

return	*msg;
}

end implementation VLabstract;

