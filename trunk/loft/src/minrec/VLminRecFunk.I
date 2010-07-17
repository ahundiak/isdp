/* $Id $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/minrec/VLminRecFunk.I
 *
 * Description: Set of functions used to compute the minimum rectangle
 *		containing an input closed & planar curve.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      06/05/00   Rama Rao     Header Creation && Error Checking in VLstroke()
 *************************************************************************/

class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"bserr.h"
#include	"maerr.h"
#include	"bs.h"
#include	"bsparameters.h"
#include	"grmacros.h"
#include	"cotxmacros.h"
#include	"msdef.h"
#include	"vlgrdef.h"
#include	"vlmsg.h"

#include	"bsbasisvect.h"
#include	"bschtptstcv.h"
#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsnorvec.h"
#include	"bsxtractpar.h"

#include	"mainvmx.h"
#include	"mamulmx.h"

extern	GRclassid	OPP_GR3dlinestr_class_id;
extern	IGRboolean	dblcmp();
extern	IGRdouble	VLatan2();
extern	IGRint		GRabsg_del_by_objid(), dblcpy();

from	GRconic		import	GRgetarc;

/*============================================================================*/
IGRlong	VLminRectangle ( Iobj, Ienv, cst, but, rat, margin,
		         Len, Wid, frm_id, txt_id, msg)

/*d This function is the generic entry for minimum rectangle computation. It's
    calling up to 3 different computation methods. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */

	struct	GRid		*Iobj;    /*I Curve ID			*/
	struct	GRmd_env	*Ienv;    /*I Environment		*/
	struct	GRvg_construct	*cst;     /*I Construction list		*/
		IGRint		but;      /*I Method selector		*/
		IGRdouble	rat;      /*I Ratio			*/
		IGRdouble	margin;   /*I Margin			*/
		IGRdouble	*Len;     /*O Length of minimal rect	*/
		IGRdouble	*Wid;     /*O Width of minimal rect	*/
	struct	GRid            *frm_id;  /*O Frame Identification	*/
	struct	GRid            *txt_id;  /*O Text Identification	*/
		IGRlong		*msg;     /*O Completion message	*/

