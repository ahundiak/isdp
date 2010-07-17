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
#include	"vsdef.h"
#include	"vsbeammacros.h"
#include	"vssectiondef.h"
#include	"vsedgedef.h"
#include	"vsedgemacros.h"
#include	"vsmiscmacros.h"
#include	"vsRDBdef.h"

#include	"vlstifftpl.h"
#include	"vlcntrline.h"
#include	"vlmark.h"
#include	"vlquerydef.h"
#include	"vlmiscmacros.h"
#include	"vlglinedef.h"

#include	"bscrossp.h"
#include	"bscveval.h"
#include	"bsdotp.h"
#include	"bslenvec.h"
#include	"bsmdistcvcv.h"
#include	"bsmdistptcv.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bspl_cv_int.h"
#include	"bssfeval.h"
#include	"bsxtractpar.h"

#include	"vsstrngproto.h"

extern	void		qsort();
extern	IGRint		extent_surface_geom();
extern	IGRdouble	fabs();

extern	GRclassid	OPP_ACncpx_class_id;
extern	GRclassid	OPP_EMSsubbs_class_id;
extern	GRclassid	OPP_GRbcsubbc_class_id;
extern  GRclassid       OPP_VLbutLine_class_id;
extern  GRclassid       OPP_VLctrLine_class_id;
extern  GRclassid       OPP_VLgenLine_class_id;
extern  GRclassid       OPP_VLmrkLine_class_id;
extern  GRclassid       OPP_VLseaLine_class_id;
extern  GRclassid       OPP_VLtrace_class_id;
extern  GRclassid       OPP_VLwatLine_class_id;

from    ACcpx_defn      import  ACgive_name;
from	GRgencs		import	GRgetmatrix;
from	EMSedge		import	EMget_bcxyz_geom;
from	VSfeature	import	VSforwardToOriginal, VSforwardToSource;

/* #define	TRACE */

/* ========================================================================== */
IGRint VLgetVSbeamFace
(
	struct	GRobj_env	*Beam,	/*I Structural Beam		*/
		IGRchar		*Name,	/*I Face from <vssectiondef.h>	*/
		IGRshort	props,	/*I history prop. <vlquerydef.h>*/
					/*  current | source | original	*/
	struct	GRobj_env	*Face,	/*O Face of the Structural Beam	*/
		IGRlong		*msg	/*O Completion code		*/
)

/*d This function extracts the GRobj_env associated with a named face of a VS beam. */

