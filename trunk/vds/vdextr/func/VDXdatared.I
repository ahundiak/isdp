/* $Id: VDXdatared.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXdatared.I
 *
 * Description:
 *		This function can be called everywehere to extablish
 *		data reduction on generated curves.
 *		This function is used to reduice data of the output
 *		of the visualization process.
 *
 * Revision History:
 *	$Log: VDXdatared.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1999/04/19  13:59:26  pinnacle
# for dynapipe
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 * -------------------------------------------------------------------*/

class implementation GRvg ;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "OMerrordef.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "growner.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "igr.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "v_miscmacros.h"
//#define	vdsDEBUG	1
#include "v_dbgmacros.h"
#include "VDPdef.h"
#include "VDSequipdef.h"
#include "parametric.h"
#include "VDmem.h"
#include "vdparmacros.h"
#include "VDAttribMac.h"
#include "VDToolsDef.h"
#include "v_dbgmacros.h"
#include "ACattrib.h"
#include "PDUerror.h"
#include "vdtree.h"

from EMSsurface	import EMget_params;
from NDmacro	import ACreturn_foot;


/*
 * Includes of function prototype.
 */
#include "bsdta_rdusf.h"
#include "bschangepar.h"
#include "bsxtractpar.h"
#include "bsfreecv.h"

/*----------------------------------------------------------------------------*/
long VDX_ObjDataReduction( msg, redTolerance, elmId, elmEnv )

long			*msg ;		/* O : Return code.		      */
IGRdouble			*redTolerance ;	/* I : Data Red Tolerance Value       */
struct GRid		*elmId ;	/* I/O : Bspline intesection.         */
struct GRmd_env		*elmEnv ; {	/* I : Object Envireonment.	      */

	long			sts,
				bsRC ;
	IGRchar			*bs_char;
	struct IGRbsp_surface	*bs_geom = NULL,
				*red_geom = NULL ;
	IGRint			tanl,
				tanr,
				tant,
				tanb;
	IGRint			option ;
	IGRboolean		erropt ;
	IGRdouble		savTolerance,
				maxerr,
				avgerr,
				uvpar[2],
				auvpar[2] ;
	IGRpoint		pt,
				apt ;
	struct GRpost_info	post_info ;
	GRobjid 		newobjid ;
	struct GRid		myid;
	IGRchar			*VDX_geom;
	IGRlong			size;

	SetProc( VDX_ObjDataReduction ); Begin

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	if( ! elmId ){	sts = MSFAIL ;	goto wrapup ; }
	if( ! elmEnv ){	sts = MSFAIL ;	goto wrapup ; }

	if( redTolerance ){
		BSxtractpar( &bsRC, BSTOLCHRDHT, &savTolerance );
		BSchangepar( &bsRC, BSTOLCHRDHT, *redTolerance );
		__DBGpr_dbl(" redTolerance ", *redTolerance );
	}
	/*
	 * See if bspline big enough to reduice.
	 */

	//printf("input id[%d, %d], mat_type=%d\n", elmId->objid, elmId->osnum,elmEnv->md_env.matrix_type);

	sts = 
	om$send( msg = message GRvg.GRgenabsg(	msg,
					&elmEnv->md_env.matrix_type,
					elmEnv->md_env.matrix,
					(IGRchar **) &bs_geom ),
		targetid = elmId->objid,
		targetos = elmId->osnum,
		senderid = NULL_OBJID );


	if( ! bs_geom ){
		__DBGpr_com( "\tInvalid input geometry" ) ;
		goto wrapup ;
	}

	if( bs_geom->u_num_poles < 100 && bs_geom->v_num_poles < 100 )
	{
		__DBGpr_com(" skipping reduction because it is small enough");
		__DBGpr_int(" u num poles less than 100 ", bs_geom->u_num_poles);
		__DBGpr_int(" v num poles less than 100 ", bs_geom->v_num_poles);
		sts = TRUE;
		goto wrapup;
	}

