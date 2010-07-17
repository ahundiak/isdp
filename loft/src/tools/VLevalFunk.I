/* $Id: VLevalFunk.I,v 1.3 2001/02/20 01:06:34 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	src/tools / VLevalFunk.I
 *
 * Description:	Evaluation functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLevalFunk.I,v $
 *	Revision 1.3  2001/02/20 01:06:34  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:44:11  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/08/02  21:54:12  pinnacle
# Created: loft/src/tools/VLevalFunk.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.6  1998/04/16  09:02:14  pinnacle
# Replaced: src/tools/VLevalFunk.I for:  by rchennup for loft
#
# Revision 1.3  1998/03/20  21:04:14  pinnacle
# Replaced: src/tools/VLevalFunk.I for:  by impd for loft
#
# Revision 1.2  1998/03/17  19:45:30  pinnacle
# Replaced: src/tools/VLevalFunk.I for:  by yzhu for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.2  1997/04/11  18:10:48  pinnacle
# Replaced: src/tools/VLevalFunk.I for: error in VLevalPltCenterNormalDistance() by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/11/97   mf		header file.
 *	04/11/97   mf		error in VLevalPltCenterNormalDistance().
 *************************************************************************/
class implementation VLabstract;

#include	<stdio.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"EMSopt.h"
#include	"EMSbnddef.h"
#include	"EMSbnd.h"
#include	"EMSssprops.h"
#include	"bserr.h"
#include	"bsparameters.h"

#include	"vsgeommacros.h"

#include	"vlplatejig.h"

/*
#define 	vdsDEBUG	1
#define 	vdserrDEBUG	1
*/
#include	"vldbgmacros.h"

#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsfreesf.h"
#include	"bslsqptlnpl.h"
#include	"bslenvec.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bssfarrevn.h"
#include	"bssfptseval.h"
#include	"bsxtractpar.h"

from	EMSboundary	import	EMget_edges;
from	EMSedge		import	EMgetstrkpy;
from	EMSloopset	import	EMget_loops;
from	EMSsubbs	import	EMget_props;

extern	void	qsort();

/*
#define	TRACE
*/

