/* $Id: VLpinAlgo.I,v 1.3 2001/09/24 19:29:20 ramarao Exp $  */
/*************************************************************************
 * I/LOFT
 *
 * File:	loft/src/pin_jig/VLpinAlgo.I
 *
 * Description:	Functions for pin jigs' report.
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLpinAlgo.I,v $
 * Revision 1.3  2001/09/24 19:29:20  ramarao
 * Fixed small bugs.
 *
 * Revision 1.2  2001/02/20 01:05:52  build
 * Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 * Revision 1.1  2001/01/16 19:29:18  ramarao
 * *** empty log message ***
 *
# Revision 1.2  2000/07/05  13:34:08  pinnacle
# Replaced: loft/src/pin_jig/VLpinAlgo.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/06/28  13:30:46  pinnacle
# Created: loft/src/pin_jig/VLpinAlgo.I by rchennup for Service Pack
#
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 06/20/00	Marc Fournier	Split from VLpinFunk.I
 *************************************************************************/

class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	"vlprototype.h"
#include	"vlpinjig.h"
#include	"OMerrordef.h"
#include	"OMindex.h"
#include	"AS_status.h"
#include	"bs.h"
#include	"bsparameters.h"
#include	"bsconic.h"
#include	"bserr.h"
#include	"bsvalues.h"
#include	"maerr.h"
#include	"msdef.h"
#include	"DIdef.h"
#include	"grmacros.h"
#include	"vsmiscmacros.h"
#include	"vsplatedef.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"ACdyn_col.h"
#include	"asbox.h"

#include	"bscv_sf_int.h"
#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bspj_pt_sf.h"
#include	"bspt_in_cv.h"
#include	"bssfeval.h"
#include	"bsxtractpar.h"

#include	"mamulmx.h"
#include	"mainvmx.h"
#include	"maidmx.h"

#include	"vlfloor.h"
#include	"vllayout.h"
#include	"vlmiscmacros.h"
#include	"vltemplate.h"

#define	vsDEBUG	1
#include	"vldbgmacros.h"

from	ACdyn_col	import	ACget_named_attribute;
from	GRgencs		import	GRgetmatrix;
from	VLpinjig	import	VLget_attributes;
from	expression	import	NDgive_value;

//	#define	TRACE 1
#define	REALP 1		/* Real plate corners for panel corners	*/

extern  GRclassid       OPP_VSplate_class_id;