	/*
	 * Do data reduction.
	 */
	tanl   = 1 ;
	tanr   = 1 ;
	tant   = 1 ;
	tanb   = 1 ;
	option = 2 ;	/* Data reduction in u and v direction */
	erropt = TRUE ;
	myid.objid = elmId->objid;
	myid.osnum = elmId->osnum;
	__DBGpr_int( "\tNumber U Poles ", bs_geom->u_num_poles );
	__DBGpr_int( "\tNumber V Poles ", bs_geom->v_num_poles );
	__DBGpr_int(" genabs msg ",*msg);
	__DBGpr_obj("genabs id ", myid);
	__DBGpr_com("Call BSdta_rdusf ");
	BSdta_rdusf( bs_geom,
		     option,	
		     tanl,
		     tanr,
		     tant,
		     tanb,
		     erropt,
		     &maxerr,
		     &avgerr,
		     uvpar,
		     pt,
		     auvpar,
		     apt,
		     &red_geom,
		     &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_int( "ERROR : Cannot reduice using BSdta_rducv RC",bsRC);
		red_geom = NULL ;
		goto wrapup ;
	}

        __DBGpr_dbl( "Average Error ", avgerr );
        __DBGpr_dbl( "Maximum Error ", maxerr );
	__DBGpr_int( "\tOld Number U Poles ", bs_geom->u_num_poles );
	__DBGpr_int( "\tOld Number V Poles ", bs_geom->v_num_poles );
	__DBGpr_int( "\tNew Number U Poles ", red_geom->u_num_poles );
	__DBGpr_int( "\tNew Number V Poles ", red_geom->v_num_poles );

	/*
	 * Only post when the new result is better. We are checking here 
	 * because the tolerance is put to bastol for precision reasons.
	 */
	if( red_geom->u_num_poles < bs_geom->u_num_poles ||
	    red_geom->v_num_poles < bs_geom->v_num_poles ){

	    post_info.construct_flag = FALSE ;
	    sts = 
	    om$send(msg = message GRvg.GRpostabsg(msg,
						elmEnv,
						&post_info,
						(IGRchar *) red_geom,
						&newobjid ),
		    targetid = elmId->objid,
		    targetos = elmId->osnum,
		    senderid = NULL_OBJID );
	    if( !(sts&*msg&1)){
		/*
		 * We re-address the previous geometry info.
		 */
		__DBGpr_com(" Error in Posting New Geometry ");
	    }
	}

	wrapup :
/*
		if( bs_geom ){
			 __DBGpr_com("about to free bs_geom");
			 BSfreesf( &bsRC, bs_geom ) ;
		}

		if( red_geom ){
			 __DBGpr_com("about to free red_geom");
			 BSfreesf( &bsRC, red_geom ) ;
		}
		if( redTolerance ){
			__DBGpr_com("about to BSchangpar");
			BSchangepar( &bsRC, BSTOLCHRDHT, savTolerance );
		}
*/
		End 
		return sts ;

} /* VDX_ObjDataReduction */
/*----------------------------------------------------------------------------*/
long VDX_sfDataReduction( msg, redTolerance, inGeom, outGeom )

long			*msg ;		/* O : Return code.		      */
IGRdouble			*redTolerance ;	/* I : Data Red Tolerance Value       */
struct IGRbsp_surface	*inGeom ;	/* I/O : Bspline intesection.         */
struct IGRbsp_surface	**outGeom ; {	/* I : Output Geometry 		      */

	long			sts,
				bsRC ;
	struct IGRbsp_surface	*bs_geom = NULL,
				*red_geom = NULL ;
	IGRint			tanl,
				tanr,
				tant,
				tanb;
	IGRint			option ;
	IGRboolean		erropt ;
	IGRdouble		savTolerance,
				maxerr,
				avgerr,
				uvpar[2],
				auvpar[2] ;
	IGRpoint		pt,
				apt ;

