/*f <VLstiffFunk.I> contains a set of functions used in the stiffener template
    construction workflow. */

class implementation VLabstract;

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"OMprimitives.h"
#include	"AS_status.h"
#include	"msdef.h"
#include	"bserr.h"
#include	"grdpbmacros.h"
#include	"gotextdef.h"
#include	"cotxmacros.h"
#include	"asmacros.h"
#include	"exmacros.h"
#include	"grmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"ACdyn_col.h"
#include	"bsparameters.h"

#include	"vsbeam.h"
#include	"vsbeamdef.h"
#include	"vsbeammacros.h"
#include	"vssectiondef.h"
#include	"vsedgedef.h"
#include	"vsedgemacros.h"
#include	"vsmiscmacros.h"

#include	"vlstifftpl.h"
#include	"vlcntrline.h"
#include	"vlmark.h"
#include	"vlquerydef.h"

#include	"bsarclength.h"
#include	"bscrossp.h"
#include	"bscveval.h"
#include	"bsdotp.h"
#include	"bslenvec.h"
#include	"bsmdistcvcv.h"
#include	"bsmdistptcv.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"

#include	"vsstrngproto.h"
#include	"griomacros.h"

extern	void		qsort();
extern	IGRdouble	fabs();

from	GRcurve		import	GRptseqspace;
from	EMSedge		import	EMget_bcxyz_geom;

/* #define	TRACE	 */

/* ========================================================================== */
void	VLstfnrAxisOrient ( 	IGRpoint	Spt,
				IGRpoint	Ept,
				IGRint		*axis,
				IGRint		*orien	)
{
	IGRdouble	xOri, yOri, zOri;

	/*c Determine stiffener main axis ( 1/2/3 for X/Y/Z) */
        xOri = Ept[0] - Spt[0];
        yOri = Ept[1] - Spt[1];
        zOri = Ept[2] - Spt[2];
        if      ( (fabs(xOri) >= fabs(yOri)) && (fabs(xOri) >= fabs(zOri)) )
                *axis = 1;
        else if ( (fabs(yOri) >= fabs(xOri)) && (fabs(yOri) >= fabs(zOri)) )
                *axis = 2;
        else    *axis = 3;

	/*c Determine stiffener orientation ( -1/1 for start/end side) */
        if      (*axis == 1) {
                if (xOri >= 0.0)        *orien = 1;
                else                    *orien = -1;
#ifdef TRACE
printf( "stiffener main axis is %d, xOri=%g, orien=%d\n", axis, xOri, *orien);
#endif
        }
        else if (*axis == 2) {
                if (yOri >= 0.0)        *orien = -1;
                else                    *orien = 1;
                if ((Spt[1] < 0.0) && (Ept[1] < 0.0))   *orien *= -1;
#ifdef TRACE
printf( "stiffener main axis is %d, yOri=%g, orien=%d\n", *axis, yOri, *orien);
#endif
        }
        else {  if (zOri >= 0.0)        *orien = -1;
                else                    *orien = 1;
#ifdef TRACE
printf( "stiffener main axis is %d, zOri=%g, orien=%d\n", *axis, zOri, *orien);
#endif
        }
}
/* ========================================================================== */
IGRint VLdirectionStfTpl ( Bcrv, Tcrv, Env, Spt, Ept, nlin, Line,
			   Arrow, Symbol, msg)

/*d This function finds the place for direction arrow mark and symbol mark.
    All the length evaluation are done on the base stiffener template curve and
    don't include the curve's extensions. */

/*h 21/03/94 : creation by Marc Fournier (COC Shipbuilding). */

	struct	GRid		*Bcrv;	 /*I Base Stiffener Template	 */
	struct	GRid		*Tcrv;	 /*I Top  Stiffener Template	 */
	struct	GRmd_env	*Env;	 /*I Local environment		 */
		IGRpoint	Spt;	 /*I Start point (before extend) */
		IGRpoint	Ept;	 /*I End   point (before extend) */
		IGRint		nlin;	 /*I Number of genLines		 */
	struct	GRid		*Line;	 /*I Array of genLines		 */
	struct	GRid		*Arrow;	 /*O Arrow of direction		 */
	struct	GRid		*Symbol; /*O Symbol of direction	 */
		IGRlong		*msg;	 /*O Completion code		 */