/* ========================================================================== */
IGRint VLfourCornersAlgo ( cnt, pnt )
	IGRint		cnt;
	VLpinJigPanel	*pnt;
{
	IGRint		i, num=0;
	IGRvector	vec[2];
	BSrc		rc;

	/* Eliminate middle points */
	for ( i=0; i<cnt; i++ ) {
		BSmkvec  ( &rc, vec[0], pnt[i].spt, pnt[i].ept );
		BSnorvec ( &rc, vec[0] );
		BSmkvec  ( &rc, vec[1], pnt[i+1].spt, pnt[i+1].ept );
		BSnorvec ( &rc, vec[1] );
		if ( BSdotp(&rc,vec[0],vec[1]) > 0.9 ) {
			pnt[i+1].bad = TRUE;
		}
	}
	if (pnt[cnt].bad == TRUE)	pnt[0].bad = TRUE;

	/* Evaluate number of corners */
	for ( i=0; i<cnt; i++ ) {
		if (pnt[i].bad == FALSE)	num++;
	}

wrapup:
	return (num);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLpanelCornerPoints ( msg, balanceId, Env, npnl, panelP )

		IGRlong		*msg;
	struct	GRid		*balanceId;
	struct	GRmd_env	*Env;
		IGRint		*npnl;
		IGRpoint	**panelP;
{
		IGRint		sts=OM_S_SUCCESS, i;
	struct	GRobj_env	Cont;
#ifdef	REALP
		IGRint		cnt=0, idx=0;
	struct	GRid		*compId;
		VLpinJigPanel	*pnt;
#else
		IGRshort	world = TRUE;
		GRrange		range;
#endif

	/* Initialise */
	*npnl   = 0;
	*panelP = NULL;
#ifdef	REALP
	compId	= NULL;
	pnt	= NULL;
#endif

	/*c Get external contour */
	Cont.obj_id.objid = NULL_OBJID;
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_CONT,
                               objId   = balanceId,
                               objEnv  = Env,
                               footId  = &Cont.obj_id,
                               footEnv = &Cont.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(CONT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef	REALP
	/*c Retrieve number of components of contour */
	sts = om$send ( msg = message GRowner.GRget_number_components
				( msg, &cnt ),
			senderid = NULL_OBJID,
			targetid = Cont.obj_id.objid,
			targetos = Cont.obj_id.osnum );
	as$status ( sts    = sts,
	    	    msg    = "GRowner.GRget_number_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
                    value  = wrapup );

	if (cnt == 0)	goto wrapup;

	/* Allocate memory */
	compId = om$calloc ( num = cnt, structure = struct GRid );

	/*c Retrieve components of external contour */
	i = 0;
	sts = om$send ( msg = message GRowner.GRget_components (
					msg,
					&Cont.mod_env,
					compId,
					cnt,
					&i,
					0, OM_K_MAXINT ),
			senderid = NULL_OBJID,
			targetid = Cont.obj_id.objid,
			targetos = Cont.obj_id.osnum );
	as$status ( sts    = sts,
	    	    msg    = "GRowner.GRget_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory */
	pnt = om$calloc ( num = cnt + 1, structure = VLpinJigPanel );

	/* Loop on external contour components */
	for ( i=0; i<=cnt; i++ ) {
		pnt[i].idx = i;
		pnt[i].bad = FALSE;
		if (i < cnt) {
		sts = VLendpts ( msg, &compId[i], &Cont.mod_env,
				 pnt[i].spt, pnt[i].ept );
		as$status ( sts    = sts,
		    	    msg    = "VLendpts()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                   	    value  = wrapup );
		}
		else {
			pnt[i].spt[0] = pnt[0].spt[0];
			pnt[i].spt[1] = pnt[0].spt[1];
			pnt[i].spt[2] = pnt[0].spt[2];
			pnt[i].ept[0] = pnt[0].ept[0];
			pnt[i].ept[1] = pnt[0].ept[1];
			pnt[i].ept[2] = pnt[0].ept[2];
		}
	}

	/* Eliminate non mandatory points */
	VLfourCornersAlgo ( cnt, pnt );

	/* Prepare output structure */
	for ( i=0; i<cnt; i++ ) {
		if (pnt[i].bad == FALSE)	(*npnl)++;
	}
	if ((*npnl) == 0)	goto wrapup;
	(*panelP) = om$calloc ( num = (*npnl), structure = IGRpoint );
	for ( i=0; i<cnt; i++ ) {
		if (pnt[i].bad == FALSE) {
			(*panelP)[idx][0] = pnt[i].spt[0];
			(*panelP)[idx][1] = pnt[i].spt[1];
			(*panelP)[idx][2] = pnt[i].spt[2];
			idx++;
		}
	}
#else
	/* Get external contour range box */
	sts = om$send ( msg = message GRgraphics.GRgetrang (
				msg,
				&(Cont.mod_env.md_env.matrix_type),
				Cont.mod_env.md_env.matrix,
				&world,
				range ),
			senderid = NULL_OBJID,
			targetid = Cont.obj_id.objid,
			targetos = Cont.obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgraphics.GRgetrang",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Prepare output structure */
	(*npnl) = 4;
	(*panelP) = om$calloc ( num = 4, structure = IGRpoint );

	(*panelP)[0][0] = range[0];
	(*panelP)[0][1] = range[1];
	(*panelP)[0][2] = range[2];

	(*panelP)[1][0] = range[0];
	(*panelP)[1][1] = range[4];
	(*panelP)[1][2] = range[2];

	(*panelP)[2][0] = range[3];
	(*panelP)[2][1] = range[4];
	(*panelP)[2][2] = range[5];

	(*panelP)[3][0] = range[3];
	(*panelP)[3][1] = range[1];
	(*panelP)[3][2] = range[5];
#endif

wrapup:
#ifdef	REALP
	if (pnt) {	om$dealloc (ptr=pnt);		pnt = NULL;	}
	if (compId) {	om$dealloc (ptr=compId);	compId = NULL;	}
#endif
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLpinCorners ( msg, pinjig, npin, ncrn, corner, npnl, panelC)

		IGRlong		*msg;
	struct	GRobj_env	*pinjig;
		IGRint		npin;
		IGRint		*ncrn;
		VLpinCorn	**corner;
		IGRint		*npnl;
		VLpinCorn	**panelC;

{

		IGRint		sts, i, j, k, suc, idx=0;
		IGRdouble	value, sept[12];
	struct	GRid		layout, balance, dummy, comp[10], Elem;
		IGRchar		name[DI_PATH_MAX];
	struct	GRobj_env	Cont;
	struct	ACrg_coll	elem, *attr;
		IGRdouble	xpin, ypin, xcal, ycal, dcal, dmin;
		IGRint		nplat, nfeet, ncomp, imin;
		IGRpoint	*PanelC;
	struct	VLpinJig	*Pin;

	/* Initialize */
	*ncrn   = 0;
	*corner = NULL;
	attr    = NULL;
	*npnl   = 0;
	*panelC = NULL;
	PanelC	= NULL;
	Pin   	= NULL;

	/* Allocate memory for <VLpinjig> attribute box */
	attr = om$calloc ( num	     = IDX_PB_MAX * npin,
			   structure = struct ACrg_coll );

	/* Retrieve <VLpinjig> attribute box */
	sts = om$send ( msg = message VLpinjig.VLget_attributes
					( msg, NULL, NULL, TRUE, attr, NULL),
			senderid = NULL_OBJID,
			targetid = pinjig->obj_id.objid,
			targetos = pinjig->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "VLpinjig.VLget_attributes",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve <VLlayout> macro */
        sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
                                        ( &suc, IDX_PT_MACR, &layout),
			senderid = NULL_OBJID,
			targetid = pinjig->obj_id.objid,
			targetos = pinjig->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "ACncpx.ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve <VLbalance> macro */
        sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
                                        ( &suc, IDX_LT_MACR, &balance),
			senderid = NULL_OBJID,
			targetid = layout.objid,
			targetos = layout.osnum );
        as$status ( sts    = sts,
                    msg    = "ACncpx.ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve <VLbalance> number of VSplates */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_NPLT,
                               objId   = &balance,
                               footId  = &dummy );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(NPLT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	sts = om$send ( msg = message expression.NDgive_value (&value),
			senderid = NULL_OBJID,
			targetid = dummy.objid,
			targetos = dummy.osnum );
	as$status ( sts    = sts,
		    msg    = "expression.NDgive_value(NPLT)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	nplat = (IGRint) value;
	*ncrn = 4 * nplat;

	/* Retrieve <VLbalance> attributes of VSplates */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_ATTR,
                               objId   = &balance,
                               footId  = &Elem );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(ATTR)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for VLpinCorn structure */
	*corner = om$calloc ( num       = (*ncrn),
			      structure = VLpinCorn );
	if (!(*corner)) {	printf( "Unable to allocate %d bytes\n",
					(*ncrn) * sizeof(VLpinCorn) ); 
				*msg = MSFAIL;	goto wrapup;	}

	/*c Retrieve number of feet in VLbalance occurence */
	sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &nfeet),
			senderid = NULL_OBJID,
			targetid = balance.objid,
			targetos = balance.osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Loop on internal contours */
	for ( i=nfeet-nplat; i<nfeet; i++) {
		idx = i - nfeet + nplat;
		Cont.obj_id.objid = NULL_OBJID;
		sprintf ( name, "%s%d", NAM_BF_VARF, i - MACRO_B_FFEET);
		sts = vl$return_foot ( msg     = msg,
				       name    = name,
	                               objId   = &balance,
	                               objEnv  = &pinjig->mod_env,
	                               footId  = &Cont.obj_id,
	                               footEnv = &Cont.mod_env );
	        as$status ( sts    = sts,
	                    msg    = "vl$return_foot(CONT)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/*c Retrieve name of VSplate */
		sprintf( elem.name, "%s%d", NAM_BB_NAM, idx);
		sts = om$send ( msg = message ACdyn_col.ACget_named_attribute
                                        ( msg, &elem ),
                                senderid = NULL_OBJID,
                                targetid = Elem.objid,
                                targetos = Elem.osnum );
                as$status ( sts    = sts,
                            msg    = "ACdyn_col.ACget_named_attribute",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/*c Retrieve number of components of contour */
		sts = om$send ( msg = message GRowner.GRget_components (
						msg,
						&Cont.mod_env,
						comp,
						4,
						&ncomp,
						0, OM_K_MAXINT ),
				senderid = NULL_OBJID,
				targetid = Cont.obj_id.objid,
				targetos = Cont.obj_id.osnum );
		as$status ( sts    = sts,
		    	    msg    = "GRowner.GRget_components",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		if (ncomp != 4) {
			printf( "Trouble for <%s> that get %d components\n", 
				name, ncomp );
			continue;	}

		sts = VLendpts ( msg, &comp[0], &Cont.mod_env,
				  &sept[0], &sept[3]);
		as$status ( sts    = sts,
		    	    msg    = "VLendpts()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                   	    value  = wrapup );

		sts = VLendpts ( msg, &comp[2], &Cont.mod_env,
				  &sept[6], &sept[9]);
		as$status ( sts    = sts,
		    	    msg    = "VLendpts()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                   	    value  = wrapup );

#ifdef TRACE
for ( j=0; j<4; j++)
printf( ">>> Corner %d is [%g,%g,%g]\n", j,
	sept[3*j], sept[3*j+1], sept[3*j+2] );
#endif
		VLorder4corners ( sept, &(*corner)[4*idx] );
#ifdef TRACE
for ( j=0; j<4; j++)
printf( "<<< Corner %d is [%g,%g,%g]\n", j,
	(*corner)[4*idx+j].dx, (*corner)[4*idx+j].dy );
printf( "\n");
#endif

		for ( j=0; j<4; j++) {
			if (!strcmp ( elem.desc.value.att_txt, "Unamed") )
				sprintf( (*corner)[4*idx + j].cp, "C%dP?", j+1); 
			else	sprintf( (*corner)[4*idx + j].cp, "C%d%s", j+1,
				  	 elem.desc.value.att_txt );
		}
	}

	/* Evaluate plate corners heights */
	Pin = om$calloc ( num = (*ncrn), structure = struct VLpinJig );
	for ( i=0; i<(*ncrn); i++ ) {
		Pin[i].flg = TRUE;
		Pin[i].xpt = (*corner)[i].dx;
		Pin[i].ypt = (*corner)[i].dy;
		Pin[i].zpt = (*corner)[i].dz;
		Pin[i].hei = 0.0;
		Pin[i].ang = 0.0;
	}
	sts = VLpinHeightAngle ( msg, &balance, &(pinjig->mod_env),
				 (*ncrn), Pin );
        as$status ( sts    = sts,
                    msg    = "VLpinHeightAngle()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	for ( i=0; i<(*ncrn); i++ )	(*corner)[i].dz = Pin[i].hei;

	/* Search closest HnVm pinjig for plate corners */
	for ( i=0; i<nplat; i++) {
		for ( j=0; j<4; j++) {
			strcpy ( (*corner)[4*i+j].pn, "Unknown");
			dmin = 1000000.0;
			imin = 0;
			for ( k=0; k<npin; k++) {
idx = (IGRint)attr[IDX_PB_MAX*k+IDX_PB_IDX].desc.value.att_exp;
xpin = attr[IDX_PB_MAX*k+IDX_PB_XPT].desc.value.att_exp;
ypin = attr[IDX_PB_MAX*k+IDX_PB_YPT].desc.value.att_exp;
				xcal  = xpin - (*corner)[4*i+j].dx;
				xcal *= xcal;
				ycal  = ypin - (*corner)[4*i+j].dy;
				ycal *= ycal;
				dcal  = sqrt (xcal+ycal);
#ifdef TRACE
printf( "SQRT(%g+%g) = %g\n", xcal, ycal, dcal);
#endif
				if (dcal < dmin) { dmin = dcal; imin = k; }
			}
			(*corner)[4*i+j].dx
			-= attr[IDX_PB_MAX*imin+IDX_PB_XPT].desc.value.att_exp;
			(*corner)[4*i+j].dy
			-= attr[IDX_PB_MAX*imin+IDX_PB_YPT].desc.value.att_exp;
			sprintf ( (*corner)[4*i+j].pn, "%s",
			attr[IDX_PB_MAX*imin+IDX_PB_NAM].desc.value.att_txt );
		}
	}

	/* Get panel corner points (geometry) */
	sts = VLpanelCornerPoints ( msg, &balance, &pinjig->mod_env,
				    npnl, &PanelC );
        as$status ( sts    = sts,
                    msg    = "VLpanelCornerPoints()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for panel corner VLpinCorn structure */
	if ((*npnl) > 0) {
		(*panelC) = om$calloc ( num	  = (*npnl),
					structure = VLpinCorn );
	}

	/* Fill panel corner VLpinCorn structure */
	for ( i=0; i<(*npnl); i++ ) {

		strcpy ( (*panelC)[i].cp, "Unknown");
		(*panelC)[i].dx = PanelC[i][0];
		(*panelC)[i].dy = PanelC[i][1];

		dmin = 1000000.0;
		imin = 0;
		for ( j=0; j<npin; j++) {
idx = (IGRint)attr[IDX_PB_MAX*j+IDX_PB_IDX].desc.value.att_exp;
xpin = attr[IDX_PB_MAX*j+IDX_PB_XPT].desc.value.att_exp;
ypin = attr[IDX_PB_MAX*j+IDX_PB_YPT].desc.value.att_exp;
			xcal  = xpin - (*panelC)[i].dx;
			xcal *= xcal;
			ycal  = ypin - (*panelC)[i].dy;
			ycal *= ycal;
			dcal  = sqrt (xcal+ycal);
			if (dcal < dmin) { dmin = dcal; imin = j; }
		}
		(*panelC)[i].dx
		-= attr[IDX_PB_MAX*imin+IDX_PB_XPT].desc.value.att_exp;
		(*panelC)[i].dy
		-= attr[IDX_PB_MAX*imin+IDX_PB_YPT].desc.value.att_exp;
		sprintf ( (*panelC)[i].pn, "%s",
		attr[IDX_PB_MAX*imin+IDX_PB_NAM].desc.value.att_txt );
		(*panelC)[i].dz = 0.0;

		for ( k=0; k<(*ncrn); k++ ) {
			if ( (!strcmp( (*corner)[k].pn, (*panelC)[i].pn ))
			&&   ( fabs((*corner)[k].dx-(*panelC)[i].dx) < 1.)
			&&   ( fabs((*corner)[k].dy-(*panelC)[i].dy) < 1.) ) {
				strcpy ( (*panelC)[i].cp, (*corner)[k].cp );
				strcat ( (*corner)[k].cp, " *" );
				(*panelC)[i].dz = (*corner)[k].dz;
				k = (*ncrn);
			}
		}
#ifdef TRACE
printf ( "panelC[%d] : %s %g %g %s\n", i,
	 (*panelC)[i].cp, (*panelC)[i].dx, (*panelC)[i].dy, (*panelC)[i].pn ); 
#endif
	}

wrapup:
	if (Pin) {	om$dealloc (ptr = Pin);		Pin = NULL;	}
	if (PanelC) {	om$dealloc (ptr = PanelC);	PanelC = NULL;	}
	if (attr) {	om$dealloc (ptr = attr);	attr = NULL;	}
	return (sts);
}
/* ========================================================================== */
void VLorder4corners ( pts, crn)
	IGRdouble	*pts;
	VLpinCorn	*crn;
{
	IGRdouble	dst[4], tmp[3];
	IGRint		i, j;
	IGRboolean	idx[4];

	/*c Fill temporary arrays */
	for ( i=0; i<4; i++) {
		dst[i] = pts[3*i+0] * pts[3*i+0]
		       + pts[3*i+1] * pts[3*i+1]
		       + pts[3*i+2] * pts[3*i+2];
		dst[i] = sqrt(dst[i]);
		idx[i] = TRUE;
	}

	/*c Compare distances */
	for ( i=0; i<4; i++) {
		for ( j=0; j<4; j++) {
			if (dst[j] < dst[i]) {	idx[i] = FALSE;
						j      = 4;	}
		}
	}

	/*c Exchange data */
	for ( i=0; i<4; i++) {
		if (idx[i]) {	crn[0].dx = pts[3*i+0];
				crn[0].dy = pts[3*i+1];
				dblcpy ( &tmp[0],   &pts[0],   3);
				dblcpy ( &pts[0],   &pts[3*i], 3);
				dblcpy ( &pts[3*i], &tmp[0],   3);
				i      = 4;	}
	}

	/*c Fill temporary arrays */
	for ( i=1; i<4; i++)	{
		dst[i] = pts[3*i+0] * pts[3*i+0]
		       + pts[3*i+1] * pts[3*i+1]
		       + pts[3*i+2] * pts[3*i+2];
		dst[i] = sqrt(dst[i]);
		idx[i] = TRUE;
	}

	/*c Compare distances */
	for ( i=1; i<4; i++) {
		for ( j=1; j<4; j++) {
			if (dst[j] > dst[i]) {	idx[i] = FALSE;
						j      = 4;	}
		}
	}

	/*c Exchange data */
	for ( i=1; i<4; i++) {
		if (idx[i]) {	crn[2].dx = pts[3*i+0];
				crn[2].dy = pts[3*i+1];
				dblcpy ( &tmp[0],   &pts[3],   3);
				dblcpy ( &pts[3],   &pts[3*i], 3);
				dblcpy ( &pts[3*i], &tmp[0],   3);
				i      = 4;	}
	}

	if (pts[7] < pts[10]) {	crn[1].dx = pts[6];
				crn[1].dy = pts[7];
				crn[3].dx = pts[9];
				crn[3].dy = pts[10];	}
	else {			crn[1].dx = pts[9];
				crn[1].dy = pts[10];
				crn[3].dx = pts[6];
				crn[3].dy = pts[7];	}
}
/* ========================================================================== */

/* ========================================================================== */
void EulerAngleToMatrix ( Ang, Mat )
	IGRpoint	Ang;	/*I Euler angles			*/
	IGRmatrix	Mat;	/*O Euler matrix			*/
{
	IGRdouble	C[3], S[3];

	C[0] = cos(Ang[0]);
	C[1] = cos(Ang[1]);
	C[2] = cos(Ang[2]);

	S[0] = sin(Ang[0]);
	S[1] = sin(Ang[1]);
	S[2] = sin(Ang[2]);

	Mat[0]  = C[1] * C[2];
	Mat[1]  = S[0] * S[1] * C[2] - C[0] * S[2];
	Mat[2]  = C[0] * S[1] * C[2] + S[0] * S[2];
	Mat[3]  = 0.0;

	Mat[4]  = C[1] * S[2];
	Mat[5]  = S[0] * S[1] * S[2] + C[0] * C[1];
	Mat[6]  = C[0] * S[1] * S[2] - S[0] * C[1];
	Mat[7]  = 0.0;

	Mat[8]  = S[1] * -1.0;
	Mat[9]  = S[0] * C[1];
	Mat[10] = C[0] * C[1];
	Mat[11] = 0.0;

	Mat[12] = 0.0;
	Mat[13] = 0.0;
	Mat[14] = 0.0;
	Mat[15] = 1.0;

	return;
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLbasePoints ( msg, Bal, Bas )
		IGRlong		*msg;	/*O Error message		*/
	struct	GRobj_env	*Bal;	/*I VLbalance occurrence	*/
		VLbalBasePts	*Bas;	/*O 8 points : base + xformed	*/
{
                IGRint          sts=OM_S_SUCCESS, cnt=0, i=0, suc, ncrn=0, idx=0;
		IGRpoint	ang, Crn[4];
	struct	GRobj_env	Cnt;
	struct	GRid		*Cmp, GCS;
		VLpinJigPanel	*Pnt;
		IGRmatrix	Eul, Gcs, T3d, Inv, Tra, Mat;
		BSrc		rc;
		IGRshort	four=4, one=1;
		IGRdouble	pnt[8];

	/* Initialise */
	ang[0] = ang[1] = ang[2] = 0.0;
	Cmp = NULL;
	Pnt = NULL;

	/* Get VLbalance external contour */
	Cnt.obj_id.objid = NULL_OBJID;
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_CONT,
                               objId   = &Bal->obj_id,
                               objEnv  = &Bal->mod_env,
                               footId  = &Cnt.obj_id,
                               footEnv = &Cnt.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(CONT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve number of components of contour */
	sts = om$send ( msg = message GRowner.GRget_number_components
				( msg, &cnt ),
			senderid = NULL_OBJID,
			targetid = Cnt.obj_id.objid,
			targetos = Cnt.obj_id.osnum );
	as$status ( sts    = sts,
	    	    msg    = "GRowner.GRget_number_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
                    value  = wrapup );

	if (cnt == 0)	goto wrapup;

	/* Allocate memory */
	Cmp = om$calloc ( num = cnt, structure = struct GRid );

	/* Retrieve components of external contour */
	sts = om$send ( msg = message GRowner.GRget_components
			( msg, &Cnt.mod_env, Cmp, cnt, &i, 0, OM_K_MAXINT ),
			senderid = NULL_OBJID,
			targetid = Cnt.obj_id.objid,
			targetos = Cnt.obj_id.osnum );
	as$status ( sts    = sts,
	    	    msg    = "GRowner.GRget_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory */
	Pnt = om$calloc ( num = cnt + 1, structure = VLpinJigPanel );

	/* Loop on external contour components */
	for ( i=0; i<=cnt; i++ ) {
		Pnt[i].idx = i;
		Pnt[i].bad = FALSE;
		if (i < cnt) {
		sts = VLendpts ( msg, &Cmp[i], &Cnt.mod_env,
				 Pnt[i].spt, Pnt[i].ept );
		as$status ( sts    = sts,
		    	    msg    = "VLendpts()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                   	    value  = wrapup );
		}
		else {
			Pnt[i].spt[0] = Pnt[0].spt[0];
			Pnt[i].spt[1] = Pnt[0].spt[1];
			Pnt[i].spt[2] = Pnt[0].spt[2];
			Pnt[i].ept[0] = Pnt[0].ept[0];
			Pnt[i].ept[1] = Pnt[0].ept[1];
			Pnt[i].ept[2] = Pnt[0].ept[2];
		}
	}

	/* Eliminate non mandatory points */
	VLfourCornersAlgo ( cnt, Pnt );

	/* Prepare output structure */
	for ( i=0; i<cnt; i++ ) {
		if (Pnt[i].bad == FALSE)	ncrn++;
	}
	if (ncrn != 4)	goto wrapup;

	for ( i=0; i<cnt; i++ ) {
		if (Pnt[i].bad == FALSE) {
			Crn[idx][0] = Pnt[i].spt[0];
			Crn[idx][1] = Pnt[i].spt[1];
			Crn[idx][2] = Pnt[i].spt[2];
			idx++;
		}
	}

	/* Get Euler angles then matrix */
	ang[0] = VLgetFootValue ( &Bal->obj_id, NAM_BF_XANG );
	ang[1] = VLgetFootValue ( &Bal->obj_id, NAM_BF_YANG );
	ang[2] = VLgetFootValue ( &Bal->obj_id, NAM_BF_ZANG );
	EulerAngleToMatrix ( ang, Eul );
#ifdef TRACE
__DBGpr_mat ( "Euler", Eul );
#endif
	/* Get ground CS matrix */
        GCS.objid = NULL_OBJID;
	GCS.osnum = Bal->mod_env.md_id.osnum;
        sts = om$send ( msg = message ACcpx.ACfind_exp_temp_obj
				( &suc, IDX_BT_GCS, &GCS ),
			senderid = NULL_OBJID,
			targetid = Bal->obj_id.objid,
			targetos = Bal->obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "ACcpx.ACfind_exp_temp_obj(GCS)",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
__DBGpr_obj ( "Ground CS", GCS );
#endif
        /* Retrieve ground cs matrix */
        sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, Gcs),
			senderid = NULL_OBJID,
                        targetid = GCS.objid,
                        targetos = GCS.osnum );
        as$status ( sts    = sts,
                    msg    = "GRgencs.GRgetmatrix",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
__DBGpr_mat ( "Ground", Gcs );
#endif
	/* Inverse ground CS matrix */
	MAinvmx  ( &rc, &four, Gcs, Inv );
#ifdef TRACE
__DBGpr_mat ( "inverse Ground", Inv );
#endif
	/* Get translation matrix to 3D */
	sts = VLget3Dtranslation ( msg, Bal, &T3d );
        as$status ( sts    = sts,
                    msg    = "VLget3Dtranslation()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
__DBGpr_mat ( "3D translate", T3d );
#endif
	/* Combine matrix */
	MAmulmx ( &rc, &four, &four, &four, Inv, T3d, Tra );
	MAmulmx ( &rc, &four, &four, &four, Tra, Eul, Mat );
#ifdef TRACE
__DBGpr_mat ( "Combine", Mat );
#endif
	/* Prepare output */
	for ( i=0; i<4; i++ ) {

		/* Base point in balanced position */
		pnt[0] = (*Bas).corner[i].balance[0] = Crn[i][0];
		pnt[1] = (*Bas).corner[i].balance[1] = Crn[i][1];
		pnt[2] = (*Bas).corner[i].balance[2] = Crn[i][2];
		pnt[3] = 1.0;

		/* Base point in ship position */
		MAmulmx ( &rc, &four, &four, &one, Mat, pnt, &pnt[4] );
#ifdef TRACE
printf ( "Point %d : [%g,%g,%g,%g] --> [%g,%g,%g,%g]\n", i,
	 pnt[0], pnt[1], pnt[2], pnt[3], pnt[4], pnt[5], pnt[6], pnt[7] );
#endif

		/* Base point in ship position */
		(*Bas).corner[i].in_ship[0] = pnt[4];
		(*Bas).corner[i].in_ship[1] = pnt[5];
		(*Bas).corner[i].in_ship[2] = pnt[6];
		
	}

wrapup:
	if (Pnt) {	om$dealloc (ptr=Pnt);	Pnt = NULL;	}
	if (Cmp) {	om$dealloc (ptr=Cmp);	Cmp = NULL;	}
        return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLget3Dtranslation ( msg, Bal, T3d )
		IGRlong		*msg;	/*O Error message		*/
	struct	GRobj_env	*Bal;	/*I VLbalance occurrence	*/
		IGRmatrix	*T3d;	/*O 3D translate matrix		*/
{
        IGRlong                 sts=OM_S_SUCCESS;
        IGRint                  cnt=0, i, nsrf=0, inv;
        IGRdouble               val;
        IGRchar                 side[DI_PATH_MAX];
        struct  GRid            list[MACRO_B_FTEMP + MACRO_B_VTEMP];
        struct  GRobj_env       Plate, *Surf;
	IGRpoint		avp;
	IGRvector		avn;
	BSrc			rc;

        /* Initialize */
        Surf = NULL;
	MAidmx ( &rc, *T3d );

        /* Get VLbalance occurence's templates */
        sts = om$send ( msg = message NDnode.NDget_objects (
                                        ND_ROOT,
                                        list,
                                        MACRO_B_FTEMP + MACRO_B_VTEMP,
                                        (struct GRid **) NULL,
                                        0,
                                        OM_K_MAXINT,
                                        &cnt ),
                        senderid = NULL_OBJID,
			targetos = Bal->obj_id.osnum,
			targetid = Bal->obj_id.objid );
        as$status ( sts    = sts,
                    msg    = "NDnode.NDget_objects",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /* Get side */
        sts = om$send ( msg = message expression.NDgive_value (&val),
			senderid = NULL_OBJID,
                        targetid = list[IDX_BT_REV].objid,
                        targetos = list[IDX_BT_REV].osnum );
        as$status ( sts    = sts,
                    msg    = "expression.NDgive_value(REV)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
        inv = (IGRint) val;
        if (inv != INVNORM_OF)     inv = INVNORM_ON;
        if (inv == INVNORM_OF)     strcpy ( side, VS_K_plTopSfPath);
        else                       strcpy ( side, VS_K_plBotSfPath);

        /* Allocate memory for parent plates' surfaces */
        Surf = om$calloc ( num = cnt - MACRO_B_FTEMP,
                           structure = struct GRobj_env );

        /* Fill structure */
        for ( i=MACRO_B_FTEMP; i<cnt; i++ ) {
		Plate.obj_id.objid = NULL_OBJID;
		sts = vl$return_foot ( msg     = msg,
	                               objId   = &list[i],
	                               objEnv  = &Bal->mod_env,
	                               footId  = &Plate.obj_id,
	                               footEnv = &Plate.mod_env );
                as$status ( sts    = sts,
                            msg    = "vl$return_foot()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
		
                if ( vs$is_ancestry_valid(object  = &Plate.obj_id,
                                          classid = OPP_VSplate_class_id) ) {
                        VLextractVSplateSurface( msg,
                                                 &Plate.obj_id,
                                                 &Plate.mod_env,
                                                 side,
                                                 &Surf[nsrf].obj_id,
                                                 &Surf[nsrf].mod_env,
                                                 NULL);
                        as$status ( sts    = sts,
                                    msg    = "VLextractVSplateSurface()",
                                    test   = (!(sts & 0x00000001 & (*msg))),
                                    action = GOTO_VALUE,
                                    value  = wrapup );
                        nsrf++;
                }
        }

        /* Evaluate the average normal */
        sts = VLevalAvNor ( Surf, nsrf, avp, avn, msg );
        as$status ( sts    = sts,
                    msg    = "VLevalAvNor()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	(*T3d)[3]  = avp[0];
	(*T3d)[7]  = avp[1];
	(*T3d)[11] = avp[2];

wrapup:
        if (Surf) {     om$dealloc(ptr = Surf);         Surf = NULL;    }
        return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