	SetProc( VDX_sfDataReduction ); Begin

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	if( redTolerance ){
		BSxtractpar( &bsRC, BSTOLCHRDHT, &savTolerance );
		BSchangepar( &bsRC, BSTOLCHRDHT, *redTolerance );
		__DBGpr_dbl(" redTolerance ", *redTolerance );
	}

	if( ! inGeom ){
		__DBGpr_com( "\tInvalid input geometry" ) ;
		*msg = MSFAIL ;
		goto wrapup ;
	}

	*outGeom = NULL ;

	/*
	 * Do data reduction.
	 */
	tanl   = 1 ;
	tanr   = 1 ;
	tant   = 1 ;
	tanb   = 1 ;
	option = 2 ;	/* Data reduction in u and v direction */
	erropt = TRUE ;

	BSdta_rdusf( inGeom,
		     option,	
		     tanl,
		     tanr,
		     tant,
		     tanb,
		     erropt,
		     &maxerr,
		     &avgerr,
		     uvpar,
		     pt,
		     auvpar,
		     apt,
		     &red_geom,
		     &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		__DBGpr_com( "ERROR : Cannot reduice using BSdta_rducv" ) ;
		*msg = MSFAIL ;
		goto wrapup ;
	}

        __DBGpr_dbl( "Average Error ", avgerr );
        __DBGpr_dbl( "Maximum Error ", maxerr );
	__DBGpr_int( "\tOld Number U Poles ", bs_geom->u_num_poles );
	__DBGpr_int( "\tOld Number V Poles ", bs_geom->v_num_poles );
	__DBGpr_int( "\tNew Number U Poles ", red_geom->u_num_poles );
	__DBGpr_int( "\tNew Number V Poles ", red_geom->v_num_poles );

	/*
	 * Only post when the new result is better. We are checking here 
	 * because the tolerance is put to bastol for precision reasons.
	 */
	if( red_geom->u_num_poles < bs_geom->u_num_poles ||
	    red_geom->v_num_poles < bs_geom->v_num_poles ){

	   *outGeom = red_geom ;
	   red_geom = NULL ;
	   *msg = MSSUCC ;
	   sts	= OM_S_SUCCESS ;
	}

	wrapup :

//		if( red_geom ) BSfreesf( &bsRC, red_geom ) ;

		if( redTolerance ){
			BSchangepar( &bsRC, BSTOLCHRDHT, savTolerance );
		}

		End 
		return sts ;

} /* VDX_sfDataReduction */

/*----------------------------------------------------------------------------*/

IGRint check_linear( p1, p2, p3, tol)
IGRdouble p1[3], p2[3], p3[3], tol;
{
IGRdouble 	t1[3], t2[3], t3[3];
IGRint		i = 0;
IGRdouble	l1=0.0, l2=0.0, l3=0.0, l4=0.0;
IGRint		msg;

	SetProc( check_linear ); Begin

	/* sub p1 from p2 and p3 */
	for(i=0; i<3; i=i+1)
	{
		t1[i] = p2[i] - p1[i];
		t2[i] = p3[i] - p1[i];
		l1 = l1 + (t1[i] * t1[i]);
		l2 = l2 + (t2[i] * t2[i]);
	}

	/* get the lengths of the two vectors */
	l3 = sqrt( l1 );
 	l4 = sqrt( l2 );
/*
	printf("l1[%.3f], l2[%.3f]\n",l1,l2);
	printf("l3[%.3f], l4[%.3f]\n",l3,l4);
	printf("t1[%.3f, %.3f, %.3f]\nt2[%.3f, %.3f, %.3f]\n",t1[0], t1[1], t1[2],t2[0], t2[1], t2[2]);
*/

	/* make unit vectors out of the 2*/
	for(i=0;i<3;i=i+1)
	{
		t1[i] = t1[i] / l3;
		t2[i] = t2[i] / l4;
	}

	//printf("t1[%.3f, %.3f, %.3f]\nt2[%.3f, %.3f, %.3f]\n",t1[0], t1[1], t1[2],t2[0], t2[1], t2[2]);

	/*check to see if the 2 are equal */
	if ( 	fabs(t1[0]) - tol < fabs(t2[0]) && fabs(t1[0]) + tol > fabs(t2[0]) &&
		fabs(t1[1]) - tol < fabs(t2[1]) && fabs(t1[1]) + tol > fabs(t2[1]) &&
		fabs(t1[2]) - tol < fabs(t2[2]) && fabs(t1[2]) + tol > fabs(t2[2]) ) msg = TRUE;
	else msg = FALSE;
wrapup:

	End
	return msg;
}