{
/*c Beginning of function */

	IGRlong			sts=OM_S_SUCCESS;
	IGRint			db_type, i, axis=0, orien=0, nseg=0;
	struct	GRobj_env	object;
	struct	IGRbsp_curve	*curve;
		IGRdouble	d=0.0, *bspar, *bsint, par[2], Mpt[12];
		IGRpoint	spt, ept, Spnt[6], Deriv[4];
		IGRvector	vec;
		BSrc		rc;
		IGRshort	n, k;
		VLstfTpl	*arg;
	struct	GRparms		parm, Spar, Epar;
		IGRdouble	midpar, difpar, Mpar[4];
		IGRmatrix	csmat;
		IGRchar		symbol_name[80];
		IGRlong		number=4;

	/*c Initialize */
	Spar.v           = Epar.v           = 0.0;
	Spar.polygon_inx = Epar.polygon_inx = 0;
	Arrow->objid   = NULL_OBJID;
	Arrow->osnum   = Env->md_id.osnum;
	Symbol->objid  = NULL_OBJID;
	Symbol->osnum  = Env->md_id.osnum;
	object.obj_id  = *Bcrv;
	object.mod_env = *Env;
	curve = NULL;
	bspar = NULL;
	bsint = NULL;
	if (!nlin)	nseg = 2;
	else		nseg = nlin;
	arg = NULL;
	arg = om$calloc ( num = nseg+2, structure = VLstfTpl );
	for ( i=0; i<nseg+2; i++) {	arg[i].pnt[0] = 0.0;
					arg[i].pnt[1] = 0.0;
					arg[i].pnt[2] = 0.0;
					arg[i].idx    = i;
					arg[i].len    = 0.0;	}

	/* Determine stiffener axis and orientation */
	VLstfnrAxisOrient ( Spt, Ept, &axis, &orien);

	/*c Get curve geometry */
	sts = VLgetGeometry ( &object, FALSE, NULL_OBJID,
			      (IGRchar **) &curve, msg);
	as$status ( sts    = sts,
	            msg    = "VLgetGeometry()",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );

	/*c Evaluate U parameters of start point (out of extension) */
	BSmdistptcv ( curve, Spt, &k, &n, &bspar, &d, &bsint, &rc);
        if (rc != BSSUCC) {	printf( "Error in BSmdistptcv()\n");
                                *msg = MSFAIL; goto wrapup;     }
	if (n > 0)	arg[0].pnt[0] = bspar[0];
	else		goto wrapup;
	Spar.u = bspar[0];
	if (bspar) {	om$dealloc (ptr = bspar);	bspar = NULL;	}
	if (bsint) {	om$dealloc (ptr = bsint);	bsint = NULL;	}
	arg[nseg+1].pnt[0] = arg[0].pnt[0];

	/*c Evaluate U parameters of end point (out of extension) */
	BSmdistptcv ( curve, Ept, &k, &n, &bspar, &d, &bsint, &rc);
        if (rc != BSSUCC) {	printf( "Error in BSmdistptcv()\n");
                                *msg = MSFAIL; goto wrapup;     }
	if (n > 0)	arg[nseg+1].pnt[1] = bspar[0];
	else		goto wrapup;
	Epar.u = bspar[0];
	if (bspar) {	om$dealloc (ptr = bspar);	bspar = NULL;	}
	if (bsint) {	om$dealloc (ptr = bsint);	bsint = NULL;	}
	arg[nseg].pnt[1] = arg[nseg+1].pnt[1];

	/*c Evaluate middle parameter */
	midpar = (arg[nseg+1].pnt[0] + arg[nseg+1].pnt[1]) / 2;
	difpar = (arg[nseg+1].pnt[1] - arg[nseg+1].pnt[0]);

#ifdef TRACE
printf( "Middle Parameter = %g\tDelta Parameter = %g\n", midpar, difpar);
#endif

	/*c Evaluate U parameters of genLines intersections */
	if (nlin) {
		for ( i=0; i<nlin; i++) {
			sts = VLendpts ( msg, &Line[i], Env, spt, ept );
	        	as$status ( sts    = sts,
	                    	    msg    = "VLendpts()",
	                    	    test   = (!(sts & 0x00000001 & (*msg))),
	                    	    action = GOTO_VALUE,
	                    	    value  = wrapup );

			BSmdistptcv (curve,ept,&k,&n,&bspar,&d,&bsint,&rc);
        		if (rc != BSSUCC) { printf( "Error in BSmdistptcv()\n");
                                	    *msg = MSFAIL; goto wrapup;     }
			if (n > 0)	arg[i+1].pnt[0] = bspar[0];
			else		goto wrapup;
			if (bspar) { om$dealloc (ptr = bspar); bspar = NULL; }
			if (bsint) { om$dealloc (ptr = bsint); bsint = NULL; }
			arg[i].pnt[1] = arg[i+1].pnt[0];
		}

		/*c Evaluate arc lengths between genLines */
		for ( i=0; i<nseg+2; i++) {
			BSarclength ( &rc, curve, &arg[i].pnt[0],
				      &arg[i].pnt[1], &arg[i].len);
        		if (rc != BSSUCC) { printf( "Error in BSarclength()\n");
                                	    *msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "Arc%2d Length = %g,\tfrom %g\tto %g\n",
	i, arg[i].len, arg[i].pnt[0], arg[i].pnt[1] );
#endif
		}

		/*c Sort segments by arc length */
        	qsort ( arg, nseg+2, sizeof(VLstfTpl), (int (*)())VLsortVertex);
#ifdef TRACE
for ( i=0; i<nseg+2; i++)
printf( "Index %2d\tParms in [%g\t%g]\tLength = %g\n",
	arg[i].idx, arg[i].pnt[0], arg[i].pnt[1], arg[i].len );
printf( "Direction marks are between genLine%d and genLine%d (%g of Length)\n",
	arg[nseg].idx-1, arg[nseg].idx,
	arg[nseg].len / arg[nseg+1].len );
#endif

		/*c Select the larger segment of the right side */
		par[0] = 0.0;
		par[1] = 1.0;
#ifdef TRACE
printf( "midpar=%g\n", midpar);
#endif
		for ( i=nseg; i>=0; i--) {
#ifdef TRACE
printf( "i=%d, orien=%d, arg[%d].pnt[0]=%g, arg[%d].pnt[1]=%g\n",
	i, orien, i, arg[i].pnt[0], i, arg[i].pnt[1]);
#endif
			if (orien == -1) {
				if (arg[i].pnt[0] < midpar) {
					par[0] = arg[i].pnt[0];
					if (arg[i].pnt[1] < midpar)
						par[1] = arg[i].pnt[1];
					else	par[1] = midpar;
					i = 0;	}
			}
			else {	if (arg[i].pnt[0] > midpar) {
					par[0] = arg[i].pnt[0];
					par[1] = arg[i].pnt[1];
					i = 0;	}
			}
		}
#ifdef TRACE
printf( "Select segment : [%g,%g]\n", par[0], par[1]);
#endif
	}
	
	else {	/*c Find middle on the base */
		sts = om$send ( msg = message GRcurve.GRptseqspace (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						Spt, Spt, Ept,
						&Spar, &Spar, &Epar,
						&number, Mpt ),
				senderid = NULL_OBJID,
				targetid = Bcrv->objid, 
				targetos = Bcrv->osnum );
        	as$status ( sts    = sts,
		            msg    = "GRcurve.GRptseqspace",
		            test   = (!(sts & 0x00000001 & (*msg))),
		            action = GOTO_VALUE,
		            value  = wrapup );

		/*c Evaluate U parameters of middle point */
		for ( i=0; i<number; i++) {
			BSmdistptcv ( curve, &Mpt[3*i],
				      &k, &n, &bspar, &d, &bsint, &rc);
        		if (rc != BSSUCC) { printf( "Error in BSmdistptcv()\n");
                                	    *msg = MSFAIL; goto wrapup;     }
			if (n > 0)	Mpar[i] = bspar[0];
			else		goto wrapup;
			if (bspar) { om$dealloc (ptr = bspar);	bspar = NULL; }
			if (bsint) { om$dealloc (ptr = bsint);	bsint = NULL; }
		}

		if (orien == -1) {	par[0] = Mpar[2];
					par[1] = Mpar[1];	}
		else {			par[0] = Mpar[1];
					par[1] = Mpar[2];	}
	}

	/*c Work with IGRpoints now ... */
	for ( i=0; i<2; i++) {
		BScveval ( curve, par[i], 0, &Spnt[i], &rc);
        	if (rc != BSSUCC) {	printf( "Error in BScveval()\n");
                               		*msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "Spnt[%d] : BScveval(%g) returns [%g,%g,%g]\n",
	i, par[i], Spnt[i][0], Spnt[i][1], Spnt[i][2] );
#endif
	}

	/*c Take middle of two parameters points */
	for ( i=0; i<3; i++)	Spnt[2][i] = 0.5 * (Spnt[0][i] + Spnt[1][i]);
#ifdef TRACE
printf( "Spnt[2] : [%g,%g,%g] is middle point\n",
	Spnt[2][0], Spnt[2][1], Spnt[2][2] );
#endif
	/*c Project it */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					Spnt[2], Spnt[3], &parm ),
			senderid = NULL_OBJID,
			targetid = Bcrv->objid,
			targetos = Bcrv->osnum );
       	as$status ( sts    = sts,
	            msg    = "GRgraphics.GRptproject",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );
#ifdef TRACE
printf( "Spnt[3] : [%g,%g,%g] is Spnt[2] projected on Bcrv\n",
	Spnt[3][0], Spnt[3][1], Spnt[3][2] );
#endif
	BScveval ( curve, parm.u, 2, Deriv, &rc);
       	if (rc != BSSUCC) {	printf( "Error in BScveval()\n");
                                *msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "After BScveval(%g)\n", parm.u);
printf( "Deriv[0] : [%g,%g,%g]\n", Deriv[0][0], Deriv[0][1], Deriv[0][2] );
printf( "Deriv[1] : [%g,%g,%g]\n", Deriv[1][0], Deriv[1][1], Deriv[1][2] );
printf( "Deriv[2] : [%g,%g,%g]\n", Deriv[2][0], Deriv[2][1], Deriv[2][2] );
#endif
	/*c Replace 1st derivative */
	BSmkvec ( &rc, vec, Spnt[0], Spnt[1]);
	if (BSdotp ( &rc, vec, Deriv[1]) < 0.0)
		for ( i=0; i<3; i++) {	Deriv[1][i] = -1.0 * vec[i];	}
	else	for ( i=0; i<3; i++) {  Deriv[1][i] = vec[i];		}
	if (orien == -1)
		for ( i=0; i<3; i++) {	Deriv[1][i] *= -1.0;	}
	BSnorvec ( &rc, Deriv[1]);
