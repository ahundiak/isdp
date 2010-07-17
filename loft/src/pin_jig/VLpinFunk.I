/* $Id: VLpinFunk.I,v 1.3 2001/09/24 19:29:22 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	loft/src/pin_jig/VLpinFunk.I
 *
 * Description:	Functions for pin jigs.
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLpinFunk.I,v $
 * Revision 1.3  2001/09/24 19:29:22  ramarao
 * Fixed small bugs.
 *
 * Revision 1.2  2001/01/16 19:27:56  ramarao
 * *** empty log message ***
 *
# Revision 1.2  2000/06/28  13:42:48  pinnacle
# Replaced: loft/src/pin_jig/VLpinFunk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/06/19  13:45:38  pinnacle
# Created: loft/src/pin_jig/VLpinFunk.I by rchennup for Service Pack
#
# Revision 1.3  1999/12/30  09:39:56  pinnacle
# Replaced VLpinFunk.I for TR 179900772 by aharihar for loft
#
# Revision 1.2  1998/10/03  18:40:16  pinnacle
# tr179801493
#
 *
 * History:
 * MM/DD/YY	AUTHOR		DESCRIPTION
 * 09/09/98	RR    		Added header and fixed TR#179801493
 * 12/24/99	Jayadev/Anand	Fix for TR179900772
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

#include	"vlfloor.h"
#include	"vllayout.h"
#include	"vlmiscmacros.h"

from	ACdyn_col	import	ACget_named_attribute, AClist_attribute;
from	VLpinjig	import	VLget_attributes;
from	expression	import	NDgive_value;

extern	void		qsort();
extern  IGRdouble       VLatan2();

extern	GRclassid	OPP_VSfrzPlate_class_id;

//	#define	TRACE 1

/* ========================================================================== */
IGRlong	VLmatrixPoints ( msg, Contour, column, line, Ipts, npts, Opts)

		IGRlong		*msg;		/*O Completion code	*/
	struct	GRobj_env	*Contour;	/*I External contour	*/
		IGRint		column;		/*I Number of columns	*/
		IGRint		line;		/*I Number of lines	*/
		IGRdouble	*Ipts;		/*I Matrix pts (all)	*/
		IGRint		*npts;		/*O Number of ret pts	*/
	struct	VLpinJig	*Opts;		/*O Matrix pts (inside)	*/

{
/*c Beginning of function */

		IGRint		i=0, j=0, sts=OM_S_SUCCESS, idx;
		IGRlong		size=0;
	struct	IGRbsp_curve	*contour;
		IGRboolean	ord;
		BSrc		rc;

	/*c Initialize */
	contour = NULL;
	*npts   = 0;

	/*c Check idiot inputs */
	if ( (column < 1) || (line < 1) ) {
		printf( "Unexpected input : %d columns x %d lines\n",
			column, line );
		*msg = MSFAIL;
		goto wrapup;
	}

