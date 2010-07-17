/* $Id: VLlayouti.I,v 1.1.1.1 2001/01/04 21:11:33 cvs Exp $  */
/***************************************************************************
* I/LOFT
*
* File: src/pin_jig/VLlayouti.I
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: VLlayouti.I,v $
*      Revision 1.1.1.1  2001/01/04 21:11:33  cvs
*      Initial import to CVS
*
# Revision 1.3  1999/05/07  15:45:26  pinnacle
# tr179900281
#
*
* History:
* MM/DD/YY  AUTHOR  DESCRIPTION
* 05/07/99  Jayadev TR179900281 Feet overflow
*
***************************************************************************/

class implementation VLlayout;

#include 	"msmacros.h"
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"nddef.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"bstypes.h"
#include	"bserr.h"
#include	"bsvalues.h"
#include	"DIdef.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"ACattrib.h"
#include	"ACrg_collect.h"
#include	"ACdyn_col.h"
#include	"vsplatedef.h"
#include	"vsmiscmacros.h"

#include	"vlplatejig.h"
#include	"vlfloor.h"
#include	"vllayout.h"
#include	"vlmsg.h"
#include	"vlgrdef.h"
#include	"vlgrmacros.h"
#include	"vlmiscmacros.h"

#include	"bsdotp.h"
#include	"bsmkvec.h"

#include	"mamulmx.h"
#include	"matypemx.h"

from	ACdyn_col	import	AClist_attribute, ACset_list_attribute,
				ACset_att_prop;
from	GRgencs		import	GRgetmatrix;
from	GRlinear	import	GRgetpolyline;

extern	GRclassid	OPP_ACdyn_col_class_id;