#ifdef TRACE
printf( "After replace 1st derivative\n");
printf( "Deriv[1] : [%g,%g,%g]\n", Deriv[1][0], Deriv[1][1], Deriv[1][2] );
#endif
	/*c Reorient 2nd derivative (if needed) */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					Spnt[3], Spnt[4], &parm ),
			senderid = NULL_OBJID,
			targetid = Tcrv->objid,
			targetos = Tcrv->osnum );
       	as$status ( sts    = sts,
	            msg    = "GRgraphics.GRptproject",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );
#ifdef TRACE
printf( "Spnt[4] : [%g,%g,%g] is Spnt[3] projected on Tcrv\n",
	Spnt[4][0], Spnt[4][1], Spnt[4][2] );
#endif
	BSmkvec ( &rc, vec, Spnt[3], Spnt[4]);
	if (BSdotp ( &rc, vec, Deriv[2]) < 0.0)
		for ( i=0; i<3; i++)	Deriv[2][i] *= -1.0;
	BSnorvec ( &rc, Deriv[2]);
#ifdef TRACE
printf( "After reorient 2nd derivative\n");
printf( "Deriv[2] : [%g,%g,%g]\n", Deriv[2][0], Deriv[2][1], Deriv[2][2] );
#endif	
	/*c Construct cs matrix */
	BScrossp ( &rc, Deriv[1], Deriv[2], Deriv[3]);
       	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
                               	*msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "Construct cs matrix\n");