	/*c Extract external contour geometry */
	sts = om$send ( msg = message GRvg.GRgetsize (
					msg,
					&Contour->mod_env.md_env.matrix_type,
					Contour->mod_env.md_env.matrix,
					&size ),
			senderid = NULL_OBJID,
			targetid = Contour->obj_id.objid,
			targetos = Contour->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetsize",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	contour = (struct IGRbsp_curve *) om$calloc (size = size);
	if (!contour) {	printf( "Unable to allocate %d bytes\n", size);
			*msg = MSFAIL;	goto wrapup; }

	sts = om$send ( msg = message GRvg.GRgetgeom (
					msg,
					&Contour->mod_env.md_env.matrix_type,
					Contour->mod_env.md_env.matrix,
					(IGRchar *) contour ),
			senderid = NULL_OBJID,
			targetid = Contour->obj_id.objid,
			targetos = Contour->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetgeom",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Check inside matrix points */
	BSpt_in_cv ( contour, &Ipts[0], FALSE, &ord, &idx, &rc);
	if (rc != BSSUCC) { printf( "Error in BSpt_in_cv()\n");
                            *msg = MSFAIL; goto wrapup; }
	for ( i=0; i<column; i++) {
		for ( j=0; j<line; j++) {
			BSpt_in_cv ( contour, &Ipts[3*(j+i*line)],
				     TRUE, &ord, &idx, &rc);
			if (rc != BSSUCC) { printf( "Error in BSpt_in_cv()\n");
                            		    *msg = MSFAIL; goto wrapup; }
			if (idx > 0) {
				Opts[*npts].idx = (IGRdouble) 0;
				Opts[*npts].col = (IGRdouble) i;
				Opts[*npts].lin = (IGRdouble) j;
				Opts[*npts].xpt = Ipts[3*(j+i*line)+0];
				Opts[*npts].ypt = Ipts[3*(j+i*line)+1];
				Opts[*npts].zpt = Ipts[3*(j+i*line)+2];
				Opts[*npts].hei = 0.0;
				Opts[*npts].ang = 0.0;
				sprintf ( Opts[*npts].nam, "H%dV%d", j+1, i+1 );
				(*npts)++;
			}
		}
	}

wrapup:
	if (contour) {	om$dealloc (ptr = contour);	contour = NULL;	}
	
	return (sts);

/*c End of function */
}
/* ========================================================================== */
IGRboolean VLjigDecode ( IGRint idx, IGRint *flag )
{
		IGRboolean	sts = TRUE;

	/*c Initialize */
	flag[0] = flag[1] = flag[2] = FALSE;

	switch (idx) {
		case  0:				break;
		case  3:	flag[1] = TRUE;
		case  1:	flag[0] = TRUE;		break;
		case  7:	flag[0] = TRUE;
		case  6:	flag[2] = TRUE;
		case  2:	flag[1] = TRUE;		break;
		case  5:	flag[0] = TRUE;
		case  4:	flag[2] = TRUE;		break;
		default:	sts = FALSE;
	}

	return (sts);
}
/* ========================================================================== */
IGRint VLsortByYpt ( a, b)

		IGRdouble	*a, *b;

{
	return ((a[1] == b[1]) ? 0 : (a[1] < b[1]) ? -1 : 1);
}
/* ========================================================================== */
IGRboolean VLjigEncode ( IGRint *idx, IGRint *flag )
{
		IGRboolean	sts = TRUE;

	/*c Initialize */
	*idx = 0;

	/*c Encode */
	if (flag[0])	*idx += 1;
	if (flag[1])	*idx += 2;
	if (flag[2])	*idx += 4;

	return (sts);
}
/* ========================================================================== */
IGRlong	VLintersectColumn ( msg, col, lin, idx, Object, Macro, Env, num, pin)

		IGRlong		*msg;	/*O Completion code	*/
		IGRint		col;	/*I Column index	*/
		IGRint		lin;	/*I VSplate index	*/
		IGRint		idx;	/*I Group index		*/
		IGRchar		*Object;/*I Intersected object	*/
	struct	GRid		*Macro;	/*I VLlayout occurence	*/
	struct	GRmd_env	*Env;	/*I Current mod env	*/
		IGRint		*num;	/*O Intersection number	*/
	struct	VLpinJig	*pin;	/*O Pin Jig buffer	*/

{
		IGRint		sts=OM_S_SUCCESS, nint=0, i, suc;
		IGRchar		name[DI_PATH_MAX];
	struct	GRobj_env	Line, Cont;
	struct	GRid		*Inter, Balance, dummy, Attr;
		IGRdouble	*Point;
	struct	ACrg_coll	elem;
		IGRdouble	value;
		IGRint		nplat, nfeet, pos1, pos2;

	/*c Initialize */
	Inter = NULL;
	Point = NULL;

	/*c Retrieve <VLbalance> macro */
        sts = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
                                        ( &suc, IDX_LT_MACR, &Balance),
			senderid = NULL_OBJID,
			targetid = Macro->objid,
			targetos = Macro->osnum );
        as$status ( sts    = sts,
                    msg    = "ACncpx.ACfind_exp_temp_obj",
                    test   = (!(sts & 0x00000001 & suc)),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Retrieve <VLbalance> number of VSplates */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_NPLT,
                               objId   = &Balance,
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

	/*c Retrieve <VLbalance> attributes of VSplates */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_ATTR,
                               objId   = &Balance,
                               footId  = &Attr );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(ATTR)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Retrieve <VLbalance> contour */
	sts = vl$return_foot ( msg     = msg,
			       name    = Object,
                               objId   = &Balance,
                               objEnv  = Env,
                               footId  = &Cont.obj_id,
                               footEnv = &Cont.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(Object)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Retrieve number of feet in VLbalance occurence */
	sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &nfeet),
			senderid = NULL_OBJID,
			targetid = Balance.objid,
			targetos = Balance.osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Get seams indices */
	pos1 = pos2 = 0;
	if (idx == 1)	pos2 = nplat - 1;
	else { 	pos1 = atoi (&Object[strlen(NAM_BF_VARF)]);
		pos1 += nplat - nfeet + MACRO_B_FFEET;
		pos2 =  pos1; }
#ifdef TRACE
printf( "Object : <%s>, nplat=%d --> pos1=%d, pos2=%d\n",
	Object, nplat, pos1, pos2);
#endif

	/*c Get column foot */
	sprintf ( name, "%s%d", NAM_LF_VARF, col);
	sts = vl$return_foot ( msg     = msg,
			       name    = name,
                               objId   = Macro,
                               objEnv  = Env,
                               footId  = &Line.obj_id,
                               footEnv = &Line.mod_env );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(VARF)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Foot <%s> : (%d|%d) in (%d|%d)\n",
	name, Line.obj_id.osnum, Line.obj_id.objid,
	Line.mod_env.md_id.osnum, Line.mod_env.md_id.objid );
#endif
	/*c Intersect column with input object */
	sts = VLcreateAllInter( msg,
                                &(Line.obj_id), &(Line.mod_env), (IGRshort)0,
                                &(Cont.obj_id), &(Cont.mod_env), (IGRshort)1,
                                &nint, &Inter, Env );
	if (nint) {
		as$status ( sts    = sts,
		    	    msg    = "VLcreateAllInter()",
                    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    action = GOTO_VALUE,
                    	    value  = wrapup );

		Point = om$calloc ( num       = 3 * nint,
				    structure = IGRdouble );
		if (!Point) {	printf( "Unable to allocate %d bytes\n",
					3 * nint * sizeof(IGRdouble) );
				*msg = MSFAIL; goto wrapup;	}

		for ( i=0; i<nint; i++) {
			sts = VLgetPtCoord( msg, Inter[i], Env, &Point[3*i]);
			as$status ( sts    = sts,
		    	    	    msg    = "VLgetPtCoord()",
                    	    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );

			gr$delete_object ( msg	     = msg,
					   md_env    = Env,
					   object_id = &Inter[i] );
		}

		qsort ( Point, nint, 3 * sizeof(IGRdouble), 
						(int (*)())VLsortByYpt);

		for ( i=0; i<nint; i++) {

			pin[*num].idx = (IGRdouble) idx;
			pin[*num].col = (IGRdouble) col;
			pin[*num].lin = (IGRdouble) lin;
			pin[*num].xpt = Point[3*i+0];
			pin[*num].ypt = Point[3*i+1];
			pin[*num].zpt = Point[3*i+2];

			/*c Retrieve index of seam */
			if (i == 0)
				sprintf( elem.name, "%s%d", NAM_BB_BSM, pos1 );
			else	sprintf( elem.name, "%s%d", NAM_BB_TSM, pos2 );
				
			sts = om$send (
				msg = message ACdyn_col.ACget_named_attribute
                                        		( msg, &elem ),
                                senderid = NULL_OBJID,
                                targetid = Attr.objid,
                                targetos = Attr.osnum );
                	as$status ( sts    = sts,
                            	msg    = "ACdyn_col.ACget_named_attribute",
                            	test   = (!(sts & 0x00000001 & (*msg))),
                            	action = GOTO_VALUE,
                            	value  = wrapup );
	
			sprintf ( pin[*num].nam, "%sV%d",
				  elem.desc.value.att_txt, col+1 );
			(*num)++;
		}
	}
	else {	*msg = OM_S_SUCCESS;
		sts  = OM_S_SUCCESS;	}

wrapup:
	if (Point) {	om$dealloc (ptr = Point);	Point = NULL;	}
	if (Inter) {	om$dealloc (ptr = Inter);	Inter = NULL;	}
	return (sts);
}
/* ========================================================================== */
IGRlong VLseamsPoints ( msg, plt, col, idx, Balance, Layout, Env, num, pin)

		IGRlong		*msg;		/*I Completion code	*/
		IGRint		plt;		/*I VSplates number	*/
		IGRint		col;		/*I Column number	*/
		IGRint		idx;		/*I Group index		*/
	struct	GRid		*Balance;	/*I VLbalance macro	*/
	struct	GRid		*Layout;	/*I VLlayout macro	*/
	struct	GRmd_env	*Env;		/*I Current mod env	*/
		IGRint		*num;		/*O Intersection number	*/
	struct	VLpinJig	*pin;		/*O Pin Jig buffer	*/