IGRint check_type(id, mod_env, st, en, tol)
IGRdouble	st, en, tol;
struct GRid	*id;
struct GRmd_env	mod_env;
{

IGRdouble	points[15], uval[10];
IGRint		count, msg, sts, i;
IGRlong		lmsg;
IGRdouble	rad= 0.0, rad1=0.0, cen[3], sweep = 0.0, matrix[16];
IGRdouble	inc = 0;
IGRint		irad = 0.0, irad1 = 0.0;

	SetProc( check_type ); Begin

	count = 10;

	inc = (en-st)/((count/2.0)-1.0);

	//printf("start[%.3f], end[%.3f], inc[%.3f]\n",st,en, inc);

	for( i=0; i<count; i=i+2)
	{
		uval[i] = 0;
		uval[i+1] = st + ( inc * (i/2.0) );
		//printf("params[%d]=%.3f, %.3f\n",i/2+1, uval[i], uval[i+1]);
	}

	sts = om$send (msg = message GRvg.EMptatpr (
		&lmsg, 
		&mod_env.md_env.matrix_type,
		mod_env.md_env.matrix, 
		uval, 
		count, 
		points),
		senderid = NULL_OBJID,
		targetid = id->objid,
		targetos = id->osnum);

	if( !(sts & lmsg & 1)){
		__DBGpr_com(" Error in GRvg.EMptatpr ");
		msg = -1;
		goto wrapup;
	}

	//printf("ptatpr msg=%d, id[%d, %d], tol[%.3f]\n",lmsg, id->objid, id->osnum, tol);

	sweep = 0;

	if( check_linear( &points[0], &points[6], &points[12], tol) == FALSE)
	{
		msg = VDXradius1 (&points[0], &points[3], &points[6], &points[9],
		     		  &rad, cen, matrix, &sweep);
		//printf("VDXradius1 msg=%d, rad=%.3f, sweep=%.3f\n", msg, rad, sweep);

		if (msg < 0) goto wrapup;
	}

	sweep = 0;

	if( check_linear( &points[0], &points[3], &points[12], tol) == FALSE)
	{
		msg = VDXradius1 (&points[0], &points[3], &points[6], &points[12],
		     		  &rad1, cen, matrix, &sweep);

		if (msg < 0) goto wrapup;

		irad = rad / tol;
		irad1 = rad1 / tol;

		if( rad + tol > rad1 && rad - tol < rad1 ){
			msg = 1;
			//printf("we have a radius[%.5f], %d, %d\n",rad, irad, irad1);
		}

	}
	else
	{
		//printf("points are linear\n");
		msg = 2;
	}
wrapup:
	End
	return msg;
}