printf( "Deriv[1] : [%g,%g,%g]\n", Deriv[1][0], Deriv[1][1], Deriv[1][2] );
printf( "Deriv[2] : [%g,%g,%g]\n", Deriv[2][0], Deriv[2][1], Deriv[2][2] );
printf( "Deriv[3] : [%g,%g,%g]\n", Deriv[3][0], Deriv[3][1], Deriv[3][2] );
#endif	
	BSnorvec ( &rc, Deriv[3]);
        if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                               	*msg = MSFAIL; goto wrapup;     }
	BScrossp ( &rc, Deriv[3], Deriv[1], Deriv[2]);
       	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
                               	*msg = MSFAIL; goto wrapup;     }
	BSnorvec ( &rc, Deriv[2]);
        if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                               	*msg = MSFAIL; goto wrapup;     }
	for ( i=0; i<3; i++) {
		csmat[4*i+0] = Deriv[1][i];
		csmat[4*i+1] = Deriv[2][i];
		csmat[4*i+2] = Deriv[3][i];
	}
	csmat[12] = csmat[13] = csmat[14] = 0.0;
	csmat[15] = 1.0;

	sts = co$unit_database_type ( osnum   = Env->md_id.osnum ,
				      db_type = &db_type );
	if ( !(sts & 1) ) {
		printf("Error in Getting the DataBase Info \n") ;
		*msg = MSFAIL ;
		goto wrapup ;
	}

	if ( db_type == GRIO_UNITS_ARE_ENGLISH ) {
		/*c Construct center point */
		if ( (orien == -1) && (nlin) )
			for ( i=0; i<3; i++) {	
				Spnt[5][i] = Spnt[1][i] + (10.0/25.4) * csmat[4*i+1]; }
		else	for ( i=0; i<3; i++) {	
				Spnt[5][i] = Spnt[0][i] + (10.0/25.4) * csmat[4*i+1]; }

		/*c Construct arrow attach point */
		for ( i=0; i<3; i++)	
			csmat[4*i+3] = Spnt[5][i] + 50.0/4.0 * csmat[4*i+0];
	} else {
		/*c Construct center point */
		if ( (orien == -1) && (nlin) )
			for ( i=0; i<3; i++) {	
				Spnt[5][i] = Spnt[1][i] + 10.0 * csmat[4*i+1]; }
		else	for ( i=0; i<3; i++) {	
				Spnt[5][i] = Spnt[0][i] + 10.0 * csmat[4*i+1]; }

		/*c Construct arrow attach point */
		for ( i=0; i<3; i++)	
			csmat[4*i+3] = Spnt[5][i] + 50.0 * csmat[4*i+0];
	}

	/*c Construct arrow foot */
	sts = VLplaceRootHeader ( csmat, "DIRarrow", Env, Arrow, msg);
	as$status ( sts    = sts,
	            msg    = "VLplaceRootHeader()",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );

	if ( db_type == GRIO_UNITS_ARE_ENGLISH )
		VLscalSymb ( csmat, Arrow, Env, msg);

	if ( db_type == GRIO_UNITS_ARE_ENGLISH ) {
		/*c Construct letter attach point */	
		for ( i=0; i<3; i++)	
			csmat[4*i+3] = Spnt[5][i] + 15.0/4.0 * csmat[4*i+0];
	} else {
		/*c Construct letter attach point */	
		for ( i=0; i<3; i++)	
			csmat[4*i+3] = Spnt[5][i] + 15.0 * csmat[4*i+0];
	}

	/*c Construct letter foot */
	switch (axis) {
		case 1:		strcpy ( symbol_name, "FRTletter");
				break;
		case 2:		strcpy ( symbol_name, "CTRletter");
				break;
		case 3:		strcpy ( symbol_name, "DWNletter");
				break;
		default: 	printf( "Unknown axis %d\n", axis);
				*msg = MSFAIL;
				goto wrapup;
	}
	sts = VLplaceRootHeader ( csmat, symbol_name, Env, Symbol, msg);
	as$status ( sts    = sts,
	            msg    = "VLplaceRootHeader()",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );

	if ( db_type == GRIO_UNITS_ARE_ENGLISH )
		VLscalSymb ( csmat, Symbol, Env, msg);

wrapup:
	if (arg)   {	om$dealloc (ptr = arg);		arg   = NULL;	}
	if (bsint) {	om$dealloc (ptr = bsint);	bsint = NULL;	}
	if (bspar) {	om$dealloc (ptr = bspar);	bspar = NULL;	}
	if (curve) {	om$dealloc (ptr = curve);	curve = NULL;	}
	return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