/*	#define	TRACE	*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRint		i, j, k, suc, col, lin, act, Inum=0, Onum=0;
		IGRint		sts=OM_S_SUCCESS, idx=0;
		IGRint		Uniform;
		BSrc		rc;
		IGRdouble	Xpitch, Ypitch, Margin, len, wid, x_col, y_lin;
	struct	GRobj_env	Cont;
	struct	GRvg_construct	cst;
	struct	GRid		cs_id;
		IGRshort	typ;
		IGRmatrix	mat;
		IGRdouble	*pnt, dX=0.0, dY=0.0;
	struct	IGRpolyline	poly;
		IGRlong		size,loc_msg;
		IGRdouble	Xvec[4], Yvec[4], xvec[4], yvec[4];
		IGRshort	four=4, one=1;
		IGRvector	Vmin, Vmax, diag, Zdep;
	struct	ACrg_coll	*Iattr;
	struct	ACrg_coll	*Oattr;
	struct	ACrg_coll	Priv[IDX_LB_FIXE2];

	/* Initialize */
	pnt         = NULL;
	poly.points = NULL;
	Iattr	    = NULL;
	Oattr	    = NULL;
	*fcount = MACRO_L_FFEET;
	for ( i=0; i<MACRO_L_FFEET; i++) {
		feet_list[i].objid = NULL_OBJID;
		feet_list[i].osnum = md_env->md_id.osnum;
	}
	VLinitCnst (&cst);
	Xvec[1] = Xvec[2] = Xvec[3] = Yvec[0] = Yvec[2] = Yvec[3] = 0.0;
	Xvec[0] = Yvec[1] = 1.0;
	Zdep[0] = Zdep[1] = Zdep[2] = 0.0;

	/* Retrieve the input parameter box (number) */
	sts = om$send ( msg = message ACdyn_col.AClist_attribute
					( msg, 0, NULL, &Inum ),
			targetid = list[IDX_LT_GRID].objid,
			targetos = list[IDX_LT_GRID].osnum );	
	as$status ( sts	   = sts,
		    msg	   = "ACdyn_col.AClist_attribute",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Allocate memory */
	Iattr = om$calloc ( num	      = Inum,
			    structure = struct ACrg_coll );
	if (!Iattr) {	printf( "Unable to allocate <%d> bytes\n",
				Inum * sizeof(struct ACrg_coll) );
			goto wrapup;	}

	/* Retrieve the input parameter box (value) */
	sts = om$send ( msg = message ACdyn_col.AClist_attribute
					( msg, Inum, Iattr, NULL ),
			targetid = list[IDX_LT_GRID].objid,
			targetos = list[IDX_LT_GRID].osnum );	
	as$status ( sts	   = sts,
		    msg	   = "ACdyn_col.AClist_attribute",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve well known data */
	Xpitch  = Iattr[IDX_LB_XPI].desc.value.att_exp;
	Ypitch  = Iattr[IDX_LB_YPI].desc.value.att_exp;
	Margin  = Iattr[IDX_LB_MRG].desc.value.att_exp;
	Uniform = (IGRint) Iattr[IDX_LB_UNI].desc.value.att_exp;

	/* Retrieve global contour */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_CONT,
			       objId   = &list[IDX_LT_MACR],
			       objEnv  = md_env,
			       footId  = &Cont.obj_id,
			       footEnv = &Cont.mod_env );
	as$status ( sts	   = sts,
		    msg	   = "vl$return_foot(CONT)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve ground cs in <VLbalance> macro templates */
	cs_id.objid = NULL_OBJID;
	cs_id.osnum = md_env->md_id.osnum;
	sts = om$send ( msg = message ACcpx.ACfind_exp_temp_obj
						( &suc, IDX_BT_GCS, &cs_id),
			targetid = list[IDX_LT_MACR].objid,
			targetos = list[IDX_LT_MACR].osnum );
	as$status ( sts	   = sts,
		    msg	   = "ACcpx.ACfind_exp_temp_obj(GCS)",
		    test   = (!(sts & 0x00000001 & suc)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve ground cs matrix */
	sts = om$send ( msg = message GRgencs.GRgetmatrix ( msg, mat),
			targetid = cs_id.objid,
			targetos = cs_id.osnum );
	as$status ( sts	   = sts,
		    msg	   = "GRgencs.GRgetmatrix",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	Zdep[2] = mat[11];
	MAtypemx ( &rc, mat, &typ);

	/* Create minimum rectangle foot */
	feet_list[IDX_LF_EXT].objid = NULL_OBJID;
	feet_list[IDX_LF_EXT].osnum = md_env->md_id.osnum;
	sts = vl$minrect ( curve   = &Cont.obj_id,
			   environ = &Cont.mod_env,
			   cst	   = &cst,
			   option  = B_STROKE,
			   margin  = Margin,
			   length  = &len,
			   width   = &wid,
			   frame   = &feet_list[IDX_LF_EXT],
                           msg     = msg );
        as$status ( sts    = sts,
                    msg    = "vl$minrect()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get the polyline associated with minimum rectangle */
	poly.num_points = 5;
	size = 3 * poly.num_points * sizeof(IGRdouble);
	poly.points = (IGRdouble *) om$calloc (size = size);
	if (!poly.points) {
		printf( "Unable to allocate %d bytes\n", size);
		poly.points = NULL;
		goto wrapup;
	}

	act = 1;
	sts = om$send ( msg = message GRlinear.GRgetpolyline (
						msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&act,
						&poly ),
			targetid = feet_list[IDX_LF_EXT].objid,
			targetos = feet_list[IDX_LF_EXT].osnum );
	as$status ( sts	   = sts,
		    msg	   = "GRlinear.GRgetpolyline",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Evaluate extremum in the XY plane of the coordinate system */
	if (poly.num_points > 1) {

		IGRvector	xVec, yVec, Curr;
		IGRdouble	xDot, yDot, xMin, yMin, xMax, yMax;
		IGRint		iMin=0, iMax=0;

		/* Initialize */
		xMin = yMin = xMax = yMax = 0.0;

		/* Build X & Y vector from CS matrix */
		xVec[0] = mat[0];	yVec[0] = mat[1];
		xVec[1] = mat[4];	yVec[1] = mat[5];
		xVec[2] = mat[8];	yVec[2] = mat[9];

		/* Loop on points */
		for ( i=0; i<(poly.num_points-1); i++ ) {

			/* Build vector from CS center to current point */
			Curr[0] = poly.points[3*i+0] - mat[3];
			Curr[1] = poly.points[3*i+1] - mat[7];
			Curr[2] = poly.points[3*i+2] - mat[11];

			/* Evaluate X & Y dot products */
			xDot = BSdotp ( &rc, Curr, xVec );
			yDot = BSdotp ( &rc, Curr, yVec );

			/* Search for extremum indices */
			if	( (xDot <= xMin) && (yDot <= yMin) ) {
				xMin = xDot;
				yMin = yDot;
				iMin = i;
			}
			else if	( (xDot >= xMax) && (yDot >= yMax) ) {
				xMax = xDot;
				yMax = yDot;
				iMax = i;
			}
		}

		/* Retrieve extremum points by index */
		for ( i=0; i<3; i++ ) {
			Vmin[i] = poly.points[3*iMin+i];
			Vmax[i] = poly.points[3*iMax+i];
		}
	}

#ifdef OLD_STUFF

	/* Get XYmin & XYmax in polyline */
	Vmin[0] = Vmin[1] =  1.0E31;	
	Vmax[0] = Vmax[1] = -1.0E31;
	Vmin[2] = Vmax[2] = Zdep[2];
	for ( i=0; i<(poly.num_points-1); i++) {
#ifdef TRACE
printf ( "Point %d :  [%g,%g,%g]\n", i,
	poly.points[3*i], poly.points[3*i+1], poly.points[3*i+2] );
#endif
		if (poly.points[3*i+0] < Vmin[0])  Vmin[0] = poly.points[3*i+0];
		if (poly.points[3*i+0] > Vmax[0])  Vmax[0] = poly.points[3*i+0];
		if (poly.points[3*i+1] < Vmin[1])  Vmin[1] = poly.points[3*i+1];
		if (poly.points[3*i+1] > Vmax[1])  Vmax[1] = poly.points[3*i+1];
	}
#ifdef TRACE
printf( "Point minimum : [%g,%g,%g]\n", Vmin[0], Vmin[1], Vmin[2] );
printf( "Point maximum : [%g,%g,%g]\n", Vmax[0], Vmax[1], Vmax[2] );
#endif

#endif

	/* Define columns & lines number */
	MAmulmx ( &rc, &four, &four, &one, mat, Xvec, xvec);
	MAmulmx ( &rc, &four, &four, &one, mat, Yvec, yvec);
	BSmkvec ( &rc, diag, Vmin, Vmax);
	if (rc != BSSUCC) { printf( "Error in BSmkvec()\n" );
			    *msg = MSFAIL; goto wrapup; }
	
	dX  = BSdotp( &rc, xvec, diag);
	if (rc != BSSUCC) { printf( "Error in BSdotp(col)\n" );
			    *msg = MSFAIL; goto wrapup; }
	if ( dX<0.0 ) dX  = -1*dX;
#ifdef TRACE
printf( "xvec : [%g,%g,%g]\tdiag : [%g,%g,%g]\tBSdotp = %g\n",
	xvec[0], xvec[1], xvec[2], diag[0], diag[1], diag[2], dX );
#endif
	col = (IGRint) (dX / Xpitch);
	dX -= col * Xpitch;
	dX /= 2.0;
#ifdef TRACE
printf( "%d x %g + 2 x %g\n", col, Xpitch, dX);
#endif

	dY = BSdotp( &rc, yvec, diag);
	if (rc != BSSUCC) { printf( "Error in BSdotp(lin)\n" );
			    *msg = MSFAIL; goto wrapup; }
	if ( dY<0.0 ) dY  = -1*dY;
#ifdef TRACE
printf( "yvec : [%g,%g,%g]\tdiag : [%g,%g,%g]\tBSdotp = %g\n",
	yvec[0], yvec[1], yvec[2], diag[0], diag[1], diag[2], dY );
#endif
	lin = (IGRint) (dY / Ypitch);
	dY -= lin * Ypitch;
	dY /= 2.0;
#ifdef TRACE
printf( "%d x %g + 2 x %g\n", lin, Ypitch, dY);
#endif

	/* Reject to few lines/columns */
	if ((col < 3) || (lin < 3)) {
		printf( "%d columns x %d lines is not enough ...\n", col, lin);
		*msg = MSFAIL;
		goto wrapup;
	}
#ifdef TRACE
printf( "%d columns with Xpitch = %g\n", col, Xpitch);
printf( "%d lines   with Ypitch = %g\n", lin, Ypitch);
#endif

	/* Adjust columns & lines number for matrix of points */
	col++;
	lin++;

	if (Uniform) {

		/* Create output parameter box */
		Onum  = IDX_LB_FIXE1 + col + lin;
		Oattr = om$calloc ( num	      = Onum,
				    structure = struct ACrg_coll );
		if (!Oattr) {	printf( "Unable to allocate <%d> bytes\n",
					Onum * sizeof(struct ACrg_coll) );
				goto wrapup;	}

		/* Name parameter box components */
		strcpy ( Oattr[IDX_LB_XPI].name, NAM_LB_XPI);
        	strcpy ( Oattr[IDX_LB_YPI].name, NAM_LB_YPI);
        	strcpy ( Oattr[IDX_LB_MRG].name, NAM_LB_MRG);
        	strcpy ( Oattr[IDX_LB_COL].name, NAM_LB_COL);
        	strcpy ( Oattr[IDX_LB_LIN].name, NAM_LB_LIN);
        	strcpy ( Oattr[IDX_LB_UNI].name, NAM_LB_UNI);
		for ( i=0; i<col; i++)
			sprintf ( Oattr[IDX_LB_FIXE1+i].name,
				  "%s%d", NAM_LB_XIX, i );
		for ( j=0; j<lin; j++)
			sprintf ( Oattr[IDX_LB_FIXE1+col+j].name,
				  "%s%d", NAM_LB_YIX, j );

		/* Type parameter box components */
		for ( i=0; i<Onum; i++)
			Oattr[i].desc.type = AC_ATTRIB_DOUBLE;

		/* Give value to parameter box components */
		Oattr[IDX_LB_XPI].desc.value.att_exp = Xpitch;
		Oattr[IDX_LB_YPI].desc.value.att_exp = Ypitch;
		Oattr[IDX_LB_MRG].desc.value.att_exp = Margin;
		Oattr[IDX_LB_COL].desc.value.att_exp = (IGRdouble) col;
		Oattr[IDX_LB_LIN].desc.value.att_exp = (IGRdouble) lin;
		Oattr[IDX_LB_UNI].desc.value.att_exp = 1.0;

		/* Generate uniform grid */
		Oattr[IDX_LB_FIXE1].desc.value.att_exp		     = 0.0;
		for ( i=1; i<col; i++)
			Oattr[IDX_LB_FIXE1+i].desc.value.att_exp     = Xpitch;
		Oattr[IDX_LB_FIXE1+col].desc.value.att_exp	     = 0.0;
		for ( j=1; j<lin; j++)
			Oattr[IDX_LB_FIXE1+col+j].desc.value.att_exp = Ypitch;
	}
	else {	/* Create output parameter box */

		col = (IGRint) Iattr[IDX_LB_COL].desc.value.att_exp;
		lin = (IGRint) Iattr[IDX_LB_LIN].desc.value.att_exp;

		Onum  = IDX_LB_FIXE1 + col + lin;
		Oattr = om$calloc ( num	      = Onum,
				    structure = struct ACrg_coll );
		if (!Oattr) {	printf( "Unable to allocate <%d> bytes\n",
					Onum * sizeof(struct ACrg_coll) );
				goto wrapup;	}

		/* Copy Iattr in Oattr */
		for ( i=0; i<Onum; i++) {
			strcpy ( Oattr[i].name, Iattr[i].name);
			Oattr[i].desc.type         =Iattr[i].desc.type;
			Oattr[i].desc.value.att_exp=Iattr[i].desc.value.att_exp;
		}
	}

	/* Fix for max number of grid lines & columns to be placed (begins) 
	   TR#179900281 - Jayadev*/

	if((col+lin)>MACRO_L_VFEET)
	{
	    loc_msg = MSSUCC;
            sts = om$send(  msg= message GRgraphics.GRdelete(&loc_msg,&Cont.mod_env),
            targetid = feet_list[IDX_LF_EXT].objid, targetos = feet_list[IDX_LF_EXT].osnum );
	    as$status( sts = sts );
		
	    *msg = MSFAIL; sts = 0;
	    ex$message(in_buff = "Too many matrix points ",field = ERROR_FIELD);
	    sleep(3);
	    goto wrapup;
	}
	/* Fix for max number of grid lines & columns to be placed (ends) */

	/* Build private box */
	strcpy ( Priv[IDX_LB_VMX].name, NAM_LB_VMX);
	strcpy ( Priv[IDX_LB_VMY].name, NAM_LB_VMY);
	strcpy ( Priv[IDX_LB_VMZ].name, NAM_LB_VMZ);
	strcpy ( Priv[IDX_LB_DLX].name, NAM_LB_DLX);
	strcpy ( Priv[IDX_LB_DLY].name, NAM_LB_DLY);
	strcpy ( Priv[IDX_LB_VXX].name, NAM_LB_VXX);
	strcpy ( Priv[IDX_LB_VXY].name, NAM_LB_VXY);
	strcpy ( Priv[IDX_LB_VXZ].name, NAM_LB_VXZ);
	strcpy ( Priv[IDX_LB_VYX].name, NAM_LB_VYX);
	strcpy ( Priv[IDX_LB_VYY].name, NAM_LB_VYY);
	strcpy ( Priv[IDX_LB_VYZ].name, NAM_LB_VYZ);

	Priv[IDX_LB_VMX].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VMY].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VMZ].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_DLX].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_DLY].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VXX].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VXY].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VXZ].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VYX].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VYY].desc.type = AC_ATTRIB_DOUBLE;
	Priv[IDX_LB_VYZ].desc.type = AC_ATTRIB_DOUBLE;

	Priv[IDX_LB_VMX].desc.value.att_exp = Vmin[0];
	Priv[IDX_LB_VMY].desc.value.att_exp = Vmin[1];
	Priv[IDX_LB_VMZ].desc.value.att_exp = Vmin[2];
	Priv[IDX_LB_DLX].desc.value.att_exp = dX;
	Priv[IDX_LB_DLY].desc.value.att_exp = dY;
	Priv[IDX_LB_VXX].desc.value.att_exp = xvec[0];
	Priv[IDX_LB_VXY].desc.value.att_exp = xvec[1];
	Priv[IDX_LB_VXZ].desc.value.att_exp = xvec[2];
	Priv[IDX_LB_VYX].desc.value.att_exp = yvec[0];
	Priv[IDX_LB_VYY].desc.value.att_exp = yvec[1];
	Priv[IDX_LB_VYZ].desc.value.att_exp = yvec[2];

	/* Allocate matrix of points */
	size  = 3 * col * lin * sizeof(IGRdouble);
	pnt   = (IGRdouble *)  om$calloc (size = size);
	if (!pnt) {	printf( "Unable to allocate %d bytes\n", size);
			goto wrapup; }

	/* Generate matrix of points */
	for ( i=0; i<col; i++) {
		x_col = Oattr[IDX_LB_FIXE1+i].desc.value.att_exp;
		if (i>0) x_col += (i-1) * Oattr[IDX_LB_XPI].desc.value.att_exp;
	for ( j=0; j<lin; j++) {
		y_lin = Oattr[IDX_LB_FIXE1+col+j].desc.value.att_exp;
		if (j>0) y_lin += (j-1) * Oattr[IDX_LB_YPI].desc.value.att_exp;
	for ( k=0; k<3; k++) {
		pnt[3*(j+i*lin)+k] = Vmin[k]
		      		   + ((dX + x_col) * xvec[k])
				   + ((dY + y_lin) * yvec[k]);
	}
	}
	}

	/* Create private box */
	sts = om$construct ( classid = OPP_ACdyn_col_class_id,
                       	     osnum   = feet_list[IDX_LF_PRIV].osnum,
                       	     p_objid = &feet_list[IDX_LF_PRIV].objid );

	/* Set private box */
        sts = om$send ( msg = message ACdyn_col.ACset_list_attribute
                                                ( msg, IDX_LB_FIXE2, Priv),
                           targetid = feet_list[IDX_LF_PRIV].objid,
                           targetos = feet_list[IDX_LF_PRIV].osnum );
	as$status ( sts	   = sts,
	    	    msg	   = "ACdyn_col.ACset_list_attribute",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

	/* Create parameter box */
	sts = om$construct ( classid = OPP_ACdyn_col_class_id,
                       	     osnum   = feet_list[IDX_LF_GRID].osnum,
                       	     p_objid = &feet_list[IDX_LF_GRID].objid );

	/* Set parameter box */
        sts = om$send ( msg = message ACdyn_col.ACset_list_attribute
                                                ( msg, Onum, Oattr),
                           targetid = feet_list[IDX_LF_GRID].objid,
                           targetos = feet_list[IDX_LF_GRID].osnum );
	as$status ( sts	   = sts,
	    	    msg	   = "ACdyn_col.ACset_list_attribute",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

	/* Set internal properties */
        sts = om$send ( msg = message ACdyn_col.ACset_att_prop (
                                                        msg,
                                                        NAM_LB_COL,
                                                        AC_ATTRIB_PRIVATE,
                                                        0 ),
                           targetid = feet_list[IDX_LF_GRID].objid,
                           targetos = feet_list[IDX_LF_GRID].osnum );
	as$status ( sts	   = sts,
	    	    msg	   = "ACdyn_col.ACset_att_prop(COL)",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

        sts = om$send ( msg = message ACdyn_col.ACset_att_prop (
                                                        msg,
                                                        NAM_LB_LIN,
                                                        AC_ATTRIB_PRIVATE,
                                                        0 ),
                           targetid = feet_list[IDX_LF_GRID].objid,
                           targetos = feet_list[IDX_LF_GRID].osnum );
	as$status ( sts	   = sts,
	    	    msg	   = "ACdyn_col.ACset_att_prop(LIN)",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

        sts = om$send ( msg = message ACdyn_col.ACset_att_prop (
                                                        msg,
                                                        NAM_LB_UNI,
                                                        AC_ATTRIB_PRIVATE,
                                                        0 ),
                           targetid = feet_list[IDX_LF_GRID].objid,
                           targetos = feet_list[IDX_LF_GRID].osnum );
	as$status ( sts	   = sts,
	    	    msg	   = "ACdyn_col.ACset_att_prop(UNI)",
	    	    test   = (!(sts & 0x00000001 & (*msg))),
	    	    action = GOTO_VALUE,
	    	    value  = wrapup );

	/* Build the grid columns (between j=0 & j=lin-1) */
	idx = 0;
	for ( i=0; i<col; i++) {
		sts = VLcreateLineSeg ( &pnt[3*i*lin],
					  &pnt[3*(lin-1+(i*lin))],
					  md_env,
					  &cst,
					  &feet_list[MACRO_L_FFEET+idx],
					  msg );
		as$status ( sts	   = sts,
		    	    msg	   = "VLcreateLineSeg()",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
		idx++;
	}

	/* Build the grid lines (between i=0 & i=col-1) */
	for ( j=0; j<lin; j++) {
		sts = VLcreateLineSeg ( &pnt[3*j],
					  &pnt[3*(j+((col-1)*lin))],
					  md_env,
					  &cst,
					  &feet_list[MACRO_L_FFEET+idx],
					  msg );
		as$status ( sts	   = sts,
		    	    msg	   = "VLcreateLineSeg()",
		    	    test   = (!(sts & 0x00000001 & (*msg))),
		    	    action = GOTO_VALUE,
		    	    value  = wrapup );
		idx++;
	}
	*fcount = MACRO_L_FFEET + idx;

wrapup:
	if (Iattr)	 { om$dealloc(ptr = Iattr);	  Iattr       = NULL; }
	if (Oattr)	 { om$dealloc(ptr = Oattr);	  Oattr       = NULL; }
	if (pnt)	 { om$dealloc(ptr = pnt);	  pnt         = NULL; }
	if (poly.points) { om$dealloc(ptr = poly.points); poly.points = NULL; }
	return(sts);
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjLayout;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/


end implementation VLlayout;