{
		IGRint		sts=OM_S_SUCCESS, i, j, nfeet=0, cnt=0;
		IGRchar		name[DI_PATH_MAX];

	/*c Retrieve number of feet in VLbalance occurence */
	sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &nfeet),
			senderid = NULL_OBJID,
			targetid = Balance->objid,
			targetos = Balance->osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Loop on projected contours (internal) */
	for ( i=nfeet-plt; i<nfeet; i++) {
		sprintf ( name, "%s%d", NAM_BF_VARF, i - MACRO_B_FFEET);
		cnt = i - nfeet + plt + 1;
		for ( j=0; j<col; j++) {
			sts = VLintersectColumn ( msg, j, cnt, idx, name,
						  Layout, Env, num, pin );
			as$status ( sts    = sts,
		    	    	    msg    = "VLintersectColumn()",
                    	    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = wrapup );
#ifdef TRACE
printf( "cnt=%d, j=%d\tnum=%d\n", cnt, j, *num);
#endif
		}
	}
#ifdef TRACE
for ( i=0; i<*num; i++)
printf( "Pnt %2d, idx=%d, col=%d, lin=%d\t[%g,%g,%g]\n",
	i, pin[i].idx, pin[i].col, pin[i].lin,
	pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif

wrapup:
	return (sts);
}
/* ========================================================================== */
IGRlong	VLbetweenPoints ( msg, nseam, inter, pin, num)

		IGRlong		*msg;		/*I  Completion code	   */
		IGRint		nseam;		/*I  Seam points number	   */
		IGRint		inter;		/*I  Intermediate number   */
	struct	VLpinJig	*pin;		/*IO Pin Jig buffer	   */
		IGRint		*num;		/*O  Between points number */

