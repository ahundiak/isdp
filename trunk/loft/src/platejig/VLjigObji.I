/* $Id: VLjigObji.I,v 1.1.1.1 2001/01/04 21:11:36 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/platejig / VLjigObji.I
 *
 * Description:	plate jigs object methods.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLjigObji.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/14  20:39:20  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.5  1997/04/07  13:32:58  pinnacle
# Replaced: src/platejig/VLjigObji.I for: File header added, intersection problem by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/03/97   mf		intersection problem in ACconstruct_fett().
 *	04/07/97   mf		header creation.
 *************************************************************************/
class implementation VLjigObj;

#include        <math.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"nddef.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"
#include	"bserr.h"
#include	"vsmiscmacros.h"
#include	"vsplatedef.h"

#include	"vlmsg.h"
#include	"vlplatejig.h"
#include	"vlglobals.h"
#include	"vlmiscmacros.h"

#include	"bsdotp.h"
#include	"bsnorvec.h"
#include	"bsxtractpar.h"

extern	GRclassid	OPP_GR3dlineseg_class_id;

/*
#define	TRACE
*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{
		IGRlong		sts=OM_S_SUCCESS;
	struct	GRvg_construct	cst;
	struct	ret_struct	str;
		IGRdouble	box[NUM_PO_ATTR], bTol, cTol, dTol, prod, hole;
		IGRint		i, type, inv, idx=MACRO_PO_FTEMP, text_num;
		IGRint		nsrf, nlin=0, nint=0, nvtx, ncmp, ncpt=0;
	struct	GRobj_env	*Surf, *Clin, Plan, *Icrv, *Ocrv, *Rcrv, Klin;
		IGRchar		side[DI_PATH_MAX], str_idx[DI_PATH_MAX];
		IGRshort	*inv1, *inv2;
		IGRboolean	adj, clo;
		IGRpoint	spt, ept, spt1, spt2, ept1, ept2, Rpt1, Rpt2;
		IGRvector	dir, Xvec, Yvec, Zvec, n;
		BSrc		rc;
		IGRdouble	*Vrtx, xpt[6], *Cpnt, Bpln[6], Ppln[6], Tpln[6];
	struct	GRlc_info	*Entr;
	struct	IGRpolyline	geom;
	struct	GRid		Wpt1_id, Wpt2_id, SavCont, TopCont, *text_id;
		IGRpoint	Wpt1, Wpt2, Wpt3, Wpt4, Cnt, p;
		IGRmatrix	loc_mat;
	struct	ACrg_coll	*Attr;
	struct	IGRplane	Iplane;

	/*c Initialize */
	*fcount = MACRO_PO_FFEET;
	Surf    = NULL;
	Clin    = NULL;
	Icrv    = NULL;
	Ocrv    = NULL;
	Rcrv    = NULL;
	inv1    = NULL;
	inv2    = NULL;
	Vrtx    = NULL;
	Entr    = NULL;
	Cpnt    = NULL;
	Attr    = NULL;
	VLinitCnst (&cst);
        cst.env_info = md_env;
        BSxtractpar ( msg, BSTOLBASIS,  &bTol);
        BSxtractpar ( msg, BSTOLCHRDHT, &cTol);
        dTol = 5 * cTol;
	for ( i=0; i<3; i++)	Xvec[i] = Yvec[i] = Zvec[i] = 0.0;
	Xvec[0] = Yvec[1] = Zvec[2] = 1.0;
	Iplane.point  = p;
	Iplane.normal = n;

	/*c Retrieve parameter box */
        sts = VLgetPlateJigObjAttr ( msg, box, &list[IDX_PO_ATTR]);
        as$status ( sts    = sts,
                    msg    = "VLgetPlateJigObjAttr(ATTR)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        type = (IGRint)box[IDX_PO_TYPE];
        inv  = (IGRint)box[IDX_PO_INV];
        if (inv != INVNORM_ON)  inv = INVNORM_OF;
        if (inv == INVNORM_OF)  strcpy ( side, VS_K_plBotSfPath);
        else                    strcpy ( side, VS_K_plTopSfPath);

	/*c Retrieve the control line */
	sts = vl$return_foot ( msg     = msg,
                               objId   = &list[IDX_PO_CTRL],
                               objEnv  = md_env,
                               footId  = &Klin.obj_id,
                               footEnv = &Klin.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(CTRL)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve section plane index */
        sts = om$send ( msg      = message NDnode.NDgive_structure
                                        ( msg, &str, md_env),
                        targetid = list[IDX_PO_INDX].objid,
                        targetos = list[IDX_PO_INDX].osnum );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDgive_structure(IDX)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        strcpy ( str_idx, str.var.text_st.text_string);

	/*c Retrieve the intersecting plane */
	sts = vl$return_foot ( msg     = msg,
                               objId   = &list[IDX_PO_PLAN],
                               objEnv  = md_env,
                               footId  = &Plan.obj_id,
                               footEnv = &Plan.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(PLAN)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Retrieve the VSplate support surfaces */
        nsrf = (IGRint)box[IDX_PO_NSRF];
	Surf = om$calloc ( num = nsrf, structure = struct GRobj_env);
	for ( i=0; i<nsrf; i++) {
		sts = vl$return_foot ( msg     = msg,
	                               objId   = &list[idx+i],
	                               objEnv  = md_env,
	                               footId  = &Surf[i].obj_id,
	                               footEnv = &Surf[i].mod_env );
                as$status ( sts    = sts,
                            msg    = "vl$return_foot(SURF)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}

	/*c Retrieve the characteristic lines (if needed) */
	idx += nsrf;
	if (type == IDX_J3) {
        	nlin = (IGRint)box[IDX_PO_NLIN];
		Clin = om$calloc ( num = nlin, structure = struct GRobj_env);
		for ( i=0; i<nlin; i++) {
			sts = vl$return_foot ( msg     = msg,
		                               objId   = &list[idx+i],
		                               objEnv  = md_env,
		                               footId  = &Clin[i].obj_id,
		                               footEnv = &Clin[i].mod_env );
	                as$status ( sts    = sts,
	                            msg    = "vl$return_foot(CLIN)",
	                            test   = (!(sts & 0x00000001 & (*msg))),
	                            action = GOTO_VALUE,
	                            value  = wrapup );
		}
	}

	/* Intersect section plane with support surfaces */
	Icrv = om$calloc ( num = 2*nsrf, structure = struct GRobj_env);
	for ( i=0; i<nsrf; i++) {
		Icrv[i].mod_env = *md_env;
		Icrv[i].obj_id.objid = NULL_OBJID;
		Icrv[i].obj_id.osnum = md_env->md_id.osnum;
		sts = VLcreateInter ( msg,
                                      &Surf[i].obj_id,
                                      &Surf[i].mod_env,
                                      (IGRshort) 0,
                                      &Plan.obj_id,
                                      &Plan.mod_env,
                                      (IGRshort) 0,
                                      &Icrv[nint].obj_id,
                                      &Icrv[nint].mod_env );
                if (sts & 0x00000001 & (*msg))	nint++;
/* Suppressed by MF : 03-APR-1997
                else {	sts     = OM_S_SUCCESS;
                        *msg    = ND_COMP_SUCC;
			*fcount = 0;
                        printf( "<VLjigObj> : degenerate case\n");
                        goto wrapup;	}
*/
	}
	if (!nint) {
		printf( "<VLjigObj> : no intersection found\n");
                goto wrapup;
        }

	/* Prepare feet */
	(*fcount) += nint + 1 + nlin;
	for ( i=0; i<*fcount; i++) { feet_list[i].objid = NULL_OBJID;
                                     feet_list[i].osnum = md_env->md_id.osnum; }

	/* Order composite curve */
	hole = box[IDX_PO_HOLE];
	Ocrv = om$calloc ( num = 2*nsrf, structure = struct GRobj_env);
	inv1 = om$calloc ( num = 2*nsrf, structure = IGRshort);
	OrderCrv ( Icrv, nint, 2*hole, bTol, Ocrv, inv1, &adj, &clo, msg);
        if (*msg != BSSUCC) {
                printf( "Scallop radius is only %g, increase it ...\n", hole);
                *msg = MSFAIL; goto wrapup; }

	/* Extract first segment direction */
        sts = VLendpts ( msg, &Ocrv[0].obj_id, &Ocrv[0].mod_env, spt, ept);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        for ( i=0; i<3; i++)    dir[i] = ept[i] - spt[i];
        BSnorvec ( &rc, dir);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Reorient curves order */
	Rcrv = om$calloc ( num = 2*nsrf, structure = struct GRobj_env);
	inv2 = om$calloc ( num = 2*nsrf, structure = IGRshort);
        prod = BSdotp ( &rc, dir, Yvec);
        prod *= inv1[0];
        if (prod >= 0.0) {
                for ( i=0; i<nint; i++) {
                        Rcrv[i] = Ocrv[nint-1-i];
                        inv2[i] = inv1[nint-1-i] * -1;
                }
#ifdef TRACE
printf( "normal:[%g,%g,%g]\t(%d|%d) & inv=%d --> (%d|%d) & inv=%d\n",
        dir[0], dir[1], dir[2], Ocrv[0].obj_id.osnum, Ocrv[0].obj_id.objid,
        inv1[0], Rcrv[0].obj_id.osnum, Rcrv[0].obj_id.objid, inv2[0] );
#endif
        }
        else {	for ( i=0; i<nint; i++) {	Rcrv[i] = Ocrv[i];
                        			inv2[i] = inv1[i];	}
        }

	/* Extract ordered vertices of the future composite curve */
        sts = VLextractVertices ( msg, nint, Rcrv, inv2, &nvtx, &Vrtx);
        as$status ( sts    = sts,
                    msg    = "VLextractVertices()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Try to manage step effect on profile */
        ncmp = nint;
        if (nint > 1) {
        cst.geometry    = (IGRchar *) &geom;
        geom.num_points = (IGRlong) 2;
        for ( i=1; i<nint; i++) {

                VLendpts ( msg, &Rcrv[i-1].obj_id, &Rcrv[i-1].mod_env,
			   spt1, ept1);
                if (inv2[i-1] == 1)     dblcpy ( &xpt[0], ept1, 3);
                else                    dblcpy ( &xpt[0], spt1, 3);

                VLendpts ( msg, &Rcrv[i].obj_id, &Rcrv[i].mod_env, spt2, ept2);
                if (inv2[i] == 1)       dblcpy ( &xpt[3], spt2, 3);
                else                    dblcpy ( &xpt[3], ept2, 3);

                prod  = (xpt[0]-xpt[3]) * (xpt[0]-xpt[3]);
                prod += (xpt[1]-xpt[4]) * (xpt[1]-xpt[4]);
                prod += (xpt[2]-xpt[5]) * (xpt[2]-xpt[5]);
                prod  = sqrt (prod);
                if (prod > bTol) {
#ifdef TRACE
printf ("Interdistance courbe %d a courbe %d = %g\n", i-1, i, prod);
printf( "Rcrv[%d] : spt=[%g,%g,%g], ept=[%g,%g,%g], inv=%d\n",
        i-1, spt1[0], spt1[1], spt1[2], ept1[0], ept1[1], ept1[2], inv2[i-1]);
printf( "Rcrv[%d] : spt=[%g,%g,%g], ept=[%g,%g,%g], inv=%d\n",
        i, spt2[0], spt2[1], spt2[2], ept2[0], ept2[1], ept2[2], inv2[i]);
printf( "Construct GR3dlineseg : [%g,%g,%g] --> [%g,%g,%g]\n\n",
        xpt[0], xpt[1], xpt[2], xpt[3], xpt[4], xpt[5] );
#endif
                        geom.points = (IGRdouble *) xpt;
                        Rcrv[ncmp].obj_id.objid = NULL_OBJID;
                        Rcrv[ncmp].obj_id.osnum = md_env->md_id.osnum;
                        Rcrv[ncmp].mod_env      = *md_env;
                        sts = om$construct (
                                classid = OPP_GR3dlineseg_class_id,
                                osnum   = Rcrv[ncmp].obj_id.osnum,
                                p_objid = &Rcrv[ncmp].obj_id.objid,
                                msg = message GRgraphics.GRaltconstruct(&cst) );
                        as$status ( sts    = sts,
                                    msg    = "GRgraphics.GRaltconstruct",
                                    test   = (!(sts&0x00000001&(*(cst.msg)))),
                                    action = GOTO_VALUE,
                                    value  = zappning );
                        ncmp++;
                }
        }
        }

zappning:
        /* Order composite curve */
        OrderCrv ( Rcrv, ncmp, dTol, bTol, Ocrv, inv1, &adj, &clo, msg);
        if (*msg != BSSUCC) { *msg = MSFAIL; goto wrapup; }

        /* Build composite curve */
	Entr = om$calloc ( num = 2*nsrf, structure = struct GRlc_info);
        for ( i=0; i<ncmp; i++) {
                Entr[i].module_info = Ocrv[i].mod_env;
                Entr[i].located_obj = Ocrv[i].obj_id;
        }
        BuildCrv ( 3, Ocrv, ncmp, inv1, adj, clo, Entr, &cst,
		   &feet_list[IDX_PO_CONT], msg);
        if (*msg != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        else *msg = MSSUCC;

	/* Extend composite curve */
        sts = VLextendCurve ( msg, &feet_list[IDX_PO_CONT], md_env, bTol, dTol,
			      box[IDX_PO_EXT1], box[IDX_PO_EXT2],
			      &Wpt1_id, &Wpt2_id );
        as$status ( sts    = sts,
                    msg    = "VLextendCurve()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extract characteristic points (if any) */
	if (nlin)	Cpnt = om$calloc ( num = 3*nlin, structure = IGRdouble);
	sts = VLextractCharpoints ( msg, &feet_list[IDX_PO_CONT], md_env,
                                    nlin, &list[count-nlin], &ncpt, Cpnt);
        as$status ( sts    = sts,
                    msg    = "VLextractCharpoints()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve average cog and normal */
	Bpln[0] = box[IDX_PO_XCOG];
	Bpln[1] = box[IDX_PO_YCOG];
	Bpln[2] = box[IDX_PO_ZCOG];
	Bpln[3] = box[IDX_PO_XNRM];
	Bpln[4] = box[IDX_PO_YNRM];
	Bpln[5] = box[IDX_PO_ZNRM];

	/* Extract plane of the intersecting plane */
	sts = om$send ( msg = message GRvg.GRdetplane (
					msg,
					&Plan.mod_env.md_env.matrix_type,
					Plan.mod_env.md_env.matrix,
					&Iplane ),
			targetid = Plan.obj_id.objid,
			targetos = Plan.obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRvg.GRdetplane(PLAN)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Project average normal on section plane */
        sts = VLcomputePlanes ( Bpln, &Plan.obj_id, box[IDX_PO_REAL], md_env,
                                Ppln, Tpln, msg);
        as$status ( sts    = sts,
                    msg    = "VLcomputePlanes()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extract & project first extremity point geometry */
        sts = VLendpts ( msg, &Wpt1_id, md_env, Wpt1, Wpt3);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        BSproj1 ( &rc, Wpt1, &Tpln[3], &Tpln[0], Wpt3);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        sts = gr$delete_object ( msg       = msg,
                                 md_env    = md_env,
                                 object_id = &Wpt1_id );
        as$status ( sts    = sts,
                    msg    = "gr$delete_object()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Extract & project second extremity point geometry */
        sts = VLendpts ( msg, &Wpt2_id, md_env, Wpt2, Wpt4);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        BSproj1 ( &rc, Wpt2, &Tpln[3], &Tpln[0], Wpt4);
        if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
        sts = gr$delete_object ( msg       = msg,
                                 md_env    = md_env,
                                 object_id = &Wpt2_id );
        as$status ( sts    = sts,
                    msg    = "gr$delete_object()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Evaluate middlepoint of weld points projection */
        for ( i=0; i<3; i++)
                Cnt[i] = (5.5 * (Wpt3[i]+Wpt4[i])) - (5.0 * (Wpt1[i]+Wpt2[i]));

        /* Create scallops in composite curve */
        if (box[IDX_PO_EXT1] < 2*hole)	hole = box[IDX_PO_EXT1] / 2.0;
        if (box[IDX_PO_EXT2] < 2*hole)	hole = box[IDX_PO_EXT2] / 2.0;
        SavCont = feet_list[IDX_PO_CONT];
	sts = VLcreateScallops ( msg, nvtx, Vrtx, md_env, hole, &cst, Cnt,
                                 2*hole, bTol, &SavCont, &TopCont);
        if (!(sts&1&(*msg)))
                printf( "Cannot create scallops on plate_jig <%s>\n", str_idx);
        else    feet_list[IDX_PO_CONT] = SavCont;

	/* Create contour */
        sts = VLcreateContour ( msg, &feet_list[IDX_PO_CONT], md_env, Tpln,
                                &cst, dTol, bTol, Rpt1, Rpt2);
        as$status ( sts    = sts,
                    msg    = "VLcreateContour()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        if (sts == 3)
		printf( "grd_dist=%g must be reevaluated\n", box[IDX_PO_REAL]);

	/* Create control points */
	#ifdef TRACE
printf( "Contour : (%d|%d)\n",
        feet_list[IDX_PO_CONT].osnum, feet_list[IDX_PO_CONT].objid);
printf( "T plane : (%g,%g,%g)\t(%g,%g,%g)\n",
        Tpln[0], Tpln[1], Tpln[2], Tpln[3], Tpln[4], Tpln[5] );
printf( "C  line : (%d|%d)\n", Klin.obj_id.osnum, Klin.obj_id.objid);
printf( "X plane : (%d|%d)\n", Plan.obj_id.osnum, Plan.obj_id.objid);
printf( "Normal  : (%g,%g,%g)\n", Bpln[3], Bpln[4], Bpln[5]);
#endif
        sts = VLcreateSline ( &feet_list[IDX_PO_CONT],
                              Tpln,
                              &Klin.obj_id,
                              &Plan.obj_id,
                              &Bpln[3],
                              md_env,
                              Xvec,
                              box[IDX_PO_MID],
                              0.0,
                              NULL,
                              &feet_list[IDX_PO_KLIN],
                              NULL,
                              NULL,
                              msg);
	as$status ( sts    = sts,
                    msg    = "VLcreateSline()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /* Create jig attributes box */
        sts = VLcreateJigBox ( msg, &feet_list[IDX_PO_KLIN], &TopCont, md_env,
                               nvtx, Vrtx, ncpt, Cpnt, box[IDX_PO_OSET],
			       str_idx, Iplane.normal, &feet_list[IDX_PO_RESU],
			       &Attr);
        as$status ( sts    = sts,
                    msg    = "VLcreateJigBox()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create jig text feet */
        sts = VLcreateJigText ( str_idx, Rpt1, Rpt2, nvtx, Vrtx, md_env,
                                &feet_list[IDX_PO_KLIN], hole, Attr,
                                &text_num, &text_id, loc_mat, msg );
        as$status ( sts    = sts,
                    msg    = "VLcreateJigText()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Copy the created text in the GRid list of feet */
        feet_list[IDX_PO_NAME] = text_id[0];
        feet_list[IDX_PO_KTXT] = text_id[1];
        for ( i=2; i<text_num; i++) feet_list[MACRO_PO_FFEET+i-2] = text_id[i];

#ifdef TRACE
for (i=0;i<*fcount;i++)
        printf( "\tFoot %d\t: (%d|%d)\n",
                i, feet_list[i].osnum, feet_list[i].objid);
#endif

wrapup:
	if (TopCont.objid != NULL_OBJID)
                gr$delete_object ( msg          = msg,
                                   md_env       = md_env,
                                   object_id    = &TopCont );

        if (Attr) {     om$dealloc(ptr = Attr);         Attr  = NULL;   }
        if (Cpnt) {     om$dealloc(ptr = Cpnt);         Cpnt  = NULL;   }
        if (Entr) {     om$dealloc(ptr = Entr);         Entr  = NULL;   }
        if (Vrtx) {     om$dealloc(ptr = Vrtx);         Vrtx  = NULL;   }
        if (inv2) {     om$dealloc(ptr = inv2);         inv2  = NULL;   }
        if (inv1) {     om$dealloc(ptr = inv1);         inv1  = NULL;   }
        if (Rcrv) {     om$dealloc(ptr = Rcrv);         Rcrv  = NULL;   }
        if (Ocrv) {     om$dealloc(ptr = Ocrv);         Ocrv  = NULL;   }
        if (Icrv) {     om$dealloc(ptr = Icrv);         Icrv  = NULL;   }
        if (Clin) {     om$dealloc(ptr = Clin);         Clin  = NULL;   }
        if (Surf) {     om$dealloc(ptr = Surf);         Surf  = NULL;   }
	return(sts);
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjPlateJigs;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLjigObj;
