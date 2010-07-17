/* $Id: VLpinjigi.I,v 1.1.1.1 2001/01/04 21:11:35 cvs Exp $  */
/***************************************************************************
* I/LOFT
*
* File: src/pin_jig/VLpinjigi.I
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: VLpinjigi.I,v $
*      Revision 1.1.1.1  2001/01/04 21:11:35  cvs
*      Initial import to CVS
*
# Revision 1.5  1999/12/30  13:01:02  pinnacle
# Replaced VLpinjigi.I for CR179900810 by jpulapar for loft
#
# Revision 1.3  1999/05/07  15:45:26  pinnacle
# tr179900281
#
*
* History:
* MM/DD/YY  AUTHOR  DESCRIPTION
* 05/07/99  Jayadev TR179900281 Feet overflow
*
***************************************************************************/

class implementation VLpinjig;

#include	"vlpinjig.h"
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
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "ACdyn_col.h"
#include	"vsplatedef.h"
#include	"vsmiscmacros.h"
#include	"msdef.h"
#include	"msmacros.h"
#include	"grdpbmacros.h"
#include	"gotextdef.h"
#include	"cotxmacros.h"

#include        "vdandef.h"
#include        "vdanmacros.h"

#include	"vlplatejig.h"
#include	"vlfloor.h"
#include	"vllayout.h"
#include	"vlmsg.h"
#include	"vlmiscmacros.h"
#include	"vlforkmacros.h"

from	ACdyn_col	import	AClist_attribute, ACset_list_attribute,
				ACshow_data;
from	expression	import	NDgive_value;