{
		IGRint		sts=OM_S_SUCCESS, i, j, k;
		IGRdouble	cTol, c1, c2;

	/*c Initialize */
	*num = 0;
	BSxtractpar ( msg, BSTOLCHRDHT, &cTol);
	*msg = OM_S_SUCCESS;

	/*c Reject inter impossible */
	if (inter <= 0)	goto wrapup;

	/*c Loop on seam points */
	for ( i=0; i<nseam; i++) {
		for ( j=0; j<i; j++) {
			if (  (pin[i].idx == pin[j].idx)
			   && (pin[i].col == pin[j].col)
			   && (pin[i].lin == pin[j].lin)
			   && (fabs(pin[i].xpt - pin[j].xpt) <= cTol)
			   && (pin[i].ypt != pin[j].ypt) ) {
#ifdef TRACE
printf( "Between %d and %d : [%g,%g,%g] --> [%g,%g,%g]\n", i, j,
	pin[i].xpt, pin[i].ypt, pin[i].zpt, pin[j].xpt, pin[j].ypt, pin[j].zpt);
#endif
				for ( k=1; k<=inter; k++) {
					pin[nseam + (*num)].idx = (IGRdouble) 3;
					pin[nseam + (*num)].col = pin[i].col;
					pin[nseam + (*num)].lin = pin[i].lin;
					pin[nseam + (*num)].xpt = pin[i].xpt;
					c1 = (IGRdouble)           k/(inter+1);
					c2 = (IGRdouble) (inter+1-k)/(inter+1);
					pin[nseam+(*num)].ypt = (c1*pin[i].ypt)
							      + (c2*pin[j].ypt);
#ifdef TRACE
printf( "i=%d, j=%d, k=%d, c1=%g, c2=%g, ypt1=%g, ypt2=%g, ypt=%g\n",
	i, j, k, c1, c2, pin[i].ypt, pin[j].ypt, pin[nseam + (*num)].ypt );
#endif
					pin[nseam + (*num)].zpt = pin[i].zpt;
					sprintf ( pin[nseam+(*num)].nam,
						  "I%dV%d", (*num) + 1,
						  (IGRint)pin[i].col + 1 );
					(*num)++;
				}
			}
		}
	}

wrapup:
	return (sts);
}
/* ========================================================================== */
IGRlong	VLeliminatePoints ( msg, npin, pin, zone, num)

		IGRlong		*msg;		/*I  Completion code	   */
		IGRint		npin;		/*I  Pin points number	   */
	struct	VLpinJig	*pin;		/*IO Pin Jig buffer	   */
		IGRdouble	zone;		/*I  Interference value	   */
		IGRint		*num;		/*O  Result points number  */