IGRint check_v_geom(tempSurf, MOD_ENV, count, types, params, tol)
struct GRid	tempSurf;
struct GRmd_env MOD_ENV;
IGRint		*types;
IGRint		*count;
IGRdouble 	tol;
IGRdouble	*params;
{
IGRint		msg, sts;
IGRlong		lmsg;
IGRdouble	prev_knot;
IGRdouble	start_knot;
IGRint		stat, i;
IGRlong                  size_of_surface;
struct IGRbsp_surface   *bsps;
IGRchar                 *geom;

	SetProc( check_v_geom ); Begin

	bsps = NULL;
	geom = NULL;

	sts = 
	om$send( msg = message GRvg.GRgenabsg(	&lmsg,
					&MOD_ENV.md_env.matrix_type,
					MOD_ENV.md_env.matrix,
					(IGRchar **) &bsps ),
		senderid = NULL_OBJID,
                targetid = tempSurf.objid,
                targetos = tempSurf.osnum );

	if( ! bsps ){
		__DBGpr_com( "\tInvalid input geometry" ) ;
		msg = -1;
		goto wrapup ;
	}

	/* check the v direction for pieces and types */
	prev_knot = -1;
	start_knot = 0;
	*count = 0;
	if( bsps->v_non_uniform == 1 )
	{
		//printf("v num knots=%d\n",bsps->v_num_knots);
		params[0] = 0.0;
		for(i=bsps->v_order-1;i<bsps->v_num_knots-(bsps->v_order-2); i=i+1)
		{
			if(prev_knot == bsps->v_knots[i])
			{			
				msg = check_type(&tempSurf, MOD_ENV, start_knot, bsps->v_knots[i], tol);
				if ( msg == FALSE){
					__DBGpr_com(" Error in check_type");
					goto wrapup;
				}
				start_knot = bsps->v_knots[i];
				params[*count+1] = bsps->v_knots[i];
				types[*count] = msg;
				*count = *count + 1;
			}
			prev_knot = bsps->v_knots[i];
		}
	}
	else
	{
		msg = check_type(&tempSurf, MOD_ENV, start_knot, 1.0, tol);

		if ( msg == FALSE){
			__DBGpr_com(" Error in check_type");
			msg = -1;
			goto wrapup;
		}

		params[0] = 0.0;
		params[1] = 1.0;

		start_knot = bsps->v_knots[i];
		types[*count] = msg;
		*count = *count + 1;
	}
	msg = TRUE;

wrapup:

/*	if( bsps ){
		__DBGpr_com("about to free bsps");
		BSfreesf( &lmsg, bsps ) ;
		bsps = NULL;
	}
*/
	End

	return msg;
}



/* place a circular projection or a revolution */
IGRint PlaceCirRevOrPro(in_obj, stparam, enparam, 
			type, VDXnum_pnts, VDX_types, 
			VDXpnts, VDXmod_env)
struct GRid	in_obj;
IGRdouble stparam, enparam;
IGRint	type;
IGRint	*VDXnum_pnts;
IGRint	*VDX_types;
IGRdouble	*VDXpnts;
struct GRmd_env	VDXmod_env;

{
IGRint	i, msg, m, sts;
IGRdouble 	uval[100], 
		rad1, 
		cen1[3],
		rad2, 
		cen2[3], 
		matrix[16], 
		sweep;
IGRlong		lmsg;

	SetProc( PlaceCirRevOrPro ); Begin

      /* get the rotation arc information */

      	VDXnum_pnts[0] = 4;
	VDXnum_pnts[1] = 4;
	VDX_types[0] = 1;
	VDX_types[1] = 1;

	if ( type == 1 ) /* we have an arc path*/ 
	{
		VDXnum_pnts[2] = 4;
		VDXnum_pnts[3] = 4;
		VDX_types[2] = 1;
		VDX_types[3] = 1;
     		VDX_types[4] = 8;	/* surface of revolution */
	}
	else /* we have a linear path */
	{
		VDXnum_pnts[2] = 2;
		VDXnum_pnts[3] = 2;
		VDX_types[2] = 0;
		VDX_types[3] = 0;
		VDX_types[4] = 0;	/* surface of projection */
	}


	/* get the profiles for the surface */
	for(i=0;i<4;i=i+1)
	{
	 	uval[i*2+1] = stparam;
		uval[i*2+9] = enparam;
		uval[i*2+0] = i*1.0/3.0;
		uval[i*2+8] = i*1.0/3.0;
	}