{
/*c Beginning of the function */

			IGRlong		sts=OM_S_SUCCESS, s_ret;
			IGRlong		siz=0;
	struct		IGRbsp_curve	*cv;
			IGRdouble	*spars;
	struct		IGRplane	plane;
			IGRpoint	point, *spts;
			IGRvector	normal;
			IGRdouble	*oldpts, *newpts;
			BSrc		rc;
			IGRvector	u, v, w;
			IGRmatrix	direct, invers, view_mat;
			IGRshort	l=4, m=4, n;
			IGRint		i, npts;
			IGRdouble	cdg[3], oldcdg[4], newcdg[4];
			IGRdouble	rng[6], Irng[6], Srng[6], Lrng[6];
			IGRdouble	pts[15], Ipts[15], Spts[15], Lpts[15];
			IGRdouble	L, IL, SL, LL, W, IW, SW, LW;
			IGRboolean	circle, Icircle, Scircle, Lcircle;
			IGRdouble	Iarea, Sarea, Larea;
			IGRdouble	old5pt[20], new5pt[20];
	struct		IGRpolyline	geom;
			IGRchar		CR[3], txt[81];
			IGRint		len;
	struct		GRvg_construct	cnst;

	/*c Initialize structures */
	cv     = NULL;
	spts   = NULL;
	spars  = NULL;
	newpts = NULL;
	oldpts = NULL;
	plane.point  = point;
	plane.normal = normal;
	if (cst == NULL) VLinitCnst (&cnst);
	else		 cnst = *cst;

	/*c Get locate object size */
	sts = om$send ( msg = message GRvg.GRgetsize (
					msg,
					&Ienv->md_env.matrix_type,
					Ienv->md_env.matrix,
					&siz ),
			senderid = NULL_OBJID,
			targetid = Iobj->objid,
			targetos = Iobj->osnum );
	if (!(sts&1&(*msg))) {
		EFmsgReport ( 0, sts,  "GRvg.GRgetsize");
		EFmsgReport ( 0, *msg, "GRvg.GRgetsize");
		goto wrapup;
	}

	/*c Allocate memory for Bspline curve */
	cv = (struct IGRbsp_curve *) om$malloc (size = siz);
	if (cv == NULL) {
		printf ( "Cannot allocate memory for IGRbsp_curve\n");
		goto wrapup;
	}

	/*c Clear buffer */
	GRabsg_del_by_objid ( &Iobj->objid, &Iobj->osnum);

	/*c Get locate object geometry */
	sts = om$send ( msg = message GRvg.GRgetgeom (
					msg,
					&Ienv->md_env.matrix_type,
					Ienv->md_env.matrix,
					(IGRchar *) cv ),
			senderid = NULL_OBJID,
			targetid = Iobj->objid,
			targetos = Iobj->osnum );
	if (!(sts&1&(*msg))) {
		EFmsgReport ( 0, sts,  "GRvg.GRgetgeom");
		EFmsgReport ( 0, *msg, "GRvg.GRgetgeom");
		goto wrapup;
	}

	/*c Get locate object plane */
	sts = om$send ( msg = message GRvg.GRdetplane (
					msg,
					&Ienv->md_env.matrix_type,
					Ienv->md_env.matrix,
					&plane ),
			senderid = NULL_OBJID,
			targetid = Iobj->objid,
			targetos = Iobj->osnum );
	if (!(sts&1&(*msg))) {
		EFmsgReport ( 0, sts,  "GRvg.GRdetplane");
		EFmsgReport ( 0, *msg, "GRvg.GRdetplane");
		*msg = VL_E_NON_PLANAR;
		goto wrapup;
	}

	/*c Construct transformation matrix */
	BSbasisvect ( &rc, plane.normal, w, u, v);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	direct[0] = u[0]; direct[4] = u[1]; direct[8]  = u[2];
        direct[1] = v[0]; direct[5] = v[1]; direct[9]  = v[2];
        direct[2] = w[0]; direct[6] = w[1]; direct[10] = w[2];
        direct[3]  = plane.point[0];
        direct[7]  = plane.point[1];
        direct[11] = plane.point[2];
        direct[12] = direct[13] = direct[14] = 0.0;
        direct[15] = 1.0;
        if ( MAinvmx ( msg, &l, direct, invers) == FALSE) {
                EFmsgReport (0, *msg, "MAinvmx()");
                goto wrapup;
        }

	/*c Allocate memory for 4dim locate point */
	npts = (IGRint) cv->num_poles;
	oldpts = om$calloc ( num = npts * 4, structure = IGRdouble );
	if (oldpts == NULL) {
		printf ( "Cannot allocate memory for IGRdouble\n");
		goto wrapup;
	}

	/*c Fill 4dim locate point */
	if (cv->rational) {
		for ( i=0; i<npts; i=i+1) {
			oldpts[i+(0*npts)] = cv->poles[(3*i)+0]/cv->weights[i];
			oldpts[i+(1*npts)] = cv->poles[(3*i)+1]/cv->weights[i];
			oldpts[i+(2*npts)] = cv->poles[(3*i)+2]/cv->weights[i];
			oldpts[i+(3*npts)] = 1.0;
		}
	}
	else {	for ( i=0; i<npts; i=i+1) {
			oldpts[i+(0*npts)] = cv->poles[(3*i)+0];
			oldpts[i+(1*npts)] = cv->poles[(3*i)+1];
			oldpts[i+(2*npts)] = cv->poles[(3*i)+2];
			oldpts[i+(3*npts)] = 1.0;
		}
	}

	/*c Allocate memory for 4dim compute point */
	newpts = om$calloc ( num = npts * 4, structure = IGRdouble );
	if (newpts == NULL) {
		printf ( "Cannot allocate memory for IGRdouble\n");
		goto wrapup;
	}

	/*c Fill 4dim compute point */
	n = (IGRshort) npts;
	if ( MAmulmx ( msg, &l, &m, &n, invers, oldpts, newpts) == FALSE) {
		EFmsgReport (0, *msg, "MAmulmx()");
		goto wrapup;
	}

	/*c Transform Bspline curve */
	if (cv->rational) {
		for ( i=0; i<npts; i=i+1) {
			cv->poles[(3*i)+0] = newpts[i+(0*npts)]*cv->weights[i];
			cv->poles[(3*i)+1] = newpts[i+(1*npts)]*cv->weights[i];
			cv->poles[(3*i)+2] = newpts[i+(2*npts)]*cv->weights[i];
		}
	}
	else {	for ( i=0; i<npts; i=i+1) {
			cv->poles[(3*i)+0] = newpts[i+(0*npts)];
			cv->poles[(3*i)+1] = newpts[i+(1*npts)];
			cv->poles[(3*i)+2] = newpts[i+(2*npts)];
		}
	}

	/*c Pretreat curves */
	if (cv->order > 2) {
		BSchtptstcv ( cv, &npts, &spts, &spars, &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		/*c Compute center of gravity */
		VLcomputeCdg ( npts, (IGRdouble *)spts, cdg);
	}
	else 	VLcomputeCdg ( cv->num_poles, cv->poles, cdg);


	/*c Switch on compute methods */
	switch (but) {

		case B_INERTI:
			if (cv->order > 2)
				VLinertia ( (IGRdouble *)spts, npts, rat, cdg,
				     	    rng, pts, &L, &W, &circle);
			else
				VLinertia ( cv->poles, cv->num_poles, rat, cdg,
				     	    rng, pts, &L, &W, &circle);
			break;
		case B_STROKE:
			if (cv->order > 2)
				VLstroke  ( (IGRdouble *)spts, npts, rat,
				     	    rng, pts, &L, &W, &circle);
			else
				VLstroke  ( cv->poles, cv->num_poles, rat,
				     	    rng, pts, &L, &W, &circle);
			break;
		case B_SQUARE:
			if (cv->order > 2)
				VLleastSquare ( (IGRdouble *)spts, npts, rat,
				     	        rng, pts, &L, &W, &circle);
			else
				VLleastSquare ( cv->poles, cv->num_poles, rat,
				     	        rng, pts, &L, &W, &circle);
			break;
		case B_BESTOF:
			if (cv->order > 2) {
				VLinertia ( (IGRdouble *)spts, npts, rat, cdg,
				     	    Irng, Ipts, &IL, &IW, &Icircle);
				s_ret = VLstroke ( (IGRdouble *)spts, npts, rat,
				     	    Srng, Spts, &SL, &SW, &Scircle);
				VLleastSquare ( (IGRdouble *)spts, npts, rat,
				     	        Lrng, Lpts, &LL, &LW, &Lcircle);
			}
			else {
				VLinertia ( cv->poles, cv->num_poles, rat, cdg,
				     	     Irng, Ipts, &IL, &IW, &Icircle);
				s_ret = VLstroke( cv->poles, cv->num_poles, rat,
				     	     Srng, Spts, &SL, &SW, &Scircle);
				VLleastSquare ( cv->poles, cv->num_poles, rat,
				     	        Lrng, Lpts, &LL, &LW, &Lcircle);
			}
			Iarea = IL * IW;
			if( s_ret == MSSUCC ) 	Sarea = SL * SW;
			else			Sarea = 0.0;
			Larea = LL * LW;
			if      ((Iarea <= Sarea) && (Iarea <= Larea)) {
				L = IL;
				W = IW;
				dblcpy ( rng, Irng, 6);
				dblcpy ( pts, Ipts, 15);
				circle = Icircle;
			}
			else if ((Sarea <= Iarea) && (Sarea <= Larea)) {
				L = SL;
				W = SW;
				dblcpy ( rng, Srng, 6);
				dblcpy ( pts, Spts, 15);
				circle = Scircle;
			}
			else {
				L = LL;
				W = LW;
				dblcpy ( rng, Lrng, 6);
				dblcpy ( pts, Lpts, 15);
				circle = Lcircle;
			}
			break;
		default:
			printf("Unreferenced method index <%d>\n", but);
			sts = MSFAIL;
			goto wrapup;
	}

	/*c Approximate length & width */
	L += 2 * margin;		W+= 2 * margin;
	if (Len != NULL) *Len = L;	if (Wid != NULL) *Wid = W;
	L = L * 100.0 + 5;		W = W * 100.0 + 5;
	L = (IGRint) (L / 10.0);	W = (IGRint) (W / 10.0);
	L = L / 10.0;			W = W / 10.0;

if (frm_id != NULL) {
	/*c Transform the 5 points from compute plane to locate plane */
	for ( i=0; i<5; i++) {
		old5pt[i]    = pts[3*i];
		old5pt[i+5]  = pts[3*i+1];
		old5pt[i+10] = pts[3*i+2];
		old5pt[i+15] = 1.0;
	}
	n = (IGRshort) 5;
	if ( MAmulmx ( msg, &l, &m, &n, direct, old5pt, new5pt) == FALSE) {
		EFmsgReport (0, *msg, "MAmulmx()");
		goto wrapup;
	}
	for ( i=0; i<5; i++) {
		pts[3*i]   = new5pt[i];
		pts[3*i+1] = new5pt[i+5];
		pts[3*i+2] = new5pt[i+10];
	}

	/*c Reorient points in direct orientation */
	for ( i=0; i<3; i++) {
		u[i] = pts[3*i+3] - pts[3*i+0];
		v[i] = pts[3*i+6] - pts[3*i+3];
	}
	BScrossp ( &rc, u, v, w);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if (BSdotp ( &rc, w, plane.normal) < 0.0) {
		for ( i=0; i<5; i++) {
			pts[12-(3*i)] = new5pt[i];
			pts[13-(3*i)] = new5pt[i+5];
			pts[14-(3*i)] = new5pt[i+10];
		}
	}
	sts = VLrectMargin ( 5, pts, margin, msg);
	if (!(sts&1&(*msg))) {
		EFmsgReport ( 0, sts,  "VLrectMargin()");
		EFmsgReport ( 0, *msg, "VLrectMargin()");
		goto wrapup;
	}

	/*c Construct minimal rectangle frame */
	frm_id->objid = NULL_OBJID;
	frm_id->osnum = cnst.env_info->md_id.osnum;
	sts = om$construct ( classid = OPP_GR3dlinestr_class_id,
			     p_objid = &frm_id->objid,
			     osnum   = frm_id->osnum );
	if (!(sts&1)) {
		EFmsgReport ( 0, sts, "om$construct:OPP_GR3dlinestr_class_id");
		*msg = MSFAIL;
		goto wrapup;
	}

	/*c GRaltconstruct minimal rectangle frame */
	geom.num_points = (IGRlong) 5;
	geom.points     = (IGRdouble *) pts;
	cnst.geometry   = (IGRchar *) &geom;
	sts = om$send ( msg      = message GRgraphics.GRaltconstruct (&cnst),
			senderid = NULL_OBJID,
			targetid = frm_id->objid,
			targetos = frm_id->osnum );
	if (!(sts&1&(*(cnst.msg)))) {
		EFmsgReport ( 0, sts,         "GRgraphics.GRaltconstruct");
		EFmsgReport ( 0, *(cnst.msg), "GRgraphics.GRaltconstruct");
		goto wrapup;
	}

	if (txt_id != NULL) {
		/*c Construct minimal rectangle text */
		CR[0] = 27;
		CR[1] = 10;
		CR[2] = 0;
		sprintf ( txt, "%g%s%g", L, CR, W);
		len = strlen(txt);

		/*c Transform the c.d.g. from compute plane to locate plane */
		dblcpy ( oldcdg, cdg, 3);	oldcdg[3] = 1.0;
		n = (IGRshort) 1;
		if ( MAmulmx ( msg, &l, &m, &n, direct, oldcdg, newcdg)
		     == FALSE) {
			EFmsgReport (0, *msg, "MAmulmx()");
			goto wrapup;
		}
		dblcpy ( cdg, newcdg, 3);

		/*c Construct view matrix for minimal rectangle text */
		dblcpy ( view_mat, invers, 16);
		view_mat[3] = view_mat[7] = view_mat[11] = 0.0;

		/*c Place minimal rectangle text */
		sts = co$place_text ( msg         = msg,
			      	      text_string = txt,
			      	      text_length = &len,
			      	      rot_matrix  = view_mat,
			      	      origin      = cdg,
			      	      flags       = 1,
			      	      buffer      = txt_id );
		if (!(sts&1&(*msg))) {
			EFmsgReport ( 0, sts,  "co$place_text()");
			EFmsgReport ( 0, *msg, "co$place_text()");
			goto wrapup;
		}
	}
}
	
wrapup:
	if (cv)     { om$dealloc (ptr = cv)   ;  cv     = NULL; }
	if (spts)   { om$dealloc (ptr = spts) ;  spts   = NULL; }
	if (spars)  { om$dealloc (ptr = spars);  spars  = NULL; }
	if (oldpts) { om$dealloc (ptr = oldpts); oldpts = NULL; }
	if (newpts) { om$dealloc (ptr = newpts); newpts = NULL; }

	return (sts);

/*c End of the function */
}
/*============================================================================*/
IGRlong	VLcomputeCdg ( npts, pts, cdg)

/*d This routine computes the center of gravity of set of 2D points. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */

	IGRint		npts;	/*I Number of points*/
	IGRdouble	pts[];  /*I Array of points*/
	IGRdouble	cdg[];  /*O Center of gravity*/

{
/*c Beginning of the function */
	
	IGRdouble       SIGMA_XX, SIGMA_XY, SIGMA_X, SIGMA_Y, SIGMA_YY;
	IGRint          i, i3, j, iP1, iP2;
	IGRdouble       one_third, two_third;
	IGRdouble       A_TR, A_RE, SIGMA_TRA, xab;
	IGRdouble       xa, xb, ya, yb, xgr, ygr, xgt, ygt;

	if (npts == 0) return MSFAIL;

        i3 = 3 * npts;

	/*c Initialize */
        SIGMA_X   = 0.0;
        SIGMA_Y   = 0.0;
        SIGMA_XX  = 0.0;
        SIGMA_YY  = 0.0;
        SIGMA_XY  = 0.0;
        SIGMA_TRA = 0.0;

        one_third = 1.0 / 3.0;
        two_third = 2.0 / 3.0;

	/*c Compute loop */
        for (j=3;j<i3;j=j+3) {

                i   = j - 3;
                iP1 = i + 1;
                iP2 = i + 2;

                xa = pts[i];
                xb = pts[j];
                ya = pts[iP1];
                yb = pts[j+1];
                xab = xb - xa;
                xgr = 0.5*xa + 0.5*xb;
                ygr = 0.5*ya;
                xgt = one_third*xa + two_third*xb;
                ygt = one_third*yb + two_third*ya;

                A_RE = xab * ya;
                A_TR = 0.5 * xab * ( yb-ya );

                SIGMA_TRA  = SIGMA_TRA + A_RE + A_TR;

                SIGMA_X    = SIGMA_X + xgr*A_RE + xgt*A_TR;
                SIGMA_Y    = SIGMA_Y + ygr*A_RE + ygt*A_TR;
        }

	/*c Evaluate of center of gravity */
        cdg[0] = SIGMA_X / SIGMA_TRA;
        cdg[1] = SIGMA_Y / SIGMA_TRA;
        cdg[2] = 0.0;

	return MSSUCC;

/*c End of the function */
}
/*============================================================================*/
IGRlong	VLinertia ( points, npts, rat, cdg, range, pts, L, W, circle)

/*d This routine extracts the minimal rectangle with an inertia based
    computation method. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */

	IGRdouble	points[]; /*I Array of points*/
	IGRint		npts;	  /*I Number of points*/
	IGRdouble	rat;	  /*I Ratio*/
	IGRdouble	cdg[];	  /*I Center of gravity*/
	IGRdouble	range[];  /*O Range box*/
	IGRdouble	pts[];    /*O Corner points*/
	IGRdouble	*L;	  /*O Length of minimal rect*/
	IGRdouble	*W;	  /*O Width of minimal rect*/
	IGRboolean	*circle;  /*O Circular case flag*/

{
/*c Beginning of the function */

	IGRint         	i3, j;
        IGRdouble      	SIGMA_XX, SIGMA_XY, SIGMA_YY;
        IGRdouble      	delta, ALPHA;
        IGRdouble      	A_TR, SIGMA_TRA;
        IGRdouble      	xgt, ygt;
        IGRdouble      	p[3], q[3];
        IGRdouble      	xpre, ypre, xcou, ycou;

        i3 = 3 * npts;

	/*c Initialize */
	SIGMA_XX  = 0.0;
        SIGMA_YY  = 0.0;
        SIGMA_XY  = 0.0;
        SIGMA_TRA = 0.0;

	/*c Change the origin */
        xpre = points[0] - cdg[0]; 	ypre = points[1] - cdg[1];

	/*c Inertia compute loop */
        for (j=3;j<i3;j=j+3) {
                xcou = points[j]   - cdg[0]; 	ycou = points[j+1] - cdg[1];
                xgt = (xpre + xcou) / 3.0; 	ygt = (ypre + ycou) / 3.0;
                A_TR = xpre*ycou - xcou*ypre;

                if (fabs(A_TR) > 0.0) {
                        SIGMA_XX   = SIGMA_XX + A_TR * xgt * xgt;
                        SIGMA_YY   = SIGMA_YY + A_TR * ygt * ygt;
                        SIGMA_XY   = SIGMA_XY + A_TR * xgt * ygt;
                }
                xpre = xcou; 			ypre = ycou;
        }

        SIGMA_XX   = 0.5 * SIGMA_XX;
        SIGMA_YY   = 0.5 * SIGMA_YY;
        SIGMA_XY   = 0.5 * SIGMA_XY;

        delta = SIGMA_XX * SIGMA_YY - SIGMA_XY * SIGMA_XY;

	/*c Evalutate main inertia axis */
        ALPHA = VLatan2( (2.0*SIGMA_XY) , (SIGMA_XX - SIGMA_YY) );
        ALPHA = ALPHA / 2.0;

	p[0] = cdg[0];		p[1] = cdg[1];		p[2] = 0.0;
        q[0] = cos(ALPHA);	q[1] = sin(ALPHA);	q[2] = 0.0;

	/*c Compute range */
        VLcomputeRng ( points, npts, p, q, rat, range, pts, L, W, circle);

	return MSSUCC;
/*c End of the function */
}
/*============================================================================*/
IGRlong	VLstroke  ( points, npts, rat, range, pts, L, W, circle)

/*d This routine extracts the minimal rectangle with an inertia based
    computation method. It's a stroke method evaluating the range at the
    corners with an edge as main inertia axis. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */


	IGRdouble	points[]; /*I Array of points*/
	IGRint		npts;	  /*I Number of points*/
	IGRdouble	rat;	  /*I Ratio*/
	IGRdouble	range[];  /*O Range box*/
	IGRdouble	pts[];    /*O Corner points*/
	IGRdouble	*L;	  /*O Length of minimal rect*/
	IGRdouble	*W;	  /*O Width of minimal rect*/
	IGRboolean	*circle;  /*O Circular case flag*/

{
/*c Beginning of the function */
	BSrc		rc;
	IGRint         	i, j;
        IGRdouble      	p[3], q[3], rng[6], box[15];
        IGRdouble      	area, len=0.0, wid=0.0;

        area = 1e+30;

	/* Corners' loop */
        for ( i=0; i<npts-1; i=i+1) {
                for ( j=0; j<3; j=j+1) {
                        p[j] = points[3*i+j];
                        q[j] = points[3*(i+1)+j] - points[3*i+j];
                }

		rc = BSSUCC ;
	        BSnorvec( &rc, q );
		if( rc != BSSUCC ) continue;

		/* Compute range */
                VLcomputeRng ( points, npts, p, q, rat,
				 range, pts, L, W, circle);
		/* Store minimal range */
                if (area > (*L) * (*W)) {
                        len = *L;
                        wid = *W;
                        dblcpy ( rng, range, 6);
                        dblcpy ( box, pts,  15);
                        area = len * wid;
                }
	}

        *L = len;
        *W = wid;
        dblcpy ( range, rng, 6);
        dblcpy ( pts, box,  15);

	return MSSUCC;

/*c End of the function */
}
/*============================================================================*/
IGRlong	VLleastSquare ( points, npts, rat, range, pts, L, W, circle)

/*d This routine extracts the minimal rectangle with a least squares
    computation method. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */
/*h 03/11/1994 : JLL, function reviewed because we used to minimize the
		 following functional equation Min( y[i] - x[i] )**2
		 that is not correct                                   */

	IGRdouble	points[]; /*I Array of points*/
	IGRint		npts;	  /*I Number of points*/
	IGRdouble	rat;	  /*I Ratio*/
	IGRdouble	range[];  /*O Range box*/
	IGRdouble	pts[];    /*O Corner points*/
	IGRdouble	*L;	  /*O Length of minimal rect*/
	IGRdouble	*W;	  /*O Width of minimal rect*/
	IGRboolean	*circle;  /*O Circular case flag*/

{
/*c Beginning of the function */

	IGRint         	i, n;
        IGRdouble      	Sx, Sy, Sxx, Sxy, Syy, alpha;
	IGRdouble	p[3], q[3];

	/*c check if the curve is closed */

	n   = 3 * (npts - 1);
        Sy  = 0.0;
	for( i=0;i<2;i++ ){
		Sx = points[i] - points[n+i];
		Sy += Sx * Sx;
	}

	if( Sy > 0.0 ) n = 3 * npts;
	else           n = 3 * (npts-1);

	Sx  = 0.0;
        Sy  = 0.0;
        Sxx = 0.0;
        Sxy = 0.0;
        Syy = 0.0;

	/*c evaluate the Cog */
        for ( i=0; i<n; i+=3 ){
                Sx += points[i];
                Sy += points[i+1];
	}

	p[0] = 3.0 * Sx / n;
	p[1] = 3.0 * Sy / n;
	p[2] = 0.0;

	/*c Compute square sums */
        for ( i=0; i<n; i+=3 ) {
                Sx  = points[i] - p[0];
                Sy  = points[i+1] - p[1];
                Sxx += Sx * Sx;
                Sxy += Sx * Sy;
                Syy += Sy * Sy;
        }

        alpha = 0.5 * VLatan2( (2.0 * Sxy) , (Sxx - Syy) );

        q[0] = cos(alpha);	q[1] = sin(alpha);	q[2] = 0.0;

	/*c Compute range */
        VLcomputeRng ( points, npts, p, q, rat, range, pts, L, W, circle);

	return MSSUCC;

/*c End of the function */

}
/*============================================================================*/
IGRboolean VLcheckAln ( pt, org, dir)

/*d This routine checks points alignements in a given direction. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */

	IGRdouble	*pt;	/*I Array of points*/
	IGRdouble	*org;	/*I Range box*/
	IGRdouble	*dir;	/*I Direction vector*/

{
/*c Beginning of the function */

	IGRdouble	vdif[2], dot;

        vdif[0] = pt[0] - org[0];
        vdif[1] = pt[1] - org[1];
        dot = vdif[0]*dir[0] + vdif[1]*dir[1];

        if (fabs(dot) <= 1.0e-10) return (TRUE);
        else                      return (FALSE);

/*c End of the function */
}
/*============================================================================*/
void VLxyMinMax ( n, pt, a, b, x0, y0, xmin, ymin, xmax, ymax)

/*d This routine in not used */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */

	IGRint		n;
	IGRdouble	pt[];
	IGRdouble	a;
	IGRdouble	b;
	IGRdouble	x0;
	IGRdouble	y0;
	IGRdouble	*xmin;
	IGRdouble	*ymin;
	IGRdouble	*xmax;
	IGRdouble	*ymax;

{
/*c Beginning of the function */

	IGRint		i;
	IGRdouble	pa, x, y;

	/*c initialize */
	x = pt[0] - x0;
	y = pt[1] - y0;
	(*xmin) = (*xmax) = a*x + b*y;
	(*ymin) = (*ymax) = a*y - b*x;

	/*c compute loop */
	for (i=0;i<n;i=i+3) {
		x  = pt[i]   - x0;
                y  = pt[i+1] - y0;

                pa = a*x + b*y;
                if      (pa < (*xmin)) (*xmin) = pa;
                else if (pa > (*xmax)) (*xmax) = pa;

                pa = a*y - b*x;
                if      (pa < (*ymin)) (*ymin) = pa;
                else if (pa > (*ymax)) (*ymax) = pa;
	}

/*c End of the function */
}
/*============================================================================*/
void VLcomputeRng ( pt, npt, p, q, rat, range, box, l, w, circle)

/*d This routine compute the range of set of 2D points. A center point and an
    axis vector must be given. */
/*h 15/09/1992 : creation by Marc FOURNIER (ISDC). */

	IGRdouble		pt[];	  /*I Array of points*/
	IGRint			npt;	  /*I Number of points*/
	IGRdouble		p[];	  /*I Center point*/
	IGRdouble		q[];	  /*I Axis vector*/
	IGRdouble		rat;	  /*I Ratio*/
	IGRdouble		range[];  /*O Range points*/
	IGRdouble		box[];	  /*O Corner points*/
	IGRdouble		*l;	  /*O Length of minimal rect*/
	IGRdouble		*w;	  /*O Width of minimal rect*/
	IGRboolean		*circle;  /*O Circular case flag*/

{
/*c Beginning of the function */

	IGRint			i, n;
	IGRdouble		x, xmin, xmax, x0, a, xdir[3];
	IGRdouble		y, ymin, ymax, y0, b, ydir[3];
	IGRdouble		pa;

	x0 = p[0];			y0 = p[1];
	a  = q[0];			b  = q[1];

	/*c Initialize */
	x = pt[0] - x0; 		y = pt[1] - y0;
	xmin = xmax = a*x + b*y; 	ymin = ymax = a*y - b*x;

	/*c Compute X & Y minmax */
	for (i=0;i<npt;i++) {
		x  = pt[3*i]   - x0;
		y  = pt[3*i+1] - y0;

                pa = a*x + b*y;
                if      (pa < xmin) xmin = pa;
                else if (pa > xmax) xmax = pa;

                pa = a*y - b*x;
                if      (pa < ymin) ymin = pa;
                else if (pa > ymax) ymax = pa;
	}

	/*c Fill range array */
	pa = a*a + b*b;
	range[0] = x0 + (xmin*a - ymin*b) / pa;
        range[1] = y0 + (xmin*b + ymin*a) / pa;
        range[2] = 0.0;
        range[3] = x0 + (xmax*a - ymax*b) / pa;
        range[4] = y0 + (xmax*b + ymax*a) / pa;
        range[5] = 0.0;

	/*c Fill box & direction array */
	for (i=0;i<3;i++) {
                box[i]    = range[i];
                box[i+3]  = box[i] + q[i] * (xmax - xmin) / pa;
                box[i+6]  = range[i+3];
                box[i+9]  = box[i+6] - q[i] * (xmax -xmin) / pa;
                box[i+12] = range[i];
                xdir[i]   = box[i+3] - box[i];
                ydir[i]   = box[i+9] - box[i];
        }

	/*c Check the square case */
	*circle = FALSE;
        *l = xdir[0]*xdir[0] + xdir[1]*xdir[1]; 	*l = sqrt(*l);
        *w = ydir[0]*ydir[0] + ydir[1]*ydir[1]; 	*w = sqrt(*w);
        if (*l < *w) { x  = *l; *l = *w; *w = x; }
        x = (*l - *w) / (*l);
        if (fabs(x) > rat) return;

	/*c Check the contour's points */
	ydir[0] = -q[1];
        ydir[1] = q[0];
        n = 0;
        for (i=0;i<npt;i++) {
                if (VLcheckAln (&(pt[3*i]), box, ydir) == TRUE )          n++;
                if (VLcheckAln (&(pt[3*i]), box, q) == TRUE )             n++;
                if (VLcheckAln (&(pt[3*i]), &(box[6]), ydir) == TRUE )    n++;
                if (VLcheckAln (&(pt[3*i]), &(box[6]), q) == TRUE )       n++;
        }
        if (n >= npt) return;

/*c End of the function */
}
/*============================================================================*/
IGRlong VLrectMargin ( npt, pts, margin, msg)

/*d This routine extand a rectangle by an constant offset */
/*h 24/02/1993 : creation by Marc FOURNIER (ISDC). */

		IGRint		npt;	/*I  Number of points	*/
		IGRdouble	pts[];	/*IO Array of points	*/
		IGRdouble	margin;	/*I  Margin value	*/
		IGRlong		*msg;	/*O Completion message	*/
{
/*c Beginning of the function */

		IGRdouble	ChtTol;
		BSrc		rc;
		IGRboolean	closed;
		IGRint		i, j;
		IGRvector	u, v;
		IGRdouble	ext[15];

	/*c Check null margin */
	BSxtractpar ( &rc, BSTOLCHRDHT, &ChtTol);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if (margin < ChtTol) goto wrapup;

	/*c Check number of given points */
	if ((npt != 4) && (npt != 5)) goto wrapup;

	/*c Check if the first and the last points are the same */
	closed = dblcmp ( &pts[0], &pts[3*(npt-1)], ChtTol, 3);
	if (  ((closed == FALSE) && (npt == 5)) 
	   || ((closed == TRUE)  && (npt == 4)) )
		{ *msg = MSFAIL; goto wrapup; }

	/*c Extend non extremity points */
	for ( i=1; i<4; i++) {
		for ( j=0; j<3; j++) {
			u[j] = pts[3*i+j] - pts[3*i+j-3];
			v[j] = pts[3*i+j] - pts[3*i+j+3];
		}
		BSnorvec ( &rc, u);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSnorvec ( &rc, v);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( j=0; j<3; j++) {
			ext[3*i+j] = pts[3*i+j] + margin * (u[j] + v[j]);
		}
	}

	/*c Extend start point */
	for ( j=0; j<3; j++) {
		u[j] = pts[j] - pts[9+j];
		v[j] = pts[j] - pts[3+j];
	}
	BSnorvec ( &rc, u);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, v);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	for ( j=0; j<3; j++) {
		ext[j]    = pts[j] + margin * (u[j] + v[j]);
		ext[12+j] = ext[j];
	}

	/*c Extend end point */
	for ( j=0; j<3; j++) {
		u[j] = pts[9+j] - pts[6+j];
		v[j] = pts[9+j] - pts[j];
	}
	BSnorvec ( &rc, u); 
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, v);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	for ( j=0; j<3; j++) {
		ext[9+j] = pts[9+j] + margin * (u[j] + v[j]);
	}

	/*c Copy extended points array in input one */
	for ( i=0; i<3*npt; i++) pts[i] = ext[i];

wrapup:
	return OM_S_SUCCESS;

/*c End of the function */
}
/*============================================================================*/

end implementation VLabstract;