/* ========================================================================== */
IGRlong	VLevalSrfAveragePlane (	struct	GRobj_env	*Srf,
					IGRint		Nsrf,
					IGRpoint	AvgPnt,
					IGRvector	AvgNrm,
					IGRlong		*msg	)
{
	IGRint			sts=OM_S_SUCCESS, i, j, depth, size;
struct	IGRbsp_surface		*srf;
	OM_S_CHANSELECT		ls_channel;
	OM_S_OBJECT_LINKAGE	ls_list;
	IGRuint			ls_number;
	GRobjid			*loopId;
	IGRushort		*props;
	IGRint			loopNum, edgeNum, edgeCnt=0, XYZnum, vrtxNum;
struct	GRid			*edgeId;
	IGRdouble		*pnt, *XYZpnt, chtTol=0.0, *vtx, d, err=0.0;
struct	EMSpartolbasis		tolbasis;
	IGRint			code=0;
	IGRboolean		AddFlag;
	BSrc			rc;

	/* Initialize */
	*msg = MSFAIL;
	AvgPnt[0] = AvgPnt[1] = AvgPnt[2] = 0.0;
	AvgNrm[0] = AvgNrm[1] = AvgNrm[2] = 0.0;
	srf    = NULL;
	pnt    = NULL;
	loopId = NULL;
	props  = NULL;
	edgeId = NULL;
	XYZpnt = NULL;
	vtx    = NULL;
	BSxtractpar ( &rc, BSTOLCHRDHT, &chtTol);
	if (rc != BSSUCC) {
		printf( "Error in BSxtractpar()\n");
		goto wrapup;
	}
	if (Nsrf < 1)	goto wrapup;

	/* Get loopset channel number */
	ls_channel.type = OM_e_num;
	sts = om$get_channel_number ( channame  = "EMSsubbs.to_loopset",
				      p_channum = &ls_channel.u_sel.number );
	as$status ( sts    = sts,
		    msg    = "om$get_channel_number()",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Loop on surfaces */
	for ( i=0; i<Nsrf; i++) {

		/* Get surface geometry */
		if (srf) {	om$dealloc (ptr = srf);	srf = NULL;	}
		sts = VLgetGeometry ( &Srf[i], (IGRboolean) FALSE,
				      NULL_OBJID, (IGRchar **) &srf, msg );
		as$status ( sts    = sts,
			    msg    = "VLgetGeometry()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Make surface boundaries */
		sts = vs$make_natural_boundary ( msg	    = msg,
					         surfaceEnv = &Srf[i].mod_env,
					         surfaceId  = &Srf[i].obj_id );
		as$status ( sts    = sts,
			    msg    = "vs$make_natural_boundary()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Get loopset list */
		ls_list.S_objid = NULL_OBJID;
		sts = om$get_channel_objects (
					osnum	     = Srf[i].obj_id.osnum,
					objid	     = Srf[i].obj_id.objid,
					p_chanselect = &ls_channel,
					size	     = 1,
					count	     = &ls_number,
					list	     = &ls_list );
		as$status ( sts    = sts,
			    msg    = "om$get_channel_objects()",
			    test   = (!(sts & 0x00000001)),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Get the number of loops */
		depth   = 1;
		if (loopId) { om$dealloc (ptr = loopId); loopId = NULL; }
		if (props) {  om$dealloc (ptr = props);  props  = NULL;	}
		size    = 0;
		loopNum = 0;
		sts = om$send ( msg = message EMSloopset.EMget_loops (
							msg,
							(IGRlong) EMS_OPT_ALL,
							&depth,
							&loopId,
							&props,
							&size,
							&loopNum ),
				senderid = NULL_OBJID,
				targetid = ls_list.S_objid,
				targetos = ls_list.osnum );
		as$status ( sts    = sts,
			    msg    = "EMSloopset.EMget_loops",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Get the edges ID */
		if (edgeId) { om$dealloc (ptr = edgeId); edgeId = NULL; }
		depth   = 1;
		size    = 0;
		edgeNum = 0;
		sts = om$send ( msg = message EMSboundary.EMget_edges (
							msg,
							depth,
							(IGRlong) EMS_OPT_ALL,
							&edgeId,
							&size,
							&edgeNum ),
				senderid = NULL_OBJID,
				targetid = loopId[0],
				targetos = ls_list.osnum );
		as$status ( sts    = sts,
			    msg    = "EMSboundary.EMget_edges",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Allocate memory for points */
		if (!pnt) {
			pnt = om$calloc ( num       = 3 * edgeNum + 3,
					  structure = IGRdouble);
		}
		else {
			size = 3 * (edgeCnt+edgeNum+1) * sizeof(IGRdouble);
			pnt = (IGRdouble *) om$realloc (
						ptr  = (IGRchar *) pnt,
						size = size );
		}

		/* Get endpoints of the edge */
		tolbasis.is_valid = tolbasis.in_world = FALSE;
		tolbasis.mattyp = NULL;
		tolbasis.mat = NULL;

		for ( j=0; j<edgeNum; j++) {

			if (XYZpnt) {	om$dealloc (ptr = XYZpnt);
					XYZpnt = NULL;	}

			sts = om$send ( msg = message EMSedge.EMgetstrkpy (
					msg,
					&Srf[i].mod_env.md_env.matrix_type,
					Srf[i].mod_env.md_env.matrix,
					srf,
					&tolbasis,
					(IGRushort) EMS_GETB_CONSISTLFXYZVTX
						  | EMS_GETB_CONSISTRTXYZVTX,
					&XYZnum,
					NULL,
					&XYZpnt,
					NULL ),
			senderid = NULL_OBJID,
			targetid = edgeId[j].objid,
			targetos = edgeId[j].osnum );
			as$status ( sts    = sts,
				    msg    = "EMSedge.EMgetstrkpy",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			dblcpy ( &pnt[3*(edgeCnt+j)], &XYZpnt[0], 3);
			dblcpy ( &pnt[3*(edgeCnt+j+1)],
				 &XYZpnt[3*(XYZnum-1)], 3);
		}
		edgeCnt += edgeNum+1;
	}
#ifdef TRACE
for ( i=0; i<edgeCnt; i++)
printf( "Edge %2d : [ %g, %g, %g]\n", i, pnt[3*i+0], pnt[3*i+1], pnt[3*i+2] );
#endif
	/* Eliminate common edge points */
	vtx = om$calloc ( num = 3 * edgeCnt, structure = IGRdouble);
	dblcpy ( &vtx[0], &pnt[0], 3);
	vrtxNum = 1;
	for ( i=1; i<edgeCnt; i++) {
		AddFlag = TRUE;
		for ( j=0; j<vrtxNum; j++) {
#ifdef TRACE
printf( "i=%2d, j=%2d\tpnt : [%g,%g,%g]\n", i, j,
	pnt[3*i+0], pnt[3*i+1], pnt[3*i+2] );
#endif
			d = (pnt[3*i+0]-vtx[3*j+0]) * (pnt[3*i+0]-vtx[3*j+0])
			  + (pnt[3*i+1]-vtx[3*j+1]) * (pnt[3*i+1]-vtx[3*j+1])
			  + (pnt[3*i+2]-vtx[3*j+2]) * (pnt[3*i+2]-vtx[3*j+2]);
			if (d < chtTol) {	AddFlag = FALSE;
						j = vrtxNum;	}
		}
		if (AddFlag) {	dblcpy ( &vtx[3*vrtxNum], &pnt[3*i], 3);
				vrtxNum++;	}
	}
#ifdef TRACE
for ( i=0; i<vrtxNum; i++)
printf( "Vertex %2d : [ %g, %g, %g]\n", i, vtx[3*i+0], vtx[3*i+1], vtx[3*i+2] );
#endif

	/* Least squares minimization */
	BSlsqptlnpl ( vrtxNum, vtx, NULL, 3, &code, AvgPnt, AvgNrm, &err, &rc);
	if (rc != BSSUCC) {
		printf( "Error in BSlsqptlnpl() returning code %d\n", code);
		*msg = MSFAIL;
		goto wrapup;
	}
#ifdef TRACE
printf( "BSlsqptlnpl on %d vertices : code=%d, err=%g\n", vrtxNum, code, err);
printf( "\tAvgPnt : [%g,%g,%g]\n", AvgPnt[0], AvgPnt[1], AvgPnt[2] );
printf( "\tAvgNrm : [%g,%g,%g]\n", AvgNrm[0], AvgNrm[1], AvgNrm[2] );
#endif

wrapup:
	if (vtx) {	om$dealloc (ptr = vtx);		vtx    = NULL;	}
	if (XYZpnt) {	om$dealloc (ptr = XYZpnt);	XYZpnt = NULL;	}
	if (edgeId) {	om$dealloc (ptr = edgeId);	edgeId = NULL;	}
	if (props) {	om$dealloc (ptr = props);	props  = NULL;	}
	if (loopId) {	om$dealloc (ptr = loopId);	loopId = NULL;	}
	if (pnt) {	om$dealloc (ptr = pnt);		pnt    = NULL;	}
	if (srf) {	om$dealloc (ptr = srf);		srf    = NULL;	}

	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLevalPltElevation (	struct	GRobj_env	*Plt,
					IGRint		Nplt,
					IGRint		Cnorm,
					IGRint		Inorm,
					IGRchar		*side,
					IGRdouble	*Elev,
					IGRlong		*msg	)
{
	IGRint		sts=OM_S_SUCCESS, i, j, k, *Rev, reverse=0, idx=0;
	IGRint		Ugrid=5, Vgrid=5, Unum, Vnum, Nmesh=0;
struct	GRobj_env	*Srf;
	IGRpoint	AvgPnt;
	IGRvector	AvgNrm, vec;
	IGRdouble	*Mesh, *UV, gap=0.0, dst=0.0, *Proj;
struct	IGRbsp_surface	*Geom, *Grid;
	BSrc		rc;
	IGRuchar	props;
struct	GRparms		parms;

	/* Initialize */
	*Elev = 0.0;
	*msg  = MSFAIL;
	Srf   = NULL;
	Proj  = NULL;
	Mesh  = NULL;
	Geom  = NULL;
	Grid  = NULL;
	UV    = NULL;
	Rev   = NULL;
	if (Nplt < 1)	goto wrapup;

	/* Allocate memory */
	Srf = om$calloc ( num = Nplt, structure = struct GRobj_env );
	Rev = om$calloc ( num = Nplt, structure = IGRint );

	/* Loop on plates */
	for ( i=0; i<Nplt; i++) {

		/* Retrieve plate surface */
		sts = VLextractVSplateSurface
                                        ( msg,
                                          &Plt[i].obj_id,
                                          &Plt[i].mod_env,
                                          side,
                                          &Srf[i].obj_id,
                                          &Srf[i].mod_env,
                                          (struct IGRbsp_surface **) NULL );
		as$status ( sts    = sts,
			    msg    = "VLextractVSplateSurface()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve normal/reverse surface property */
		sts = om$send ( msg = message EMSsubbs.EMget_props
						( msg, &props),
                                senderid = NULL_OBJID,
                                targetid = Srf[i].obj_id.objid,
                                targetos = Srf[i].obj_id.osnum );
                as$status ( sts = sts,
                            msg = "EMSsubbs.EMget_props",
                            test = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
                if (props & EMSIS_NRML_REVERSED)        Rev[i] = 1;
                else                                    Rev[i] = -1;
#ifdef TRACE
printf( "Surface (%d|%d)\tRev[%d] = %d\n",
	Srf[i].obj_id.osnum, Srf[i].obj_id.objid, i, Rev[i] );
#endif
	}

	/* Treat reversed surfaces */
	for ( i=0; i<Nplt; i++) 	reverse += Rev[i];
	if (reverse < 0)	reverse = -1;
	else if (reverse > 0)	reverse = 1;
	else			reverse = Rev[0];

	/* Evaluate average plane */
	sts = VLevalSrfAveragePlane ( Srf, Nplt, AvgPnt, AvgNrm, msg);
	as$status ( sts    = sts,
		    msg    = "VLevalSrfAveragePlane()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Project average point (of quadratic evaluation) of surfaces */
	Proj = om$calloc ( num = 3 * Nplt, structure = IGRdouble );
	for ( i=0; i<Nplt; i++) {

		sts = om$send ( msg = message GRgraphics.GRptproject (
					msg,
					&Srf[i].mod_env.md_env.matrix_type,
					Srf[i].mod_env.md_env.matrix,
					AvgPnt,
					&Proj[3*i],
					&parms ),
				senderid = NULL_OBJID,
				targetid = Srf[i].obj_id.objid,
				targetos = Srf[i].obj_id.osnum );
                as$status ( sts = sts,
                            msg = "GRgraphics.GRptproject",
                            test = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
	}

	/* Take the closest surface point */
	gap = 1e+100;
	for ( i=0; i<Nplt; i++) {
		dst = (AvgPnt[0]-Proj[3*i+0]) * (AvgPnt[0]-Proj[3*i+0])
                    + (AvgPnt[1]-Proj[3*i+1]) * (AvgPnt[1]-Proj[3*i+1])
                    + (AvgPnt[2]-Proj[3*i+2]) * (AvgPnt[2]-Proj[3*i+2]);
		if (dst < gap) {	idx = i;	gap = dst;	}
	}

	/* Reorient normal */
	for ( i=0; i<3; i++)	vec[i] = AvgPnt[i] - Proj[3*idx+i];
	if (BSdotp ( &rc, vec, AvgNrm) < 0.0) {
		for ( i=0; i<3; i++)	AvgNrm[i] *= -1.0;
	}

	/* Set average normal to Z in non Shell/Wall case */
        if (Cnorm == IDX_J5) {	AvgNrm[0] = 0.0;
				AvgNrm[1] = 0.0;
				AvgNrm[2] = 1.0;	}

/* Start - Added By Rama Rao - 07/28/00 */
        if (Cnorm == IDX_J4) {  AvgNrm[0] = 0.0;
                                AvgNrm[1] = 1.0;
                                AvgNrm[2] = 0.0;        }
/* End - Added By Rama Rao - 07/28/00 */

        /* Reverse normal if needed */
	for ( i=0; i<3; i++)	AvgNrm[i] *= reverse;

        /* Inverse normal if needed */
        for ( i=0; i<3; i++)    AvgNrm[i] *= Inorm;

	/* Loop on surfaces */
	Mesh = om$calloc ( num	     = 3 * Nplt * Ugrid * Vgrid,
			   structure = IGRdouble);
	UV = om$calloc ( num = 2 * Ugrid * Vgrid, structure = IGRdouble);
	for ( i=0; i<Nplt; i++) {

		if (Geom) {	om$dealloc (ptr = Geom);	Geom = NULL; }
		if (Grid) {	BSfreesf ( &rc, Grid);		Grid = NULL; }

		/* Reparametrize surface */
		sts = VLevalUvGridFromSrf ( Srf[i], Ugrid, Vgrid, 0,
					    &Geom, &Grid, msg );
		as$status ( sts    = sts,
			    msg    = "VLevalUvGridFromSrf()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		Unum = Grid->u_num_poles;
		Vnum = Grid->v_num_poles;

		/* Fill U and V parameters array */
		for ( j=0; j<Unum; j++) {
			for ( k=0; k<Vnum; k++) {
				UV[2*(j*Vnum+k)+0]
				= Grid->poles[3*(j*Vnum+k)+0];
				UV[2*(j*Vnum+k)+1]
				= Grid->poles[3*(j*Vnum+k)+1];
			}
		}

		/* Evaluate geometric values at uv */
		BSsfptseval ( Geom, Unum * Vnum, UV, &Mesh[3*i*Unum*Vnum], &rc);
                if (rc != BSSUCC) {     printf( "Error in BSsfptseval ()\n");
                                        *msg = MSFAIL;  goto wrapup;    }
		Nmesh += Unum * Vnum;
	}

	/* Evaluate elevation */
	for ( i=0; i<Nmesh; i++) {
#ifdef TRACE
printf( "i=%2d\tMesh : [%g,%g,%g]\n", i, Mesh[3*i+0], Mesh[3*i+1], Mesh[3*i+2]);
#endif
                for ( j=0; j<3; j++)    vec[j] = Mesh[3*i+j] - AvgPnt[j];
                gap = BSdotp ( &rc, AvgNrm, vec);
                if (rc != BSSUCC) {     printf( "Error in BSdotp ()\n");
                                        *msg = MSFAIL;  goto wrapup;    }
                if (gap > *Elev)       	*Elev = gap;
        }
#ifdef TRACE
printf( "VLevalSrfAveragePlane() returns point    : [%g,%g,%g]\n",
	AvgPnt[0], AvgPnt[1], AvgPnt[2]);
printf( "VLevalSrfAveragePlane() returns normal   : [%g,%g,%g]\n",
	AvgNrm[0], AvgNrm[1], AvgNrm[2]);
printf( "VLevalSrfAveragePlane() returns distance = %g\n", *Elev);
#endif

wrapup:

#ifdef TRACE
printf( "BSfreesf (Grid) ...\n");
#endif
	if (Grid) {	BSfreesf ( &rc, Grid);		Grid = NULL;	}

#ifdef TRACE
printf( "om$dealloc (Geom) ...\n");
#endif
	if (Geom) {	om$dealloc (ptr = Geom);	Geom = NULL;	}

#ifdef TRACE
printf( "om$dealloc (UV) ...\n");
#endif
	if (UV) {	om$dealloc (ptr = UV);		UV = NULL;	}

#ifdef TRACE
printf( "om$dealloc (Mesh) ...\n");
#endif
	if (Mesh) {	om$dealloc (ptr = Mesh);	Mesh = NULL;	}

#ifdef TRACE
printf( "om$dealloc (Proj) ...\n");
#endif
	if (Proj) {	om$dealloc (ptr = Proj);	Proj = NULL;	}

#ifdef TRACE
printf( "om$dealloc (Rev) ...\n");
#endif
	if (Rev) {	om$dealloc (ptr = Rev);		Rev  = NULL;	}

#ifdef TRACE
printf( "om$dealloc (Srf) ...\n");
#endif
	if (Srf) {	om$dealloc (ptr = Srf);		Srf  = NULL;	}

	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLevalUvGridFromPlane ( 	struct	GRobj_env	*Plane,
						IGRint		Unpt,
						IGRint		Vnpt,
					struct	IGRbsp_surface	**Geom,
					struct	IGRbsp_surface	**Grid,
						IGRlong		*msg	)
{
	IGRint		sts=OM_S_SUCCESS, i, j;
	BSrc		rc;

        SetProc ( VLevalUvGridFromPlane ); Begin
	/* Get geometry */
	sts = VLgetGeometry ( Plane, FALSE, NULL_OBJID, (IGRchar **) Geom, msg);
	as$status ( sts    = sts,
		    msg    = "VLgetGeometry()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Allocate memory for grid */
	BSallocsf ( (IGRshort) 2, (IGRshort) 2, Unpt, Vnpt, FALSE, (IGRshort) 0,
		    Grid, &rc );
	if (rc != BSSUCC) {
		printf( "Error in BSallocsf()\n");
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Fill Grid structure */
	(*Grid)->u_num_poles = Unpt;
	(*Grid)->v_num_poles = Vnpt;
	for ( i=0; i<Unpt; i++) {
		for ( j=0; j<Vnpt; j++) {
			(*Grid)->poles[3*(i*Vnpt+j)+0] = (IGRdouble) i/(Unpt-1);
			(*Grid)->poles[3*(i*Vnpt+j)+1] = (IGRdouble) j/(Vnpt-1);
		}
	}

wrapup: 
        End
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLevalSrfGeometry (

struct	GRobj_env	*Srf,	/*I	Surface objects array		*/
	IGRint		Nsrf,	/*I	Number of surface objects	*/
	IGRdouble	*Avp,	/*O	Average point (if !NULL)	*/
	IGRdouble	*Avn,	/*O	Average normal (if !NULL)	*/
	IGRint		*Npnt,	/*O	Mesh points number (if !NULL)	*/
	IGRdouble	**Pnt,	/*O	Mesh points array (if !NULL)	*/
	IGRlong		*msg	/*O	Completion code			*/

)

/*	Marc Fournier (COC shipbuilding, France)	10-Feb-1995	*/
/*	Avp is the average point of the reparametrized surfaces.	*/
/*	Avp is the average normal of the reparametrized surfaces.	*/
/*	Npnt and Pnt arguments must !NULL to get returned values.	*/
/*	In this case Pnt must be om$dealloc() by caller.		*/
/*	Nnrm and Nrm arguments must !NULL to get returned values.	*/
/*	In this case Nrm must be om$dealloc() by caller.		*/

{
	IGRint		sts=OM_S_SUCCESS, i, j, k, l;
	IGRint		valid=0, Rev, Umax=5, Vmax=5, Unum, Vnum;
	IGRdouble	U, V;
	IGRpoint	AvgPnt, Spnt, pnt;
	IGRvector	AvgNrm, Snrm, nrm;
struct	IGRbsp_surface	*Geom, *Grid;
	BSrc		rc;
	IGRboolean	pnt_flag=FALSE;
	IGRuchar	props;

	SetProc( VLevalSrfGeometry ); Begin
	/* Initialize */
	AvgPnt[0] = AvgPnt[1] = AvgPnt[2] = 0.0;
	AvgNrm[0] = AvgNrm[1] = AvgNrm[2] = 0.0;
	Geom = NULL;
	Grid = NULL;
	if ( ((!Avp) && (!Avn)) || ((!Srf) && (Nsrf)) )	goto wrapup;
	Spnt[0] = Spnt[1] = Spnt[2] = 0.0;
	pnt[0]  = pnt[1]  = pnt[2]  = 0.0;
	nrm[0]  = nrm[1]  = nrm[2]  = 0.0;
	if ( (Npnt) && (Pnt) ) {
		pnt_flag  = TRUE;
		*Npnt = 0;
		*Pnt  = om$calloc ( num       = 3 * Umax * Vmax * Nsrf,
				    structure = IGRdouble );
	}

	/* Loop on surfaces */
	for ( i=0; i<Nsrf; i++) {

		/* Reparametrize surface */
		if (Grid) {	BSfreesf ( &rc, Grid);		Grid = NULL; }
		if (Geom) {	om$dealloc (ptr = Geom);	Geom = NULL; }
		sts = VLevalUvGridFromSrf ( Srf[i], Umax, Vmax, 0,
					    &Geom, &Grid, msg);
		as$status ( sts    = sts,
			    msg    = "VLevalUvGridFromSrf()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		if ( (Grid->u_num_poles == 1) || (Grid->v_num_poles == 1) ) {
		// for TR179800786
		// if ( (Grid->u_num_poles == 1) && (Grid->v_num_poles == 1) ) {
			if (Grid) {	BSfreesf ( &rc, Grid);
					Grid = NULL;	}
			if (Geom) {	om$dealloc (ptr = Geom);
					Geom = NULL;	}
			sts = VLevalUvGridFromPlane ( &Srf[i], Umax, Vmax,
					    	      &Geom, &Grid, msg);
			as$status ( sts    = sts,
				    msg    = "VLevalUvGridFromPlane()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		//* for TR179800456   
		       if ( (Grid->u_num_poles == 1) || 
			    (Grid->v_num_poles == 1) ) {
                          sts = MSFAIL;
			  goto wrapup;
		       } 
		}

		/* Set values */
		Unum = Grid->u_num_poles;
		Vnum = Grid->v_num_poles;
		Snrm[0] = Snrm[1] = Snrm[2] = 0.0;

		/* Loop on U */
		for ( j=0; j<Unum; j++) {

			/* Loop on V */
			for ( k=0; k<Vnum; k++) {
				U = Grid->poles[3*(j*Vnum+k)+0];
				V = Grid->poles[3*(j*Vnum+k)+1];

/* Sometimes VLevalUvGridFromSrf() returns negative parameter values ... */
				if (U < 0.0)	U *= -1.0;
				if (V < 0.0)	V *= -1.0;

				BSsfarrevn ( &rc, Geom, 1, &U, 1, &V, pnt, nrm);
				if (rc == BSSUCC) {
					valid++;
					for ( l=0; l<3; l++) {
						Spnt[l] += pnt[l];
						Snrm[l] += nrm[l];
					}
					if (pnt_flag) {
						dblcpy ( &(*Pnt)[3*(*Npnt)],
							 &pnt[0], 3 );
						(*Npnt)++;
					}
				}
				else 
printf( "Error in BSsfarrevn (U=%g,V=%g)\n", U, V);
			}
		}

		/* Retrieve surface properties */
		 sts = om$send ( msg = message EMSsubbs.EMget_props
							( msg, &props ),
                                senderid = NULL_OBJID,
                                targetid = Srf[i].obj_id.objid,
                                targetos = Srf[i].obj_id.osnum );
                as$status ( sts = sts,
                            msg = "EMSsubbs.EMget_props",
                            test = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
                if (props & EMSIS_NRML_REVERSED)        Rev =  1;
                else                                    Rev = -1;

		/* Collecting and orienting surface normal */
                if (!i) for ( l=0; l<3; l++)    AvgNrm[l] += Rev * Snrm[l];
                else {  if (BSdotp ( &rc, Snrm, AvgNrm) * Rev < 0.0) {
                                for ( l=0; l<3; l++)
					AvgNrm[l] -= Rev * Snrm[l];	}
                        else {	for ( l=0; l<3; l++)
					AvgNrm[l] += Rev * Snrm[l];	}
                }
	}

	/*c Evaluate the COG. */
        for ( l=0; l<3; l++)    AvgPnt[l] = Spnt[l] / valid;

        /*c Normalise the average normal. */
        BSnorvec(&rc, AvgNrm);
        if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                                *msg = MSFAIL;  goto wrapup;    }

wrapup:

	if (Avp)	dblcpy ( &Avp[0], &AvgPnt[0], 3);
	if (Avn)	dblcpy ( &Avn[0], &AvgNrm[0], 3);

	if (Grid) {	BSfreesf ( &rc, Grid);		Grid = NULL;	}
	if (Geom) {	om$dealloc (ptr = Geom);	Geom = NULL;	}

	End
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRint	VLtmpSort ( 	VLstfTpl	*a,
			VLstfTpl	*b	)
{
	return ((a->len == b->len) ? 0 : (a->len > b->len) ? -1 : 1);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLdistanceAlongNormal (	VLstfTpl	*Pnt,
				IGRint		Npnt,
				IGRdouble	*Avp,
				IGRdouble	*Avn,
				IGRdouble	*Dist,
				IGRlong		*msg	)
{
	IGRint		i, j;
	IGRvector	vec;
	BSrc		rc;

	/* Initialize */
	*Dist = 0.0;
	*msg  = MSSUCC;

	/* Determine maximum distance along normal */
	for ( i=0; i<Npnt; i++) {
		Pnt[i].idx = i;
		for ( j=0; j<3; j++)	vec[j] = Pnt[i].pnt[j] - Avp[j];
		Pnt[i].len = BSdotp ( &rc, Avn, vec);
		if ( (rc == BSSUCC) && (Pnt[i].len > *Dist) )
			*Dist = Pnt[i].len;
	}

	/* Sort points */
	qsort ( Pnt, Npnt, sizeof(VLstfTpl), VLtmpSort);
#ifdef TRACE
printf ("\n");
for ( i=0; i<Npnt; i++)
	printf ( "\tPoint %2d is at %g\n", i, Pnt[i].len);
#endif
	return (OM_S_SUCCESS);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLevalPltCenterNormalDistance (

struct	GRobj_env	*Plt,	 /*I	Structural plate objects array	*/
	IGRint		Nplt,	 /*I	Number of struct. plate objects	*/
	IGRchar		*side,	 /*I	Structural plate objects side	*/
	IGRint		Cnorm,	 /*I	Average normal correction	*/
	IGRint		Inorm,	 /*I	Average normal inversion	*/
	IGRboolean	optimiz, /*I	Optimization by 3 points	*/
	IGRdouble	*Avp,	 /*O	Average point (if !NULL)	*/
	IGRdouble	*Avn,	 /*O	Average normal (if !NULL)	*/
	IGRdouble	*dist,	 /*O	Maximum distance (if !NULL)	*/
	IGRlong		*msg	 /*O	Completion code			*/

)

{
	IGRint		sts=OM_S_SUCCESS, Npnt=0, i;
struct	GRobj_env	*Srf;
	IGRdouble	chtTol, *Pnt, *Nrm, dst=0.0, opt=0.0;
	IGRpoint	AvgPnt, p1;
	IGRvector	AvgNrm, v1, v2, v3;
	BSrc		rc;
	VLstfTpl	*Tmp;
	IGRint		idx[3];
struct	IGRplane	Plan;

	/* Initialize */
	*msg = MSFAIL;
	if (dist) 	*dist = 0.0;
	Srf = NULL;
	Pnt = NULL;
	Nrm = NULL;
	Tmp = NULL;
	if (Nplt < 1) {
		printf( "No structural plates available ...\n");
		goto wrapup;
	}
	BSxtractpar ( &rc, BSTOLCHRDHT, &chtTol);
	if (rc != BSSUCC) {
		printf( "Error in BSxtractpar()\n");
		goto wrapup;
	}

	/* Allocate memory */
	Srf = om$calloc ( num = Nplt, structure = struct GRobj_env );

	/* Loop on plates */
	for ( i=0; i<Nplt; i++) {

		/* Retrieve plate surface */
		sts = VLextractVSplateSurface
                                        ( msg,
                                          &Plt[i].obj_id,
                                          &Plt[i].mod_env,
                                          side,
                                          &Srf[i].obj_id,
                                          &Srf[i].mod_env,
                                          (struct IGRbsp_surface **) NULL );
		as$status ( sts    = sts,
			    msg    = "VLextractVSplateSurface()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Check for lonely planar plates */
	if (Nplt == 1) {
		Plan.point  = p1;
		Plan.normal = v1;
		sts = om$send ( msg = message GRvg.GRdetplane (
					msg,
					&Srf[0].mod_env.md_env.matrix_type,
					Srf[0].mod_env.md_env.matrix,
					&Plan ),
				senderid = NULL_OBJID,
				targetid = Srf[0].obj_id.objid,
				targetos = Srf[0].obj_id.osnum );
		if (sts & 0x00000001 & (*msg)) {

			sts = VLevalSrfGeometry ( Srf, 1, AvgPnt, AvgNrm,
						  NULL, NULL, msg);
			as$status ( sts    = sts,
				    msg    = "VLevalSrfGeometry()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			dblcpy ( &AvgPnt[0], &(Plan.point)[0] , 3);
			if (BSdotp ( &rc, Plan.normal, AvgNrm) < 0.0) {
				for ( i=0; i<3; i++)
					AvgNrm[i] = Plan.normal[i] * -1.0;
			}
			else {	for ( i=0; i<3; i++)
					AvgNrm[i] = Plan.normal[i];
			}

			/* Set average normal to Z if wanted */
			if (Cnorm == IDX_J5) {	AvgNrm[0] = 0.0;
						AvgNrm[1] = 0.0;
						AvgNrm[2] = 1.0;	}

/* Start - Added By Rama Rao - 07/28/00 */
        		if (Cnorm == IDX_J4) {  AvgNrm[0] = 0.0;
                                		AvgNrm[1] = 1.0;
                                		AvgNrm[2] = 0.0;        }
/* End - Added By Rama Rao - 07/28/00 */

			/* Inverse normal if wanted */
			for ( i=0; i<3; i++)	AvgNrm[i] *= Inorm;

			/* End of the game */
			goto wrapup;
		}
	}

	/* Linear evaluations and data access */
	sts = VLevalSrfGeometry ( Srf, Nplt, AvgPnt, AvgNrm, &Npnt, &Pnt, msg);
	as$status ( sts    = sts,
		    msg    = "VLevalSrfGeometry()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Set average normal to Z if wanted */
	if (Cnorm == IDX_J5) {	AvgNrm[0] = 0.0;
				AvgNrm[1] = 0.0;
				AvgNrm[2] = 1.0;	}

/* Start - Added By Rama Rao - 07/28/00 */
        if (Cnorm == IDX_J4) {  AvgNrm[0] = 0.0;
                                AvgNrm[1] = 1.0;
                                AvgNrm[2] = 0.0;        }
/* End - Added By Rama Rao - 07/28/00 */

	/* Inverse normal if wanted */
	for ( i=0; i<3; i++)	AvgNrm[i] *= Inorm;

	/* Store data */
	Tmp = om$calloc ( num = Npnt, structure = VLstfTpl);
	for ( i=0; i<Npnt; i++) {
		Tmp[i].pnt[0] = Pnt[3*i+0];
		Tmp[i].pnt[1] = Pnt[3*i+1];
		Tmp[i].pnt[2] = Pnt[3*i+2];
	}

	/* Evaluate distance along regular normal 
	if( Cnorm == IDX_J3 )
	{
	*/
	sts = VLdistanceAlongNormal ( Tmp, Npnt, AvgPnt, AvgNrm, &dst, msg);
	as$status ( sts    = sts,
		    msg    = "VLdistanceAlongNormal()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
/*
	}
	else
	{
       		dst = AvgPnt[2]; 
	}
*/

	if ( (Cnorm == IDX_J5) && (optimiz) ) {

		/* Polish method by 3 points */
		idx[0] = 0;
		for ( idx[1]=idx[0]+1; idx[1]<Npnt; (idx[1])++) {
			BSmkvec ( &rc, v1, Tmp[idx[0]].pnt, Tmp[idx[1]].pnt);
			if (BSlenvec( &rc, v1) > 100.0 * chtTol)	break;
		}
		BSnorvec ( &rc, v1);

		for ( idx[2]=idx[1]+1; idx[2]<Npnt; (idx[2])++) {
			BSmkvec ( &rc, v2, Tmp[idx[1]].pnt, Tmp[idx[2]].pnt);
			if (BSlenvec( &rc, v2) > 100.0 * chtTol)	break;
		}

		for ( i=0; i<3; i++)
			p1[i] = ( Tmp[idx[0]].pnt[i]
				+ Tmp[idx[1]].pnt[i]
				+ Tmp[idx[2]].pnt[i] ) / 3.0;
		BSmkvec ( &rc, v2, Tmp[idx[0]].pnt, Tmp[idx[2]].pnt);
		BSnorvec ( &rc, v2);

		BScrossp ( &rc, v1, v2, v3);
		BSnorvec ( &rc, v3);
		if (BSdotp ( &rc, v3, AvgNrm) < 0.0) {
			for ( i=0; i<3; i++)	v3[i] *= -1.0;
		}

		sts = VLdistanceAlongNormal ( Tmp, Npnt, p1, v3, &opt, msg);
		as$status ( sts    = sts,
			    msg    = "VLdistanceAlongNormal()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		if ( (opt != 0.0) && (opt < chtTol) ) {
			dblcpy ( &AvgPnt[0], &p1[0], 3);
			dblcpy ( &AvgNrm[0], &v3[0], 3);
			dst = opt;
		}
#ifdef TRACE
		else	printf( "3 points optimization failed\n");
#endif
	}

wrapup:

	if (Avp)	dblcpy ( &Avp[0], &AvgPnt[0], 3);
	if (Avn)	dblcpy ( &Avn[0], &AvgNrm[0], 3);
	if (dist)	*dist = dst ;
#ifdef TRACE
if (Avp)  printf( "Average Point    : [%g,%g,%g]\n", Avp[0], Avp[1], Avp[2]);
if (Avn)  printf( "Average Normal   : [%g,%g,%g]\n", Avn[0], Avn[1], Avn[2]);
if (dist) printf( "Maximum Distance = %g\n", *dist);
#endif
	if (Tmp) {	om$dealloc (ptr = Tmp);	Tmp = NULL;	}
	if (Nrm) {	om$dealloc (ptr = Nrm);	Nrm = NULL;	}
	if (Pnt) {	om$dealloc (ptr = Pnt);	Pnt = NULL;	}
	if (Srf) {	om$dealloc (ptr = Srf);	Srf = NULL;	}

	return (sts);
}
/* ========================================================================== */

end implementation VLabstract;
