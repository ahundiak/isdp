/* $Id: VLjigMgri.I,v 1.2 2001/01/16 19:33:40 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/platejig / VLjigMgri.I
 *
 * Description:	plate jigs manager methods.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLjigMgri.I,v $
 *	Revision 1.2  2001/01/16 19:33:40  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/04/10  16:38:06  pinnacle
# initial revision
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/04/13  10:45:58  pinnacle
# Replaced: src/platejig/VLjigMgri.I for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.2  1997/04/07  13:31:58  pinnacle
# Replaced: src/platejig/VLjigMgri.I for: File header added, delete temporary objects  by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/07/97   mf		header added.
 *	04/07/97   mf		delete of temp. objects in ACconstruct_feet().
 *************************************************************************/
class implementation VLjigMgr;

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

#include	"vlglobals.h"
#include	"vlplatejig.h"
#include	"vlcntrline.h"
#include	"vlmiscmacros.h"

#include	"bsdotp.h"

extern	GRclassid	OPP_VLjigObj_class_id;

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
		IGRlong		sts=OM_S_SUCCESS, loc_msg;
		IGRdouble	Dmin, Dsup, Ppnt[3], Bpln[6], prod;
		IGRint		*Binr, i;
		IGRint		npln=0, nrng=0, nfrm=0, nprt=0, nimg=0;
		IGRint		nplt=0, nmax=0, nlin=0, ntpl=MACRO_PO_FTEMP;
		IGRint		type, grop, inv, idx=MACRO_PM_FTEMP;
	struct	GRobj_env	*Plat, Fram, *Clin, *Port, *Surf, Supp, Klin;
		IGRchar		Sexp[DI_PATH_MAX], side[DI_PATH_MAX];
		IGRdouble	box[NUM_PM_ATTR], val[NUM_PO_ATTR];
	struct	GRid		*Temp, occ_id, pln_id, frz_id;
		BSrc		rc;
		IGRvector	Xvec, Yvec, Zvec;
	struct	GRobj_env	Dummy;

	/*c Initialize */
	*fcount = MACRO_PM_FFEET;
	Binr = NULL;
	Plat = NULL;
	Clin = NULL;
	Temp = NULL;
	Port = NULL;
	Surf = NULL;
	Ppnt[0] = Ppnt[1] = Ppnt[2] = 0.0;
	for ( i=0; i<3; i++)    Xvec[i] = Yvec[i] = Zvec[i] = 0.0;
        Xvec[0] = Yvec[1] = Zvec[2] = 1.0;

	/*c Retrieve parameter box */
	sts = VLgetPlateJigMgrAttr ( msg, box, &list[IDX_PM_ATTR]);
	as$status ( sts    = sts,
                    msg    = "VLgetPlateJigMgrAttr(ATTR)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	type = (IGRint)box[IDX_PM_TYPE];
	grop = (IGRint)box[IDX_PM_GROP];
	inv  = (IGRint)box[IDX_PM_INV];
	if (inv != INVNORM_ON)	inv = INVNORM_OF;
        if (inv == INVNORM_OF)	strcpy ( side, VS_K_plBotSfPath);
        else			strcpy ( side, VS_K_plTopSfPath);

	/*c Retrieve the real VSplate(s) */
	nplt = (IGRint)box[IDX_PM_NPLT];
	sts = VLsortPlateImage ( msg, nplt, &list[idx], md_env, &Plat, &nimg);
        as$status ( sts    = sts,
                    msg    = "VLsortPlateImage()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Take only port side VSplate (if needed) */
	if (type == IDX_J4) {
		Port = om$calloc ( num = nplt, structure = struct GRobj_env);
		sts = VLsortPortVSplates ( nplt, Plat, side, md_env,
                                           &nprt, &Port, NULL, NULL, msg);
                as$status ( sts    = sts,
                            msg    = "VLsortPortVSplates()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

                nplt = nprt;
                for ( i=0; i<nplt; i++)    Plat[i] = Port[i];
	}
	
	/* Retrieve the support surfaces */
	Surf = om$calloc ( num = nplt, structure = struct GRobj_env);
	for ( i=0; i<nplt; i++) {

		/* Copy VSplates to create frozen one */
                frz_id.objid = NULL_OBJID;
                frz_id.osnum = md_env->md_id.osnum;
                sts = gr$copy_object ( msg              = msg,
                                       object_id        = &Plat[i].obj_id,
                                       md_env           = &Plat[i].mod_env,
                                       new_env          = md_env,
                                       new_id           = &frz_id,
                                       display_flag     = 0 );
                as$status ( sts    = sts,
                            msg    = "gr$copy_object()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
		
		/* Extract support surface of the copy */
		sts = VLextractVSplateSurface ( msg,
						&frz_id,
						md_env,
						side,
						&Supp.obj_id,
						&Supp.mod_env,
						NULL );
		as$status ( sts    = sts,
                    	    msg    = "VLextractVSplateSurface()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		/* Copy VSplate support surface */
		Surf[i].mod_env = *md_env;
		Surf[i].obj_id.objid = NULL_OBJID;
		Surf[i].obj_id.osnum = md_env->md_id.osnum;
                sts = gr$copy_object ( msg              = msg,
                                       object_id        = &Supp.obj_id,
                                       md_env           = &Supp.mod_env,
                                       new_env          = &Surf[i].mod_env,
                                       new_id           = &Surf[i].obj_id,
                                       display_flag     = 0 );
                as$status ( sts    = sts,
                            msg    = "gr$copy_object()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Delete VSplate copy */
                if (frz_id.objid != NULL_OBJID)
                        gr$delete_object ( msg       = msg,
                                           md_env    = md_env,
                                           object_id = &frz_id );
	}
	idx += nplt;

	/*c Retrieve the real SMframe (if needed) */
	nmax = (IGRint)box[IDX_PM_NFRM];
	if (grop) 
		nfrm = nmax;
	else {	nfrm = 1;
		sts = vl$return_foot ( msg     = msg,
	                               objId   = &list[idx],
	                               objEnv  = md_env,
	                               footId  = &Fram.obj_id,
	                               footEnv = &Fram.mod_env );
		as$status ( sts    = sts,
                    	    msg    = "vl$return_foot(FRAME)",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
#ifdef TRACE
printf( "grop = %d\tFrame is (%d|%d) in (%d|%d)\n", grop,
	Fram.obj_id.osnum, Fram.obj_id.objid,
	Fram.mod_env.md_id.osnum, Fram.mod_env.md_id.objid );
#endif
	}
	idx += nfrm;

	/*c Retrieve the real characteristic line(s) */
	if (type == IDX_J3)	nlin = (IGRint)box[IDX_PM_NLIN];
	if (nlin) {
		Clin = om$calloc ( num = nlin, structure = struct GRobj_env);
		for ( i=0; i<nlin; i++) {
			sts = vl$return_foot ( msg     = msg,
		                               objId   = &list[idx+i],
		                               objEnv  = md_env,
		                               footId  = &Clin[i].obj_id,
		                               footEnv = &Clin[i].mod_env );
			as$status ( sts    = sts,
	                    	    msg    = "vl$return_foot(CLINE)",
	                    	    test   = (!(sts & 0x00000001 & (*msg))),
	                    	    action = GOTO_VALUE,
	                    	    value  = wrapup );
		}
	}

	/*c Decode frame entries */
	Binr = om$calloc ( num = nmax, structure = IGRint);
	VLdecode ( (IGRint)box[IDX_PM_CODE], nmax, Binr);
	for ( i=0; i<nmax; i++) {
#ifdef TRACE
printf( "Frame|Plane %2d is %d\n", i, Binr[i]);
#endif
		if (Binr[i])	npln++;
	}

	/*c Initialize feet */
	(*fcount) += npln;
	for ( i=0; i<*fcount; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	(*fcount) -= npln;

	/*c Build control line(s) */
	sts = VLbuildCntrLine ( msg, nplt, Plat, Xvec, type, VS_K_plTopSfPath,
				NULL, md_env, &feet_list[IDX_PM_CTR1],
				&feet_list[IDX_PM_CTR2] );
	as$status ( sts    = sts,
                    msg    = "VLbuildCntrLine()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Build Ppoint (if any) */
	if (grop) {
		sts = exp$create ( exp_syntax = "plug_Ppoint",
				   osnum      = md_env->md_id.osnum,
				   p_exp_id   = &feet_list[IDX_PM_PPNT].objid,
				   p_osnum    = &feet_list[IDX_PM_PPNT].osnum,
				   type_rq    = EXP_TEXT );
		as$status ( sts    = sts,
	                    msg    = "exp$create(PPNT))",
	                    test   = (sts != EXP_S_SUCCESS),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}
	else {	sts = VLfindPpPoint ( msg, &Fram, md_env, nplt, Plat, Xvec,
				      box[IDX_PM_MID], box[IDX_PM_SPAC],
				      &feet_list[IDX_PM_PPNT], Ppnt, &nrng);
		as$status ( sts    = sts,
                    	    msg    = "VLfindPpPoint()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		if (nrng > JF_LENGTH) {
			printf( "Too many template_jigs selected\n");
                	gr$delete_object ( msg       = msg,
                	                   md_env    = &md_env,
                        	           object_id = &feet_list[IDX_PM_PPNT]);
                	*msg = MSFAIL;
                	goto wrapup;
		}
	}

	/* Reevaluate ground distance */
	sts = VLevalPltCenterNormalDistance
	( Plat, nplt, side, type, -1*inv, TRUE, &Bpln[0], &Bpln[3], &Dsup, msg);
        as$status ( sts    = sts,
                    msg    = "VLevalPltCenterNormalDistance()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if( box[IDX_PM_DIR] == 1.0 ) for ( i=0; i<3; i++)    Bpln[3+i] *= -1.0;

	Dmin = box[IDX_PM_GRD] + Dsup + box[IDX_PM_HOLE];
	sts = exp$create ( exp_value = Dmin,
			   p_exp_id  = &feet_list[IDX_PM_REAL].objid,
			   osnum     = md_env->md_id.osnum,
			   p_osnum   = &feet_list[IDX_PM_REAL].osnum );
	as$status ( sts    = sts,
                    msg    = "exp$create(REAL))",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Initialize templates */
	ntpl += nplt + nlin;
	Temp = om$calloc ( num = ntpl, structure = struct GRid);
	for ( i=0; i<ntpl; i++) {
		Temp[i].objid = NULL_OBJID;
		Temp[i].osnum = md_env->md_id.osnum;
	}

	/* Prepare the attribute box */
	val[IDX_PO_REAL] = Dmin;
	val[IDX_PO_EXT1] = box[IDX_PM_EXT1];
	val[IDX_PO_EXT2] = box[IDX_PM_EXT2];
	val[IDX_PO_HOLE] = box[IDX_PM_HOLE];
	val[IDX_PO_INV]  = (IGRdouble)inv;
	val[IDX_PO_MID]  = box[IDX_PM_MID];
	val[IDX_PO_TYPE] = (IGRdouble)type;
	val[IDX_PO_OSET] = box[IDX_PM_OSET];
	val[IDX_PO_NSRF] = (IGRdouble)nplt;
	val[IDX_PO_NLIN] = (IGRdouble)nlin;
	val[IDX_PO_STOP] = box[IDX_PM_STOP];
	val[IDX_PO_STWI] = box[IDX_PM_STWI];

	/* Set the (first) control line */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_CL_CV,
                               objId   = &feet_list[IDX_PM_CTR1],
                               objEnv  = md_env,
                               footId  = &Klin.obj_id,
                               footEnv = &Klin.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(NAM_CL_CV)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	as$make_source ( go_grid = Klin.obj_id,
			 mod_env = &Klin.mod_env,
			 as_os   = md_env->md_id.osnum,
			 as_grid = &Temp[IDX_PO_CTRL] );

	/* Set the VSplate support surfaces */
	for ( i=0; i<nplt; i++)
		as$make_source ( go_grid = Surf[i].obj_id,
				 mod_env = &Surf[i].mod_env,
				 as_os   = md_env->md_id.osnum,
				 as_grid = &Temp[MACRO_PO_FTEMP+i] );

	/* Set the characteristic lines */
	for ( i=0; i<nlin; i++)
		Temp[MACRO_PO_FTEMP+nplt+i] = list[MACRO_PM_FTEMP+nplt+nfrm+i];

	/* Set average normal to Z in non Shell/Wall case */
        if (type != IDX_J3) {
                prod = BSdotp ( &rc, &Bpln[3], Zvec);
                dblcpy ( &Bpln[3], Zvec, 3);
                if (prod < 0.0) for ( i=0; i<3; i++)    Bpln[3+i] *= -1.0;
        }

	/* Fill parameter box with cog and normal */
	val[IDX_PO_XCOG] = Bpln[0];
	val[IDX_PO_YCOG] = Bpln[1];
	val[IDX_PO_ZCOG] = Bpln[2];
	val[IDX_PO_XNRM] = Bpln[3];
	val[IDX_PO_YNRM] = Bpln[4];
	val[IDX_PO_ZNRM] = Bpln[5];

	/* Construct the <VLjigObj> feet */
	idx = MACRO_PO_FTEMP;
	for ( i=0; i<nmax; i++) {
		if (Binr[i]) {
			/* Construct the attribute box */
			val[IDX_PO_ORDR] = (IGRdouble)i;
			sts = VLsetPlateJigObjAttr ( msg, val,
						     &Temp[IDX_PO_ATTR] );
			as$status ( sts    = sts,
		                    msg    = "VLsetPlateJigObjAttr(ATTR)",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Construct the section plane */
			Temp[IDX_PO_PLAN].objid = NULL_OBJID;
			Temp[IDX_PO_PLAN].osnum = md_env->md_id.osnum;
			if (grop)
				Temp[IDX_PO_PLAN] = list[MACRO_PM_FTEMP+nplt+i];
			else {	sts = VLbuildJigFixPlane ( msg, &Klin.obj_id,
							   Ppnt, Bpln, type,
							   box[IDX_PM_MID], i,
							   box[IDX_PM_SPAC],
							   md_env, &pln_id );
				as$status ( sts    = sts,
			                    msg    = "VLbuildJigFixPlane()",
			                    test   = (!(sts&0x00000001&(*msg))),
			                    action = GOTO_VALUE,
			                    value  = wrapup );

				/* Make source on fix grid plane */
				as$make_source ( go_grid = pln_id,
						 mod_env = md_env,
						 as_os   = md_env->md_id.osnum,
						 as_grid = &Temp[IDX_PO_PLAN] );
			}

			/* Construct the index */
			sprintf( Sexp, "%d/%d", i+1, npln);
			sts =
			exp$create ( exp_name   = NULL,
                                     exp_syntax = Sexp,
                                     osnum      = md_env->md_id.osnum,
                                     p_exp_id   = &Temp[IDX_PO_INDX].objid,
                                     p_osnum    = &Temp[IDX_PO_INDX].osnum,
                                     type_rq    = EXP_TEXT );
			as$status ( sts    = sts,
		                    msg    = "exp$create(INDX))",
		                    test   = (sts != EXP_S_SUCCESS),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Contruct, place & change state <VLjigObj> object */
			sts =
			vl$placeLoftMacro ( msg      = msg,
                                            classid  = OPP_VLjigObj_class_id,
                                            MacName  = MACRO_PO_DEF,
                                            number   = ntpl,
                                            template = Temp,
                                            Env      = md_env,
					    ChgState = FALSE,
                                            occ_id   = &occ_id );

			if( !(sts&(*msg)&1) ) continue;

			/* Move to root the <VLjigObj> object */
			if (occ_id.objid != NULL_OBJID) {
			sts = om$send ( msg = message NDnode.NDmove_to_root
					( msg, &feet_list[idx], md_env),
					targetid = occ_id.objid,
					targetos = occ_id.osnum );
			as$status ( sts    = sts,
		                    msg    = "NDnode.NDmove_to_root",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
#ifdef TRACE
printf( "\t<VLjigObj> NDmove_to_root as foot %d : (%d|%d)\n",
	idx, feet_list[idx].osnum, feet_list[idx].objid );
#endif

			/* Increase the variable feet index */
			idx++;
			}

			/* Delete ATTR evanescent template */
			if (Temp[IDX_PO_ATTR].objid != NULL_OBJID) {
				sts = vl$return_foot (
						msg     = msg,
			                        objId   = &Temp[IDX_PO_ATTR],
			                        objEnv  = md_env,
			                        footId  = &Dummy.obj_id,
						footEnv = &Dummy.mod_env );
				as$status ( sts    = sts,
		                    	    msg    = "vl$return_foot(ATTR)",
test   = (!(sts & 0x00000001 & (*msg))),
		                    	    action = GOTO_VALUE,
		                    	    value  = wrapup );
#ifdef TRACE
printf( ">>gr$delete_object[%d|%d] : Temp[%d] ATTR\n",
	Dummy.obj_id.osnum, Dummy.obj_id.objid, IDX_PO_ATTR );
#endif
                		sts = gr$delete_object (
						msg       = msg,
	       	         	          	md_env    = &Dummy.mod_env,
	                        	        object_id = &Dummy.obj_id );
				as$status ( sts    = sts,
		                    	    msg    = "gr$delete_object()",
test   = (!(sts & 0x00000001 & (*msg))),
		                    	    action = GOTO_VALUE,
		                    	    value  = wrapup );
			}

			/* Delete PLAN evanescent template */
			if ((!grop) && (Temp[IDX_PO_PLAN].objid != NULL_OBJID))
			{
				sts = vl$return_foot (
						msg     = msg,
			                        objId   = &Temp[IDX_PO_PLAN],
			                        objEnv  = md_env,
			                        footId  = &Dummy.obj_id,
						footEnv = &Dummy.mod_env );
				as$status ( sts    = sts,
		                    	    msg    = "vl$return_foot(PLAN)",
test   = (!(sts & 0x00000001 & (*msg))),
		                    	    action = GOTO_VALUE,
		                    	    value  = wrapup );
#ifdef TRACE
printf( ">>gr$delete_object[%d|%d] : Temp[%d] PLAN\n",
	Dummy.obj_id.osnum, Dummy.obj_id.objid, IDX_PO_PLAN );
#endif
                		sts = gr$delete_object (
						msg       = msg,
	       	         	          	md_env    = &Dummy.mod_env,
	                        	        object_id = &Dummy.obj_id );
				as$status ( sts    = sts,
		                    	    msg    = "gr$delete_object()",
test   = (!(sts & 0x00000001 & (*msg))),
		                    	    action = GOTO_VALUE,
		                    	    value  = wrapup );
			}

			/* Delete INDX evanescent template */
			if (Temp[IDX_PO_INDX].objid != NULL_OBJID) {
				sts = vl$return_foot (
						msg     = msg,
			                        objId   = &Temp[IDX_PO_INDX],
			                        objEnv  = md_env,
			                        footId  = &Dummy.obj_id,
						footEnv = &Dummy.mod_env );
				as$status ( sts    = sts,
		                    	    msg    = "vl$return_foot(INDX)",
test   = (!(sts & 0x00000001 & (*msg))),
		                    	    action = GOTO_VALUE,
		                    	    value  = wrapup );
#ifdef TRACE
printf( ">>gr$delete_object[%d|%d] : Temp[%d] INDX\n",
	Dummy.obj_id.osnum, Dummy.obj_id.objid, IDX_PO_INDX );
#endif
                		sts = gr$delete_object (
						msg       = msg,
	       	         	          	md_env    = &Dummy.mod_env,
	                        	        object_id = &Dummy.obj_id );
				as$status ( sts    = sts,
		                    	    msg    = "gr$delete_object()",
test   = (!(sts & 0x00000001 & (*msg))),
		                    	    action = GOTO_VALUE,
		                    	    value  = wrapup );
			}
		}
	}
	(*fcount) += idx;


wrapup:
	/* Delete VSplate copy (if needed) */
	if (frz_id.objid != NULL_OBJID) {
		vl$return_foot ( msg     = msg,
		                 objId   = &frz_id,
		                 objEnv  = md_env,
		                 footId  = &Dummy.obj_id,
				 footEnv = &Dummy.mod_env );
		gr$delete_object ( msg       = &loc_msg,
				   md_env    = &Dummy.mod_env,
				   object_id = &Dummy.obj_id );
	}

	/* Delete support surfaces */
	if (Surf) {
		for ( i=0; i<nplt; i++) {
	                if (Surf[i].obj_id.objid != NULL_OBJID) {
				vl$return_foot ( msg     = msg,
				                 objId   = &Surf[i].obj_id,
				                 objEnv  = &Surf[i].mod_env,
				                 footId  = &Dummy.obj_id,
						 footEnv = &Dummy.mod_env );
	                        gr$delete_object ( msg       = &loc_msg,
	                                           md_env    = &Dummy.mod_env,
	                                           object_id = &Dummy.obj_id );
	                }
	        }
		om$dealloc(ptr = Surf);
		Surf  = NULL;
        }

	if (Port) {	om$dealloc(ptr = Port);		Port  = NULL;	}
	if (Temp) {	om$dealloc(ptr = Temp);		Temp  = NULL;	}
	if (Clin) {	om$dealloc(ptr = Clin);		Clin  = NULL;	}
	if (Plat) {	om$dealloc(ptr = Plat);		Plat  = NULL;	}
	if (Binr) {	om$dealloc(ptr = Binr);		Binr = NULL;	}

	return(OM_S_SUCCESS);
}

end implementation VLjigMgr;
