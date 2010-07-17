/*f <VLsnachFunk.I> contruct a hollow template (A.C.H. design) */

class implementation VLabstract;

#include        <stdio.h>
#include        "vlprototype.h"
#include        "OMerrordef.h"
#include        "OMindex.h"
#include        "AS_status.h"
#include        "godef.h"
#include        "grmacros.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"
#include        "grdpb.h"
#include        "gotextdef.h"
#include        "maerr.h"
#include        "bs.h"
#include        "bsparameters.h"
#include        "msdef.h"
#include        "asmacros.h"
#include        "DIdef.h"
#include        "bsvalues.h"
#include        "math.h"
#include        "cotxmacros.h"
#include        "msmacros.h"
#include        "vlplatejig.h"
#include        "vlmsg.h"

#include        "bscrossp.h"
#include        "bsdotp.h"
#include        "bsmkvec.h"
#include        "bsnorvec.h"
#include        "bsproj1.h"
#include        "bsxlnpl.h"

extern  void            BuildCrv(), OrderCrv();
extern  IGRint          dblcpy();

extern  IGRchar         *strrchr();
extern  IGRdouble       acos(), fabs(), cos(), sin();
extern  IGRint          strcmp();

extern  GRclassid       OPP_GR3dlineseg_class_id;
extern  GRclassid       OPP_GR3dcircle_class_id;

from	GRlinear	import	GRgetpolyline;

/*	#define TRACE	*/
/*	#define TRACE_MEMORY	*/

/* ========================================================================== */
IGRlong VLcreateAchContour ( msg, Curve, Kline, Hole, Env, Tpln, cst, Mat,
			     DistTol, BaseTol, Length, Radius, Width )

/*d This function creates the complete ACH contour. */

/*h 07/02/94 : creation by Marc FOURNIER (ISDC). */

                IGRlong         *msg;         /*O     Completion code         */
        struct  GRid            *Curve;       /*IO    Ems curve --> contour   */
        struct  GRid            *Kline;       /*I     Control line	      */
        struct  GRid            *Hole;        /*O     Targeting hole	      */
        struct  GRmd_env        *Env;         /*I     Current module env      */
                IGRdouble       *Tpln;        /*I     T plane                 */
        struct  GRvg_construct  *cst;         /*I     Construction list       */
		IGRdouble	*Mat;	      /*I     Template plane matrix   */
                IGRdouble       DistTol;      /*I     Distance tolerance      */
                IGRdouble       BaseTol;      /*I     Basis tolerance         */
		IGRdouble	Length;       /*I     Hollow length	      */
		IGRdouble	Radius;       /*I     Hollow radius	      */
		IGRdouble	Width;        /*I     Hollow width	      */