{
		IGRint		sts=OM_S_SUCCESS, i, j, k, l, nval=0;
		IGRdouble	len2, itf2, yval;
		IGRchar		name[80];

	/* Initialize */
	*msg = OM_S_SUCCESS;
	*num = 1;
	pin[0].flg = TRUE;
	itf2 = zone * zone;

	/* Reject inter impossible */
	if (npin <= 1)	goto wrapup;

	/* Geometrical elimination */
	for ( i=1; i<npin; i++) {
		pin[i].flg = TRUE;
		for ( j=0; j<i; j++) {

			len2 = (pin[i].xpt-pin[j].xpt)*(pin[i].xpt-pin[j].xpt)
			     + (pin[i].ypt-pin[j].ypt)*(pin[i].ypt-pin[j].ypt)
			     + (pin[i].zpt-pin[j].zpt)*(pin[i].zpt-pin[j].zpt);

			if (len2 <= itf2) {
#ifdef TRACE
printf( "Pnt %2d:[%g,%g] elim from Pnt %2d:[%g,%g]\td=%g\n",
	i, pin[i].xpt, pin[i].ypt, j, pin[j].xpt, pin[j].ypt, sqrt(len2) );
#endif
				pin[i].flg = FALSE;
				j = i;
			}
		}
		if (pin[i].flg)	(*num)++;
	}

/* Looks like this logical elimination is not wirking. It is eliminating the 
seam points which should have been there. Commented for TR#179801493 */

#if 0
	/* Logical elimination of "seam" points */
	for ( i=1; i<npin; i++) {
		if (pin[i].flg) {
			for ( j=0; j<i; j++) {
			if (  (pin[j].flg)
			   && (pin[i].idx == 2)
			   && (pin[j].idx == pin[i].idx)
			   && (pin[j].col == pin[i].col)
			   && (!strcmp(pin[i].nam,pin[j].nam)) ) {
#ifdef TRACE
printf( "Pnt %2d:(%d|%d):[%g,%g] logic equal to Pnt %2d:(%d|%d):[%g,%g]\n",
	i, pin[i].lin, pin[i].col, pin[i].xpt, pin[i].ypt,
	j, pin[j].lin, pin[j].col, pin[j].xpt, pin[j].ypt );
#endif

				/* Extract seam name */
				strcpy ( name, pin[i].nam);
				l = strlen(name);
				for ( k=0; k<l; k++) {
					if ( (name[k] >= '0')
					&&   (name[k] <= '9') ) {
						nval = k;
						k = l;
					}
				}
				for ( k=nval; k<l; k++) {
					if (name[k] == 'V')	break;
				}
				name[k] = '\0';
				l = strlen(name);

				/* Loop on seam points */
				yval = 0.0;
				nval = 0;
				for ( k=0; k<npin; k++) {
					if (  (k != i)
					   && (k != j)
					   && (pin[k].flg)
					   && (pin[k].idx == pin[i].idx)
					   && (!strncmp( pin[k].nam, name, l)) )
					{
						yval += pin[k].ypt;
						nval++;
					}
				}
#ifdef TRACE
printf( "Average <%s> : nval=%d, yval=%g\n", name, nval, yval);
#endif

				if 	((!nval) || (yval == 0.0))
					pin[i].flg = FALSE;
				else {	yval /= nval;
					if ( fabs(pin[i].ypt-yval)
					<=   fabs(pin[j].ypt-yval) )
						pin[j].flg = FALSE;
					else	pin[i].flg = FALSE;
				}
				(*num)--;
#ifdef TRACE
printf( "Pnt %d : flag=%d\tPnt %d : flag=%d\n\n", i, pin[i].flg, j, pin[j].flg);
#endif
			}
			}
		}
	}
#endif

	/* Sort pin jigs by columns and y values */
	qsort ( pin, npin, sizeof(struct VLpinJig), (int (*)())VLsortPJcolYpt);

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLgetVSplatePrjPoint
(
		IGRlong		*msg,
	struct	GRobj_env	*Plate,
		IGRchar		*name,
		IGRpoint	Point,
		IGRvector	Axis,
		IGRpoint	*Proj
)
{
		IGRlong		sts=OM_S_SUCCESS;
	struct	GRobj_env	Surf;
	struct	IGRbsp_surface	*srf, *esf;
		IGRdouble	*upar, *vpar;
		IGRpoint	*pnt;
		IGRlong		npt;
		BSrc		rc;
		IGRdouble	tol=0.0;

	/* Initialize */
	upar	= NULL;
	vpar	= NULL;
	pnt	= NULL;
	srf	= NULL;
	esf	= NULL;

	/* Extract VSplate surface */
	sts = VLextractVSplateSurface ( msg, &Plate->obj_id, &Plate->mod_env,
					name, &Surf.obj_id, &Surf.mod_env,
					&srf );
	as$status ( sts    = sts,
    	    	    msg    = "VLextractVSplateSurface()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Project point on surface */
	BSpj_pt_sf ( srf, Point, Axis, &npt, &pnt, &upar, &vpar, &rc );
#ifdef TRACE
printf( "BSpj_pt_sf(REGULAR) returns npt=%d\n", npt );
#endif
	if ( (rc == BSSUCC) && (npt > 0) )
	{
		BSsfeval ( srf, upar[0], vpar[0], 1, Proj,  &rc);
#ifdef TRACE
	printf(" Projected point %g,%g,%g\n",*Proj,*(Proj+1),*(Proj+2));
#endif
	}

	/* If someting's wrong */
	if ( (rc != BSSUCC) || (npt <= 0) )
	{
		// Extract CHT tolerance 
		BSxtractpar ( &rc, BSTOLCHRDHT,  &tol);

		// Extend surface 
		sts = extent_surface_geom ( srf, 30.0, &esf );
		as$status ( sts    = sts,
			    msg    = "extent_surface_geom()",
		            test   = (!(sts & 0x00000001)),
		            action = GOTO_VALUE,
		            value  = wrapup );

		// Project point on extended surface 
		BSpj_pt_sf ( esf, Point, Axis, &npt, &pnt, &upar, &vpar, &rc );
#ifdef TRACE
printf( "BSpj_pt_sf(EXTENDED) returns npt=%d\n", npt );
#endif
		if ( (rc == BSSUCC) && (npt > 0) )
		    BSsfeval ( esf, upar[0], vpar[0], 1, Proj,  &rc);

	/* Below code by Jayadev and Anand for TR 179900772 */
		if ( (rc != BSSUCC) || (npt <= 0) )
		{
#ifdef TRACE
		    printf(" Point not projected on plate\n");
#endif
	/* This is the fix for TR179900772. It is essential that the calling
	 * function knows that project point on surface failed. */
		    *msg = MSFAIL;
		    sts = OM_E_ERROR;
		    goto wrapup;
		}
	/* Above code by Jayadev and Anand for TR 179900772 */

#ifdef TRACE
printf( "Proj(0) : [%g,%g,%g]\n", Proj[0][0], Proj[0][1], Proj[0][2] );
printf( "Proj(1) : [%g,%g,%g]\n", Proj[1][0], Proj[1][1], Proj[1][2] );
printf( "Proj(2) : [%g,%g,%g]\n", Proj[2][0], Proj[2][1], Proj[2][2] );
printf( "Proj(3) : [%g,%g,%g]\n", Proj[3][0], Proj[3][1], Proj[3][2] );
#endif
	}

wrapup:
	if (vpar) {	om$dealloc (ptr = vpar);	vpar  = NULL;	}
	if (upar) {	om$dealloc (ptr = upar);	upar  = NULL;	}
	if (pnt) {	om$dealloc (ptr = pnt);		pnt   = NULL;	}
	if (srf) {	om$dealloc (ptr = srf);		srf   = NULL;	}
	if (esf) {	om$dealloc (ptr = esf);		esf   = NULL;	}
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong	VLpinHeightAngle ( msg, Balance, Env, nmax, pin)

		IGRlong		*msg;		/*I  Completion code	*/
		IGRint		nmax;		/*I  Pin points number	*/
	struct	VLpinJig	*pin;		/*IO Pin Jig buffer	*/
	struct	GRid		*Balance;	/*I VLbalance macro	*/
	struct	GRmd_env	*Env;		/*I Current mod env	*/

{

		IGRint		sts=OM_S_SUCCESS, nplat=0, nfeet=0, idx=0;
	struct	GRobj_env	foot, *plate;
		IGRdouble	value;
		IGRint		i, j, k;
		IGRchar		name[MAX_CHA_TEMP];
		IGRpoint	Pnt, Pt1[4], Pt2[4];
		IGRvector	Xv, Zv, Av;
		BSrc		rc;

	/* Initialize */
	plate = NULL;

	/* Retrieve balanced VSplates' number */
	sts = vl$return_foot ( msg     = msg,
			       name    = NAM_BF_NPLT,
                               objId   = Balance,
                               footId  = &foot.obj_id );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(NPLT)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = om$send ( msg = message expression.NDgive_value (&value),
			senderid = NULL_OBJID,
			targetid = foot.obj_id.objid,
			targetos = foot.obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "expression.NDgive_value",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	nplat = (IGRint) value;

	/*c Allocate memory for VSplates array */
	plate = om$calloc ( num	      = nplat,
			    structure = struct GRobj_env );
	if (!plate) {	printf( "Unable to allocate %d bytes\n",
				nplat * sizeof(struct GRobj_env) );
			*msg = MSFAIL; goto wrapup;	}

	/*c Retrieve the number of feet of the <VLbalance> macro */
	sts = om$send ( msg = message GRowner.GRget_number_components
						( msg, &nfeet),
			senderid = NULL_OBJID,
			targetid = Balance->objid,
			targetos = Balance->osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/*c Get the balanced VSplates */
	for ( i=MACRO_B_FFEET; i<nfeet; i++) {
		sprintf ( name, "%s%d", NAM_BF_VARF, i-MACRO_B_FFEET);
		sts = vl$return_foot ( msg     = msg,
				       name    = name,
	                               objId   = Balance,
	                               objEnv  = Env,
	                               footId  = &foot.obj_id,
	                               footEnv = &foot.mod_env );
	        as$status ( sts    = sts,
	                    msg    = "vl$return_foot(VARF)",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		if (vs$is_ancestry_valid (object  = &foot.obj_id,
					  classid = OPP_VSfrzPlate_class_id) ) {
			plate[idx] = foot;
			idx++;
		}
	}

	/*c Verify that what we get is what we want */
	if (idx != nplat) { 	printf( "We expect %d VSplates and we get %d\n",
					nplat, idx );
				*msg = MSFAIL; 	goto wrapup;	}

	/*c Evaluate height of pins */
	for ( i=0; i<nmax; i++) {
		if (pin[i].flg) {
#ifdef TRACE
printf( "PIN %2d : [%g,%g,%g]\n", i, pin[i].xpt, pin[i].ypt, pin[i].zpt );
#endif
		for ( j=0; j<nplat; j++) {

			/* Get projected point on bottom VSplate */
			Pnt[0] = pin[i].xpt;
			Pnt[1] = pin[i].ypt;
			Pnt[2] = pin[i].zpt;
			Zv[0] = 0.0; Zv[1] = 0.0; Zv[2] = 1.0;
			sts = VLgetVSplatePrjPoint ( msg,
						     &plate[j],
						     VS_K_plBotSfPath,
						     Pnt,
						     Zv,
						     Pt1 );
			as$status ( sts    = sts,
		    	    	    msg    = "VLgetVSplatePrjPoint()",
                    	    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = skip );

			/* Get projected point on top VSplate */
			Pnt[0] = pin[i].xpt;
			Pnt[1] = pin[i].ypt;
			Pnt[2] = pin[i].zpt;
			Zv[0] = 0.0; Zv[1] = 0.0; Zv[2] = 1.0;
			sts = VLgetVSplatePrjPoint ( msg,
						     &plate[j],
						     VS_K_plTopSfPath,
						     Pnt,
						     Zv,
						     Pt2 );
			as$status ( sts    = sts,
		    	    	    msg    = "VLgetVSplatePrjPoint()",
                    	    	    test   = (!(sts & 0x00000001 & (*msg))),
                    	    	    action = GOTO_VALUE,
                    	    	    value  = skip );
#ifdef TRACE
printf(" Bottom Surface\n");
printf( "Pt1(0) : [%g,%g,%g]\n", Pt1[0][0], Pt1[0][1], Pt1[0][2] );
printf( "Pt1(1) : [%g,%g,%g]\n", Pt1[1][0], Pt1[1][1], Pt1[1][2] );
printf( "Pt1(2) : [%g,%g,%g]\n", Pt1[2][0], Pt1[2][1], Pt1[2][2] );
printf( "Pt1(3) : [%g,%g,%g]\n", Pt1[3][0], Pt1[3][1], Pt1[3][2] );

printf(" Top Surface\n");
printf( "Pt2(0) : [%g,%g,%g]\n", Pt2[0][0], Pt2[0][1], Pt2[0][2] );
printf( "Pt2(1) : [%g,%g,%g]\n", Pt2[1][0], Pt2[1][1], Pt2[1][2] );
printf( "Pt2(2) : [%g,%g,%g]\n", Pt2[2][0], Pt2[2][1], Pt2[2][2] );
printf( "Pt2(3) : [%g,%g,%g]\n", Pt2[3][0], Pt2[3][1], Pt2[3][2] );
#endif

			/*c Build local normal to surface */

		/* For pin height calculation, take the lesser of the two
		 * heights, ie, take Pt2 if the below condition is true and
		 * vice-versa.  	Jayadev and Anand for TR 179900772 */
			if (Pt1[0][2] >= Pt2[0][2])
			{
			    pin[i].hei = fabs( Pt2[0][2] - pin[i].zpt );
			    BScrossp ( &rc, Pt1[1], Pt1[2], Av);
			}
			else
			{
			    pin[i].hei = fabs( Pt1[0][2] - pin[i].zpt );
			    BScrossp ( &rc, Pt2[1], Pt2[2], Av);
			}

			/*c Project normal to surface in YZ plane */
			Av[0] = 0.0;
			BSnorvec ( &rc, Av);

			/*c Reorient projected normal */
			Zv[0] = 0.0; Zv[1] = 0.0; Zv[2] = 1.0;
			if (BSdotp( &rc, Av, Zv) < 0.0)
				for ( k=0; k<3; k++)	Av[k] *= -1.0;

			/*c Compute angle */
			Zv[0] = 0.0; Zv[1] = 0.0; Zv[2] = 1.0;
			BScrossp ( &rc, Av, Zv, Xv);
			value = VLatan2( Xv[0], BSdotp( &rc, Av, Zv) );
			pin[i].ang = (M_PI/2.0) - value;
#ifdef TRACE
printf( "Pin %2d with Plate %d : Height = %g\tAngle = %g\n",
	i, j, pin[i].hei, pin[i].ang / M_PI * 180.0); 
#endif

			j = nplat;
skip:
			;
		}
		}
	}
		
wrapup:
	if (plate) {	om$dealloc (ptr = plate);	plate = NULL;	}
	return (sts);
}
/* ========================================================================== */
IGRint VLsortPJcolYpt ( a, b)

	struct	VLpinJig	*a, *b;

{
	if (a->col == b->col)
		return ((a->ypt == b->ypt) ? 0 : (a->ypt < b->ypt) ? -1 : 1);
	else	return ((a->col == b->col) ? 0 : (a->col < b->col) ? -1 : 1);
}
/* ========================================================================== */
IGRlong	VLgetPinAttributes ( 		IGRlong		*msg,
				struct	GRid		*PinJig,
					IGRint		idx,
				struct	ACrg_coll	*elem	)
{
	IGRint		sts;

	/* Get attributes collection of pinjig number idx */
	sts = om$send ( msg = message VLpinjig.VLget_attributes
				( msg, &idx, NULL, TRUE, elem, NULL ),
			senderid = NULL_OBJID,
			targetid = PinJig->objid,
			targetos = PinJig->osnum );
	as$status ( sts    = sts,
	   	    msg    = "VLpinjig.VLget_attributes",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
}
/* ========================================================================== */

/* ========================================================================== */
void	VLnamePJcollection (	struct	ACrg_coll	*attr,
					IGRint		*idx	)
{

	/* Set attributes names */
	if (!idx) {
		strcpy ( attr[IDX_PB_COL].name, NAM_PB_COL);
		strcpy ( attr[IDX_PB_LIN].name, NAM_PB_LIN);
		strcpy ( attr[IDX_PB_XPT].name, NAM_PB_XPT);
		strcpy ( attr[IDX_PB_YPT].name, NAM_PB_YPT);
		strcpy ( attr[IDX_PB_ZPT].name, NAM_PB_ZPT);
		strcpy ( attr[IDX_PB_HEI].name, NAM_PB_HEI);
		strcpy ( attr[IDX_PB_ANG].name, NAM_PB_ANG);
		strcpy ( attr[IDX_PB_IDX].name, NAM_PB_IDX);
		strcpy ( attr[IDX_PB_NAM].name, NAM_PB_NAM);
	}
	else {	sprintf( attr[IDX_PB_COL].name, "%s%d", NAM_PB_COL, *idx);
		sprintf( attr[IDX_PB_LIN].name, "%s%d", NAM_PB_LIN, *idx);
		sprintf( attr[IDX_PB_XPT].name, "%s%d", NAM_PB_XPT, *idx);
		sprintf( attr[IDX_PB_YPT].name, "%s%d", NAM_PB_YPT, *idx);
		sprintf( attr[IDX_PB_ZPT].name, "%s%d", NAM_PB_ZPT, *idx);
		sprintf( attr[IDX_PB_HEI].name, "%s%d", NAM_PB_HEI, *idx);
		sprintf( attr[IDX_PB_ANG].name, "%s%d", NAM_PB_ANG, *idx);
		sprintf( attr[IDX_PB_IDX].name, "%s%d", NAM_PB_IDX, *idx);
		sprintf( attr[IDX_PB_NAM].name, "%s%d", NAM_PB_NAM, *idx);
	}

	/* Set attributes types */
	attr[IDX_PB_COL].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_LIN].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_XPT].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_YPT].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_ZPT].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_HEI].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_ANG].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_IDX].desc.type = AC_ATTRIB_DOUBLE;
	attr[IDX_PB_NAM].desc.type = AC_ATTRIB_TEXT;
}
/* ========================================================================== */

