class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"AS_status.h"
#include	"bserr.h"
#include	"bsparameters.h"
#include        "grmacros.h"
#include        "grdpbmacros.h"
#include        "dpmacros.h"
#include        "EMSssprops.h"
#include        "EMSdpb.h"

#include	"vsedgedef.h"
#include	"vsedgemacros.h"
#include	"vsmiscmacros.h"
#include	"vldbgmacros.h"

#include	"bsalloccv.h"
#include	"bsallocsf.h"
#include	"bscrossp.h"
#include	"bscv_copy.h"
#include	"bscveval.h"
#include	"bsdirfitcv.h"
#include	"bsfndcvtrns.h"
#include	"bsfreecv.h"
#include	"bsfreesf.h"
#include	"bsnorvec.h"
#include	"bspartofcv.h"
#include	"bspt_in_plg.h"
#include	"bssf3o4cvs.h"
#include	"bsxtractpar.h"

#include	"vlCprototype.h"

extern	GRclassid	OPP_GR3dpoint_class_id;
extern  IGRboolean 	VLcolinear();

from	EMSbsedge	import	EMbsinit;
from	EMSedge		import	EMgetbcgeom;
from	EMSplane	import	EMplane;
from    GRbcsubbc       import  EMcurve_by_poles;

/*	#define	TRACE	*/