	sts = om$send (msg = message GRvg.EMptatpr (
		&lmsg, &VDXmod_env.md_env.matrix_type,
		VDXmod_env.md_env.matrix, uval, 16, &VDXpnts[0]),
		senderid = NULL_OBJID,
		targetid = in_obj.objid,
		targetos = in_obj.osnum);

	if( !(sts&lmsg&1)){
		__DBGpr_com(" Error in GRvg.EMptatpr1 ");
		__DBGpr_obj(" id ", in_obj);
		msg = -1;
		goto wrapup;
	}

	m=24;
	
	if( type == 1 ) /* we have an arc path*/ 
	{
		/* get the profiles for the surface */
		for(i=0;i<4;i=i+1)
		{
	 		uval[i*2+0] = 0.0;
			uval[i*2+8] = 1.0;
			uval[i*2+1] = (i*( (enparam-stparam) /3.0) )+stparam;
			uval[i*2+9] = (i*( (enparam-stparam) /3.0) )+stparam;
		}

		/*
		for(i=0;i<8;i=i+1)
		{
	 		printf("uv %d=[%.3f, %.3f]\n", i, uval[i*2], uval[i*2+1]);
		}
		*/

		sts=om$send (msg = message GRvg.EMptatpr (
			&lmsg, &VDXmod_env.md_env.matrix_type,
			VDXmod_env.md_env.matrix, uval, 16, &VDXpnts[m]),
			senderid = NULL_OBJID,
			targetid = in_obj.objid,
			targetos = in_obj.osnum);

		if( !(sts&lmsg&1)){
			__DBGpr_com(" Error in GRvg.EMptatpr2 ");
			__DBGpr_obj(" id ", in_obj);
			msg = -1;
			goto wrapup;
		}

		__DBGpr_com (" Call VDXradius1 #4_1 ");
		msg = VDXradius1 (&VDXpnts[m + 0], &VDXpnts[m + 3], &VDXpnts[m + 6],
			&VDXpnts[m + 9], &rad1, cen1, matrix, &sweep);
		__DBGpr_int (" VDXradius1 #4_1 ", msg );
		if (msg < 0) goto wrapup;

		__DBGpr_com (" Call VDXradius1 #5 ");
		msg = VDXradius1 (&VDXpnts[m + 12], &VDXpnts[m + 15], &VDXpnts[m + 18],
			&VDXpnts[m + 21], &rad2, cen2, matrix, &sweep);
		__DBGpr_int (" VDXradius1 #5 ", msg );
		if (msg < 0) goto wrapup;

		/*
		__DBGpr_dbl("profile rad1 ", rad1 );
		__DBGpr_dbl("profile rad2 ", rad2 );
		__DBGpr_vec("center #1 ", cen1 );
		__DBGpr_vec("center #2 ", cen2 );
		*/
		msg = TRUE;
	}
	else
	{
		/* set up the projection here */
		/* get the profiles for the surface */
		for(i=0;i<2;i=i+1)
		{
	 		uval[i*2+0] = 0.0;
			uval[i*2+4] = 1.0;
			uval[i*2+1] = (i*(enparam-stparam))+stparam;
			uval[i*2+5] = (i*(enparam-stparam))+stparam;
		}

		sts = om$send (msg = message GRvg.EMptatpr (
			&lmsg, &VDXmod_env.md_env.matrix_type,
			VDXmod_env.md_env.matrix, uval, 8, &VDXpnts[m]),
			senderid = NULL_OBJID,
			targetid = in_obj.objid,
			targetos = in_obj.osnum);

		if( !(sts&lmsg&1)){
			__DBGpr_com(" Error in GRvg.EMptatpr3 ");
			__DBGpr_obj(" id ", in_obj);
			msg = -1;
			goto wrapup;
		}
		msg = TRUE;
	}
wrapup:
	End
	return msg;
}
end implementation GRvg ;