/*h 15/03/94 : creation by Marc Fournier (COC Shipbuilding). */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, count=0, i;
		IGRlong		*descrs;
		IGRchar		**names;

	/* Initialize */
	descrs = NULL;
	names  = NULL;
	Face->obj_id.objid = NULL_OBJID;
	Face->obj_id.osnum = Beam->mod_env.md_id.osnum;
	Face->mod_env	   = Beam->mod_env;

	/* Get list of VS beam faces */
        sts = vs$listBeamFaces ( msg    = msg,
                                 beam   = &Beam->obj_id,
                                 count  = &count,
                                 names  = &names,
                                 descrs = &descrs );
        as$status ( sts    = sts,
                    msg    = "vs$listBeamFaces()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extract named face */
	for ( i=0; i<count; i++) {
		if ( ! strcmp ( Name, &(strrchr ( names[i], ':' )[1]) ) ) {

switch (props & VL_Q_TOP_LIM_MASK) {

case VL_Q_TOP_CURRENT:	sts = vl$return_foot ( msg     = msg,
					       name    = names[i],
					       objId   = &Beam->obj_id,
					       objEnv  = &Beam->mod_env,
					       footId  = &Face->obj_id,
					       footEnv = &Face->mod_env );
		        as$status ( sts    = sts,
		                    msg    = "vl$return_foot() for CURRENT",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			break;

case VL_Q_TOP_SOURCE:	sts = om$send
			( msg = message VSfeature.VSforwardToSource (
				msg,
				OM_e_wrt_object,
				message NDmacro.ACreturn_foot (
					msg,
					names[i],
					&Face->obj_id,
					&Face->mod_env.md_env.matrix_type,
					Face->mod_env.md_env.matrix ) ),
				senderid = NULL_OBJID,
				targetid = Beam->obj_id.objid,
				targetos = Beam->obj_id.osnum );
		        as$status ( sts    = sts,
		                    msg    = "NDmacro.ACreturn_foot",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			break;

case VL_Q_TOP_ORIGINAL:	sts = om$send
			( msg = message VSfeature.VSforwardToOriginal (
				msg,
				OM_e_wrt_object,
				message NDmacro.ACreturn_foot (
					msg,
					names[i],
					&Face->obj_id,
					&Face->mod_env.md_env.matrix_type,
					Face->mod_env.md_env.matrix ) ),
				senderid = NULL_OBJID,
				targetid = Beam->obj_id.objid,
				targetos = Beam->obj_id.osnum );
		        as$status ( sts    = sts,
		                    msg    = "NDmacro.ACreturn_foot",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			break;
}
			break;
		}
	}

wrapup:
	if (names)  {	VSfreeList (count,names);	names  = NULL;	}
	if (descrs) {	free (descrs);			descrs = NULL;	}
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLgetCommonEdge ( Beam, Wname, Fname, Wface, Fface, Env, Cedge, msg)

/*d This function extracts the GRobj_env associated with a named faces of a
Structural Beam (if pointers aren't set to NULL). If the face(s) name(s) are
NULL the associated GRobj_env pointer is taken as input.
It also finds the hypothetical common edge between the two faces and return its GRobj_env. */

/*h 15/03/94 : creation by Marc Fournier (COC Shipbuilding). */

	struct	GRobj_env	*Beam;	/*I  Structural Beam		 */
		IGRchar		*Wname;	/*I  Face from <vssectiondef.h>	 */
		IGRchar		*Fname;	/*I  Face from <vssectiondef.h>	 */
	struct	GRobj_env	*Wface;	/*IO Face of the Structural Beam */
	struct	GRobj_env	*Fface;	/*IO Face of the Structural Beam */
	struct	GRmd_env	*Env;	/*I  Local environment		 */
	struct	GRid		*Cedge;	/*O  Common edge between 2 faces */
		IGRlong		*msg;	/*O  Completion code		 */

{
/* Beginning of function */

		IGRint			sts=OM_S_SUCCESS, i, j, k;
		IGRint			w_count=0, f_count=0;
	struct	GRobj_env		w_face, f_face;
	struct	GRid			*w_edges, *f_edges;
		OM_S_CHANNUM		Cnumber;
		OM_S_CHANSELECT		Cselect;
		IGRuint			Ccount;
		OM_S_OBJECT_LINKAGE	*Clist;
	struct	IGRbsp_curve		cv;
	struct	GRvg_construct		cst;

	/* Initialize */
	w_edges	     = NULL;
	f_edges	     = NULL;
	Clist	     = NULL;
	Cedge->objid = NULL_OBJID;
	Cedge->osnum = Env->md_id.osnum;
	cv.poles = cv.knots = cv.weights = NULL;
	VLinitCnst (&cst);

	/* Get first face */
	if (Wname[0] != '\0') {
		sts = VLgetVSbeamFace ( Beam, Wname, VL_Q_TOP_SOURCE,
					&w_face, msg);
        	as$status ( sts    = sts,
                    	    msg    = "VLgetVSbeamFace()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		if (Wface)	*Wface = w_face;
	}
	else	w_face = *Wface;
#ifdef TRACE
printf( "\nWeb Face is (%d|%d) in (%d|%d)\n", 
	w_face.obj_id.osnum, w_face.obj_id.objid,
	w_face.mod_env.md_id.osnum, w_face.mod_env.md_id.objid );
#endif

	/* Get first face edges */
	sts = vs$get_surface_edges ( msg      = msg,
				     sfId     = &w_face.obj_id,
				     sfEnv    = &w_face.mod_env,
				     edgeType = VS_K_CONTOUR_EDGES,
				     edCount  = &w_count,
				     edList   = &w_edges );
        as$status ( sts    = sts,
                    msg    = "vs$get_surface_edges()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
for ( i=0; i<w_count; i++)
printf( "\tEdge %d is (%d|%d)\n", i, w_edges[i].osnum, w_edges[i].objid );
#endif

	/* Get second face */
	if (Fname[0] != '\0') {
		sts = VLgetVSbeamFace ( Beam, Fname, VL_Q_TOP_SOURCE,
					&f_face, msg);
        	as$status ( sts    = sts,
                    	    msg    = "VLgetVSbeamFace()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		if (Fface)	*Fface = f_face;
	}
	else	f_face = *Fface;
#ifdef TRACE
printf( "\nFlange Face is (%d|%d) in (%d|%d)\n", 
	f_face.obj_id.osnum, f_face.obj_id.objid,
	f_face.mod_env.md_id.osnum, f_face.mod_env.md_id.objid );
#endif

	/* Get second face edges */
	sts = vs$get_surface_edges ( msg      = msg,
				     sfId     = &f_face.obj_id,
				     sfEnv    = &f_face.mod_env,
				     edgeType = VS_K_CONTOUR_EDGES,
				     edCount  = &f_count,
				     edList   = &f_edges );
        as$status ( sts    = sts,
                    msg    = "vs$get_surface_edges()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
for ( i=0; i<f_count; i++)
printf( "\tEdge %d is (%d|%d)\n", i, f_edges[i].osnum, f_edges[i].objid );
#endif

	/* Make query structure for <common_edge> channel */
	om$get_channel_number ( channame  = "EMSedge.to_common_edge",
                                p_channum = &Cnumber );
	om$make_chanselect ( channum      = Cnumber,
                             p_chanselect = &Cselect );
#ifdef TRACE
printf( "Channel <EMSedge.to_common_edge> is %d\n\n", Cnumber );
#endif

	/* Try to find the common edge between faces */
	for ( i=0; i<w_count; i++) {
#ifdef TRACE
printf( "Web Edge %d is (%d|%d)\n", i, w_edges[i].osnum, w_edges[i].objid );
#endif
		om$get_channel_count ( osnum        = w_edges[i].osnum,
                                       objid        = w_edges[i].objid,
                                       p_chanselect = &Cselect,
                                       count        = &Ccount );

		if (Clist) {    om$dealloc (ptr = Clist); Clist = NULL; }
                Clist = om$calloc ( num       = Ccount,
                                    structure = OM_S_OBJECT_LINKAGE );

                om$get_channel_objects ( osnum        = w_edges[i].osnum,
                                         objid        = w_edges[i].objid,
                                         p_chanselect = &Cselect,
                                         list         = Clist,
                                         size         = Ccount,
                                         count        = &Ccount );

		for ( j=0; j<Ccount; j++) {
#ifdef TRACE
printf( "\tChannel Web Edge %d is (%d|%d)\n", j,
	Clist[j].osnum, Clist[j].S_objid );
#endif
			for ( k=0; k<f_count; k++) {
#ifdef TRACE
printf( "\t\tFlange Edge %d is (%d|%d)\n", k,
	f_edges[k].osnum, f_edges[k].objid );
#endif
				if (  (Clist[j].osnum   == f_edges[k].osnum)
				   && (Clist[j].S_objid == f_edges[k].objid) ) {
					sts = om$send ( msg =
					      message EMSedge.EMget_bcxyz_geom (
							msg,
							&Beam->mod_env.md_env,
							/* &Env->md_env */
							&w_face.obj_id,
							NULL,
							0,
							OM_K_MAXINT,
							FALSE,
							NULL,
							&cv ),
					      senderid = NULL_OBJID,
					      targetid = w_edges[i].objid,
					      targetos = w_edges[i].osnum );
        				as$status (
					sts    = sts,
                    			msg    = "EMSedge.EMget_bcxyz_geom",
                    			test   = (!(sts & 0x00000001 & (*msg))),
                    			action = GOTO_VALUE,
                    			value  = wrapup );

					cst.geometry = (IGRchar *) &cv;
					sts = om$construct (
					classid = OPP_GRbcsubbc_class_id,
					osnum   = Cedge->osnum,
					p_objid = &Cedge->objid,
					msg     = message GRgraphics.GRconstruct
								(&cst) );
        				as$status (
					sts    = sts,
                    			msg    = "om$construct(GRbcsubbc)",
                    			test   =
					(!(sts & 0x00000001 & (*(cst.msg)))),
                    			action = GOTO_VALUE,
                    			value  = wrapup );

#ifdef TRACE
printf( "Edge (%d|%d) is constructed as (%d|%d)\n", 
	w_edges[i].osnum, w_edges[i].objid, Cedge->osnum, Cedge->objid );
#endif
					k = f_count;
					j = Ccount;
					i = w_count;
				}
			}
		}
	}

	/* Kludge for image */
	sts = VLimgKludge ( &Beam->obj_id, Env, Cedge, msg);
        as$status ( sts    = sts,
                    msg    = "VLimgKludge()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	if (cv.weights) { om$dealloc (ptr = cv.weights); cv.weights = NULL; }
	if (cv.knots)   { om$dealloc (ptr = cv.knots);	 cv.knots   = NULL; }
	if (cv.poles)   { om$dealloc (ptr = cv.poles);	 cv.poles   = NULL; }
	if (Clist)      { om$dealloc (ptr = Clist);	 Clist      = NULL; }
	if (f_edges)    { om$dealloc (ptr = f_edges);	 f_edges    = NULL; }
	if (w_edges)    { om$dealloc (ptr = w_edges);	 w_edges    = NULL; }
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLtopStfTpl ( Face, Bedge, Height, Wside, Env, Tedge, msg)

/*d This function computes the top edge of the stiffener template. */

/*h 15/03/94 : creation by Marc Fournier (COC Shipbuilding). */

	struct	GRobj_env	*Face;	/*I Face of the Structural Beam */
	struct	GRid		*Bedge;	/*I Bottom edge of Face 	*/
		IGRdouble	Height;	/*I Height of Stiff Template	*/
		IGRdouble	Wside;	/*I Web side of Stiff Template	*/
	struct	GRmd_env	*Env;	/*I Local environment		*/
	struct	GRid		*Tedge;	/*O Top edge of Stiff Template 	*/
		IGRlong		*msg;	/*O  Completion code		*/

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i;
	struct	IGRbsp_surface	*sf;
		IGRpoint	Bspt, Bept, Tspt, pnt;
	struct	GRparms		Bsparm, Beparm, Tsparm;
		IGRboolean	Uiso=TRUE, iso=TRUE;
		BSrc		rc;
		IGRvector	vec;
		IGRdouble	len;
	struct	GRvg_construct	cst;

	/* Initialize */
	sf	     = NULL;
	Tedge->objid = NULL_OBJID;
	Tedge->osnum = Env->md_id.osnum;
	VLinitCnst (&cst);

	/* Get the face geometry */
	sts = VLgetGeometry ( Face, FALSE, NULL_OBJID, (IGRchar **)&sf, msg);
        as$status ( sts    = sts,
                    msg    = "VLgetGeometry()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get extremity points of Bottom edges */
	sts = VLendpts ( msg, Bedge, Env, Bspt, Bept);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get start point parameters */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Face->mod_env.md_env.matrix_type,
					Face->mod_env.md_env.matrix,
					Bspt, pnt, &Bsparm ),
			senderid = NULL_OBJID,
			targetid = Face->obj_id.objid,
			targetos = Face->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRptproject",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

#ifdef TRACE
printf( "Start  : [%g,%g,%g]\t--> [%g,%g,%g]\tU=%g, V=%g\n",
	Bspt[0], Bspt[1], Bspt[2], pnt[0], pnt[1], pnt[2], Bsparm.u, Bsparm.v );
#endif
	/* Get end point parameters */
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Face->mod_env.md_env.matrix_type,
					Face->mod_env.md_env.matrix,
					Bept, pnt, &Beparm ),
			senderid = NULL_OBJID,
			targetid = Face->obj_id.objid,
			targetos = Face->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRptproject",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "End    : [%g,%g,%g]\t--> [%g,%g,%g]\tU=%g, V=%g\n",
	Bept[0], Bept[1], Bept[2], pnt[0], pnt[1], pnt[2], Beparm.u, Beparm.v );
#endif
	/* Determine if bottom edge is an U/V isoparametric */
	if	(fabs ( Bsparm.u - Beparm.u) < 1e-6)	Uiso = TRUE;
	else if	(fabs ( Bsparm.v - Beparm.v) < 1e-6)    Uiso = FALSE;
	else {	printf( "Error : Spt (U=%g|V=%g)\tEpt (U=%g|V=%g)\n",
			Bsparm.u, Bsparm.v, Beparm.u, Beparm.v );
		*msg = MSFAIL;	goto wrapup;	}
#ifdef TRACE
printf( "Bottom edge is an U-isoparametric curve : %d\n", Uiso);
#endif
	/* Determine maximum height of template */
	if (Uiso)	BSsfeval ( sf, 1.0 - Bsparm.u, Bsparm.v, 0, &pnt, &rc);
	else		BSsfeval ( sf, Bsparm.u, 1.0 - Bsparm.v, 0, &pnt, &rc);
			if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
#ifdef TRACE
printf( "Ortho start point : [%g,%g,%g]\n", pnt[0], pnt[1], pnt[2] );
#endif
	BSmkvec ( &rc, vec, Bspt, pnt);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	len = BSlenvec ( &rc, vec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if ( (len < Height) && (Wside == VAL_TO_WEBR) )	len = Height;
#ifdef TRACE
printf( "Hface=%g, Htemplate=%g\n", len, Height);
#endif
	/* Determine height point */
	BSnorvec ( &rc, vec);
	for ( i=0; i<3; i++)	Tspt[i] = Bspt[i] + Height * vec[i];
	sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Face->mod_env.md_env.matrix_type,
					Face->mod_env.md_env.matrix,
					Tspt, pnt, &Tsparm ),
			senderid = NULL_OBJID,
			targetid = Face->obj_id.objid,
			targetos = Face->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRptproject",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Height : [%g,%g,%g]\t--> [%g,%g,%g]\tU=%g, V=%g\n",
	Tspt[0], Tspt[1], Tspt[2], pnt[0], pnt[1], pnt[2], Tsparm.u, Tsparm.v );
#endif
	/* Create isoparametric "top edge" curve */
	if (Uiso)	Tsparm.v = -1.0;
	else		Tsparm.u = -1.0;
	sts = VLretrieveIsoOrEdg ( msg, Face, Tspt, FALSE, Tsparm.u, Tsparm.v,
				   Env, &cst, &iso, Tedge);
        as$status ( sts    = sts,
                    msg    = "VLretrieveIsoOrEdg",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Isocurve (U=%g|V=%g) is (%d|%d)\n",
	Tsparm.u, Tsparm.v, Tedge->osnum, Tedge->objid );
#endif

wrapup:
	if (sf) {	om$dealloc (ptr = sf);	sf = NULL;	}
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLcontourStfTpl ( Bedge, Tedge, Env, dTol, bTol, Contour, msg)

/*d This function constructs the contour of the stiffener template. */

/*h 16/03/94 : creation by Marc Fournier (COC Shipbuilding). */

	struct	GRid		*Bedge;		/*I Bottom edge of Face */
	struct	GRid		*Tedge;		/*I Bottom edge of Face */
	struct	GRmd_env	*Env;		/*I Local environment	*/
		IGRdouble	dTol;		/*I Distance tolerance	*/
		IGRdouble	bTol;		/*I Base tolerance	*/
	struct	GRid		*Contour;	/*O Template contour 	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i;
		IGRshort	Inv[4];
		IGRboolean	adj, clo;
	struct	GRvg_construct	cst;
	struct	GRobj_env	Icv[4], Ocv[4];
	struct	GRlc_info	Ecv[4];
		IGRpoint	lpt[4];

	/* Initialize */
	for ( i=0; i<4; i++) {
		Icv[i].mod_env = *Env;
		Ocv[i].mod_env = *Env;
	}
	Icv[0].obj_id = *Bedge;
	Icv[1].obj_id = *Tedge;
	VLinitCnst (&cst);

	/* Extracts extremities */
	sts = VLorderedEndpts ( Bedge, Tedge, Env, lpt, msg);
        as$status ( sts    = sts,
                    msg    = "VLorderedEndpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create first side curve */
        sts = VLcreateLineSeg ( lpt[0], lpt[1], &Icv[2].mod_env, &cst,
                                  &Icv[2].obj_id, msg);
        as$status ( sts    = sts,
                    msg    = "VLcreateLineSeg()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create second side curve */
        sts = VLcreateLineSeg ( lpt[2], lpt[3], &Icv[3].mod_env, &cst,
                                  &Icv[3].obj_id, msg);
        as$status ( sts    = sts,
                    msg    = "VLcreateLineSeg()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Order contour curves */
	OrderCrv ( Icv, 4, dTol, bTol, Ocv, Inv, &adj, &clo, msg);
        if (*msg != BSSUCC) {   printf( "Error in OrderCrv()\n");
                                *msg = MSFAIL; goto wrapup;     }

	/* Build contour curves */
	for ( i=0; i<4; i++) {  Ecv[i].module_info = Ocv[i].mod_env;
                                Ecv[i].located_obj = Ocv[i].obj_id;     }
	BuildCrv ( (IGRshort)3, Ocv, 4, Inv, adj, clo, Ecv, &cst, Contour, msg);
        if (*msg != BSSUCC) {   printf( "Error in BuildCrv()\n");
                                *msg = MSFAIL; goto wrapup;     }

	*msg = MSSUCC;

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLorderedEndpts ( Master, Slave, Env, Extrem, msg)

/*d This function extracts and reorder the endpoints of two curves. The first
curve give the general direction start --> end. */

/*h 16/03/94 : creation by Marc Fournier (COC Shipbuilding). */

	struct	GRid		*Master;	/*I Master curve	*/
	struct	GRid		*Slave;		/*I Slave curve		*/
	struct	GRmd_env	*Env;		/*I Local environment	*/
		IGRpoint	Extrem[];	/*O Extremities		*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS;
		IGRpoint	spt[2], ept[2];
		IGRvector	Mvec, Svec;
		BSrc		rc;

	/* Extract endpoints of master curve */
	sts = VLendpts ( msg, Master, Env, spt[0], ept[0]);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Select endpoints */
	BSmkvec ( &rc, Mvec, spt[0], ept[0]);
        if (rc != BSSUCC) {	printf( "Error in BSmkvec()\n");
                                *msg = MSFAIL; goto wrapup;     }

	/* Extract endpoints of slave curve */
	sts = VLendpts ( msg, Slave, Env, spt[1], ept[1]);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Select endpoints */
	BSmkvec ( &rc, Svec, spt[1], ept[1]);
        if (rc != BSSUCC) {	printf( "Error in BSmkvec()\n");
                    
            *msg = MSFAIL; goto wrapup;     }

	/* Fill extremities */
	dblcpy ( Extrem[0], spt[0], 3);
	dblcpy ( Extrem[2], ept[0], 3);
	if (BSdotp ( &rc, Mvec, Svec) >= 0) {
		dblcpy ( Extrem[1], spt[1], 3);
		dblcpy ( Extrem[3], ept[1], 3);	}
	else {	dblcpy ( Extrem[1], ept[1], 3);
		dblcpy ( Extrem[3], spt[1], 3);	}
        if (rc != BSSUCC) {	printf( "Error in BSdotp()\n");
                                *msg = MSFAIL; goto wrapup;     }

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLtextStfTpl ( Bedge, Tedge, Extrem, Vertex, TagNam, nvtx,
		      Env, Qline, Qlist, Xinv, Text, Line, msg)

/*d This function prepares the creation of the texts and linesegs feet of Stiffener Templates */

/*h 16/03/94 : creation by Marc Fournier (COC Shipbuilding). */

	struct	GRid		*Bedge;		/*I Bottom extended	*/
	struct	GRid		*Tedge;		/*I Top extended	*/
		IGRpoint	Extrem[];	/*I Extremities' array	*/
		IGRpoint	Vertex[];	/*I Vertices' array	*/
		IGRchar		TagNam[];	/*I Tag names array	*/
		IGRint		nvtx;		/*I Number of vertices	*/
	struct	GRmd_env	*Env;		/*I Local environment	*/
		VLquLine	Qline[];	/*I Check line array	*/
	struct	GRobj_env	Qlist[];	/*I object line array	*/
		IGRdouble	Xinv;	 	/*I Image inverse X	*/
	struct	GRid		Text[];		/*O $ texts		*/
	struct	GRid		Line[];		/*O Line segments	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, j, clid, cnt=0;
		IGRpoint	spt, ept;

	/* Endpoints of Bedge (extended) */
	sts = VLendpts ( msg, Bedge, Env, spt, ept);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create marks and lines for start/end side */
	for ( i=0; i<2; i++) {
		sts = VLmarkStfTpl ( Extrem[2*i], "$", ept, Tedge, Env, 
			      	     NULL, 0.8, Xinv, &Text[i], &Line[i], msg);
       		as$status ( sts    = sts,
	                    msg    = "VLmarkStfTpl()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	      	            action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Create marks and lines for vertices */
	for ( i=0; i<nvtx; i++) {

		clid = -1;
		for ( j=0; j<IDX_SC_LINE; j++) {
			VLfilterDef ( 1, &Qlist[i], &cnt, Qline[j].dname);
			if (cnt) { clid = j; j = IDX_SC_SIZE; }
		}
		if (clid == -1) {
			if (vs$is_ancestry_valid
				( object  = &Qlist[i].obj_id,
				  classid = Qline[IDX_SC_MACR].claid ) )
			 clid = j;
		}
		if (clid == -1) {
			printf( "Trouble in the force ...\n");
			*msg = MSFAIL;	goto wrapup;
		}

		if (Qline[clid].plane) {
			sts = VLmarkStfTpl ( Vertex[i], &TagNam[80*i],
					     ept, Tedge, Env, &Qlist[i], 0.5,
					     Xinv, &Text[2+i], &Line[2+i], msg);
			if (!(sts & 0x00000001 & (*msg)))
			sts = VLmarkStfTpl ( Vertex[i], &TagNam[80*i],
					     ept, &Line[0], Env, &Qlist[i], 0.5,
					     Xinv, NULL, &Line[2+i], msg);
			if (!(sts & 0x00000001 & (*msg)))
			sts = VLmarkStfTpl ( Vertex[i], &TagNam[80*i],
					     ept, &Line[1], Env, &Qlist[i], 0.5,
					     Xinv, NULL, &Line[2+i], msg);
		}
		else	sts = VLmarkStfTpl ( Vertex[i], &TagNam[80*i],
					     ept, Tedge, Env, NULL, 0.5,
					     Xinv, &Text[2+i], &Line[2+i], msg);
      		as$status ( sts    = sts,
                    	    msg    = "VLmarkStfTpl()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLmarkStfTpl ( Point, Tname, Track, Tedge, Env, Ortho, Weight, Xinv,
		      Text, Line, msg)

/*d This function creates the texts and linesegs feet of Stiffener Templates.
    If Ortho isn't set to NULL the line segment created in it's plane */

/*h 16/03/94 : creation by Marc Fournier (COC Shipbuilding). */

		IGRpoint	Point;   	/*I Work point		*/
		IGRchar		*Tname;		/*I Work text		*/
		IGRpoint	Track;   	/*I X direction point	*/
	struct	GRid		*Tedge;		/*I Top curve		*/
	struct	GRmd_env	*Env;		/*I Local environment	*/
	struct	GRobj_env	*Ortho;		/*I Source line object	*/
		IGRdouble	Weight;		/*I Text on Line	*/
		IGRdouble	Xinv;	 	/*I Image inverse X	*/
	struct	GRid		*Text;		/*O Mark text		*/
	struct	GRid		*Line;		/*O Line segment	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, len, nint=0, nseg=0;
	struct	GRvg_construct	cst;
		IGRchar		txt[DI_PATH_MAX];
	struct	GRparms		parm;
		IGRpoint	pnt, Opt[3], Tpnt;
		IGRvector	xvec, yvec, zvec, Onm[3];
		IGRmatrix	loc_mat;
		BSrc		rc;
	struct	GRdpb_text_symb	text_symb;
		IGRint		size=sizeof(struct GRdpb_text_symb);
		IGRlong		ret;
	struct	GRobj_env	Edge;
	struct	IGRbsp_curve	*Ecv, *Ocv;
		IGRdouble	*a, *b, *u, *pt;

	/* Initialize */
	*msg = MSSUCC;
	Ecv  = NULL;
	Ocv  = NULL;
	a    = NULL;
	b    = NULL;
	u    = NULL;
	pt   = NULL;

	if (Ortho) {

		/* Get source line geometry */
		sts = VLgetGeometry ( Ortho, FALSE, NULL_OBJID,
			       	       (IGRchar **) &Ocv, msg);
		as$status ( sts    = sts,
		            msg    = "VLgetGeometry()",
		            test   = (!(sts & 0x00000001 & (*msg))),
		            action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get 3 points of source line */
		BScveval ( Ocv, 0.0, 0, &Opt[0], &rc);
        	if (rc != BSSUCC) {	printf( "Error in BScveval()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BScveval ( Ocv, 0.5, 0, &Opt[1], &rc);
        	if (rc != BSSUCC) {	printf( "Error in BScveval()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BScveval ( Ocv, 1.0, 0, &Opt[2], &rc);
        	if (rc != BSSUCC) {	printf( "Error in BScveval()\n");
                                	*msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "Points  : [%g,%g,%g], [%g,%g,%g], [%g,%g,%g]\n",
	Opt[0][0], Opt[0][1], Opt[0][2],
	Opt[1][0], Opt[1][1], Opt[1][2],
	Opt[2][0], Opt[2][1], Opt[2][2] );
#endif
		/* Make 3 vectors of source line plane */
		BSmkvec ( &rc, Onm[0], Opt[1], Opt[0]);
        	if (rc != BSSUCC) {	printf( "Error in BSmkvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BSmkvec ( &rc, Onm[1], Opt[1], Opt[2]);
        	if (rc != BSSUCC) {	printf( "Error in BSmkvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BScrossp ( &rc, Onm[0], Onm[1], Onm[2]);
        	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
                                	*msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "Vectors : [%g,%g,%g], [%g,%g,%g], [%g,%g,%g]\n",
	Onm[0][0], Onm[0][1], Onm[0][2],
	Onm[1][0], Onm[1][1], Onm[1][2],
	Onm[2][0], Onm[2][1], Onm[2][2] );
#endif
		BSnorvec ( &rc, Onm[2]);
        	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }

		/* Get edge line geometry */
		Edge.mod_env = *Env;
		Edge.obj_id  = *Tedge;
		sts = VLgetGeometry ( &Edge, FALSE, NULL_OBJID,
			       	       (IGRchar **) &Ecv, msg);
		as$status ( sts    = sts,
		            msg    = "VLgetGeometry()",
		            test   = (!(sts & 0x00000001 & (*msg))),
		            action = GOTO_VALUE,
	                    value  = wrapup );

		/* Allocate memory for outputs */
		pt = om$calloc ( num = 3*Ecv->num_poles, structure = IGRdouble);
		u  = om$calloc ( num =   Ecv->num_poles, structure = IGRdouble);
		a  = om$calloc ( num =   Ecv->num_poles, structure = IGRdouble);
		b  = om$calloc ( num =   Ecv->num_poles, structure = IGRdouble);

		BSpl_cv_int ( &rc, Ecv, Opt[1], Onm[2],
			      &nint, pt, u, &nseg, a, b );
#ifdef TRACE
printf( "BSpl_cv_int() returns rc=%d, nint=%d, nseg=%d, pt=[%g,%g,%g]\n",
	rc, nint, nseg, pt[0], pt[1], pt[2] );
#endif
        	if ( (rc != BSSUCC) || (!nint) ) {
			*msg = MSFAIL; goto wrapup;     }
		else	dblcpy ( pnt, &pt[0], 3 );
	}
	else {	/* Project Point of Tedge */
		sts = om$send ( msg = message GRgraphics.GRptproject (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						Point, pnt, &parm ),
				senderid = NULL_OBJID,
				targetid = Tedge->objid,
				targetos = Tedge->osnum );
        	as$status ( sts    = sts,
	                    msg    = "GRgraphics.GRptproject",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Create line segment */
	if (Line) {
		VLinitCnst (&cst);
		Line->objid = NULL_OBJID;
		Line->osnum = Env->md_id.osnum;
		sts = VLcreateLineSeg ( pnt, Point, Env, &cst, Line, msg);
        	as$status ( sts    = sts,
	                    msg    = "VLcreateLineSeg()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	/* Create mark text */
	if (Text) {

		if ( (Weight < 0.0) || (Weight > 0.99) )	Weight = 1.0;
		for ( i=0; i<3; i++)	Tpnt[i] = Weight * Point[i]
						+ (1.0 - Weight) * pnt[i];

		/* Construct text placement matrix */
		for ( i=0; i<3; i++) {	xvec[i] = Track[i] - Tpnt[i];
					yvec[i] = pnt[i]   - Tpnt[i];	}
		BSnorvec ( &rc, xvec);
        	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BSnorvec ( &rc, yvec);
        	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BScrossp ( &rc, xvec, yvec, zvec);
        	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BSnorvec ( &rc, zvec);
        	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BScrossp ( &rc, yvec, zvec, xvec);
        	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
                                	*msg = MSFAIL; goto wrapup;     }
		BSnorvec ( &rc, xvec);
        	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
                                	*msg = MSFAIL; goto wrapup;     }

		for ( i=0; i<3; i++) {	loc_mat[4*i+0] = xvec[i] * Xinv;
					loc_mat[4*i+1] = yvec[i];
					loc_mat[4*i+2] = zvec[i];
					loc_mat[4*i+3] = Tpnt[i];
					loc_mat[12+i]  = 0.0;	}
		loc_mat[15] = 1.0;

		/* Retrieve text symbology */
        	gr$get_text_symb ( msg    = msg,
	                           sizbuf = &size,
       	   		           buffer = &text_symb,
                	           nret   = &ret );

		/* Define text parameters */
		Text->objid = NULL_OBJID;
		Text->osnum = Env->md_id.osnum;
		txt[0] = '\0';
		sprintf ( txt, "%s", Tname);
		len = strlen (txt);
		text_symb.Active_just = CENTER_CAP;

		/* Place text */
		sts = co$place_text ( msg	  = msg,
				      text_string = txt,
				      text_length = &len,
				      lbs_matrix  = loc_mat,
				      origin	  = Tpnt,
				      TextSymb	  = &text_symb,
				      mode	  = GRbe,
				      flags	  = 1,
				      buffer	  = Text );
        	as$status ( sts    = sts,
	                    msg    = "co$place_text()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup:
	if (pt)  {	om$dealloc (ptr = pt);	pt  = NULL;	}
	if (u)   {	om$dealloc (ptr = u);	u   = NULL;	}
	if (b)   {	om$dealloc (ptr = b);	b   = NULL;	}
	if (a)   {	om$dealloc (ptr = a);	a   = NULL;	}
	if (Ocv) {	om$dealloc (ptr = Ocv);	Ocv = NULL;	}
	if (Ecv) {	om$dealloc (ptr = Ecv);	Ecv = NULL;	}
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLsortVertex (	VLstfTpl	*a,	VLstfTpl	*b	)
{
	return ( (a->len == b->len) ? 0 : (a->len < b->len) ? -1 : 1 );
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLqueryStfTpl (

	struct	GRobj_env	*Surf,	/*I Surface for range query	*/
	struct	GRobj_env	*Stf,	/*I Stiffener processed		*/
		VLquLine	Qline[],/*I Array of class ID for filter*/
		IGRdouble	Extd,	/*I Surface extension value	*/
	struct	GRmd_env	*Env,	/*I Local environment		*/
		IGRint		*nlin,	/*O Number of lines		*/
	struct	GRobj_env	**Line,	/*O Lines array 		*/
		IGRint		*nmac,	/*O Number of macros		*/
	struct	GRobj_env	**Macr,	/*O Macros array 		*/
		IGRlong		*msg	/*O Completion code		*/
)

/*d This function queries, filters and sorts objects.
    Ouput vertices that are the projection of minimum distance points.
    There are ordered from start to end of Line. */

/*h 17/03/94 : creation by Marc Fournier (COC Shipbuilding). */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, ncla=0, nsum=0;
	struct	GRmd_env	loc_env;
	struct	GRobj_env	Extended;
	struct	GRvg_construct	cst;
	struct	IGRbsp_surface	*surf_sf, *extd_sf;
		IGRshort	world=TRUE;
		GRrange		range;
		IGRlong		loc_msg;
		IGRboolean	srf_flag=FALSE, stf_flag=FALSE;

	/* Initialize */
	loc_env = *Env;
	ex$get_modid ( mod_osnum = loc_env.md_id.osnum,
                       mod_id    = &loc_env.md_id.objid );
	VLinitCnst (&cst);
	surf_sf = NULL;
	extd_sf = NULL;
	*nlin = 0;	*Line = NULL;
	*nmac = 0;	*Macr = NULL;

	/* What query ? */
	for ( i=0; i<IDX_SC_LINE; i++) {
		if (Qline[i].query) {	srf_flag = TRUE;
					i = IDX_SC_LINE;	}
	}
        if (Qline[IDX_SC_MACR].query) 	stf_flag = TRUE;

	/* Query lines on/thru surface */
	if (srf_flag) {

		/* Extend surface (if needed) */
		if (Extd <= 0.0)	Extended = *Surf;
		else {	/* Retrieve surface geometry */
			sts = VLgetGeometry ( Surf, FALSE, NULL_OBJID,
					      (IGRchar **) &surf_sf, msg);
			as$status ( sts    = sts,
		                    msg    = "VLgetGeometry()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Extend surface geometry */
			sts = extent_surface_geom ( surf_sf, Extd, &extd_sf);
			as$status ( sts    = sts,
		                    msg    = "extent_surface_geom()",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
			if (surf_sf) {	om$dealloc (ptr = surf_sf);
					surf_sf = NULL;	}

			/* Construct extended surface */
			cst.geometry = (IGRchar *) extd_sf;
			Extended.obj_id.objid = NULL_OBJID;
			Extended.obj_id.osnum = Env->md_id.osnum;
			Extended.mod_env      = *Env;
	        	sts = om$construct (classid = OPP_EMSsubbs_class_id,
 	                            	    osnum   = Extended.obj_id.osnum,
	                             	    p_objid = &Extended.obj_id.objid,
	                             	    msg =
					    message GRgraphics.GRconstruct
							(&cst) );
	        	as$status ( sts    = sts,
		                    msg    = "om$construct(EMSsubbs)",
		                    test   = (!(sts&0x00000001&(*(cst.msg)))),
		       	            action = GOTO_VALUE,
		                    value  = wrapup );
			if (extd_sf) {	om$dealloc (ptr = extd_sf);
					extd_sf = NULL;	}
		}

		/* Get GRrange of (extended) surface */
		sts = om$send ( msg = message GRgraphics.GRgetrang (
                                        msg,
                                        &Extended.mod_env.md_env.matrix_type,
                                        Extended.mod_env.md_env.matrix,
                                        &world,
                                        range ),
				senderid = NULL_OBJID,
	                        targetid = Extended.obj_id.objid,
	                        targetos = Extended.obj_id.osnum );
		if ( (Extended.obj_id.objid != NULL_OBJID) && (Extd > 0.0) )
			gr$delete_object ( msg          = &loc_msg,
	                                   md_env       = &Extended.mod_env,
	                                   object_id    = &Extended.obj_id,
	                                   display_flag = 0 );
	        as$status ( sts    = sts,
	                    msg    = "GRgraphics.GRgetrang",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Send a (surface) range query */
		VLrLocRef ( range, nlin, Line, &loc_env);
#ifdef TRACE
printf( "VLrLocRef() returns %d objects\n", *nlin);
#endif
		/* Filter lines */
		if (*nlin) {
			nsum    = (*nlin);
			(*nlin) = 0;
			for ( i=0; i<IDX_SC_LINE; i++) {
				ncla = 0;
				if (Qline[i].query) {
					VLfilterDef ( nsum, &(*Line)[(*nlin)],
						      &ncla, Qline[i].dname );
#ifdef TRACE
printf( "\tVLfilterDef (%d objects) with <%s> and retains %d ...\n",
	nsum, Qline[i].dname, ncla);
#endif
					nsum    -= ncla;
					(*nlin) += ncla;
				}
			}
		}
	}

	/* Query macros on/thru stiffener */
	if (stf_flag) {
#ifdef TRACE
printf( "VLgetMacOnStiff on (%d|%d), (%d|%d)\n",
	Stf->obj_id.osnum, Stf->obj_id.objid,
	loc_env.md_id.osnum, loc_env.md_id.objid );
#endif
		sts = VLgetMacOnStiff ( Stf, &loc_env, nmac, Macr);
		as$status ( sts    = sts,
	                    msg    = "VLgetMacOnStiff()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
#ifdef TRACE
printf( "VLgetMacOnStiff() returns %d objects\n", *nmac);
for ( i=0; i<*nmac; i++)
printf( "\tMacro %2d is (%d,%d)\n", i, 
	(*Macr)[i].obj_id.osnum, (*Macr)[i].obj_id.objid );
#endif
	}

wrapup:
	if (extd_sf) {	om$dealloc (ptr = extd_sf);	extd_sf = NULL;	}
	if (surf_sf) {	om$dealloc (ptr = surf_sf);	surf_sf = NULL;	}
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
void	VLelimVertex ( 		IGRint		cnt,
				VLstfTpl	Vtx[],
				IGRint		*num	)
{
		IGRint		i, j;
		IGRlong		msg;
		IGRdouble	cht=0;

	/* Get CHT tolerance from system */
	BSxtractpar ( &msg, BSTOLCHRDHT, &cht);

	/* Eliminate coexistant vertices */
	for ( i=1; i<cnt; i++) {
		if (fabs(Vtx[i-1].len-Vtx[i].len) < cht) {
			if (Vtx[i-1].idx < Vtx[i].idx)	Vtx[i] = Vtx[i-1];
			for ( j=i; j<cnt; j++)		Vtx[j-1] = Vtx[j];
			i--;
			cnt--;
		}
	}

	/* New number of vertices */
	(*num) = cnt;
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLvertexStfTpl ( nlst, List, nmac, Macr, Line, Dist, spt, ept, Qline,
			attr, nvtx, Vtx, Tag, msg)

		IGRint		nlst;	 /*I  Number of queried objects	  */
	struct	GRobj_env	List[];  /*IO Array of queried objects	  */
		IGRint		nmac;	 /*I  Number of queried macros	  */
	struct	GRobj_env	Macr[];  /*I  Array of queried macros	  */
	struct	GRobj_env	*Line;	 /*I  Line for geometric filter	  */
		IGRdouble	Dist;	 /*I  Geometric filter tolerance  */
		IGRpoint	spt;	 /*I  Line (unextended) start pt  */
		IGRpoint	ept;	 /*I  Line (unextended) end   pt  */
		VLquLine	Qline[]; /*I  Array of class ID for filter*/
	struct	ACrg_coll	**attr;	 /*IO Attributes box		  */
		IGRint		*nvtx;	 /*O  Number of vertices	  */
		IGRpoint	**Vtx;	 /*O  Vertices ordered along Line */
		IGRchar		**Tag;	 /*O  Tag names ordered along Line*/
		IGRlong		*msg;	 /*O  Completion code		  */

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, j, nmdi=0, cnt=0;
		IGRpoint	*line_pt, *test_pt, pnt;
	struct	IGRbsp_curve	*line_cv, *test_cv;
		VLstfTpl	*sort_vx;
		IGRdouble	*line_pa, *test_pa, dist=0.0, len;
		BSrc		rc;
		IGRvector	Svec, Evec;
	struct	GRobj_env	*Rlist, Foot;
		IGRmatrix	mat1, mat2;
	struct	GRparms		parm;
		IGRshort	four=4;

	/* Initialize */
	line_cv = NULL;
	test_cv = NULL;
	sort_vx = NULL;
	line_pa = NULL;
	test_pa = NULL;
	line_pt = NULL;
	test_pt = NULL;
	Rlist   = NULL;
	*nvtx   = 0;
	*Vtx    = NULL;
	*Tag    = NULL;
	(*attr)[IDX_SB_TNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_BNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_CNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_SNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_WNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_XNUM].desc.value.att_exp = 0.0;

	/* Get line geometry */
	sts = VLgetGeometry ( Line, FALSE, NULL_OBJID,
			      (IGRchar **) &line_cv, msg);
	as$status ( sts    = sts,
	            msg    = "VLgetGeometry()",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );

	/* Allocate memory for vertices sorting array */
        sort_vx = om$calloc ( num       = nlst+nmac,
                              structure = VLstfTpl );

	/* Allocate memory for resulting list */
        Rlist = om$calloc ( num       = nlst+nmac,
                            structure = struct GRobj_env );

	/* Loop on queried macros */
	for ( i=0; i<nmac; i++) {

		/* Retrieve "cs" foot */
		sts = vl$return_foot ( msg     = msg,
				       name    = "cs",
				       objId   = &Macr[i].obj_id,
				       objEnv  = &Macr[i].mod_env,
				       footId  = &Foot.obj_id,
				       footEnv = &Foot.mod_env );
		if (!(sts & 0x00000001 & (*msg))) {
			sts  = OM_S_SUCCESS;
			*msg = MSSUCC;
			continue;
		}

		/* Get "cs" matrix */
		sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, mat1),
				senderid = NULL_OBJID,
                                targetid = Foot.obj_id.objid,
                                targetos = Foot.obj_id.osnum );
		if (!(sts & 0x00000001 & (*msg))) {
			sts  = OM_S_SUCCESS;
			*msg = MSSUCC;
			continue;
		}

		/* Apply transformation matrix */
		MAmulmx ( &rc, &four, &four, &four,
			  Foot.mod_env.md_env.matrix, mat1, mat2 );
		pnt[0] = mat2[3];
                pnt[1] = mat2[7];
                pnt[2] = mat2[11];

		/* Project center of "cs" matrix on bottom edge */
		sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Line->mod_env.md_env.matrix_type,
					Line->mod_env.md_env.matrix,
					pnt, sort_vx[*nvtx].pnt, &parm ),
				senderid = NULL_OBJID,
                                targetid = Line->obj_id.objid,
                                targetos = Line->obj_id.osnum );
		if (!(sts & 0x00000001 & (*msg))) {
			sts  = OM_S_SUCCESS;
			*msg = MSSUCC;
			continue;
		}

		/* Fill the vertex area */
		BSmkvec ( &rc, Svec, spt, sort_vx[*nvtx].pnt );
		sort_vx[*nvtx].len = BSlenvec ( &rc, Svec);
		sort_vx[*nvtx].idx = *nvtx;
		sort_vx[*nvtx].typ = IDX_SC_MACR;

		sts = VLgetMacroNames ( &Macr[i], sort_vx[*nvtx].nam,
				        sort_vx[*nvtx].tag, msg );
                as$status ( sts    = sts,
                            msg    = "VLgetMacroNames()",
                            test   = (!(sts & 0x00000001 & (*msg))),
       	                    action = GOTO_VALUE,
                            value  = wrapup );

		/* Store macros in resulting list */
		Rlist[*nvtx] = Macr[i];

		/* Increment values */
		(*nvtx)++;
	}

	/* Loop on queried lines */
	for ( i=0; i<nlst; i++) {

		if (test_pa) { om$dealloc (ptr = test_pa); test_pa = NULL; }
                if (line_pa) { om$dealloc (ptr = line_pa); line_pa = NULL; }
                if (test_cv) { om$dealloc (ptr = test_cv); test_cv = NULL; }
                if (test_pt) { om$dealloc (ptr = test_pt); test_pt = NULL; }
                if (line_pt) { om$dealloc (ptr = line_pt); line_pt = NULL; }

                sts = VLgetGeometry ( &List[i], FALSE, NULL_OBJID,
                                      (IGRchar **)&test_cv, msg);
                as$status ( sts    = sts,
                            msg    = "VLgetGeometry()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

                BSmdistcvcv ( line_cv, test_cv, &nmdi, &line_pa, &test_pa,
                              &line_pt, &test_pt, &dist, &rc );
                if (rc != BSSUCC) {     printf( "Error in BSmdistcvcv()\n");
                                        *msg = MSFAIL; goto wrapup;     }
#ifdef TRACE
printf( "List[%2d]\tnmdi=%d, dist=%g\n", i, nmdi, dist);
#endif
		VLfilterDef ( 1, &List[i], &cnt, Qline[IDX_SC_MRKL].dname);
		if (cnt) {
#ifdef TRACE
printf( "Marking Line (%d|%d) : nmdi = %d\n",
	List[i].obj_id.osnum, List[i].obj_id.objid, nmdi);
#endif
			sort_vx[*nvtx].typ = IDX_SC_MRKL;
			if (nmdi > 1)	continue;
		}

                if ( (nmdi > 0) && (dist < Dist) ) {

                        BSmkvec ( &rc, Svec, spt, line_pt[0] );
                        sort_vx[*nvtx].len = BSlenvec ( &rc, Svec);
                        BSmkvec ( &rc, Evec, ept, line_pt[0] );
                        len = BSlenvec ( &rc, Evec);

                        if ( (sort_vx[*nvtx].len > Dist) && (len > Dist) ) {
				dblcpy ( sort_vx[*nvtx].pnt, line_pt[0], 3);
                                sort_vx[*nvtx].idx = *nvtx;
				sts = VLgetLineNames ( &List[i], Qline,
						       sort_vx[*nvtx].nam,
						       sort_vx[*nvtx].tag, msg);
		                as$status ( sts    = sts,
		                            msg    = "VLgetLineNames()",
		                            test   =
						(!(sts & 0x00000001 & (*msg))),
		       	                    action = GOTO_VALUE,
		                            value  = wrapup );

				for ( j=0; j<IDX_SC_LINE; j++) {
					VLfilterDef ( 1, &List[i],
						      &cnt, Qline[j].dname);
					if (cnt) {
						Rlist[*nvtx] = List[i];
						sort_vx[*nvtx].typ = j;
						j = IDX_SC_LINE;
					}
				}

                                (*nvtx)++;
                        }
                }
	}

	/* Sort vertices from extended start point to extended end point*/
        qsort ( sort_vx, *nvtx, sizeof(VLstfTpl), (int (*)())VLsortVertex);
	VLelimVertex ( *nvtx, sort_vx, nvtx);
#ifdef TRACE
for ( i=0; i<*nvtx; i++)
printf( "Vtx %2d from %-10s\tabs=%g\tidx=%d\ttyp=%d\n", i,
	sort_vx[i].nam, sort_vx[i].len, sort_vx[i].idx, sort_vx[i].typ );
#endif

	/* Fill the ACrg_collection */
	for ( i=0; i<*nvtx; i++) {

		(*attr)[IDX_SB_TNUM].desc.value.att_exp += 1.0;

		switch (sort_vx[i].typ) {
		case IDX_SC_BUTT :
			(*attr)[IDX_SB_BNUM].desc.value.att_exp += 1.0;
			break;
		case IDX_SC_CTRL :
			(*attr)[IDX_SB_CNUM].desc.value.att_exp += 1.0;
			break;
		case IDX_SC_MRKL :
			(*attr)[IDX_SB_MNUM].desc.value.att_exp += 1.0;
			break;
		case IDX_SC_SEAM :
			(*attr)[IDX_SB_SNUM].desc.value.att_exp += 1.0;
			break;
		case IDX_SC_WATL :
			(*attr)[IDX_SB_WNUM].desc.value.att_exp += 1.0;
			break;
		case IDX_SC_TRAC :
			(*attr)[IDX_SB_YNUM].desc.value.att_exp += 1.0;
			break;
		case IDX_SC_MACR :
			(*attr)[IDX_SB_XNUM].desc.value.att_exp += 1.0;
			break;
		default :
			printf( "Unknown case %d\n", sort_vx[i].typ);
		}

		strcpy ( (*attr)[IDX_SB_PVAR+i].desc.value.att_txt,
			 sort_vx[i].nam );
	}
        /* Allocate memory for vertices' array */
        (*Vtx) = om$calloc ( num = *nvtx, structure = IGRpoint );

	/* Allocate memory for tag names array */
	(*Tag) = om$calloc ( num = (*nvtx) * 80, structure = IGRchar );

        /* Store sorted vertices in vertices' array and update Qlist */
        for ( i=0; i<*nvtx; i++) {
		dblcpy ( (*Vtx)[i], sort_vx[i].pnt, 3);
		strcpy ( &(*Tag)[80*i], sort_vx[i].tag );
		List[i] = Rlist[sort_vx[i].idx];
	}

wrapup:
	if (Rlist)   {	om$dealloc (ptr = Rlist);	Rlist   = NULL;	}
	if (test_pt) {	om$dealloc (ptr = test_pt);	test_pt = NULL;	}
	if (line_pt) {	om$dealloc (ptr = line_pt);	line_pt = NULL;	}
	if (test_pa) {	om$dealloc (ptr = test_pa);	test_pa = NULL;	}
	if (line_pa) {	om$dealloc (ptr = line_pa);	line_pa = NULL;	}
	if (sort_vx) {	om$dealloc (ptr = sort_vx);	sort_vx = NULL;	}
	if (test_cv) {	om$dealloc (ptr = test_cv);	test_cv = NULL;	}
	if (line_cv) {	om$dealloc (ptr = line_cv);	line_cv = NULL;	}
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint VLcreateAttrStfTpl ( nline, nmacr, attr, msg)

/*d This function creates an ACrg_coll array with default values. Memory
    allocated by this function will be free by caller. */

/*h 23/03/94 : creation by Marc Fournier (COC Shipbuilding). */

		IGRint		nline;	 /*I Number of generic lines	*/
		IGRint		nmacr;	 /*I Number of stiffener macros	*/
	struct	ACrg_coll	**attr;	 /*O Attributes array		*/
		IGRlong		*msg;	 /*O Completion code		*/

{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i;

	/* Initialize */
	*attr = NULL;
	*msg  = MSSUCC;
	if ((nline+nmacr+IDX_SB_PVAR) > IDX_SB_PMAX)	{
		printf( "Too much attributes <%d> for ACrg_coll\n",nline+nmacr);
		*msg = MSFAIL; goto wrapup; }

	/* Allocate memory for ACrg_coll */
	*attr = om$calloc ( num       = nline+nmacr+IDX_SB_PVAR,
			    structure = struct ACrg_coll );

	/* Give names to fix attributes */
	strcpy ( (*attr)[IDX_SB_TNUM].name, NAM_SB_TNUM);
	strcpy ( (*attr)[IDX_SB_BNUM].name, NAM_SB_BNUM);
	strcpy ( (*attr)[IDX_SB_CNUM].name, NAM_SB_CNUM);
	strcpy ( (*attr)[IDX_SB_MNUM].name, NAM_SB_MNUM);
	strcpy ( (*attr)[IDX_SB_SNUM].name, NAM_SB_SNUM);
	strcpy ( (*attr)[IDX_SB_WNUM].name, NAM_SB_WNUM);
	strcpy ( (*attr)[IDX_SB_YNUM].name, NAM_SB_YNUM);
	strcpy ( (*attr)[IDX_SB_XNUM].name, NAM_SB_XNUM);

	/* Give types to fix attributes */
	(*attr)[IDX_SB_TNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_BNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_CNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_MNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_SNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_WNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_YNUM].desc.type = AC_ATTRIB_DOUBLE;
	(*attr)[IDX_SB_XNUM].desc.type = AC_ATTRIB_DOUBLE;

	/* Give default values to fix attributes */
	(*attr)[IDX_SB_TNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_BNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_CNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_MNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_SNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_WNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_YNUM].desc.value.att_exp = 0.0;
	(*attr)[IDX_SB_XNUM].desc.value.att_exp = 0.0;

	/* Give names & types & default values to variables generic lines */
	for ( i=0; i<nline+nmacr; i++) {
		sprintf ( (*attr)[IDX_SB_PVAR+i].name, "%s%d", NAM_SB_GNAM, i);
		(*attr)[IDX_SB_PVAR+i].desc.type = AC_ATTRIB_TEXT;
		(*attr)[IDX_SB_PVAR+i].desc.value.att_txt[0] = '\0';
	}

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
void VLqLineStfTpl (	VLquLine	Qline[]	)
{

	/* VLbutLine */
	strcpy ( Qline[IDX_SC_BUTT].dname, "*Butt*" );
	Qline[IDX_SC_BUTT].claid = OPP_VLbutLine_class_id;
	Qline[IDX_SC_BUTT].plane = (IGRboolean) IDX_SO_BUTT;

	/* VLctrLine */
	strcpy ( Qline[IDX_SC_CTRL].dname, "CntrLine" );
	Qline[IDX_SC_CTRL].claid = OPP_VLctrLine_class_id;
	Qline[IDX_SC_CTRL].plane = (IGRboolean) IDX_SO_CTRL;

	/* VLmrkLine */
	strcpy ( Qline[IDX_SC_MRKL].dname, "Mark" );
	Qline[IDX_SC_MRKL].claid = OPP_VLmrkLine_class_id;
	Qline[IDX_SC_MRKL].plane = (IGRboolean) IDX_SO_MRKL;

	/* VLseaLine */
	strcpy ( Qline[IDX_SC_SEAM].dname, "*Seam*" );
	Qline[IDX_SC_SEAM].claid = OPP_VLseaLine_class_id;
	Qline[IDX_SC_SEAM].plane = (IGRboolean) IDX_SO_SEAM;

	/* VLwatLine */
	strcpy ( Qline[IDX_SC_WATL].dname, "WatLine" );
	Qline[IDX_SC_WATL].claid = OPP_VLwatLine_class_id;
	Qline[IDX_SC_WATL].plane = (IGRboolean) IDX_SO_WATL;

	/* VLtrace */
	strcpy ( Qline[IDX_SC_TRAC].dname, "VLtrace" );
	Qline[IDX_SC_TRAC].claid = OPP_VLtrace_class_id;
	Qline[IDX_SC_TRAC].plane = (IGRboolean) IDX_SO_TRAC;

	/* Stiffener macro */
	Qline[IDX_SC_MACR].dname[0] = '\0';
	Qline[IDX_SC_MACR].claid = OPP_ACncpx_class_id;
	Qline[IDX_SC_MACR].plane = (IGRboolean) IDX_SO_MACR;
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLaskMacroNames (	struct	GRobj_env	*object,
					VLquLine	Qline[],
					IGRchar		occName[],
					IGRchar		defName[],
					IGRchar		datName[],
					IGRlong		*msg	)
{
		IGRint		sts=OM_S_SUCCESS, cnt=-1, idx=-1, i;
		IGRchar		*defname;
	struct	GRid		macdef;
	struct	ret_struct	str;

	/* Initialize */
	if (occName)	strcpy ( occName, "Unamed");
	if (defName)	strcpy ( defName, "Unamed");
	if (datName)	strcpy ( datName, "Unamed");
	*msg = MSFAIL;
	if (!object)	goto wrapup;
	*msg = MSSUCC;

	/* Get occurence name (if needed) */
	if (occName) {
		sts = om$send ( msg = message GRgraphics.GRgetname
					( msg, occName),
				senderid = NULL_OBJID,
				targetid = object->obj_id.objid,
				targetos = object->obj_id.osnum);
		if (  (!(sts & 0x00000001 & (*msg))) || (occName[0] == '\0') ) {
			strcpy ( occName, "Unamed");
			sts = OM_S_SUCCESS;
			*msg = MSSUCC;
		}
		else	strcpy ( occName, &strrchr ( occName, ':')[1] );
	}

	/* Get macro definition name (if needed) */
	if (defName) {
		sts = om$send ( msg = message ACcpx.find_macro (&macdef),
				senderid = NULL_OBJID,
				targetid = object->obj_id.objid,
				targetos = object->obj_id.osnum);
                as$status ( sts    = sts,
                            msg    = "ACcpx.find_macro",
			    test   = (!(sts & 0x00000001)),
                            action = GOTO_VALUE,
                            value  = wrapup );

		sts = om$send ( msg = message ACcpx_defn.ACgive_name (&defname),
				senderid = NULL_OBJID,
				targetid = macdef.objid,
				targetos = macdef.osnum );
		as$status ( sts    = sts,
			    msg    = "ACcpx_defn.ACgive_name",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		if (defname)	strcpy ( defName, defname);
	}

	/* Get data name (if needed) */
	if (datName) {

		/* Verify if we treat a subclass of VLgenLine */
		for ( i=0; i<IDX_SC_LINE; i++) {
			VLfilterDef ( 1, object, &cnt, Qline[i].dname);
			if (cnt) {	idx = i;
					i   = IDX_SC_LINE;	}
		}

		/* Exit if not a generic line or if a control or marking line */
		if (!cnt)	goto wrapup;

		/* Retrieve VLgenLine "data" name */
		sts = om$send ( msg = message NDmacro.ACgive_structure (
					(IGRint *) msg,
					&idx,
					"contents:dataName",
					&str,
					&object->mod_env ),
				senderid = NULL_OBJID,
				targetid = object->obj_id.objid,
				targetos = object->obj_id.osnum);
		if (!(sts & 0x00000001 & (*msg))) {
			sts = OM_S_SUCCESS;
			*msg = MSSUCC;
		}
		else if (str.var.text_st.text_string)
			strcpy ( datName, str.var.text_st.text_string);
	}

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLgetLineNames (	struct	GRobj_env	*object,
					VLquLine	Qline[],
					IGRchar		occName[],
					IGRchar		tagName[],
					IGRlong		*msg	)
{
		IGRint		sts=OM_S_SUCCESS;
		IGRchar		defName[DI_PATH_MAX], datName[DI_PATH_MAX];

	/* Initialize */
	if (tagName)	tagName[0] = '\0';

	/* Retrieve genLine names (if any) */
	sts = VLaskMacroNames ( object, Qline, occName, defName, datName, msg);
	as$status ( sts    = sts,
		    msg    = "VLaskMacroNames()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	
	/* Take <datName> instead of <occName> according to <defName> */
	if (  ( ! strcmp ( defName, BUTT_DEF_1)    )
	   || ( ! strcmp ( defName, SEAM_DEF_1)    )
	   || ( ! strcmp ( defName, WatLine_DEF_1) )
	   || ( ! strcmp ( defName, TRACE_DEF_4)   ) ) {
		if (datName)	strcpy ( tagName, datName);
	}
	else if ( (tagName) && (occName) )
		strcpy ( tagName, occName);

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLgetMacroNames (	struct	GRobj_env	*object,
					IGRchar		occName[],
					IGRchar		tagName[],
					IGRlong		*msg	)
{
		IGRint		sts=OM_S_SUCCESS;

	/* Initialize */
	if (tagName)	tagName[0] = '\0';

	/* Retrieve macro name (if any) */
	sts = VLaskMacroNames ( object, NULL, occName, NULL, NULL, msg);
	as$status ( sts    = sts,
		    msg    = "VLaskMacroNames()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Store tag name (if needed) */
	if ( (tagName) && (occName) )	strcpy ( tagName, occName);

wrapup:
	return (sts);
}
/* ========================================================================== */
IGRint VLcheckLinearity (
			struct	GRobj_env	*Stiff,
			struct	GRmd_env	*md_env,
			IGRint			*linear	)
{
	IGRlong			status=OM_S_SUCCESS;
	IGRint			suc,sts;
	struct	ret_struct	attrVal;
	char			attrName[40];

	strcpy( attrName, VS_K_prMbrGeoAttr );

	sts = om$send( msg = message NDmacro.ACgive_structure (
							&suc,
							NULL,
							attrName,
							&attrVal,
							md_env     ),
			senderid = NULL_OBJID,
			targetid = Stiff->obj_id.objid,
			targetos = Stiff->obj_id.osnum	);
        as$status ( msg    = "NDmacro.ACgive_structure",
                    test   = (!(sts & 1 & suc)),
                    action = GOTO_VALUE,
                    value  = quit );

	if( attrVal.var.root_pm_st.value == VS_rdb_bmLINEAR ) 
	{
		*linear = 1;
	}
	sts = MSSUCC;
quit :
	return sts;
}


end implementation VLabstract;