/* ========================================================================== */
IGRlong	VLextractSurfaceEdge
(
	IGRlong		*msg,	/*O	Completion code			*/
struct	GRobj_env	*Sf,	/*I	Surface structure		*/
	IGRdouble	u,	/*I	U parameter value		*/
	IGRdouble	v,	/*I	V parameter value		*/
	IGRdouble	*n,	/*I	Direction vector		*/
struct	GRmd_env	*Env,	/*I	Current module environment	*/
struct	GRvg_construct	*Cst,	/*I	Construction list		*/
struct	GRid		*Line,	/*O	Edge object copy		*/
struct	GRid		*Plan,	/*O	Plan object			*/
	IGRchar		*Name	/*O	Edge "isometric" name		*/
)
{
								
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		edgnum=0, i, idx=0, suc;
struct	GRid		*edgcrv, edg_id;
	IGRpoint	spt, ept, ppt, pln[3];
struct	GRparms		*parm;
	IGRdouble	dst, dif;
	IGRvector	vec, ort;
	BSrc		rc;
#ifdef TRACE
	IGRchar		name[100];

printf( ">> VLextractSurfaceEdge : u=%g, v=%g, n : [%g,%g,%g]\n",
	u, v, n[0], n[1], n[2] );
#endif

	/* Initialize */
	edgcrv = NULL;
	parm   = NULL;
	if (Line) {	Line->objid = NULL_OBJID;
			Line->osnum = Env->md_id.osnum;	}
	if (Plan) {	Plan->objid = NULL_OBJID;
			Plan->osnum = Env->md_id.osnum;	}
	if (Name) {
		if (u == -1.0)		sprintf ( Name, "v=%g", v);
		else if (v == -1.0)	sprintf ( Name, "u=%g", u);
		else {	printf( "Unmatchable UV = (%g|%g)\n", u, v);
			*msg = MSFAIL; goto wrapup;	}
	}

	/* Retrieve surface external edges */
        vs$get_surface_edges ( msg      = msg,
                               sfId     = &Sf->obj_id,
                               sfEnv    = &Sf->mod_env,
                               edgeType = VS_K_CONTOUR_EDGES,
                               edCount  = &edgnum,
                               edList   = &edgcrv );
        as$status ( sts    = *msg,
                    msg    = "vs$get_surface_edges()",
                    test   = (!(0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "\tvs$get_surface_edges() returns %d edges\n", edgnum);
#endif
	/* Allocate memory */
	if (!edgnum)	goto wrapup;
	parm = om$calloc ( num = 2 * edgnum, structure = struct GRparms );

	/* Loop on edges */
	for ( i=0; i<edgnum; i++) {

		/* Extract graphical edge (without copy) */
		edg_id.objid = NULL_OBJID;
		edg_id.osnum = Env->md_id.osnum;
		vs$get_graphic_edge ( msg     = msg,
                                      edId    = &edgcrv[i],
                                      edEnv   = &Sf->mod_env,
                                      copy    = FALSE,
                                      copyEnv = Env,
                                      grEdge  = &edg_id );
                as$status ( sts    = *msg,
                            msg    = "vs$get_graphic_edge()",
                            test   = (!(0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
#ifdef TRACE
om$get_classname ( osnum     = edg_id.osnum,
		   objid     = edg_id.objid,
		   classname = name );
printf( "Edge %d is a <%s>\n", i, name);
#endif
		/* Test if the edge is degenerated to a point */
		if (vs$is_ancestry_valid ( object  = &edg_id,
					   classid = OPP_GR3dpoint_class_id) ) {
			parm[2*i+0].u = parm[2*i+0].v = -1.0;
			parm[2*i+1].u = parm[2*i+1].v = -1.0;
			continue;
		}

		/* Extract endpoints */
		sts = VLendpts ( msg, &edg_id, &Sf->mod_env, spt, ept);
                as$status ( sts    = sts,
                            msg    = "VLendpts()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
#ifdef TRACE
printf( "\tEdge %d : [%g,%g,%g]\t-->[%g,%g,%g]\n", 
	i, spt[0], spt[1], spt[2], ept[0], ept[1], ept[2] );
#endif
		/* Project start point on surface (to get parameters) */
		sts = om$send ( msg = message GRgraphics.GRptproject (
						msg,
						&Sf->mod_env.md_env.matrix_type,
						Sf->mod_env.md_env.matrix,
						spt, ppt, &parm[2*i+0] ),
				senderid = NULL_OBJID,
				targetid = Sf->obj_id.objid,
				targetos = Sf->obj_id.osnum );
                as$status ( sts    = sts,
                            msg    = "GRgraphics.GRptproject(start point)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Project end point on surface (to get parameters) */
		sts = om$send ( msg = message GRgraphics.GRptproject (
						msg,
						&Sf->mod_env.md_env.matrix_type,
						Sf->mod_env.md_env.matrix,
						ept, ppt, &parm[2*i+1] ),
				senderid = NULL_OBJID,
				targetid = Sf->obj_id.objid,
				targetos = Sf->obj_id.osnum );
                as$status ( sts    = sts,
                            msg    = "GRgraphics.GRptproject(end point)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}

	/* Find closest edge to theorical isometric wanted */
	dst = 2.1;
	dif = 0.0;
	for ( i=0; i<edgnum; i++) {

		if (  (parm[2*i+0].u < 0.0)
		   && (parm[2*i+0].v < 0.0)
		   && (parm[2*i+1].u < 0.0)
		   && (parm[2*i+1].v < 0.0) )
			continue;

		else if (v < 0.0)
			dif = fabs(parm[2*i+0].u - u)
			    + fabs(parm[2*i+1].u - u);

		else if (u < 0.0)
			dif = fabs(parm[2*i+0].v - v)
			    + fabs(parm[2*i+1].v - v);

		if (dif < dst) {	dst = dif;
#ifdef TRACE
printf( "\tdistance for edge %d is %g\n", i, dst);
#endif
					idx = i;	}
	}

	if (Line) {
		/* Extract graphical edge (with copy) */
		vs$get_graphic_edge ( msg     = msg,
	                              edId    = &edgcrv[idx],
	                              edEnv   = &Sf->mod_env,
	                              copy    = TRUE,
	                              copyEnv = Env,
	                              grEdge  = Line );
        	as$status ( sts    = *msg,
	                    msg    = "vs$get_graphic_edge()",
	                    test   = (!(0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	if (Plan) {

		/* Extract graphical edge (without copy) */
		edg_id.objid = NULL_OBJID;
		edg_id.osnum = Env->md_id.osnum;
		vs$get_graphic_edge ( msg     = msg,
                                      edId    = &edgcrv[idx],
                                      edEnv   = &Sf->mod_env,
                                      copy    = FALSE,
                                      copyEnv = Env,
                                      grEdge  = &edg_id );
                as$status ( sts    = *msg,
                            msg    = "vs$get_graphic_edge()",
                            test   = (!(0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Extract endpoints */
		sts = VLendpts ( msg, &edg_id, &Sf->mod_env, pln[0], pln[2]);
                as$status ( sts    = sts,
                            msg    = "VLendpts()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
	                    value  = wrapup );

		/* Build middle point */
		for ( i=0; i<3; i++)	ppt[i] = 0.5 * (pln[0][i] + pln[1][i]);
		sts = om$send ( msg = message GRgraphics.GRptproject (
						msg,
						&Sf->mod_env.md_env.matrix_type,
						Sf->mod_env.md_env.matrix,
						ppt, pln[1], &parm[0] ),
				senderid = NULL_OBJID,
				targetid = edg_id.objid,
				targetos = edg_id.osnum );
                as$status ( sts    = sts,
                            msg    = "GRgraphics.GRptproject(middle point)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Check colinearity */
		if (VLcolinear ( 3, (IGRdouble *) pln, vec) ) {

			if (!n) {	printf( "Need a direction vector\n");
					*msg = MSFAIL;  goto wrapup;    }
			BSnorvec ( &rc, n);
			if (rc != BSSUCC) {
				printf( "Error in BSnorvec()\n");
				*msg = MSFAIL;	goto wrapup;	}

			for ( i=0; i<3; i++)	vec[i] = pln[2][i] - pln[0][i];
			BSnorvec ( &rc, vec);
			if (rc != BSSUCC) {
				printf( "Error in BSnorvec()\n");
				*msg = MSFAIL;	goto wrapup;	}

			BScrossp ( &rc, n, vec, ort);
			if (rc != BSSUCC) {
				printf( "Error in BScrossp()\n");
				*msg = MSFAIL;	goto wrapup;	}

			BSnorvec ( &rc, ort);
			if (rc != BSSUCC) {
				printf( "Error in BSnorvec()\n");
				*msg = MSFAIL;	goto wrapup;	}

			for ( i=0; i<3; i++)	pln[1][i] += ort[i];
		}

		/* Build extremity plane */
		Cst->geometry = (IGRchar *) NULL;
		sts = om$construct ( classid = OPP_EMSplane_class_id,
				     osnum   = Plan->osnum,
				     p_objid = &Plan->objid,
				     msg = message EMSplane.EMplane
						( &suc, Cst, pln, 3) );
		as$status ( sts    = sts,
                            msg    = "om$construct(EMSplane.EMplane)",
                            test   = (!(sts & 0x00000001 & (*(Cst->msg)))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}

	if ( (Plan) && (Name) ) {
		sts = VLchangeTemporaryName ( Env, Plan, Name, msg);
                as$status ( sts    = sts,
                            msg    = "VLchangeTemporaryName",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}
#ifdef TRACE
printf( ">> VLextractSurfaceEdge\n\n");
#endif

wrapup:
	if (parm) {	om$dealloc (ptr = parm);	parm = NULL;	}
	if (edgcrv) {	om$dealloc (ptr = edgcrv);	edgcrv = NULL;	}
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLsplitAtTurns
(
struct	IGRbsp_curve	*Icrv,	/*I	Input bspline curve 	*/
struct	IGRbsp_curve	**Ocrv,	/*O	Output bspline curves	*/
	IGRint		*cnt,	/*O	Number of outputs	*/
	IGRlong		*msg	/*O	Completion code		*/
)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRdouble	*pnt, *par, p1, p2, p3;
	BSrc		rc;
	IGRint		count=0;
struct	IGRbsp_curve	*Lcrv;

	/* Initialize */
	pnt  = NULL;
	par  = NULL;
	Lcrv = NULL;

	/* Allocate memory */
	pnt = om$calloc ( num = 3 * Icrv->num_poles, structure = IGRdouble );
	par = om$calloc ( num =     Icrv->num_poles, structure = IGRdouble );

	/* Search turns */
	BSfndcvtrns ( Icrv, &count, (IGRpoint *) pnt, par, &rc);
	if (rc != BSSUCC) {
		printf( "Error in BSfndcvtrns()\n");
		*msg = MSFAIL; goto wrapup;	}

	if (count == 0) {

		/* Allocate memory */
		BSalloccv ( Icrv->order, Icrv->num_poles, Icrv->rational,
			    Icrv->num_boundaries, &Ocrv[*cnt], &rc );
		if (rc != BSSUCC) {
			printf( "Error in BSalloccv()\n");
			*msg = MSFAIL; goto wrapup;	}

		/* Store data */
		BScv_copy ( &rc, Icrv, Ocrv[*cnt]);
		if (rc != BSSUCC) {
			printf( "Error in BScv_copy()\n");
			*msg = MSFAIL; goto wrapup;	}
		else	(*cnt)++;
	}
	else {	/* Allocate memory */
		BSalloccv ( Icrv->order, Icrv->num_poles + 2 * Icrv->order - 1,
			    Icrv->rational, Icrv->num_boundaries,
			    &Ocrv[*cnt], &rc );
		if (rc != BSSUCC) {
			printf( "Error in BSalloccv()\n");
			*msg = MSFAIL; goto wrapup;	}

		/* Split input curve (left part) */
		p1 = 0.0;
		p3 = par[0];
		p2 = 0.5 * (p1 + p3);
		BSpartofcv ( &rc, Icrv, p1, p2, p3, Ocrv[*cnt]);
		if (rc != BSSUCC) {
			printf( "Error in BSpartofcv()\n");
			*msg = MSFAIL; goto wrapup;	}

		/* Allocate memory */
		BSalloccv ( Icrv->order, Icrv->num_poles + 2 * Icrv->order - 1,
			    Icrv->rational, Icrv->num_boundaries, &Lcrv, &rc );
		if (rc != BSSUCC) {
			printf( "Error in BSalloccv()\n");
			*msg = MSFAIL; goto wrapup;	}

		/* Split input curve (right part) */
		p1 = par[0];
		p3 = 1.0;
		p2 = 0.5 * (p1 + p3);
		BSpartofcv ( &rc, Icrv, p1, p2, p3, Lcrv);
		if (rc != BSSUCC) {
			printf( "Error in BSpartofcv()\n");
			*msg = MSFAIL; goto wrapup;	}

		/* Call VLsplitAtTurns of second part of the curve */
		(*cnt)++;
		sts = VLsplitAtTurns ( Lcrv, Ocrv, cnt, msg);
	        as$status ( sts    = *msg,
	                    msg    = "VLsplitAtTurns()",
	                    test   = (!(0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	if (Lcrv) {	om$dealloc (ptr = Lcrv);	Lcrv = NULL;	}
	if (par) {	om$dealloc (ptr = par);		par = NULL;	}
	if (pnt) {	om$dealloc (ptr = pnt);		pnt = NULL;	}
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLextractUvEdges
(
	IGRlong		*msg,	/*O	Completion code		*/
struct	GRobj_env	*Sf,	/*I	Working surface object	*/
	IGRint		*Nedg,	/*O	Number of natural edge	*/
	IGRint		*Onum,	/*O	Output edges' number	*/
struct	IGRbsp_curve	**Ocrv	/*O	Output edges' array	*/
)

/*	This function converts 1, 2, 3 or 4 edges in 4 bspline-curves,	*/
/*	if it is possible. The 3 side surface cannot be treated and in	*/
/*	this peculiar case the <Onum> value will be 3.			*/
/*	The <Oedg> array must be allocated to struct IGRbsp_curve[4]	*/
/*	by the caller.							*/
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i, j;
struct	GRid		*Sedg;
struct	IGRbsp_curve	Uedg;

	/* Initialize */
	*Nedg = 0;
	*Onum = 0;
	Sedg = NULL;
	Uedg.poles   = NULL;
	Uedg.knots   = NULL;
	Uedg.weights = NULL;
	Uedg.bdrys   = NULL;

	/* Get surface edges */
	vs$get_surface_edges ( msg      = msg,
                               sfId     = &Sf->obj_id,
                               sfEnv    = &Sf->mod_env,
                               edgeType = VS_K_CONTOUR_EDGES,
                               edCount  = Nedg,
                               edList   = &Sedg );
        as$status ( sts    = *msg,
                    msg    = "vs$get_surface_edges()",
                    test   = (!(0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Treat edges */
	for ( i=0; i<*Nedg; i++) {

		/* Deallocate (if needed) */
		if (Uedg.poles) {	om$dealloc (ptr = Uedg.poles);
					Uedg.poles = NULL;	}
		if (Uedg.knots) {	om$dealloc (ptr = Uedg.knots);
					Uedg.knots = NULL;	}
		if (Uedg.weights) {	om$dealloc (ptr = Uedg.weights);
					Uedg.weights = NULL;	}
		if (Uedg.bdrys) {	om$dealloc (ptr = Uedg.bdrys);
					Uedg.bdrys = NULL;	}

		/* Get UV space representation */
                sts = om$send ( msg = message EMSedge.EMgetbcgeom
                        ( msg, 0, OM_K_MAXINT, FALSE, NULL, &Uedg, NULL, 0 ),
                                senderid = NULL_OBJID,
                                targetid = Sedg[i].objid,
                                targetos = Sedg[i].osnum );
                as$status ( sts    = sts,
	                    msg    = "EMSedge.EMgetbcgeom",
	                    test   = (!(0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Scale on UV curve */
		for ( j=0; j<3*Uedg.num_poles; j++)	Uedg.poles[j] *= 1000.0;

		/* Get turns (recursively) and split */
                /* in VLevalUvGridFromSrf, it set Ocrv[50]: TR179800806 */
                     if ( *Onum >= 50 ) break;   
		sts = VLsplitAtTurns ( &Uedg, Ocrv, Onum, msg);
                as$status ( sts    = sts,
	                    msg    = "VLturnsAndSplit",
	                    test   = (!(0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}

	/* Scale of resulting curves */
	for ( i=0; i<*Onum; i++) {
		for ( j=0; j<3*Ocrv[i]->num_poles; j++)
			Ocrv[i]->poles[j] *= 0.001;
	}

wrapup:
	if (Uedg.poles) {	om$dealloc (ptr = Uedg.poles);
				Uedg.poles = NULL;	}
	if (Uedg.knots) {	om$dealloc (ptr = Uedg.knots);
				Uedg.knots = NULL;	}
	if (Uedg.weights) {	om$dealloc (ptr = Uedg.weights);
				Uedg.weights = NULL;	}
	if (Uedg.bdrys) {	om$dealloc (ptr = Uedg.bdrys);
				Uedg.bdrys = NULL;	}
	if (Sedg) {	om$dealloc (ptr = Sedg);	Sedg = NULL;	}
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
void	VLevalUvGridFrom4Cv
(
	IGRint		opt,	/*I	Option (0 light, 1 complete)	*/
	IGRint		Unum,	/*I	Num of pts to approx in U dir	*/
	IGRint		Vnum,	/*I	Num of pts to approx in V dir	*/
struct	IGRbsp_curve	**curv,	/*I	4 curves in UV space		*/
struct	IGRbsp_surface	**grid,	/*O	Solution in UV space		*/
	BSrc		*rc	/*O	Completion code			*/
)
{
	IGRint		i, j, N=0, M=0;
struct	IGRbsp_curve	*work[4], *fitt;
	IGRdouble	tanl[3], tanr[3], U;
	IGRshort	order;
	BSrc		rc1;
        IGRdouble       tolerance = 0.0;
 	IGRboolean      bssts;
	IGRlong         msg;

 
        SetProc( VLevalUvGridFrom4Cv ); Begin
	/* Initialize */
	if (Unum > Vnum)	N = Unum;
	else			N = Vnum;
	for ( i=0; i<3; i++)	tanl[i] = tanr[i] = 0.0;
	for ( i=0; i<4; i++)	work[i] = NULL;
	fitt = NULL;

switch (opt) {

	case 0:
	
		for ( i=0; i<4; i++) {
	
			/* Allocate memory for working curve */
			BSalloccv ( 2, N, 0, 0, &work[i], rc);
			if (*rc != BSSUCC) {
				printf( "Error in BSalloccv()\n");
				goto wrapup;	}
	
			/* Evaluate working curve poles */
			for ( j=0; j<N; j++) {
				U = (IGRdouble) j / (N - 1);
				BScveval ( curv[i], U, 0,
					   (IGRpoint *) &(work[i]->poles[3*j]),
					   rc);
				work[i]->knots[j+1] = U;
			}
	                work[i]->knots[0]   = 0.0;
	                work[i]->knots[N+1] = 1.0;
	
			/* Evaluate working curve others */
			work[i]->order          = 2;
	                work[i]->periodic       = FALSE;
	                work[i]->non_uniform    = FALSE;
	                work[i]->num_poles      = N;
	                work[i]->num_knots      = N + 2;
	                work[i]->rational       = FALSE;
	                work[i]->planar         = FALSE;
	                work[i]->phy_closed     = FALSE;
	                work[i]->num_boundaries = 0;
		}
		break;

	default:

		Unum = 21;
		Vnum = 21;

		/* Determine M */
		for ( i=0; i<4; i++)
			if (curv[i]->num_poles > M)
				M = (IGRint) curv[i]->num_poles;
		M += 3;

		/* Allocate memory for fitting */
		BSalloccv ( 4, M, 0, 0, &fitt, rc);
		if (*rc != BSSUCC) {
			printf( "Error in BSalloccv()\n");
			goto wrapup;	}

		/* Allocate memory for working */
		for ( i=0; i<4; i++) {
			BSalloccv ( 4, 21, 0, 0, &work[i], rc);
			if (*rc != BSSUCC) {
				printf( "Error in BSalloccv()\n");
				goto wrapup;	}
		}

		/* Build working curves */
		for ( i=0; i<4; i++) {

			/* Determine order */
			order = 4;
			if (curv[i]->num_poles < order)
				order = curv[i]->num_poles;

			/* Building fitting curve */
			BSdirfitcv ( curv[i]->num_poles,
                                     (IGRpoint *) &(curv[i]->poles[0]),
                                     order, 0, 0, 0,
                                     tanl, tanr,
                                     fitt,
                                     rc );
			if (*rc != BSSUCC) {
				printf( "Error in BSdirfitcv()\n");
				goto wrapup;	}

			/* Define stroking points number */
			if ( (i == 0) || (i == 2) )	N = Unum;
			else				N = Vnum;

			/* Evaluate working curve poles */
			for ( j=0; j<N; j++) {
				U = (IGRdouble) j / (N - 1);
				BScveval ( fitt, U, 0,
					   (IGRpoint *) &(work[i]->poles[3*j]),
					   rc);
				work[i]->knots[j+1] = U;
			}
	                work[i]->knots[0]   = 0.0;
	                work[i]->knots[N+1] = 1.0;
	
			/* Evaluate working curve others */
			work[i]->order          = 2;
	                work[i]->periodic       = FALSE;
	                work[i]->non_uniform    = FALSE;
	                work[i]->num_poles      = N;
	                work[i]->num_knots      = N + 2;
	                work[i]->rational       = FALSE;
	                work[i]->planar         = FALSE;
	                work[i]->phy_closed     = FALSE;
	                work[i]->num_boundaries = 0;
		}
}	/* End of switch */

        bssts = BSEXTRACTPAR (&msg, BSTOLBASIS, tolerance);

	/* Scale on poles */
	for ( i=0; i<4; i++) {
		N = 3 * work[i]->num_poles;
		for ( j=0; j<N; j++)	{
                  /* tr179800589 */
                  if ( fabs(work[i]->poles[j] - 0.0 ) < tolerance )
                              work[i]->poles[j] = 0.0;
		  else if(fabs(work[i]->poles[j] - 1.0) < tolerance ) 
                              work[i]->poles[j] = 1.0;
                  work[i]->poles[j] *= 1000.0;
                }/* for */	
        } /* for i */

	/* Evaluate coons patch */
	BSsf3o4cvs ( work[0], work[1], work[2], work[3], grid, rc);
        if (*rc != BSSUCC) {
                printf("Error in BSsf3o4cvs() and rc = %d\n", *rc);
                goto wrapup;     }

	/* Scale of poles */
	N = 3 * (*grid)->u_num_poles * (*grid)->v_num_poles;
	for ( i=0; i<N; i++)	(*grid)->poles[i] *= 0.001 ;

wrapup:
/*      if *rc !=0 from BSsf3o4cvs, here, it always cover it to 0  
	if (fitt) {	BSfreecv ( rc, fitt);		fitt = NULL;	}
	if (work) {
		for ( i=0;  i<4; i++) {
			BSfreecv ( rc, work[i]);	work[i] = NULL;	}
	}
*/
        /* for TR179800589: */ 
	if (fitt) {	BSfreecv ( &rc1, fitt);		fitt = NULL;	}
	if (work) {
		for ( i=0;  i<4; i++) {
			BSfreecv ( &rc1, work[i]);	work[i] = NULL;	}
	}
        if( rc1 != BSSUCC ) *rc = BSFAIL; 
        End
}
/* ========================================================================== */

/* ========================================================================== */
void	VLevalUvGridFrom3Cv
(
	IGRint		num,	/*I	Number of parameters		*/
struct	IGRbsp_curve	**curv,	/*I	4 curves in UV space		*/
struct	IGRbsp_surface	**grid,	/*O	Solution in UV space		*/
	BSrc		*rc	/*O	Completion code			*/
)
{
	IGRint		i, j, Unum;
	IGRdouble	*pCrv, div=0.0;
	BSrc		locRc;

	/* Initialize */
	pCrv = NULL;
	*rc = BSFAIL;

	if (num < 3)	goto wrapup;
	else		div = (IGRdouble) 1.0 / (num - 1);

	/* Allocate memory for curves' points */
	pCrv = om$calloc ( num = 3 * 3 * num, structure = IGRdouble);

	/* Evaluate regular points on curves */
	for ( i=0; i<3; i++) {
		for ( j=0; j<num; j++) {
			BScveval ( curv[i], j * div, 0,
				   (IGRpoint *) &pCrv[3*(num*i+j)], rc);
		        if (*rc != BSSUCC) {
		                printf("Error in BScveval()\n");
		                goto wrapup;     }
		}
	}

	/* Fill the surface structure */
	Unum = num * (num + 1) * 0.5;

	/* Allocate memory for surface structure */
	BSallocsf ( 2, 2, Unum, 1, FALSE, 0, grid, rc);
        if (*rc != BSSUCC) {
                printf("Error in BSallocsf()\n");
                goto wrapup;     }
	(*grid)->u_num_poles = Unum;
	(*grid)->v_num_poles = 1;

	/* Call trilinear coons patch */
	POtriaCoons ( 3, &pCrv[0], &pCrv[3*num], &pCrv[6*num], num,
		      (*grid)->poles);

wrapup:
	if ( (*rc != BSSUCC) && (*grid) ) {
		BSfreesf ( &locRc, *grid);
		*grid = NULL;	}
	if (pCrv) {	om$dealloc (ptr = pCrv);	pCrv = NULL;	}

}
/* ========================================================================== */

/* ========================================================================== */
void	VLevalUvGridFromPnt
(
	IGRint		Unum,	/*I	Num of pts to approx in U dir	*/
	IGRint		Vnum,	/*I	Num of pts to approx in V dir	*/
struct	IGRbsp_surface	*geom,	/*I	Surface				*/
struct	IGRbsp_surface	**grid,	/*O	Solution in UV space		*/
	BSrc		*rc	/*O	Completion code			*/
)
{
	IGRint		i, j, cnt=0, res;
	IGRdouble	*par, Udiv, Vdiv;
struct	IGRpolyline	poly;
	IGRboolean	Ovalue;
	BSrc		locRc;

	/* Initialize */
	par = NULL;
	poly.points = NULL;
	*rc = BSFAIL;
	if ( (Unum < 1) || (Vnum < 1) )	goto wrapup;
	else {	Unum *= 2;
		Vnum *= 2;
		Udiv = 1.0 / (Unum - 1);
		Vdiv = 1.0 / (Vnum - 1);	}

	/* Store boundary UV points */
	if (!geom->num_boundaries) {
		printf( "No boundaries imposed on working surface\n");
		goto wrapup;	}
	else {	poly.num_points = geom->bdrys[0].num_points;
		poly.points = om$calloc ( num = 3 * poly.num_points,
					  structure = IGRdouble );
		for ( i=0; i<poly.num_points; i++) {
			poly.points[3*i+0] = geom->bdrys[0].points[2*i+0];
			poly.points[3*i+1] = geom->bdrys[0].points[2*i+1];
			poly.points[3*i+2] = 0.0;
		}
	}

	/* Allocate memory */
	par = om$calloc ( num = 3 * Unum * Vnum, structure = IGRdouble);

	/* Fill point array */
	for ( i=0; i<Unum; i++) {
		for ( j=0; j<Vnum; j++) {
			par[3*(i*Vnum+j)]   = i * Udiv;
			par[3*(i*Vnum+j)+1] = j * Udiv;
			par[3*(i*Vnum+j)+2] = 0.0;
		}
	}

	/* Determine polyline (boundaries) orientation */
	BSpt_in_plg ( poly, &par[0], FALSE, &Ovalue, &res, rc);
        if (*rc != BSSUCC) {
                printf("Error in BSpt_in_plg()\n");
                goto wrapup;     }

	/* Determine points position */
	for ( i=0; i<Unum; i++) {
		for ( j=0; j<Vnum; j++) {
			BSpt_in_plg ( poly, &par[3*(i*Vnum+j)], TRUE, &Ovalue,
				      &res, rc);
		        if (*rc != BSSUCC) {
		                printf("Error in BSpt_in_plg()\n");
		                goto wrapup;     }
			else if ((res == 1) || (res == 2)) {
				par[3*(i*Vnum+j)+2] = (IGRdouble) res;
				cnt++;	}
		}
	}
	if (!cnt) {
		printf( "No points found inside boundaries\n");
		*rc = BSFAIL;	}

	/* Allocate memory for surface structure */
	BSallocsf ( 2, 2, cnt, 1, FALSE, 0, grid, rc);
        if (*rc != BSSUCC) {
                printf("Error in BSallocsf()\n");
                goto wrapup;     }
	(*grid)->u_num_poles = cnt;
	(*grid)->v_num_poles = 1;

	/* Fill the surface structure */
	cnt = 0;
	for ( i=0; i<Unum; i++) {
		for ( j=0; j<Vnum; j++) {
			if (par[3*(i*Vnum+j)+2] > 0) {
				(*grid)->poles[3*cnt+0] = par[3*(i*Vnum+j)+0];
				(*grid)->poles[3*cnt+1] = par[3*(i*Vnum+j)+1];
				(*grid)->poles[3*cnt+2] = 0.0;
				cnt++;
			}
		}
	}

wrapup:
	if ( (*rc != BSSUCC) && (*grid) ) {
		BSfreesf ( &locRc, *grid);
		*grid = NULL;	}
	if (par) {		om$dealloc (ptr = par);
				par = NULL;	}
	if (poly.points) {	om$dealloc (ptr = poly.points);
				poly.points = NULL;	}
}
/* ========================================================================== */
	
end implementation VLabstract;