extern	GRclassid	OPP_ACdyn_col_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;

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

		IGRint		sts=OM_S_SUCCESS, opt_flag[6], interpin=0, suc;
		IGRdouble	value, interfer, margin, *pts, *txtpts;
	struct	GRobj_env	Cont, Jcirc, Meas;
	struct	GRid		parm_id, priv_id, Balance, foot;
		IGRint		num, col, lin, i, j, k=0;
	struct	ACrg_coll	*parm, *priv;
		IGRdouble	dX, dY, x_col, x_pit, y_lin, y_pit;
		IGRpoint	Vmin, offset;
		IGRvector	xvec, yvec;
		IGRint		n0=0, n1=0, n2=0, n3=0, nplat=0, nmax=0, npin;
	struct	VLpinJig	*pin;
	struct	ACrg_coll	elem[IDX_PB_MAX];
		IGRmatrix	sMat;
		IGRchar		MacName[20], txt[DI_PATH_MAX];
	struct	GRmd_env	loc_env;
	struct  GRvg_construct  cst;

	/* Initialize */
	*fcount = MACRO_P_FFEET + MACRO_P_VFEET;
	for ( i=0; i<*fcount; i++) { feet_list[i].objid = NULL_OBJID;
				     feet_list[i].osnum = md_env->md_id.osnum; }
	parm   = NULL;
	priv   = NULL;
	pts    = NULL;
	txtpts = NULL;
	pin    = NULL;

	VLinitCnst( &cst );

	/* Retrieve option flag */
	sts = om$send ( msg = message expression.NDgive_value (&value),
			targetid = list[IDX_PT_OPTF].objid,
			targetos = list[IDX_PT_OPTF].osnum );
	as$status ( sts    = sts,
                    msg    = "expression.NDgive_value(OPTF)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	VLdecode ( (IGRint) value, 6, opt_flag);
	if (!(IGRint) value) {	*msg = MSFAIL;	goto wrapup;	}

	if (opt_flag[2]) {
		/* Retrieve number of intermediate seam pins */
		sts = om$send ( msg = message expression.NDgive_value (&value),
				targetid = list[IDX_PT_IPIN].objid,
				targetos = list[IDX_PT_IPIN].osnum );
		as$status ( sts    = sts,
                    	    msg    = "expression.NDgive_value(IPIN)",
                    	    test   = (!(sts & 0x00000001)),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );
		interpin = (IGRint) value;
	}

	/* Retrieve interference radius value */
	sts = om$send ( msg = message expression.NDgive_value (&interfer),
			targetid = list[IDX_PT_INFR].objid,
			targetos = list[IDX_PT_INFR].osnum );
	as$status ( sts    = sts,
                    msg    = "expression.NDgive_value(INFR)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Set offset point */
	offset[0] = -1.0 * fabs (interfer);
	offset[1] = -1.0 * fabs (interfer);
	offset[2] = 0.0;

	/* Retrieve Parameter Box in <VLlayout> */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_LF_GRID,
                               objId   = &list[IDX_PT_MACR],
                               footId  = &parm_id );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(GRID)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
	printf( "\tACdyn_col [%s] is (%d|%d)\n",
		NAM_LF_GRID, parm_id.osnum, parm_id.objid );
	om$send ( msg      = message ACdyn_col.ACshow_data (msg),
		  targetid = parm_id.objid,
		  targetos = parm_id.osnum );
#endif
	sts = om$send ( msg = message ACdyn_col.AClist_attribute
						( msg, 0, NULL, &num),
			targetid = parm_id.objid,
			targetos = parm_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACdyn_col.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	parm = om$calloc ( num	     = num,
			   structure = struct ACrg_coll );
	if (!parm) {	*msg = MSFAIL;	goto wrapup;	}

	sts = om$send ( msg = message ACdyn_col.AClist_attribute
						( msg, num, parm, NULL),
			targetid = parm_id.objid,
			targetos = parm_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACdyn_col.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve Private Box in <VLlayout> */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_LF_PRIV,
                               objId   = &list[IDX_PT_MACR],
                               footId  = &priv_id );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(PRIV)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
	printf( "\tACdyn_col [%s] is (%d|%d)\n",
		NAM_LF_PRIV, priv_id.osnum, priv_id.objid );
	om$send ( msg      = message ACdyn_col.ACshow_data (msg),
		  targetid = priv_id.objid,
		  targetos = priv_id.osnum );
#endif
	sts = om$send ( msg = message ACdyn_col.AClist_attribute
						( msg, 0, NULL, &num),
			targetid = priv_id.objid,
			targetos = priv_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACdyn_col.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	priv = om$calloc ( num	     = num,
			   structure = struct ACrg_coll );
	if (!priv) {	*msg = MSFAIL;	goto wrapup;	}

	sts = om$send ( msg = message ACdyn_col.AClist_attribute
						( msg, num, priv, NULL),
			targetid = priv_id.objid,
			targetos = priv_id.osnum );
	as$status ( sts    = sts,
                    msg    = "ACdyn_col.AClist_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Regenerate meshing */
        col    = (IGRint) parm[IDX_LB_COL].desc.value.att_exp;
        lin    = (IGRint) parm[IDX_LB_LIN].desc.value.att_exp;
        margin = (IGRdouble) parm[IDX_LB_MRG].desc.value.att_exp;
        x_pit  = parm[IDX_LB_XPI].desc.value.att_exp;
        y_pit  = parm[IDX_LB_YPI].desc.value.att_exp;

        pts = om$calloc ( num       = 3 * col * lin,
                          structure = IGRdouble );
        if (!pts) {     printf( "Unable to allocate %d bytes\n",
                                3 * col * lin * sizeof(IGRdouble) );
                        *msg = MSFAIL; goto wrapup;     }

        txtpts = om$calloc (  num        = 3*( col + lin ),
           	               structure = IGRdouble );
        if (!txtpts) {     printf( "Unable to allocate %d bytes\n",
                                (col + lin) * sizeof(IGRdouble) );
                        *msg = MSFAIL; goto wrapup;     }

	Vmin[0] = priv[IDX_LB_VMX].desc.value.att_exp;
        Vmin[1] = priv[IDX_LB_VMY].desc.value.att_exp;
        Vmin[2] = priv[IDX_LB_VMZ].desc.value.att_exp;
        dX      = priv[IDX_LB_DLX].desc.value.att_exp;
        dY      = priv[IDX_LB_DLY].desc.value.att_exp;
        xvec[0] = priv[IDX_LB_VXX].desc.value.att_exp;
        xvec[1] = priv[IDX_LB_VXY].desc.value.att_exp;
        xvec[2] = priv[IDX_LB_VXZ].desc.value.att_exp;
        yvec[0] = priv[IDX_LB_VYX].desc.value.att_exp;
        yvec[1] = priv[IDX_LB_VYY].desc.value.att_exp;
        yvec[2] = priv[IDX_LB_VYZ].desc.value.att_exp;

        for ( i=0; i<col; i++) {

                x_col = parm[IDX_LB_FIXE1+i].desc.value.att_exp;
                if (i > 0)      x_col += (i-1) * x_pit;

                for ( j=0; j<lin; j++) {

                        y_lin = parm[IDX_LB_FIXE1+col+j].desc.value.att_exp;
                        if (j > 0)      y_lin += (j-1) * y_pit;

                        for ( k=0; k<3; k++) {
                                pts[3*(j+i*lin)+k] = Vmin[k]
                                                   + ((dX + x_col) * xvec[k])
                                                   + ((dY + y_lin) * yvec[k]);

		  	   if( i == 0 ) 
			   {
				if( k == 0 ) txtpts[3*j+k] = pts[3*(j+i*lin)+k] - dX - 4.0*interfer;
				else if ( k == 1 ) txtpts[3*j+k] = pts[3*(j+i*lin)+k] + interfer ;
				else txtpts[3*j+k] = pts[3*(j+i*lin)+k];
			   }
			   if( j == 0 ) 
			   {
				if( k == 1 ) txtpts[3*(i+lin)+k] = pts[3*(j+i*lin)+k] - dY - interfer;
				else  txtpts[3*(i+lin)+k] = pts[3*(j+i*lin)+k];
			   }
                        }
                }
        }

	/* Put H1V1 in a foot attribute box */
	VLnamePJcollection ( elem, NULL);

#ifdef TRACE
printf( "H1V1 is [%g,%g,%g]\n", pts[0], pts[1], pts[2] );
#endif
	elem[IDX_PB_COL].desc.value.att_exp = 0.0;
	elem[IDX_PB_LIN].desc.value.att_exp = 0.0;
	elem[IDX_PB_XPT].desc.value.att_exp = pts[0];
	elem[IDX_PB_YPT].desc.value.att_exp = pts[1];
	elem[IDX_PB_ZPT].desc.value.att_exp = pts[2];
	elem[IDX_PB_ANG].desc.value.att_exp = 0.0;
	elem[IDX_PB_IDX].desc.value.att_exp = -1.0;
	strcpy ( elem[IDX_PB_NAM].desc.value.att_txt, "H1V1");

	sts = om$construct ( classid = OPP_ACdyn_col_class_id,
                             osnum   = feet_list[IDX_PF_ATTR].osnum,
                             p_objid = &feet_list[IDX_PF_ATTR].objid );

	sts = om$send ( msg = message ACdyn_col.ACset_list_attribute
					( msg, IDX_PB_MAX, elem),
                           targetid = feet_list[IDX_PF_ATTR].objid,
                           targetos = feet_list[IDX_PF_ATTR].osnum );
        as$status ( sts    = sts,
                    msg    = "ACdyn_col.ACset_list_attribute",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve <VLbalance> macro */
	sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
					( &suc, IDX_LT_MACR, &Balance),
			targetid = list[IDX_PT_MACR].objid,
			targetos = list[IDX_PT_MACR].osnum );
	as$status ( sts    = sts,
                    msg    = "ACncpx.ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve external contour (projected) */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_CONT,
                               objId   = &Balance,
                               objEnv  = md_env,
                               footId  = &Cont.obj_id,
                               footEnv = &Cont.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(CONT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve number of copied plates in VLbalance occurence */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_NPLT,
                               objId   = &Balance,
                               footId  = &foot );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(NPLT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = om$send ( msg = message expression.NDgive_value (&value),
			targetid = foot.objid,
			targetos = foot.osnum );
	as$status ( sts    = sts,
                    msg    = "expression.NDgive_value(NPLT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	nplat = (IGRint) value;

	/* Matrix Internal Points */
        num = col * (lin + 2 + nplat * (2 + interpin));
        pin = om$calloc ( num       = num,
                          structure = struct VLpinJig );
        if (!pin) {     printf( "Unable to allocate %d bytes\n",
                                 num * sizeof(struct VLpinJig));
                        *msg = MSFAIL;  goto wrapup;    }

	if (opt_flag[0]) {
		/* Case of <Matrix Internal Points> */
		ex$message (msgnumb = VL_M_MATRIX_INTERNAL_POINTS);
                sts = VLmatrixPoints(msg, &Cont, col, lin, pts, &n0, &pin[0]);
                as$status ( sts    = sts,
			    msg    = "VLmatrixPoints()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        nmax += n0;
#ifdef TRACE
printf( "\n\tThere are %d Matrix Internal Points ...\n", n0);
for ( i=0; i<nmax; i++)
printf( "\t\tidx=%d, col=%d, lin=%d :\t[%g,%g,%g]\n",
        pin[i].idx, pin[i].col, pin[i].lin,
        pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif
        }

	if (opt_flag[1]) {
		/* Case of <External Contour Points> */
		ex$message (msgnumb = VL_M_EXTERNAL_CONTOUR_POINTS);
		for ( i=0; i<col; i++) {
                        sts = VLintersectColumn ( msg, i, 0, 1, NAM_BF_CONT,
                                                    &list[IDX_PT_MACR], md_env,
                                                    &n1, &pin[n0] );
                        as$status ( sts    = sts,
			   	    msg    = "VLintersectColumn()",
                    	    	    test   = (!(sts & 0x00000001 & (*msg))),
                                    action = GOTO_VALUE,
                                    value  = wrapup );
                }
        nmax += n1;
#ifdef TRACE
printf( "\n\tThere are %d External Contour Points ...\n", n1);
for ( i=n0; i<nmax; i++)
printf( "\t\tidx=%d, col=%d, lin=%d :\t[%g,%g,%g]\n",
        pin[i].idx, pin[i].col, pin[i].lin,
        pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif
        }

	if (opt_flag[2]) {
		/* Case of <Columns Seams Points> */
		ex$message (msgnumb = VL_M_CONTOUR_SEAMS_POINTS);
		sts = VLseamsPoints ( msg, nplat, col, 2, &Balance,
                                        &list[IDX_PT_MACR], md_env, &n2,
				        &pin[n0+n1] );
                as$status ( sts    = sts,
			    msg    = "VLseamsPoints()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        nmax += n2;
#ifdef TRACE
printf( "\n\tThere are %d Columns Seams Points ...\n", n2);
for ( i=n0+n1; i<nmax; i++)
printf( "\t\tidx=%d, col=%d, lin=%d :\t[%g,%g,%g]\n",
        pin[i].idx, pin[i].col, pin[i].lin,
        pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif
        }

	if (interpin) {
                /* Between Seams Points */
		ex$message (msgnumb = VL_M_BETWEEN_SEAMS_POINTS);
                sts = VLbetweenPoints ( msg, n2, interpin, &pin[n0+n1], &n3);
                as$status ( sts    = sts,
			    msg    = "VLbetweenPoints()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
        nmax += n3;
#ifdef TRACE
printf( "\n\tThere are %d Between Seams Points ...\n", n3);
for ( i=n0+n1+n2; i<nmax; i++)
printf( "\t\tidx=%d, col=%d, lin=%d :\t[%g,%g,%g]\n",
        pin[i].idx, pin[i].col, pin[i].lin,
        pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif
        }

	/* Eliminate multipoints */
        sts = VLeliminatePoints ( msg, nmax, pin, 2*interfer, &npin);
        as$status ( sts    = sts,
		    msg    = "VLeliminatePoints()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "\n\tThere are %d Real Pin Points ...\n", npin);
for ( i=0; i<nmax; i++)
printf( "\t\tidx=%d, col=%d, lin=%d :\t[%g,%g,%g]\tflg=%d\n",
        pin[i].idx, pin[i].col, pin[i].lin,
        pin[i].xpt, pin[i].ypt, pin[i].zpt, pin[i].flg );
#endif

	/* Fix for TR#179900281 begins */

	if(npin> MACRO_P_VFEET)
	{
		*msg = MSFAIL; sts = 0;
		ex$message(in_buff = "Too many pin jigs on the plate", 
		           field = ERROR_FIELD);
		sleep(3);
		goto wrapup;
	}

	/* Fix for TR#179900281 ends */

	/* Create number of pin jigs expression */
	sts = exp$create ( exp_value = (IGRdouble) npin,
                           p_exp_id  = &feet_list[IDX_PF_NPIN].objid,
                           osnum     = md_env->md_id.osnum,
                           p_osnum   = &feet_list[IDX_PF_NPIN].osnum);
        as$status ( sts    = sts,
                    msg    = "exp$create(NPIN))",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Compute height and angle for each pin */
	ex$message (msgnumb = VL_M_HEIGHT_AND_ANGLE);
	sts = VLpinHeightAngle ( msg, &Balance, md_env, nmax, pin);
        as$status ( sts    = sts,
		    msg    = "VLpinHeightAngle()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Generate symbol matrix */
	dblcpy ( sMat, md_env->md_env.matrix, 16);
	for ( i=0; i<3; i++ ) {
		 sMat[4*i+0] *= 0.25 * interfer / 50.0;
		 sMat[4*i+1] *= 0.25 * interfer / 50.0;
		 sMat[4*i+2] *= 0.25 * interfer / 50.0;
	}

	/* Determine pin jig symbol macro name */
	if	( (opt_flag[4] == 1) && (opt_flag[5] == 1) )
		strcpy ( MacName, "POINsymbol" );
	else if	( (opt_flag[4] == 0) && (opt_flag[5] == 1) )
		strcpy ( MacName, "CROSsymbol" );
	else if	( (opt_flag[4] == 1) && (opt_flag[5] == 0) )
		strcpy ( MacName, "PLUSsymbol" );
	else	strcpy ( MacName, "CIRCsymbol" );

	/* Create feet */
	npin = 0;
	for ( i=0; i<nmax; i++) {
        	if (pin[i].flg) {
#ifdef TRACE
printf( "\tcol=%d : \t[%g,%g,%g]\n",
        pin[i].col, pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif		
		/* Modify symbol matrix */
		sMat[3]  = pin[i].xpt;
		sMat[7]  = pin[i].ypt;
		sMat[11] = pin[i].zpt;

		/* Place symbol */
		Jcirc.obj_id.objid = NULL_OBJID;
		Jcirc.obj_id.osnum = md_env->md_id.osnum;
		sts = VLplaceRootHeader ( sMat, MacName, md_env,
					  &Jcirc.obj_id, msg );
		as$status ( sts    = sts,
                            msg    = "VLplaceRootHeader()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Create VLjunction foot */
		Jcirc.mod_env = *md_env;
		elem[IDX_PB_COL].desc.value.att_exp = (IGRdouble) pin[i].col;
		elem[IDX_PB_LIN].desc.value.att_exp = (IGRdouble) pin[i].lin;
		elem[IDX_PB_XPT].desc.value.att_exp = (IGRdouble) pin[i].xpt;
		elem[IDX_PB_YPT].desc.value.att_exp = (IGRdouble) pin[i].ypt;
		elem[IDX_PB_ZPT].desc.value.att_exp = (IGRdouble) pin[i].zpt;
		elem[IDX_PB_HEI].desc.value.att_exp = (IGRdouble) pin[i].hei;
		elem[IDX_PB_ANG].desc.value.att_exp = (IGRdouble) pin[i].ang;
		elem[IDX_PB_IDX].desc.value.att_exp = (IGRdouble) pin[i].idx;
		strcpy ( elem[IDX_PB_NAM].desc.value.att_txt, pin[i].nam);

		/* Create measure string */
		txt[0] = '\0';
/*
		sprintf ( txt, "%s : H = %-.0f",
			  elem[IDX_PB_NAM].desc.value.att_txt,
			  elem[IDX_PB_HEI].desc.value.att_exp );
*/
		sprintf ( txt, "%-.0f", elem[IDX_PB_HEI].desc.value.att_exp );

		/* Create measure foot */
		Meas.mod_env		= *md_env;
		Meas.obj_id.objid	= NULL_OBJID;
		Meas.obj_id.osnum	= md_env->md_id.osnum;
		if (opt_flag[3] == IDX_PJO_DON) {

			IGRshort	len;
			IGRpoint	cnt;
			IGRint		siz=sizeof(struct GRdpb_text_symb);
		struct	GRdpb_text_symb	dts;
			IGRlong		ret;

			/* Retrieve text symbology */
			gr$get_text_symb ( msg    = msg,
					   sizbuf = &siz,
					   buffer = &dts,
					   nret   = &ret );

			/* Create text foot */
			len = strlen (txt);
			cnt[0] = elem[IDX_PB_XPT].desc.value.att_exp;
			cnt[1] = elem[IDX_PB_YPT].desc.value.att_exp
			       - 0.25 * interfer;
//			       - interfer;
			cnt[2] = elem[IDX_PB_ZPT].desc.value.att_exp;
			dts.Active_just		= CENTER_TOP;
//			dts.Active_width	= interfer * 0.5;
//			dts.Active_height	= interfer * 0.5;

			dts.Active_width        = interfer;
			dts.Active_height       = interfer;

			sts = co$place_text (
					msg		= msg,
					text_string	= txt,
					text_length	= &len,
					origin		= cnt,
					rot_matrix	= md_env->md_env.matrix,
					ModuleInfo	= md_env,
					TextSymb	= &dts,
					mode		= GRbe,
					buffer		= &Meas.obj_id );
		        as$status ( sts    = sts,
		                    msg    = "co$place_text(MEASURE))",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
		else {	/* Create expression text foot */
			sts = exp$create ( exp_syntax = txt,
		                           p_exp_id   = &Meas.obj_id.objid,
		                           osnum      = md_env->md_id.osnum,
		                           p_osnum    = &Meas.obj_id.osnum,
					   type_rq    = EXP_TEXT );
		        as$status ( sts    = sts,
		                    msg    = "exp$create(MEASURE))",
		                    test   = (sts != EXP_S_SUCCESS),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}

		/* Create VLjunction */
		loc_env = *md_env;
		loc_env.md_id.objid = NULL_OBJID;
		sts = vl$createLoftFork (
				msg     = msg,
				graphic = &Jcirc,
				attr    = elem,
				number  = IDX_PB_MAX,
				measure	= &Meas,
				Env     = &loc_env,
				forkId	= &feet_list[MACRO_P_FFEET+npin] );
		as$status ( sts    = sts,
                            msg    = "vl$createLoftFork(1st)",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Increment pins' number */
		npin++;
		}
	}
	*fcount = MACRO_P_FFEET + npin;

  	cst.env_info    = md_env;
  	cst.properties &=  ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);

	for( i=0; i<(col+lin); ++i )
	{
	   struct  GRobj_env 	   pt_obj;
	   struct  ACrg_coll       dummy_attr;
	   IGRchar         	   line_txt[DI_PATH_MAX];
	   IGRshort		   len;
	   IGRpoint		   cnt;
	   IGRint		   siz=sizeof(struct GRdpb_text_symb);
	   struct		   GRdpb_text_symb	dts;
	   IGRlong		   ret;
           struct  IGRpolyline	   geom;

	   line_txt[0] = '\0';

	   if( i<lin )	sprintf( line_txt, "H%d", i+1 );
	   else		sprintf( line_txt, "V%d", i-lin+1 );

	   dummy_attr.desc.type = AC_ATTRIB_TEXT;
	   strcpy ( dummy_attr.desc.value.att_txt, line_txt);

  	   geom.num_points = 1;
	   geom.points     = &txtpts[3*i+k];

  	   cst.geometry  = (char *)&geom;

	   pt_obj._osnum = md_env->md_id.osnum;
  	   sts = om$construct( classid = OPP_GR3dpoint_class_id,
                      	       osnum   = pt_obj._osnum,
                      	       p_objid = &pt_obj._objid,
			       msg     = message GRgraphics.GRaltconstruct(&cst) );
	   as$status ( sts    = sts,
                       msg    = "vl$createLoftFork(1st)",
                       test   = (!(sts & 0x00000001 & (*msg))),
                       action = GOTO_VALUE,
                       value  = wrapup );
	   pt_obj.mod_env = *md_env;

	   /* Create measure foot */
	   Meas.mod_env		= *md_env;
	   Meas.obj_id.objid	= NULL_OBJID;
	   Meas.obj_id.osnum	= md_env->md_id.osnum;

	   /* Retrieve text symbology */
	   gr$get_text_symb ( msg    = msg,
	   		      sizbuf = &siz,
			      buffer = &dts,
			      nret   = &ret );

	   /* Create text foot */
	   len = strlen (line_txt);

	   cnt[0] = txtpts[3*i];
	   cnt[1] = txtpts[3*i+1];
	   cnt[2] = txtpts[3*i+2];

	   dts.Active_just	= CENTER_TOP;
	   dts.Active_width     = interfer*2.0;
	   dts.Active_height    = interfer*2.0;

	   sts = co$place_text (
					msg		= msg,
					text_string	= line_txt,
					text_length	= &len,
					origin		= cnt,
					rot_matrix	= md_env->md_env.matrix,
					ModuleInfo	= md_env,
					TextSymb	= &dts,
					mode		= GRbe,
					buffer		= &Meas.obj_id );
       	   as$status ( sts    = sts,
		                    msg    = "co$place_text(MEASURE))",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

	   /* Create VLjunction */
	   loc_env = *md_env;
	   loc_env.md_id.objid = NULL_OBJID;
	   sts = vl$createLoftFork (
				msg     = msg,
				graphic = &pt_obj,
				attr    = &dummy_attr,
				number  = 1,
				measure	= &Meas,
				Env     = &loc_env,
				forkId	= &feet_list[(*fcount)++] );
	   as$status ( sts    = sts,
                       msg    = "vl$createLoftFork(1st)",
                       test   = (!(sts & 0x00000001 & (*msg))),
                       action = GOTO_VALUE,
                       value  = wrapup );
	   cst.geometry = NULL;
	}

wrapup:
	if (pin) {	om$dealloc (ptr = pin);		pin  = NULL;	}
	if (pts) {	om$dealloc (ptr = pts);		pts  = NULL;	}
	if (priv) {	om$dealloc (ptr = priv);	priv = NULL;	}
	if (parm) {	om$dealloc (ptr = parm);	parm = NULL;	}
	if (txtpts) {	om$dealloc (ptr = txtpts);	txtpts  = NULL;	}
	return(sts);
}
/* ========================================================================== */

/* ========================================================================== */
method	VLget_attributes (		IGRlong		*msg;
					IGRint		*idx;
					IGRint		*npin;
					IGRboolean	format;
				struct	ACrg_coll	*attr;
				struct	ACrg_coll	*glob	)
{
	IGRint		sts=OM_S_SUCCESS, Npj=0, i;
struct	GRid		foot;
	IGRdouble	value=0.0;
struct	ACrg_coll	elem[IDX_PB_MAX];
	IGRchar		name[MAX_CHA_TEMP];

	/* Find number of pinjigs */
	sts = om$send ( msg = message NDmacro.ACreturn_foot
				( msg, NAM_PF_NPIN, &foot, NULL, NULL),
			targetid = my_id );
	as$status ( sts    = sts,
		    msg    = "NDmacro.ACreturn_foot(NPIN)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	sts = om$send ( msg = message expression.NDgive_value (&value),
                        targetid = foot.objid,
                        targetos = foot.osnum );
	as$status ( sts    = sts,
		    msg    = "expression.NDgive_value",
		    test   = (!(sts & 0x00000001)),
		    action = GOTO_VALUE,
		    value  = wrapup );

	Npj = (IGRint) value;

	/* Build unformatted collection to query foot */
	VLnamePJcollection ( elem, NULL);

	/* If output pinjig attributes wanted */
	if (attr) {

		/* Format output collection and fill it */
		if	( (idx) && (*idx >= 0) && (*idx < Npj) ) {

			sprintf ( name, "%s%d", NAM_PF_VARF, *idx);
			sts = om$send ( msg = message NDmacro.ACreturn_foot
					( msg, name, &foot, NULL, NULL),
					targetid = my_id );
			as$status ( sts    = sts,
				    msg    = "NDmacro.ACreturn_foot()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			sts = om$send ( msg = message ACdyn_col.AClist_attribute
						( msg, IDX_PB_MAX, elem, NULL),
					targetid = foot.objid,
					targetos = foot.osnum);
			as$status ( sts    = sts,
		                    msg    = "ACdyn_col.AClist_attribute",
			            test   = (!(sts & 0x00000001 & (*msg))),
			            action = GOTO_VALUE,
			            value  = wrapup );

			if (format == TRUE) {
				VLnamePJcollection ( attr, idx);
				VLfillPJcollection ( elem, attr);
			}
			else {	VLnamePJcollection ( attr, NULL);
				VLfillPJcollection ( elem, attr);
			}
		}
		else if (!idx) {
		for ( i=0; i<Npj; i++) {

			sprintf ( name, "%s%d", NAM_PF_VARF, i);
			sts = om$send ( msg = message NDmacro.ACreturn_foot
					( msg, name, &foot, NULL, NULL),
					targetid = my_id );
			as$status ( sts    = sts,
				    msg    = "NDmacro.ACreturn_foot()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			sts = om$send ( msg = message ACdyn_col.AClist_attribute
						( msg, IDX_PB_MAX, elem, NULL),
					targetid = foot.objid,
					targetos = foot.osnum);
			as$status ( sts    = sts,
		                    msg    = "ACdyn_col.AClist_attribute",
			            test   = (!(sts & 0x00000001 & (*msg))),
			            action = GOTO_VALUE,
			            value  = wrapup );

			VLnamePJcollection ( &attr[i*IDX_PB_MAX], &i);
			VLfillPJcollection ( elem, &attr[i*IDX_PB_MAX]);
		}
		}
		else	goto wrapup;
	}

wrapup:

	if (npin)	*npin = Npj;

	if (glob) {

		sts = om$send ( msg = message NDmacro.ACreturn_foot
					( msg, NAM_PF_ATTR, &foot, NULL, NULL),
				targetid = my_id );
		as$status ( sts    = sts,
			    msg    = "NDmacro.ACreturn_foot(ATTR)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		VLnamePJcollection ( glob, NULL);

		sts = om$send ( msg = message ACdyn_col.AClist_attribute
					( msg, IDX_PB_MAX, glob, NULL),
				targetid = foot.objid,
				targetos = foot.osnum);
		as$status ( sts    = sts,
	                    msg    = "ACdyn_col.AClist_attribute",
		            test   = (!(sts & 0x00000001 & (*msg))),
		            action = GOTO_VALUE,
		            value  = wrapup );
	}

	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjPinJigs;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/* ========================================================================== */

end implementation VLpinjig;