{
/*c Beginning of function */

                IGRint          i, action=1;
                IGRlong         sts=OM_S_SUCCESS;
                IGRpoint        pnt[16], tmp[4];
		IGRpoint	Tinf, Ttop, Tlow, Tlef, Tmid, Trig, TLef, TRig;
                BSrc            rc;
		IGRvector	vec, LRvec;
                IGRdouble       d1, d2, dist;
	struct	IGRpolyline	geom, poly;
        struct  GRobj_env       Icv[16];
        struct  GRobj_env       Ocv[16];
                IGRshort        inv[16];
                IGRboolean      adj, clo;
        struct  GRlc_info       entries[16];
	struct	IGRellipse	hole;

	/*c Initialize */
	for ( i=0; i<16; i++) {
		Icv[i].mod_env	    = *Env;
		Icv[i].obj_id.objid = NULL_OBJID;
		Icv[i].obj_id.osnum = Env->md_id.osnum;
		pnt[i][0] = pnt[i][1] = pnt[i][2] = 0.0;
	}
	Icv[0].obj_id   = *Curve;
        cst->geometry   = (IGRchar *) &geom;
	geom.num_points = (IGRlong) 2;
	poly.points     = NULL;
	poly.num_points = (IGRlong) 3;
	Hole->objid = NULL_OBJID;
	Hole->osnum = Env->md_id.osnum;

	/*c Allocate memory for LK line vertices */
#ifdef TRACE_MEMORY
printf( "poly.points = om$calloc (%d,<IGRdouble>)\n", 3 * poly.num_points);
#endif
	poly.points = om$calloc ( num	    = 3 * poly.num_points,
                                  structure = IGRdouble );

	/*c Retrieve curve's end points */
        sts = VLendpts ( msg, Curve, Env, pnt[0], pnt[15] );
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Points for construction planes */
	for ( i=0; i<3; i++)	Tinf[i] = Tpln[i] - Length * Tpln[i+3];
	for ( i=0; i<3; i++)	Ttop[i] = Tpln[i] + Length * Tpln[i+3];

	sts = VLvector ( msg, Tpln, pnt[0],  1.0, 1.0, FALSE, vec);
        as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	d1 = BSdotp ( &rc, &Tpln[3], vec);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	sts = VLvector ( msg, Tpln, pnt[15], 1.0, 1.0, FALSE, vec);
        as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	d2 = BSdotp ( &rc, &Tpln[3], vec);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	if (fabs(d1) < fabs(d2))	dist = d1;
	else				dist = d2;

	if (d1 < -2 * Length) {
		for ( i=0; i<3; i++)
			Tlow[i] = Tpln[i] + (dist + Length) * Tpln[i+3];
	}
	else {	ex$message (msgnumb = VL_E_NO_HOLLOW_TEMPLATE);
		*msg = MSFAIL; goto wrapup;	}

	/*c Retrieve LK line's first points */
	sts = om$send ( msg = message GRlinear.GRgetpolyline (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						&action,
						&poly ),
			senderid = NULL_OBJID,
			targetid = Kline->objid,
			targetos = Kline->osnum );
        as$status ( sts    = sts,
                    msg    = "GRlinear.GRgetpolyline",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Projection on low plane */
	BSproj1 ( &rc, pnt[0],  &Tpln[3], &Tlow[0], pnt[1]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[15], &Tpln[3], &Tlow[0], pnt[14]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Projection on inf plane */
	BSproj1 ( &rc, pnt[0],  &Tpln[3], &Tinf[0], tmp[0]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[15], &Tpln[3], &Tinf[0], tmp[3]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Projection on T plane */
	BSproj1 ( &rc, pnt[0],  &Tpln[3], &Tpln[0], tmp[1]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[15], &Tpln[3], &Tpln[0], tmp[2]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	sts = VLvector ( msg, tmp[1], tmp[2], 1.0, 1.0, TRUE, LRvec);
        as$status ( sts    = sts,
                    msg    = "VLvector()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	BSxlnpl ( &rc, &Tpln[3], &Tpln[0], &poly.points[0], &poly.points[3],
		  Tmid );
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	for ( i=0; i<3; i++) {	Tlef[i] = Tmid[i] - Length * LRvec[i];
				TLef[i] = Tmid[i] - Width / 2 * LRvec[i];
				Trig[i] = Tmid[i] + Length * LRvec[i];
				TRig[i] = Tmid[i] + Width / 2 * LRvec[i]; }
#ifdef TRACE
printf( "Tpln normal : [%g,%g,%g]\n", Tpln[3], Tpln[4], Tpln[5] );
printf( "Tmid normal : [%g,%g,%g]\n", LRvec[0], LRvec[1], LRvec[2] );
#endif
	/*c Projection on Left plane */
	BSproj1 ( &rc, tmp[0], LRvec, TLef, pnt[4]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, tmp[1], LRvec, TLef, pnt[5]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Projection on left plane */
	BSproj1 ( &rc, pnt[1], LRvec, Tlef, pnt[2]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[4], LRvec, Tlef, pnt[3]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[5], LRvec, Tlef, pnt[6]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Projection on Right plane */
	BSproj1 ( &rc, tmp[2], LRvec, TRig, pnt[10]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, tmp[3], LRvec, TRig, pnt[11]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Projection on right plane */
	BSproj1 ( &rc, pnt[10], LRvec, Trig, pnt[9]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[11], LRvec, Trig, pnt[12]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[14], LRvec, Trig, pnt[13]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Projection on top plane */
	BSproj1 ( &rc, pnt[6], &Tpln[3], Ttop, pnt[7]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
	BSproj1 ( &rc, pnt[9], &Tpln[3], Ttop, pnt[8]);
        if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }

	/*c Create line segments */
	for ( i=1; i<16; i++) {
        	geom.points = (IGRdouble *) &pnt[i-1];
		sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
				     osnum   = Icv[i].obj_id.osnum,
				     p_objid = &Icv[i].obj_id.objid,
				     msg     = message GRgraphics.GRaltconstruct
								(cst) );
        	as$status ( sts    = sts,
                    	    msg    = "om$construct(GRgraphics.GRaltconstruct)",
                    	    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
	}

	/*c Order components of contour */
#ifdef TRACE
for ( i=0; i<16; i++)
printf( "Component %2d : (%d|%d)\n",
	i, Icv[i].obj_id.osnum, Icv[i].obj_id.objid );
#endif
	OrderCrv (Icv, (IGRint)16, DistTol, BaseTol, Ocv, inv, &adj, &clo, msg);
        if (*msg != BSSUCC) { printf( "Error in OrderCrv() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }
	
	/*c Construct contour */
	for ( i=0; i<16; i++) {	entries[i].module_info = Ocv[i].mod_env;
				entries[i].located_obj = Ocv[i].obj_id;	}
	BuildCrv((IGRshort)3, Ocv, 16, inv, adj, clo, entries, cst, Curve, msg);
	if (*msg != BSSUCC) { printf( "Error in BuildCrv() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }
        else *msg = MSSUCC;

	/*c Construct hole foot */
	cst->geometry  = (IGRchar *) &hole;
	hole.prim_axis = Radius;
	hole.sec_axis  = Radius;
	dblcpy ( hole.rot_matrix, Mat, 16);
	dblcpy ( hole.origin, Tmid, 3);

	sts = om$construct ( classid = OPP_GR3dcircle_class_id,
			     osnum   = Hole->osnum,
			     p_objid = &(Hole->objid),
			     msg = message GRgraphics.GRaltconstruct (cst) );
	as$status ( sts    = sts,
                    msg    = "om$construct(GRgraphics.GRaltconstruct)",
                    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :
	if (poly.points) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = poly.points)\n");
#endif
		om$dealloc (ptr = poly.points);
		poly.points = NULL;
	}
	geom.num_points = (IGRlong) 0;
        cst->geometry   = (IGRchar *) NULL;
        return (sts);

/*c End of function */
}
/* ========================================================================== */

end implementation VLabstract;