/* ========================================================================== */
void	VLfillPJcollection (	struct	ACrg_coll	*elem,
				struct	ACrg_coll	*attr	)
{
attr[IDX_PB_COL].desc.value.att_exp = elem[IDX_PB_COL].desc.value.att_exp;
attr[IDX_PB_LIN].desc.value.att_exp = elem[IDX_PB_LIN].desc.value.att_exp;
attr[IDX_PB_XPT].desc.value.att_exp = elem[IDX_PB_XPT].desc.value.att_exp;
attr[IDX_PB_YPT].desc.value.att_exp = elem[IDX_PB_YPT].desc.value.att_exp;
attr[IDX_PB_ZPT].desc.value.att_exp = elem[IDX_PB_ZPT].desc.value.att_exp;
attr[IDX_PB_HEI].desc.value.att_exp = elem[IDX_PB_HEI].desc.value.att_exp;
attr[IDX_PB_ANG].desc.value.att_exp = elem[IDX_PB_ANG].desc.value.att_exp;
attr[IDX_PB_IDX].desc.value.att_exp = elem[IDX_PB_IDX].desc.value.att_exp;
	strcpy( attr[IDX_PB_NAM].desc.value.att_txt,
		elem[IDX_PB_NAM].desc.value.att_txt);
#ifdef TRACE
printf( "<%s>, [ %g, %g, %g ], hei=%g, ang=%g\n",
	attr[IDX_PB_NAM].desc.value.att_txt,
	attr[IDX_PB_XPT].desc.value.att_exp,
	attr[IDX_PB_YPT].desc.value.att_exp,
	attr[IDX_PB_ZPT].desc.value.att_exp,
	attr[IDX_PB_HEI].desc.value.att_exp,
	attr[IDX_PB_ANG].desc.value.att_exp );
#endif
}
/* ========================================================================== */

end implementation VLabstract;
