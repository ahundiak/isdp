/* $Id: VLtemplFunk.I,v 1.1.1.1 2001/01/04 21:11:38 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/template/VLtemplFunk.I
 *
 * Description: Contains a set of functions used to compute general operations
 *		in the plates' templates construction workflow.	
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLtemplFunk.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:38  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/02/18  13:16:56  pinnacle
# mf
#
# Revision 1.2  2000/02/15  15:48:32  pinnacle
# template_obj.u have now variable number of feet
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.5  1998/04/17  10:41:20  pinnacle
# Replaced: src/template/VLtemplFunk.I for:  by smpathak for loft
#
# Revision 1.4  1998/02/26  09:49:56  pinnacle
# Replaced: src/template/VLtemplFunk.I for:  by smpathak for loft
#
# Revision 1.3  1998/02/05  20:38:56  pinnacle
# Replaced: src/template/VLtemplFunk.I for:  by rchennup for loft
#
# Revision 1.2  1998/01/02  05:56:32  pinnacle
# Replaced: src/template/VLtemplFunk.I for:  by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      01/02/98   Rama Rao     Header Creation and Fix for TR#179702404
 *      02/26/98   S.M.Pathak   modified for TR#179800492
 *      04/17/98   S.M.Pathak   modified for TR#179800990
 *************************************************************************/

class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"OMprimitives.h"
#include	"OMindex.h"
#include	"AS_status.h"
#include	"godef.h"
#include	"grmacros.h"
#include	"grdpbdef.h"
#include	"grdpbmacros.h"
#include	"grdpb.h"
#include	"gotextdef.h"
#include	"csdef.h"
#include	"values.h"
#include	"macro.h"
#include	"maerr.h"
#include	"bs.h"
#include	"bsparameters.h"
#include	"msdef.h"
#include	"EMSmsgdef.h"
#include	"EMSssprops.h"
#include	"EMSdpb.h"
#include	"dpezmac.h"
#include	"asmacros.h"
#include	"DIdef.h"
#include	"bsvalues.h"
#include	"math.h"
#include	"cotxmacros.h"

#include	"vsplatedef.h"
#include        "vsedgedef.h"
#include        "vsedgemacros.h"
#include        "vsmiscmacros.h"

#include	"vlplatejig.h"
#include        "vlgrdef.h"
#include        "vlgrmacros.h"
#include        "vlmiscmacros.h"
#include        "vlrolline.h"

#include	"bscrossp.h"
#include	"bscveval.h"
#include	"bsdotp.h"
#include	"bsfreesf.h"
#include	"bslenvec.h"
#include	"bsnorvec.h"
#include	"bspj_pt_sf.h"
#include	"bspolyxtdst.h"
#include	"bspolyxttpt.h"
#include	"bsproj1.h"
#include	"bspt_in_plg.h"
#include	"bsrgbxplint.h"
#include	"bssfarrevn.h"
#include	"bssfeval.h"
#include	"bstst_plan.h"
#include	"bsxtractpar.h"

#include	"mamulmx.h"

extern	void		BuildCrv(), OrderCrv();
extern	void		dblcpy();

extern	IGRchar		*strrchr();
extern	IGRint		strcmp();
extern	void		qsort();
extern 	IGRdouble 	BSdistptpt();

extern	GRclassid	OPP_ACheader_class_id;
extern	GRclassid	OPP_EMSplane_class_id;
extern	GRclassid	OPP_GR3dlineseg_class_id;
extern	GRclassid	OPP_GR3dlinestr_class_id;
extern	GRclassid	OPP_GR3dorthpoly_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;
extern	GRclassid	OPP_GRbspline_class_id;
extern	GRclassid	OPP_GRcompcurve_class_id;
extern	GRclassid	OPP_GRgencs_class_id;

from	EMSsubbs	import	EMisoparcvs, EMget_props;
from	EMSplane	import	EMplane;
from	GRbspline	import	GRptextend;
from	GRcurve		import	GRtotlength;
from	GRgencs		import	GRgetmatrix;
from	GRlinear	import	GRgetpolyline;
from	expression	import	NDgive_value;

/*	#define	TRACE	*/
/*	#define	TRACE_MEMORY	*/

/* ========================================================================== */
IGRint VLsortName ( a, b)

	struct	VLsortTpl	*a, *b;

{
	return ( strcmp ( a->name, b->name) );
}
/* ========================================================================== */
IGRint VLsortRang ( a, b)

	struct	VLsortTpl	*a, *b;

{
	return ((a->y == b->y) ? 0 : (a->y > b->y) ? -1 : 1);
}
/* ========================================================================== */
void VLsort3dTemplates ( array, number)

	struct  VLsortTpl	*array;
		IGRint		number;

{
	struct	VLsortTpl	*tmp;
		IGRint		siz=sizeof(struct VLsortTpl);
		IGRint		num=0;
		IGRint		i, j;

#ifdef	TRACE
printf( "\n\t\t\tSORT STEP 0, number=%d\n", number);
for ( i=0; i<number; i++)
	printf( "sort 0 : <%s> element %d\tXrng=%g\tYrng=%g\n",
		array[i].name, array[i].idx, array[i].x, array[i].y);
#endif
	
	/* Initialize */
	tmp = NULL;
#ifdef TRACE_MEMORY
printf( "tmp = om$calloc(%d,<struct VLsortTpl>)\n", number);
#endif
	tmp = om$calloc ( num = number, structure = struct VLsortTpl);

	/* First sort by name */
	qsort ( array, number, siz, (int (*)())VLsortName);

#ifdef	TRACE
printf( "\n\t\t\tSORT STEP 1, number=%d\n", number);
for ( i=0; i<number; i++)
	printf( "sort 1 : <%s> element %d\tXrng=%g\tYrng=%g\n",
		array[i].name, array[i].idx, array[i].x, array[i].y);
#endif

	/* Second sort by Y range */
	for ( i=0; i<number; i++) {
		if (strcmp ( array[num].name, array[i].name) != 0) {
			for ( j=num; j<i; j++) tmp[j-num] = array[j];
			qsort ( tmp, i-num, siz, (int (*)())VLsortRang);
			for ( j=num; j<i; j++) array[j] = tmp[j-num];
			num = i;
		}
	}

#ifdef	TRACE
printf( "\n\t\t\tSORT STEP 2, number=%d\n", number);
for ( i=0; i<number; i++)
	printf( "sort 2 : <%s> element %d\tXrng=%g\tYrng=%g\n",
		array[i].name, array[i].idx, array[i].x, array[i].y);
#endif

	for ( j=num; j<number; j++) { tmp[j-num] = array[j]; }
	qsort ( tmp, number-num, siz, (int (*)())VLsortRang);
	for ( j=num; j<number; j++) { array[j] = tmp[j-num]; }

#ifdef	TRACE
printf( "\n\t\t\tSORT STEP 3, number=%d\n", number);
for ( i=0; i<number; i++)
	printf( "sort 3 : <%s> element %d\tXrng=%g\tYrng=%g\n",
		array[i].name, array[i].idx, array[i].x, array[i].y);
#endif

	if (tmp) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = tmp)\n");
#endif
		om$dealloc (ptr = tmp);
		tmp = NULL;
	}
}
/* ========================================================================== */
IGRboolean VLpltPlaInterference ( Plate, Plane, Env, msg)

/*d This function checks the interference between the range box of a plate and
    an infinite plane. It returns TRUE if there is an interference and FALSE
    elsewhere. */

/*h 28/09/92 : creation by Marc FOURNIER (ISDC). */

	struct	GRid		*Plate;		/*I Struct plate support*/
	struct	GRid		*Plane;		/*I Ems plane		*/
	struct	GRmd_env	*Env;		/*I Current module env	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRboolean	rc=TRUE;
		IGRint		sts;
		IGRboolean	world;
		GRrange		range;
	struct	IGRplane	plane;
		IGRpoint	point;
		IGRvector	normal;
		IGRint		npts=0;
		IGRpoint	int_pts[6];
		BSrc		bsrc;

	/* Get plate range */
	world = TRUE;
	sts = om$send ( msg      = message GRgraphics.GRgetrang (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&world,
					range ),
			senderid = NULL_OBJID,
			targetid = Plate->objid,
			targetos = Plate->osnum );
	if (!((*msg)&1&sts)) 	rc = FALSE;
	as$status ( sts    = sts,
		    msg    = "GRgraphics.GRgetrang",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
/*
printf( "Plate range : (%g|%g|%g) --> (%g|%g|%g) with world=%d\n",
	range[0], range[1], range[2], range[3], range[4], range[5], world);
*/

	/* Get plane normal & point */
	plane.point  = point;
	plane.normal = normal;
	sts = om$send ( msg      = message GRvg.GRdetplane (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&plane ),
			senderid = NULL_OBJID,
			targetid = Plane->objid,
			targetos = Plane->osnum );
	if (!((*msg)&1&sts)) 	rc = FALSE;
	as$status ( sts    = sts,
		    msg    = "GRvg.GRdetplane",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Check plate box & plane interference */
	BSrgbxplint ( &range[0], &range[3], plane.point, plane.normal, 1.0,
		      &npts, int_pts, &bsrc);
	if ( (bsrc != BSSUCC) || (npts == 0) ) { rc = FALSE; goto wrapup; }

wrapup:
	return (rc);
/* End of function */
}
/* ========================================================================== */
IGRboolean VLverifyIntersect ( plate, plane, Env, msg)

/*d This function verify if a STRUCT plate and a plane intersection is empty
    or not. If intersection isn't empty the function returns TRUE, else FALSE.
    The function retrieve the names of the elements and build a name for the
    intersection : this will be the name of resulting template. */

/*h 27/09/92 : creation by Marc FOURNIER (ISDC). */

	struct	GRobj_env	*plate;		/*I Struct plate	*/
	struct	GRobj_env	*plane;		/*I Ems plane		*/
	struct	GRmd_env	*Env;		/*I Current module env	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRboolean	rc=TRUE;
		IGRint		sts;
	struct	GRobj_env	support;

	/* Retrieve plate support surface ID */
	sts = VLextractVSplateSurface ( msg,
					&plate->obj_id,
					&plate->mod_env,
					VS_K_plBotSfPath,
			       		&support.obj_id,
				        &support.mod_env,
				        (struct IGRbsp_surface **) NULL );
	as$status ( sts    = sts,
		    msg    = "VLextractVSplateSurface()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Check intersection between plate and plate */
	rc = VLpltPlaInterference ( &support.obj_id, &plane->obj_id, Env, msg);
	if (!((*msg)&1)) 	rc = FALSE;
	as$status ( sts    = *msg,
		    msg    = "VLpltPlaInterference()",
               	    test   = (!(0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

wrapup:
	return (rc);
/* End of function */
}
/* ========================================================================== */
IGRlong VLcreateName ( msg, nplate, Iplate, Iplane, Env, code, name)

/*d This function creates the name associated to the template or a template_jig
    from STRUCT plate name(s) and EMS plane name. */

/*h 29/09/92 : creation by Marc FOURNIER (ISDC).
    22/09/93 : modified by Marc FOURNIER (ISDC).
*/

		IGRlong		*msg;		/*O Completion code	*/
		IGRint		nplate;		/*I Plates' number	*/
	struct	GRid		Iplate[];	/*I Struct plate(s)	*/
	struct	GRid		Iplane[];	/*I Ems plane(s)	*/
	struct	GRmd_env	*Env;		/*I Current module env	*/
		IGRchar		code[];		/*I Templates or Jigs ?	*/
		IGRchar		name[];		/*O template name	*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	GRid		plane;
	struct	GRid		plate;
		IGRchar		plate_name[DI_PATH_MAX];
		IGRchar		plane_name[DI_PATH_MAX];
		IGRchar		tmp[DI_PATH_MAX];
	struct	VLsortTpl	*plt;
		IGRint		i, inter;

	/* Initialize */
	plt     = (struct VLsortTpl *)NULL;
	name[0] = plate_name[0] = plane_name[0] = '\0';
	inter   = 0;

	/* Verification */
	if ((strcmp ( code, P_JIGS_NAME)) && nplate != 1) {
		printf( "Cannot create a name for a <%s> with %d VSplates\n",
			code, nplate);
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Allocate memory */
#ifdef TRACE_MEMORY
printf( "plt = om$calloc(%d,<struct VLsortTpl>)\n", nplate);
#endif
	plt = om$calloc ( num = nplate, structure = struct VLsortTpl);


	/* Retrieve plane ID thru pretend (if any) */
	sts = vl$return_foot ( msg    = msg,
			       objId  = Iplane,
			       footId = &plane );
	if (!((*msg)&1&sts)) 	plane = *Iplane;

	/* Retrieve plane name in the SMAN frame system */
	om$send ( msg      = message GRvg.GRgetname ( msg, plane_name),
		  senderid = NULL_OBJID,
		  targetid = plane.objid,
		  targetos = plane.osnum );
	if (!((*msg)&1)) strcpy ( plane_name, "Unknown");
	else 		 strcpy ( plane_name, &strrchr(plane_name,':')[1]);
	if (plane_name[0] == '\0') strcpy ( plane_name, "Empty");

	/* Retrieve plate(s) ID thru pretend (if any) */
	for ( i=0; i<nplate; i++) {
		sts = vl$return_foot ( msg    = msg,
				       objId  = &Iplate[i],
				       footId = &plate );
		as$status ( sts    = sts,
			    msg    = "vl$return_foot",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		if (VLpltPlaInterference ( &plate, &plane, Env, msg)) {
			/* Retrieve plate(s) name in the EMS directories */
			om$send ( msg      = message GRvg.GRgetname ( msg, tmp),
				  senderid = NULL_OBJID,
				  targetid = plate.objid,
				  targetos = plate.osnum );
			if (!((*msg)&1))
				strcpy ( plt[inter].name, "Unknown");
			else 	strcpy ( plt[inter].name,
					 &strrchr(tmp,':')[1]);
			if (plt[inter].name[0] == '\0')
				strcpy ( plt[inter].name, "Empty");
			inter++;
		}
	}

	qsort ( plt, inter, sizeof(struct VLsortTpl), (int (*)())VLsortName);
	for ( i=0; i<inter; i++)  {
		strcat ( plate_name, plt[i].name);
		strcat ( plate_name, "-");
	}
	plate_name[strlen(plate_name)-1] = '\0';

	/* Create Template/Jig name object */
	if (strcmp ( code, P_JIGS_NAME))
		sprintf ( name, "%s_%s", plate_name, plane_name);
	else	sprintf ( name, "%s_%s", plane_name, plate_name);

wrapup:
	if (plt) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = plt)\n");
#endif
		om$dealloc (ptr = plt);
		plt = NULL;
	}
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLextendCurve ( msg, Curve, Env, d, b, ext1, ext2, Pt1, Pt2)

/*d This function extends a curve at endpoints. If Pt1 (or Pt2) isn't set to
    NULL the corresponding welding point is constructed and returned. */

/*h 03/11/92 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	/*O  Completion code		*/
	struct	GRid		*Curve;	/*IO Ems curve			*/
	struct	GRmd_env	*Env;	/*I  Current module env		*/
		IGRdouble       d;      /*I  Distance tolerance         */
                IGRdouble       b;      /*I  Basic tolerance            */
		IGRdouble	ext1;   /*I  Extension at start point	*/
		IGRdouble	ext2;   /*I  Extension at end point	*/
	struct	GRid		*Pt1;	/*O  Welding point 1		*/
	struct	GRid		*Pt2;	/*O  Welding point 2		*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRpoint	spt, ept;
	struct	GRvg_construct	cst;
	struct	IGRpolyline	geom;
		IGRint		i;
		IGRlong		size=-1;
	struct	IGRbsp_curve	*cv;
		BSrc		rc;
		IGRdouble	xpt[6];
		IGRvector	dir, vec;
		IGRdouble	sign;
	struct	GRparms		parm;
		IGRpoint	deriv[2];
	struct	GRobj_env	Icv[3], Ocv[3];
		IGRshort	inv[3];
		IGRboolean	adj, clo;
	struct	GRlc_info	entries[3];
#ifdef TRACE
		IGRchar		name[DI_PATH_MAX];
#endif
	
	/* Initialize */
	VLinitCnst (&cst);
	cst.geometry   = (IGRchar *) &geom;
	cv             = NULL;
	Icv[0].obj_id  = *Curve;
	Icv[0].mod_env = *Env;

	/* Get input curve size */
#ifdef TRACE
om$get_classname ( osnum     = Curve->osnum,
		   objid     = Curve->objid,
		   classname = name );
printf( "Curve (%d|%d) is a <%s>\n", Curve->osnum, Curve->objid, name);
#endif
	sts = om$send ( msg      = message GRvg.GRgetsize (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&size ),
			senderid = NULL_OBJID,
			targetid = Curve->objid,
			targetos = Curve->osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetsize",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Allocate memory for input curve geometry */
#ifdef TRACE_MEMORY
printf( "cv = om$calloc(%d)\n", size);
#endif
	cv = (struct IGRbsp_curve *) om$calloc (size = size);

	/* Get input curve geometry */
	sts = om$send ( msg      = message GRvg.GRgetgeom (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					(IGRchar *) cv ),
			senderid = NULL_OBJID,
			targetid = Curve->objid,
			targetos = Curve->osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetgeom",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Retrieve curve's end points */
	BScveval ( cv, 0.0, 0, (IGRpoint *)spt, &rc);
	if (rc != BSSUCC) { printf( "Error in BScveval(0.0)\n");
			    *msg = MSFAIL; goto wrapup; }
	BScveval ( cv, 1.0, 0, (IGRpoint *)ept, &rc);
	if (rc != BSSUCC) { printf( "Error in BScveval(1.0)\n");
			    *msg = MSFAIL; goto wrapup; }

	if (Pt1) {
		/* Construct first welding point */
		geom.num_points = (IGRlong)     1;
		geom.points = (IGRdouble *) spt;
		Pt1->objid = NULL_OBJID;
		Pt1->osnum = Env->md_id.osnum;
		sts = om$construct ( classid = OPP_GR3dpoint_class_id,
			     	     osnum   = Pt1->osnum,
			     	     p_objid = &Pt1->objid,
			     	     msg     = message
					       GRgraphics.GRaltconstruct(&cst));
		as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	}
	
	if (Pt2) {
		/* Construct second welding point */
		geom.num_points = (IGRlong)     1;
		geom.points = (IGRdouble *) ept;
		Pt2->objid = NULL_OBJID;
		Pt2->osnum = Env->md_id.osnum;
		sts = om$construct ( classid = OPP_GR3dpoint_class_id,
			     	     osnum   = Pt2->osnum,
			     	     p_objid = &Pt2->objid,
			     	     msg     = message
					       GRgraphics.GRaltconstruct(&cst));
		as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	}

	/* Build direction vector */
	for ( i=0; i<3; i++)	dir[i] = ept[i] - spt[i];
	BSnorvec ( &rc, dir);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n");
			    *msg = MSFAIL; goto wrapup; }

	/* Retrieve start side parameter */
	parm.u = parm.v = -1.0;
	sts = om$send ( msg          = message GRbspline.GRptproject (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                spt,
                                                &xpt[0],
                                                &parm),
                        senderid = NULL_OBJID,
                        targetid = Curve->objid,
                        targetos = Curve->osnum );
	as$status ( sts    = sts,
		    msg    = "GRbspline.GRptproject",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Evaluate start side derivatives */
	BScveval ( cv, parm.u, 1, deriv, &rc);
	if (rc != BSSUCC) { printf( "Error in BScveval(%g)\n", parm.u);
			    *msg = MSFAIL; goto wrapup; }
	dblcpy ( vec, deriv[1], 3);
	BSnorvec ( &rc, vec);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n");
			    *msg = MSFAIL; goto wrapup; }

	sign = BSdotp ( &rc, dir, vec);
	if (rc != BSSUCC) { printf( "Error in BSdotp()\n");
			    *msg = MSFAIL; goto wrapup; }

	if (sign >= 0.0)
		for ( i=0; i<3; i++) xpt[3+i] = xpt[i] - (ext1 * vec[i]);
	else
		for ( i=0; i<3; i++) xpt[3+i] = xpt[i] + (ext1 * vec[i]);

	/* Construct first extension line */
	geom.num_points = (IGRlong) 2;
	geom.points = (IGRdouble *) xpt;
	Icv[1].obj_id.objid = NULL_OBJID;
	Icv[1].obj_id.osnum = Env->md_id.osnum;
	Icv[1].mod_env      = *Env;
	sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
			     osnum   = Icv[1].obj_id.osnum,
			     p_objid = &Icv[1].obj_id.objid,
			     msg     = message GRgraphics.GRaltconstruct(&cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve end side parameter */
	parm.u = parm.v = -1.0;
	sts = om$send ( msg          = message GRbspline.GRptproject (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                ept,
                                                &xpt[0],
                                                &parm),
                        senderid = NULL_OBJID,
                        targetid = Curve->objid,
                        targetos = Curve->osnum );
	as$status ( sts    = sts,
		    msg    = "GRbspline.GRptproject",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Evaluate end side derivatives */
	BScveval ( cv, parm.u, 1, deriv, &rc);
	if (rc != BSSUCC) { printf( "Error in BScveval(%g)\n", parm.u);
			    *msg = MSFAIL; goto wrapup; }
	dblcpy ( vec, deriv[1], 3);
	BSnorvec ( &rc, vec);
	if (rc != BSSUCC) { printf( "Error in BSnorvec()\n");
			    *msg = MSFAIL; goto wrapup; }

	sign = BSdotp ( &rc, dir, vec);
	if (rc != BSSUCC) { printf( "Error in BSdotp()\n");
			    *msg = MSFAIL; goto wrapup; }

	if (sign >= 0.0)
		for ( i=0; i<3; i++) xpt[3+i] = xpt[i] + (ext2 * vec[i]);
	else
		for ( i=0; i<3; i++) xpt[3+i] = xpt[i] - (ext2 * vec[i]);

	/* Construct second extension line */
	geom.num_points = (IGRlong) 2;
	geom.points = (IGRdouble *) xpt;
	Icv[2].obj_id.objid = NULL_OBJID;
	Icv[2].obj_id.osnum = Env->md_id.osnum;
	Icv[2].mod_env      = *Env;
	sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
			     osnum   = Icv[2].obj_id.osnum,
			     p_objid = &Icv[2].obj_id.objid,
			     msg     = message GRgraphics.GRaltconstruct(&cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Order curve & extensions */
	OrderCrv ( Icv, 3, d, b, Ocv, inv, &adj, &clo, msg);
        if (*msg != BSSUCC) { printf( "Error in OrderCrv() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }

	/* Build composite curve */
        for ( i=0; i<3; i++) { entries[i].module_info = Ocv[i].mod_env;
                	       entries[i].located_obj = Ocv[i].obj_id; }

	if 	(vs$is_ancestry_valid ( object   = Curve,
				   	classid = OPP_GRcompcurve_class_id ) )
        	BuildCrv ( 3, Ocv, 3, inv, adj, clo, entries, &cst, Curve, msg);
	else if (vs$is_ancestry_valid ( object   = Curve,
					classid = OPP_GRbspline_class_id ) )
        	BuildCrv ( 1, Ocv, 3, inv, adj, clo, entries, &cst, Curve, msg);
	else {
printf( "Curve (%d|%d) not subclass of GRcompcurve nor GRbspline\n",
	Curve->osnum, Curve->objid);
		*msg = MSFAIL;
		goto wrapup;
	}
        if (*msg != BSSUCC) { printf( "Error in BuildCrv() : %d\n", *msg);
                              *msg = MSFAIL; goto wrapup; }
        else *msg = MSSUCC;

wrapup:
	if (cv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = cv)\n");
#endif
		om$dealloc (ptr = cv);
		cv = NULL;
	}
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLcomputePlanes( Bplane, plane_id, grd_dist, Env, Pplane, Tplane, msg)

/*d This function creates the support plane for a plate's templates. The basis
    plane is defined by cog (projected on the plate along average normal) and
    the average normal itself. The P plane is defined by a point at <grd_dist>
    of cog along the average normal and the average normal itself. */

/*h 04/11/92 : creation by Marc FOURNIER (ISDC). */

		IGRdouble	*Bplane; 	/*I Basis plane		*/
	struct  GRid            *plane_id;      /*I Section plane       */
		IGRdouble	grd_dist;	/*I Ground distance	*/
	struct	GRmd_env	*Env;		/*I Current module env	*/
		IGRdouble	*Pplane; 	/*O P plane		*/
		IGRdouble	*Tplane; 	/*O T plane		*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct  IGRplane        Splane;
                IGRpoint        point;
                IGRvector       normal;
                BSrc            rc;
                IGRvector       Xvec;
		IGRint		i;
	struct	GRid		support;
		IGRdouble	mu, nu;

	/* Initialize */
        Splane.point  = point;
        Splane.normal = normal;

	/* Retrieve plane ID thru pretend (if any) */
	sts = vl$return_foot ( msg    = msg,
			       objId  = plane_id,
			       footId = &support );
        if (!((*msg)&1&sts))	support = *plane_id;

        /* Retrieve section plane */
        sts = om$send ( msg      = message GRvg.GRdetplane (
                                        msg,
                                        &Env->md_env.matrix_type,
                                        Env->md_env.matrix,
                                        &Splane ),
                        senderid = NULL_OBJID,
                        targetid = support.objid,
                        targetos = support.osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRdetplane",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Compute P plane normal */
	dblcpy ( &Pplane[3], &Bplane[3], 3);

	/* Compute P plane point */
	for ( i=0; i<3; i++) Pplane[i] = Bplane[i] + (grd_dist * Pplane[i+3]);

        /* Compute T plane normal */
        BScrossp ( &rc, &Bplane[3], Splane.normal, Xvec);
	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
			      	*msg = MSFAIL;	goto wrapup;	}
        BSnorvec ( &rc, Xvec);
	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
			      	*msg = MSFAIL;	goto wrapup;	}
        BScrossp ( &rc, Splane.normal, Xvec, &Tplane[3]);
	if (rc != BSSUCC) {	printf( "Error in BScrossp()\n");
			      	*msg = MSFAIL;	goto wrapup;	}
        BSnorvec ( &rc, &Tplane[3]);
	if (rc != BSSUCC) {	printf( "Error in BSnorvec()\n");
			      	*msg = MSFAIL;	goto wrapup;	}

	/* Compute T plane point */
	mu = BSdotp ( &rc, &Tplane[3], &Pplane[3]);
	if (rc != BSSUCC) {	printf( "Error in BSdotp()\n");
			      	*msg = MSFAIL;	goto wrapup;	}
	if (mu != 0.0) {
		for ( i=0; i<3; i++) Xvec[i] = Pplane[i] - Splane.point[i];
		nu = BSdotp ( &rc, Xvec, &Pplane[3]);
		if (rc != BSSUCC) {	printf( "Error in BSdotp()\n");
				      	*msg = MSFAIL;	goto wrapup;	}
		for ( i=0; i<3; i++)
			Tplane[i] = Splane.point[i] + (nu / mu * Tplane[i+3]);
	}
	else {	printf( "Error : Cannot project average normal ...\n");
		*msg = MSFAIL; goto wrapup; }
#ifdef TRACE
printf( "Fplane : [%g|%g|%g]\t-->\t[%g|%g|%g]\n",
	Splane.point[0], Splane.point[1], Splane.point[2],
	Splane.normal[0], Splane.normal[1], Splane.normal[2]);
printf( "Pplane : [%g|%g|%g]\t-->\t[%g|%g|%g]\n",
	Pplane[0], Pplane[1], Pplane[2], Pplane[3], Pplane[4], Pplane[5]);
printf( "Tplane : [%g|%g|%g]\t-->\t[%g|%g|%g]\n",
	Tplane[0], Tplane[1], Tplane[2], Tplane[3], Tplane[4], Tplane[5]);
#endif

wrapup :
	return (sts);

/* End of function */
}
/* ========================================================================== */
IGRlong VLcreateContour ( msg, Curve, Env, Tplane, cst,
			  DistTol, BaseTol, Spt, Ept)

/*d This function creates the complete contour. */

/*h 03/11/92 : creation by Marc FOURNIER (ISDC). */

		IGRlong		*msg;	/*O  	Completion code		*/
	struct	GRid		*Curve;	/*IO 	Ems curve --> contour	*/
	struct	GRmd_env	*Env;	/*I  	Current module env	*/
		IGRdouble	*Tplane;/*I	T plane			*/
	struct	GRvg_construct	*cst;	/*I  	Construction list	*/
		IGRdouble	DistTol;/*I	Distance tolerance	*/
		IGRdouble	BaseTol;/*I	Basis tolerance		*/
		IGRdouble	Spt[];	/*O	Rplane point 1		*/	
		IGRdouble	Ept[];	/*O	Rplane point 2		*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRpoint	spt, ept;
		BSrc		rc;
	struct	GRobj_env	Icv[4];
	struct	GRobj_env	Ocv[4];
		IGRshort	inv[4];
		IGRboolean	adj, clo;
	struct	IGRpolyline	geom;
		IGRdouble	pts[6];
		IGRint		i;
	struct	GRlc_info	entries[4];

	/* Initialize */
	Icv[0].mod_env = *Env;
	Icv[0].obj_id  = *Curve;
	for (i=1;i<4;i++) {
		Icv[i].mod_env      = *Env;
		Icv[i].obj_id.objid = NULL_OBJID;
		Icv[i].obj_id.osnum = Env->md_id.osnum;
	}
	geom.num_points = (IGRlong)     2;
	geom.points     = (IGRdouble *) pts;

	/* Retrieve curve's end points */
	sts = VLendpts ( msg, Curve, Env, spt, ept);
	as$status ( sts    = sts,
	    	    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "Curve (%d|%d) : [%g,%g,%g] ---> [%g,%g,%g]\n",
	Curve->osnum, Curve->objid,
	spt[0], spt[1], spt[2], ept[0], ept[1], ept[2] );
#endif
	/* Project the curve's start point on the plane P */
	BSproj1 ( &rc, spt, &Tplane[3], &Tplane[0], Spt);
	if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
#ifdef TRACE
printf( "Start Point [%g,%g,%g]\tprojected as [%g,%g,%g]\n",
	spt[0], spt[1], spt[2], Spt[0], Spt[1], Spt[2] );
#endif
	/* Project the curve's end point on the plane P */
	BSproj1 ( &rc, ept, &Tplane[3], &Tplane[0], Ept);
	if (rc != BSSUCC) { sts = *msg = MSFAIL; goto wrapup; }
#ifdef TRACE
printf( "End   Point [%g,%g,%g]\tprojected as [%g,%g,%g]\n",
	ept[0], ept[1], ept[2], Ept[0], Ept[1], Ept[2] );
#endif

	/* Exit before construction (if needed) */
	if (!cst)	goto wrapup;

	/* Construct the P plane line segment */
	cst->geometry   = (IGRchar *)   &geom;
	dblcpy ( &pts[0], Ept, 3);
	dblcpy ( &pts[3], Spt, 3);
	sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
			     osnum   = Icv[2].obj_id.osnum,
			     p_objid = &Icv[2].obj_id.objid,
			     msg     = message GRgraphics.GRaltconstruct (cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Construct the start line segment */
	dblcpy ( &pts[0], Spt, 3);
	dblcpy ( &pts[3], spt, 3);
	sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
			     osnum   = Icv[3].obj_id.osnum,
			     p_objid = &Icv[3].obj_id.objid,
			     msg     = message GRgraphics.GRaltconstruct (cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Construct the end line segment */
	dblcpy ( &pts[0], ept, 3);
	dblcpy ( &pts[3], Ept, 3);
	sts = om$construct ( classid = OPP_GR3dlineseg_class_id,
			     osnum   = Icv[1].obj_id.osnum,
			     p_objid = &Icv[1].obj_id.objid,
			     msg     = message GRgraphics.GRaltconstruct (cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	
	/* Construct the <contour> composite curve */
	OrderCrv ( Icv, (IGRint)4, DistTol, BaseTol, Ocv, inv, &adj, &clo, msg);
	if (*msg != BSSUCC) { printf( "Error in OrderCrv() : %d\n", *msg);
			      *msg = MSFAIL; goto wrapup; }
	
	for ( i=0; i<4; i++) {
		entries[i].module_info = Ocv[i].mod_env;
		entries[i].located_obj = Ocv[i].obj_id;
	}
	BuildCrv( (IGRshort)3, Ocv, 4, inv, adj, clo, entries, cst, Curve, msg);
	if (*msg != BSSUCC) { printf( "Error in BuildCrv() : %d\n", *msg);
			      *msg = MSFAIL; goto wrapup; }
	else *msg = MSSUCC;
#ifdef TRACE
printf( "Contour (%d|%d) is constructed\n", Curve->osnum, Curve->objid );
#endif
	cst->geometry   = (IGRchar *) NULL;

wrapup :
	geom.num_points = (IGRlong)   0;
	return (sts);
	
/* End of function */
}
/* ========================================================================== */
IGRboolean VLcounterClockwise ( npt, pts, msg)

/*d This evaluate if a set of Z planar points is described in counter clockwise
    (TRUE) or clockwise (FALSE) orientation. */

/*h 16/06/93 : creation by Marc FOURNIER (ISDC). */

		IGRint		npt;		/*I number of points	*/
		IGRdouble	pts[];		/*I array of points	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */
	
		IGRboolean	ccw=TRUE;
		IGRvector	vec1, vec2, vec3;
		IGRint		i;
		BSrc		rc;

	/* Initialize */
	*msg = MSFAIL;
	if (npt < 3)	goto wrapup;

	/* Construct first vector */
	for ( i=0; i<3; i++)	vec1[i] = pts[3*(npt-1)+i] - pts[3*(npt-2)+i];
	BSnorvec ( &rc, vec1);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Construct second vector */
	for ( i=0; i<3; i++)	vec2[i] = pts[3+i] - pts[0+i];
	BSnorvec ( &rc, vec2);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Evaluate cross product */
	BScrossp ( &rc, vec1, vec2, vec3);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if (vec3[2] >= 0)	ccw = TRUE;
	else			ccw = FALSE;
	*msg = MSSUCC;

wrapup:	
	return (ccw);

/* End of function */
}
/* ========================================================================== */
IGRlong VLcontrolDist ( Plate, Nplate, Cnorm, Inorm, side, Odist, msg)

/*d This function controls the minimum distance between several plate support
    surfaces and the templates support plane. The new minimum distance is
    returned. */

/*h 05/11/92 : creation by Marc FOURNIER (ISDC).
    19/03/93 : modified by Marc FOURNIER (ISDC).
    15/06/93 : modified by Marc FOURNIER (ISDC).  */

	struct	GRobj_env	Plate[];	/*I VS plates array	*/
		IGRint		Nplate;		/*I Number of plates	*/
		IGRint		Cnorm;		/*I Normal correction	*/
		IGRint		Inorm;		/*I Normal inversion	*/
		IGRchar		*side;		/*I Top or Bottom ?	*/
		IGRdouble	*Odist;		/*O minimum distance	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	GRobj_env	Surf;
		IGRint		i, j, k, l, Unum, Vnum, Rev=0, Nmesh=0;
		IGRvector	vec, Zvec, nrm, Snrm, Avn;
		IGRpoint	Avp, pnt;
		IGRdouble	gap=0.0, U, V, *Mesh;
		BSrc		rc;
		IGRuchar	props;
	struct	IGRbsp_surface	*SFgeom, *UVgrid;

	/* Initialize */
	Zvec[0] = 0.0;	Zvec[1] = 0.0;	Zvec[2] = 1.0;
	Avp[0]  = Avp[1] = Avp[2] = 0.0;
	Avn[0]  = Avn[1] = Avn[2] = 0.0;
	*Odist  = 0.0;
	SFgeom  = NULL;
	UVgrid  = NULL;
	Unum    = Vnum = 5;
	Mesh    = NULL;
	
	/* Allocate memory for meshing points */
#ifdef TRACE_MEMORY
printf( "Mesh = om$calloc(%d,<IGRdouble>)\n", 3 * Nplate * Unum * Vnum);
#endif
	Mesh = om$calloc ( num	     = 3 * Nplate * Unum * Vnum,
			   structure = IGRdouble );

	/* Evaluate distance between plate surface and P plane */
	for ( i=0; i<Nplate; i++) {

		/* Extract support surface from plate */
		sts = VLextractVSplateSurface
					( msg,
					  &Plate[i].obj_id,
					  &Plate[i].mod_env,
					  side,
					  &Surf.obj_id,
					  &Surf.mod_env,
					  (struct IGRbsp_surface **) NULL );
		as$status ( sts    = sts,
			    msg    = "VLextractVSplateSurface()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		sts = om$send ( msg = message EMSsubbs.EMget_props ( msg,
                                                                     &props ),
                                senderid = NULL_OBJID,
                                targetid = Surf.obj_id.objid,
                                targetos = Surf.obj_id.osnum );
                as$status ( sts = sts,
                            msg = "EMSsubbs.EMget_props",
                            test = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );
                if (props & EMSIS_NRML_REVERSED)        Rev =  1;
                else                                    Rev = -1;

		/* Reparametrize surface */
		if (SFgeom) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = SFgeom)\n");
#endif
			om$dealloc (ptr = SFgeom);
			SFgeom = NULL;
		}
		if (UVgrid) { BSfreesf ( &rc, UVgrid);   UVgrid = NULL; }

		sts = VLevalUvGridFromSrf ( Surf, Unum, Vnum, 0,
					     &SFgeom, &UVgrid, msg);
		as$status ( sts    = sts,
			    msg    = "VLevalUvGridFromSrf()",
                	    test   = (!(sts & 0x00000001 & (*msg))),
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		Unum = UVgrid->u_num_poles;
		Vnum = UVgrid->v_num_poles;
		Snrm[0] = Snrm[1] = Snrm[2] = 0.0;

		for ( j=0; j<Unum; j++) {
			for ( k=0; k<Vnum; k++) {
				U = UVgrid->poles[3*(j*Unum+k)+0];
				V = UVgrid->poles[3*(j*Vnum+k)+1];
				BSsfarrevn ( &rc, SFgeom, 1, &U, 1, &V,
					     pnt, nrm);
				if (rc != BSSUCC) {
                                        printf( "Error in BSsfarrevn()\n");
                                        *msg = MSFAIL;  goto wrapup;    }
				
				dblcpy ( &Mesh[3*Nmesh], pnt, 3);
				Nmesh++;
                                for ( l=0; l<3; l++) {
                                        Avp[l]  += pnt[l] / Unum / Vnum;
                                        Snrm[l] += nrm[l];  }
			}
		}

		/* Collecting and orienting surface normal */
		if (!i) for ( l=0; l<3; l++)    Avn[l] += Rev * Snrm[l];
                else {  if (BSdotp ( &rc, Snrm, Avn) * Rev < 0.0)
                                for ( l=0; l<3; l++) Avn[l] -= Rev * Snrm[l];
                        else    for ( l=0; l<3; l++) Avn[l] += Rev * Snrm[l];
                }
	}

	/* Evaluate the COG. */
        for ( l=0; l<3; l++)    Avp[l] /= (IGRdouble) Nplate;

	/* Normalise the average normal. */
        BSnorvec(&rc, Avn);
        if (rc != BSSUCC) {     printf( "Error in BSnorvec()\n");
                                *msg = MSFAIL;  goto wrapup;    }

	/* Set average normal to Z in non Shell/Wall case */
        if (Cnorm != IDX_J3)	dblcpy ( Avn, Zvec, 3);

	/* Inverse normal if needed */
	for ( l=0; l<3; l++)	Avn[l] *= Inorm;
#ifdef TRACE
printf( "Avp : [%g,%g,%g]\tAvn : [%g,%g,%g]\n",
	Avp[0], Avp[1], Avp[2], Avn[0], Avn[1], Avn[2] );
#endif
	
	/* Evaluate distance */
	for ( i=0; i<Nmesh; i++) {
		for ( l=0; l<3; l++) 	vec[l] = Mesh[3*i+l] - Avp[l];
		gap = BSdotp ( &rc, Avn, vec);
        	if (rc != BSSUCC) {     printf( "Error in BSdotp ()\n");
                                	*msg = MSFAIL;  goto wrapup;    }
                if (gap > *Odist) 	*Odist = gap;
	}

wrapup :

	if (UVgrid) { BSfreesf ( &rc, UVgrid);   UVgrid = NULL; }
	if (SFgeom) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = SFgeom)\n");
#endif
		om$dealloc (ptr = SFgeom);
		SFgeom = NULL;
	}
	if (Mesh) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Mesh)\n");
#endif
		om$dealloc (ptr = Mesh);
		Mesh = NULL;
	}
	return (sts);
	
/* End of function */
}
/* ========================================================================== */
IGRboolean VLcolinear ( npt, pts, base)

/*d This function returns TRUE if the given points are colinears */

/*h 10/11/92 : creation by Marc FOURNIER (ISDC). */

		IGRint		npt;	/*I	number of points	*/
		IGRdouble	pts[];	/*I	points array		*/
		IGRvector	base;	/*O	director vector		*/

{
/* Beginning of function */

		IGRboolean	linear=FALSE;
		IGRlong		msg;
		IGRdouble	tol;
		IGRint		i, j;
		IGRvector	curr, prod;
		BSrc		rc;
	
	/* Initialize */
	if (npt < 2) goto wrapup;
	for ( j=0; j<3; j++) base[j] = pts[3*(npt-1)+j] - pts[j]; 
	if (npt == 2) { linear=TRUE; goto wrapup; }
	BSxtractpar ( &msg, BSTOLBASIS, &tol);

	/* Check colinearity */
	for ( i=1; i<npt-1; i++) {
		for ( j=0; j<3; j++) curr[j] = pts[3*i+j] - pts[j];
		BScrossp ( &rc, base, curr, prod);
		if ((prod[0] > tol) || (prod[1] > tol) || (prod[2] > tol)) {
			linear = FALSE;
			goto wrapup;
		}
	}
	linear = TRUE;
wrapup:
	return (linear);

/* End of function */
}
/* ========================================================================== */
IGRlong VLverifyExtremity ( plate, ref_plane, Env, ncap, u, v, msg)

/*d This function try to find 0, 1 or 2 planar extremities of the plate. */

/*h 06/11/92 : creation by Marc FOURNIER (ISDC).
    09/11/92 : modification by Marc FOURNIER (ISDC). */

	struct	GRobj_env	*plate;		/*I Struct plate	 */
	struct	GRobj_env	*ref_plane;	/*I Reference plane	 */
	struct	GRmd_env	*Env;		/*I Current module env	 */
		IGRint		*ncap;		/*O Number of cap planes */
		IGRdouble	u[];		/*O U parameters array	 */
		IGRdouble	v[];		/*O V parameters array	 */
		IGRlong		*msg;		/*O Completion code	 */

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	GRid		surf_id, *edge_crv, edge_id;
	struct	GRmd_env	surf_env;
	struct	IGRbsp_surface	*sf;
		IGRint		U, V, edge_num=0, i, j;
		IGRdouble	*bdu, *bdv, *wu0, *wu1, *wv0, *wv1;
		IGRboolean	planar[4], linear[4], degen=FALSE;
		IGRdouble	vec[12];
		BSrc		rc;
	struct	IGRplane	plane;
		IGRpoint	point;
		IGRvector	normal;
		IGRdouble	dot[4];

	/* Initialize */
	*ncap = 0;
	u[0]  = u[1] = v[0] = v[1] = -1.0;
	sf    = NULL;
	bdu   = bdv = wu0 = wu1 = wv0 = wv1 = NULL;
	*msg  = MSFAIL;
	edge_crv = NULL;

	/* Extract support surface from plate */
	sts = VLextractVSplateSurface ( msg,
					&plate->obj_id,
					&plate->mod_env,
					VS_K_plBotSfPath,
			       		&surf_id,
					&surf_env,
					&sf);
	as$status ( sts    = sts,
		    msg    = "VLextractVSplateSurface()",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Retrieve surface external edges */
        vs$get_surface_edges ( msg      = msg,
                               sfId     = &surf_id,
                               sfEnv    = &surf_env,
                               edgeType = VS_K_CONTOUR_EDGES,
                               edCount  = &edge_num,
                               edList   = &edge_crv );
        as$status ( sts    = *msg,
                    msg    = "vs$get_surface_edges()",
                    test   = (!(0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Check natural edges */
	if (edge_num != 4)	degen = TRUE;
	else {
	for ( i=0; i<edge_num; i++) {

			/* Extract graphical edge (without copy) */
                	edge_id.objid = NULL_OBJID;
                	edge_id.osnum = Env->md_id.osnum;
                	vs$get_graphic_edge ( msg     = msg,
	                                      edId    = &edge_crv[i],
	                                      edEnv   = &surf_env,
	                                      copy    = FALSE,
	                                      copyEnv = Env,
	                                      grEdge  = &edge_id );
	                as$status ( sts    = *msg,
	                            msg    = "vs$get_graphic_edge()",
	                            test   = (!(0x00000001 & (*msg))),
	                            action = GOTO_VALUE,
	                            value  = wrapup );

			/* Test if the edge is degenerated to a point */
	                if (vs$is_ancestry_valid (
				object  = &edge_id,
	                        classid = OPP_GR3dpoint_class_id) ) {
				degen = TRUE;
				i = edge_num;
			}
		}
	}

	/* Retrieve UV poles number */
	U = sf->u_num_poles;
	V = sf->v_num_poles;

	/* Malloc & fill border U points (and weights) array */
#ifdef TRACE_MEMORY
printf( "bdu = om$calloc(%d,<IGRdouble>)\n", 6 * U);
#endif
	bdu = om$calloc ( num = 6 * U, structure = IGRdouble );
	for ( i=0; i<U; i++) {
		dblcpy ( &bdu[3*i],     &sf->poles[3*i],           3);
		dblcpy ( &bdu[3*(i+U)], &sf->poles[3*(i+U*(V-1))], 3);
	}
	if (sf->rational) {
#ifdef TRACE_MEMORY
printf( "wv0 = om$calloc(%d,<IGRdouble>)\n", U);
#endif
		wv0 = om$calloc ( num = U, structure = IGRdouble );
#ifdef TRACE_MEMORY
printf( "wv1 = om$calloc(%d,<IGRdouble>)\n", U);
#endif
		wv1 = om$calloc ( num = U, structure = IGRdouble );
		for ( i=0; i<U; i++) {
			wv0[i] = sf->weights[i];
			wv1[i] = sf->weights[i+U*(V-1)];
		}
	}

	/* Malloc & fill border V points (and weights) array */
#ifdef TRACE_MEMORY
printf( "bdv = om$calloc(%d,<IGRdouble>)\n", 6 * V);
#endif
	bdv = om$calloc ( num = 6 * V, structure = IGRdouble );
	for ( j=0; j<V; j++) {
		dblcpy ( &bdv[3*j],     &sf->poles[3*j*U],       3);
		dblcpy ( &bdv[3*(j+V)], &sf->poles[3*(U-1+j*U)], 3);
	}
	if (sf->rational) {
#ifdef TRACE_MEMORY
printf( "wu0 = om$calloc(%d,<IGRdouble>)\n", V);
#endif
		wu0 = om$calloc ( num = V, structure = IGRdouble );
#ifdef TRACE_MEMORY
printf( "wu1 = om$calloc(%d,<IGRdouble>)\n", V);
#endif
		wu1 = om$calloc ( num = V, structure = IGRdouble );
		for ( j=0; j<V; j++) {
			wu0[j] = sf->weights[j*U];
			wu1[j] = sf->weights[U-1+j*U];
		}
	}

	/* Test planarity of iso v=0 */
	planar[0] = FALSE;
	BStst_plan ( U, &bdu[0],   wv0, &planar[0], &vec[0], &rc);
	if (rc != BSSUCC) { 	printf( "Error in BStst_plan(v=0)\n");
				*msg = MSFAIL; goto wrapup; }
	if (planar[0] == TRUE)	linear[0] = FALSE;
	else 			linear[0] = VLcolinear( U, &bdu[0],   &vec[0]);

	/* Test planarity of iso v=1 */
	planar[1] = FALSE;
	BStst_plan ( U, &bdu[3*U], wv1, &planar[1], &vec[3], &rc);
	if (rc != BSSUCC) { 	printf( "Error in BStst_plan(v=1)\n");
				*msg = MSFAIL; goto wrapup; }
	if (planar[1] == TRUE)	linear[1] = FALSE;
	else 			linear[1] = VLcolinear( U, &bdu[3*U], &vec[3]);

	/* Test planarity of iso u=0 */
	planar[2] = FALSE;
	BStst_plan ( V, &bdv[0],   wu0, &planar[2], &vec[6], &rc);
	if (rc != BSSUCC) { 	printf( "Error in BStst_plan(u=0)\n");
				*msg = MSFAIL; goto wrapup; }
	if (planar[2] == TRUE)	linear[2] = FALSE;
	else 			linear[2] = VLcolinear( V, &bdv[0],   &vec[6]);

	/* Test planarity of iso u=1 */
	planar[3] = FALSE;
	BStst_plan ( V, &bdv[3*V], wu1, &planar[3], &vec[9], &rc);
	if (rc != BSSUCC) { 	printf( "Error in BStst_plan(u=1)\n");
				*msg = MSFAIL; goto wrapup; }
	if (planar[3] == TRUE)	linear[3] = FALSE;
	else 			linear[3] = VLcolinear( V, &bdv[3*V], &vec[9]);

	/* Get reference plane normal & point */
	plane.point  = point;
	plane.normal = normal;
	sts = om$send ( msg = message GRvg.GRdetplane (
				msg,
				&ref_plane->mod_env.md_env.matrix_type,
				ref_plane->mod_env.md_env.matrix,
			        &plane ),
			senderid = NULL_OBJID,
			targetid = ref_plane->obj_id.objid,
			targetos = ref_plane->obj_id.osnum );
	if (!((*msg)&1&sts)) 	rc = FALSE;
	as$status ( sts    = sts,
		    msg    = "GRvg.GRdetplane",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Check valid cap planes */
	for (i=0;i<4;i++)
		dot[i] = fabs ( BSdotp ( &rc, plane.normal, &vec[3*i]) );

	if (  ((dot[0] >= 0.5) && (planar[0] == TRUE))
	   || ((degen == FALSE) && (dot[0] <= 0.5) && (linear[0] == TRUE)) ) {
		v[*ncap] = 0.0;
		(*ncap)++;
	}

	if (  ((dot[1] >= 0.5) && (planar[1] == TRUE))
	   || ((degen == FALSE) && (dot[1] <= 0.5) && (linear[1] == TRUE)) ) {
		v[*ncap] = 1.0;
		(*ncap)++;
	}

	if (  ((dot[2] >= 0.5) && (planar[2] == TRUE))
	   || ((degen == FALSE) && (dot[2] <= 0.5) && (linear[2] == TRUE)) ) {
		u[*ncap] = 0.0;
		(*ncap)++;
	}

	if (  ((dot[3] >= 0.5) && (planar[3] == TRUE))
	   || ((degen == FALSE) && (dot[3] <= 0.5) && (linear[3] == TRUE)) ) {
		u[*ncap] = 1.0;
		(*ncap)++;
	}

	if (*ncap > 2) {
		printf( "Error in VLverifyExtremity(), ncap=%d\n", *ncap);
		*ncap = 2;
	}

wrapup :

	if (edge_crv) {	om$dealloc (ptr = edge_crv);
			edge_crv = NULL;	}
	if (wu1) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = wu1)\n");
#endif
		om$dealloc (ptr = wu1);
		wu1 = NULL;
	}
	if (wu0) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = wu0)\n");
#endif
		om$dealloc (ptr = wu0);
		wu0 = NULL;
	}
	if (bdv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = bdv)\n");
#endif
		om$dealloc (ptr = bdv);
		bdv = NULL;
	}
	if (wv1) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = wv1)\n");
#endif
		om$dealloc (ptr = wv1);
		wv1 = NULL;
	}
	if (wv0) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = wv0)\n");
#endif
		om$dealloc (ptr = wv0);
		wv0 = NULL;
	}
	if (bdu) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = bdu)\n");
#endif
		om$dealloc (ptr = bdu);
		bdu = NULL;
	}
	if (sf) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = sf)\n");
#endif
		om$dealloc (ptr = sf);
		sf = NULL;
	}
	return (sts);
	
/* End of function */
}
/* ========================================================================== */
IGRlong VLextremityPlane ( sf, u, v, norm, Env, cst, plane_id, track, idx, msg)

/*d This function construct an extremity plane. */

/*h 09/11/92 : creation by Marc FOURNIER (ISDC). */

	struct	IGRbsp_surface	**sf;		/*I Bspline structure	*/
		IGRdouble	u;		/*I U parameter value	*/
		IGRdouble	v;		/*I V parameter value	*/
		IGRdouble	norm[];		/*I Direction vector	*/
	struct	GRmd_env	*Env;		/*I Current module env 	*/
	struct	GRvg_construct	*cst;		/*I Construction list	*/
	struct	GRid		*plane_id;	/*O Constructed plane	*/
		IGRdouble	track[];	/*O Surface/Plane track	*/
		IGRchar		idx[];		/*O Virtual plan name	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRint		suc=OM_S_SUCCESS;
		IGRpoint	pts[3];
		BSrc		rc;
		IGRvector	dir, ortho, dummy;
		IGRint		i;

	/* Initialize */
	*msg = MSSUCC;
	ortho[0] = ortho[1] = ortho[2] = 0.0;

	/* Retrieve 3 points of surface */
	if      (u == -1.0) {
		BSsfeval ( *sf, 0.0, v, 0, &pts[0], &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSsfeval ( *sf, 0.5, v, 0, &pts[1], &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSsfeval ( *sf, 1.0, v, 0, &pts[2], &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		sprintf ( idx, "v=%g", v);
	}
	else if (v == -1.0) {
		BSsfeval ( *sf, u, 0.0, 0, &pts[0], &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSsfeval ( *sf, u, 0.5, 0, &pts[1], &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSsfeval ( *sf, u, 1.0, 0, &pts[2], &rc);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		sprintf ( idx, "u=%g", u);
	}
	else {
		printf( "uv = (%f|%f), non available values\n", u, v);
		goto wrapup;
	}

	if (track) {
		dblcpy ( track, pts[1], 3);
#ifdef TRACE
printf( "idx : <%s>\ttrack ; [%g,%g,%g]\n",
	idx, pts[1][0], pts[1][1], pts[1][2]);
#endif
	}

	/* Correct colinearity (if needed) */
	if (VLcolinear( (IGRint) 3, pts[0], dummy) == TRUE) {
		for (i=0;i<3;i++) dir[i] = pts[2][i] - pts[0][i];
		BSnorvec ( &rc, norm);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSnorvec ( &rc, dir);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BScrossp ( &rc, norm, dir, ortho);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSnorvec ( &rc, ortho);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for (i=0;i<3;i++) pts[1][i] += ortho[i];
#ifdef TRACE
printf( "Colinear points -> track ; [%g,%g,%g]\n",
	pts[1][0], pts[1][1], pts[1][2]);
#endif
		if (track)	dblcpy ( track, pts[1], 3);
	}

	if (plane_id) {
		/* Construct valid extremity plane */
		cst->geometry = (IGRchar *) NULL;
		plane_id->objid = NULL_OBJID;
		plane_id->osnum = Env->md_id.osnum;
		sts = om$construct ( classid = OPP_EMSplane_class_id,
				     osnum   = Env->md_id.osnum,
				     p_objid = &plane_id->objid,
				     msg     = message EMSplane.EMplane (
							&suc,
							cst,
							(IGRpoint *)pts,
							3 ) );
		as$status ( sts    = sts,
			    msg    = "om$construct(EMSplane.EMplane)",
			    test   = (!(sts & 0x00000001 & (*(cst->msg)))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		sts = VLchangeTemporaryName ( Env, plane_id, idx, msg);
		as$status ( sts    = sts,
			    msg    = "VLchangeTemporaryName()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

wrapup :
	return (sts);
	
/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRchar	*VLmainOrientation (        IGRvector       dir	)
{
        IGRvector       vec, dot;
        BSrc            rc;

        /* X direction */
        vec[0]=1.0; vec[1]=vec[2]=0.0;
        dot[0] = BSdotp ( &rc, dir, vec);

        /* Y direction */
        vec[1]=1.0; vec[0]=vec[2]=0.0;
        dot[1] = BSdotp ( &rc, dir, vec);

        /* Z direction */
        vec[2]=1.0; vec[0]=vec[1]=0.0;
        dot[2] = BSdotp ( &rc, dir, vec);

        /* Absolute values */
        vec[0] = fabs(dot[0]);
        vec[1] = fabs(dot[1]);
        vec[2] = fabs(dot[2]);

        /* Determine direction */
        if ( (vec[0] >= vec[1]) && (vec[0] >= vec[2]) ) {
                if (dot[0] >= 0.0)      return ( "FWD" );
                else                    return ( "AFT" );
        }
        else if ( (vec[1] >= vec[0]) && (vec[1] >= vec[2]) ) {
                if (dot[1] >= 0.0)      return ( "PRT" );
                else                    return ( "STB" );
        }
        else {
                if (dot[2] >= 0.0)      return ( "TOP" );
                else                    return ( "BOT" );
        }

}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLcreateSline ( Contour, Tplane, Cline, Frame, Normal, Env, Axis,
			Middle, Size, Sf, Sline, Angle, LeanDir, msg)

/*d This function construct the 2 points of the S line : intersection between
    the template and the Rplane (plane containing the control line). If the
    Angle output is set to NULL the projected angle line isn't computed. */

/*h 13/11/92 : creation by Marc FOURNIER (ISDC). */

	struct	GRid		*Contour;	/*I Template contour	*/
		IGRdouble	Tplane[]; 	/*I T plane		*/
	struct	GRid		*Cline;		/*I Control line	*/
	struct	GRid		*Frame;		/*I Frame system plane	*/
		IGRdouble	*Normal;	/*I Plate normal	*/
	struct	GRmd_env	*Env;		/*I Current module env	*/
		IGRdouble	*Axis;		/*I Ship axis		*/
		IGRdouble	Middle;		/*I Middle ship value	*/
		IGRdouble	Size;		/*I User text size	*/
	struct	IGRbsp_surface	*Sf;		/*I Plate support surf. */
	struct	GRid		*Sline;		/*O S line 		*/
		IGRdouble	*Angle;		/*O Angle S ^ C lines	*/
		IGRchar		*LeanDir;	/*O Leaning direction	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	IGRplane	Rplane, Fplane;
		IGRpoint	point;
		IGRvector	normal;
	struct	GRid		Pt1, Pt2, TplaneId, RplaneId, SlineId;
	struct	ret_struct	str;
		IGRpoint	prjpt;
	struct	GRparms		parm;
		IGRlong		size=-1;
	struct	IGRbsp_curve	*ctrl;
		IGRpoint	deriv[2];
		IGRdouble	MainDir[3];
		BSrc		rc;
		IGRint		i, j;
	struct	IGRpolyline	geom;
		IGRdouble	pts[9];
	struct	GRvg_construct	cst;
	struct	GRid		frameplane;
		IGRvector	X, Y, Z, W;
		IGRdouble	Slength;
		IGRint		siz;
	struct	GRdpb_text_symb	text_symb;
		IGRlong		ret;
		IGRboolean	inv_flag;
		IGRdouble	Uparm=0.0;

	/* Initialize */
	Fplane.point = Rplane.point  = point;
	Fplane.normal = Rplane.normal = normal;
	Pt1.objid = Pt2.objid = NULL_OBJID;
	Pt1.osnum = Pt2.osnum = Env->md_id.osnum;
	TplaneId.objid = RplaneId.objid = SlineId.objid = NULL_OBJID;
	TplaneId.osnum = RplaneId.osnum = SlineId.osnum = Env->md_id.osnum;
	ctrl = NULL;
	VLinitCnst (&cst);

	/* Create S line start point object */
	sts = VLcreatePtInter ( msg, Contour, Env, Cline, Env, &Pt1, Env);
	as$status ( sts    = sts,
		    msg    = "VLcreatePtInter()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	as$make_source ( go_grid = Pt1, mod_env = Env, as_grid = &Pt1);

	/* Find the U parameter of the start point */
	sts = om$send ( msg      = message NDnode.NDgive_structure
							( msg, &str, Env),
			senderid = NULL_OBJID,
			targetid = Pt1.objid,
			targetos = Pt1.osnum);
	as$status ( sts    = sts,
		    msg    = "NDnode.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = om$send ( msg      = message GRbspline.GRptproject (
						msg,
						&Env->md_env.matrix_type,
						Env->md_env.matrix,
						str.var.point_st.pt,
						prjpt,
						&parm),
			senderid = NULL_OBJID,
			targetid = Cline->objid,
			targetos = Cline->osnum );
	as$status ( sts    = sts,
		    msg    = "GRbspline.GRptproject",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );
#ifdef TRACE
printf( "Start point : (%d|%d)\t(%g,%g,%g)\tu=%g\n",
	Pt1.osnum, Pt1.objid,
	str.var.point_st.pt[0], str.var.point_st.pt[1], str.var.point_st.pt[2],
	parm.u );
#endif
	Uparm = parm.u;

	/* Get control line <IGRbsp_curve> geometry */
	sts = om$send ( msg      = message GRvg.GRgetsize (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&size),
			senderid = NULL_OBJID,
			targetid = Cline->objid,
			targetos = Cline->osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetsize",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );
#ifdef TRACE_MEMORY
printf( "ctrl = om$calloc(%d)\n", size);
#endif
	ctrl = (struct IGRbsp_curve *) om$calloc (size = size); ;

	sts = om$send ( msg      = message GRvg.GRgetgeom (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					(IGRchar *) ctrl),
			senderid = NULL_OBJID,
			targetid = Cline->objid,
			targetos = Cline->osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRgetgeom",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );

	BScveval ( ctrl, Uparm, 1, deriv, &rc);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Retrieve R plane */
	sts = VLdetplane ( msg, Cline, Env, Normal, Axis, &Rplane);
	as$status ( sts    = sts,
		    msg    = "VLdetplane()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "VLdetplane(R plane) : (%g,%g,%g) & (%g,%g,%g)\n",
	Rplane.point[0], Rplane.point[1], Rplane.point[2],
	Rplane.normal[0], Rplane.normal[1], Rplane.normal[2]);
#endif

	/* Create R plane object */
	sts = VLcreatePlane ( Rplane.point, Rplane.normal, Env, &cst,
			      &RplaneId, msg);
	as$status ( sts    = sts,
		    msg    = "VLcreatePlane()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create S line object */
	sts = VLcreateInter ( msg, &RplaneId, Env, (IGRshort)0,
			      Frame, Env, (IGRshort)0, &SlineId, Env);
	as$status ( sts    = sts,
		    msg    = "VLcreateInter()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create T plane object */
	sts = VLcreatePlane ( &Tplane[0], &Tplane[3], Env, &cst,
			      &TplaneId, msg);
	as$status ( sts    = sts,
		    msg    = "VLcreatePlane()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create S line end point object */
	sts = VLcreateInter ( msg, &SlineId, Env, (IGRshort)0,
			      &TplaneId, Env, (IGRshort)0, &Pt2, Env);
	as$status ( sts    = sts,
		    msg    = "VLcreateInter()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	as$make_source ( go_grid = Pt2, mod_env = Env, as_grid = &Pt2);

	/* Find the U parameter of the end point */
	sts = om$send ( msg      = message NDnode.NDgive_structure
							( msg, &str, Env),
			senderid = NULL_OBJID,
			targetid = Pt2.objid,
			targetos = Pt2.osnum);
	as$status ( sts    = sts,
		    msg    = "NDnode.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Retrieve plane ID thru pretend (if any) */
	sts = vl$return_foot ( msg    = msg,
			       objId  = Frame,
			       footId = &frameplane );
        if (!((*msg)&1&sts)) 	frameplane = *Frame;

	/* Retrieve direction plane */
	sts = om$send ( msg      = message GRvg.GRdetplane (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&Fplane ),
			senderid = NULL_OBJID,
			targetid = frameplane.objid,
			targetos = frameplane.osnum );
	as$status ( sts    = sts,
		    msg    = "GRvg.GRdetplane",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Construct ship axis */
	MainDir[0] = MainDir[1] = MainDir[2] = 0.0;
	if      (Middle == Y_MID_SHIP)	MainDir[1] = 1.0;	/* Y axis */
	else if (Middle == Z_MID_SHIP)	MainDir[2] = 1.0;	/* Z axis */
	else				MainDir[0] = 1.0;	/* X axis */

#ifdef TRACE
printf( "MainDir             : ( %g| %g| %g)\t\tMiddle = %g\n",
	MainDir[0], MainDir[1], MainDir[2], Middle);
printf( "str.var.point_st.pt : ( %g| %g| %g)\n",
	str.var.point_st.pt[0], str.var.point_st.pt[1], str.var.point_st.pt[2]);
printf( "prjpt               : ( %g| %g| %g)\n", prjpt[0], prjpt[1], prjpt[2]);
#endif
	
	/* Be sure to take the derivative with the good orientation */
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	if ( BSdotp ( &rc, MainDir, deriv[1]) < 0) {
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		for ( i=0; i<3; i++) Z[i] = -1.0 * deriv[1][i];
	}
	else	for ( i=0; i<3; i++) Z[i] =  1.0 * deriv[1][i];
	BSnorvec ( &rc, Z);

	/* Evaluate the plate template leaning direction */
	if (LeanDir) {

			IGRvector	A, B, C;
	                IGRdouble       *upa, *vpa;
       		        IGRpoint        *pnt;
       		        IGRlong         npt;
			IGRpoint	Eval[4];

		/* Build Sline vector */
		for ( i=0; i<3; i++)
			B[i] = str.var.point_st.pt[i] - prjpt[i];
		BSnorvec ( &rc, B);

		/* Get local normal to surface */
		upa = NULL;
		vpa = NULL;
		BSpj_pt_sf ( Sf, prjpt, B, &npt, &pnt, &upa, &vpa, &rc );
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		if (pnt) {	om$dealloc(ptr=pnt);	pnt=NULL;	}
		
		if (npt > 0) {
			BSsfeval ( Sf, upa[0], vpa[0], 1, Eval, &rc);
			if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
			for ( i=0; i<3; i++)	A[i] = Eval[1][i];
			BSnorvec ( &rc, A);
		}
		else {
			for ( i=0; i<3; i++)	A[i] = Normal[i];
		}
		if (upa) {	om$dealloc(ptr=upa);	upa=NULL;	}
		if (vpa) {	om$dealloc(ptr=vpa);	vpa=NULL;	}

		/* Cross product of 2nd derivative & Sline vector */
		BScrossp ( &rc, A, B, C);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSnorvec ( &rc, C);

		/* Dot product beween Rplane normal & C vector */
		Uparm = BSdotp ( &rc, Rplane.normal, C);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

		/* Potentialy reorient Frame plane normal */
		for ( i=0; i<3; i++)	A[i] = Uparm * Fplane.normal[i];
		BSnorvec ( &rc, A);

		/* Get the leaning */
		strcpy ( LeanDir, VLmainOrientation(A));
	}

	if (Angle) {

		if (*Angle == -1)	inv_flag = TRUE;
		else			inv_flag = FALSE;

		/* Evaluate Sline ^ Control line angle */
		for ( i=0; i<3; i++) X[i] = str.var.point_st.pt[i] - prjpt[i];
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSnorvec ( &rc, X);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		*Angle = acos(BSdotp ( &rc, X, Z));
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

		/* Take complementaty angle (if necessary) */
		if (MainDir[0] == 1.0) {
			if (prjpt[0] < Middle) {
#ifdef TRACE
printf( "Take complementary angle : %g --> %g\n",
	(*Angle) * 180.0 / M_PI, (M_PI - (*Angle)) * 180.0 / M_PI);
#endif
				*Angle = M_PI - (*Angle);
				for ( i=0; i<3; i++) Z[i] = -1.0 * Z[i];
			}
		}

		/* Create sector point */
		if (inv_flag == TRUE)
			for ( i=0; i<3; i++)	Fplane.normal[i] *= -1.0;
		BScrossp ( &rc, Fplane.normal, X, Y);
		if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
		BSnorvec ( &rc, Y);
		for ( i=0; i<3; i++)
			W[i] = (sin(*Angle) * Y[i]) - (cos(*Angle) * X[i]);

#ifdef TRACE
printf( "X : ( %g| %g| %g)\n", X[0], X[1], X[2]);
printf( "Y : ( %g| %g| %g)\n", Y[0], Y[1], Y[2]);
printf( "Z : ( %g| %g| %g)\n", Z[0], Z[1], Z[2]);
printf( "ALPHA=%g\tSINUS=%g\tCOSINUS=%g\n", *Angle, sin(*Angle), cos(*Angle));
printf( "W : ( %g| %g| %g)\n", W[0], W[1], W[2]);
#endif

		/* Retrieve text symbology */
		siz = sizeof (struct GRdpb_text_symb);
		gr$get_text_symb ( msg    = msg,
			   	   sizbuf = &siz,
			   	   buffer = &text_symb,
			   	   nret   = &ret );
		if (Size <= 0.0)	Slength = text_symb.Active_height * 5.0;
		else			Slength = Size * 5.0;
	
		/* Evaluate angle point */
		geom.num_points = (IGRlong)     3;
		geom.points     = (IGRdouble *) pts;
		cst.geometry    = (IGRchar *)   &geom;
		dblcpy ( &pts[0], prjpt, 3);
		dblcpy ( &pts[3], str.var.point_st.pt, 3);
		for ( i=0; i<3; i++) pts[6+i] = pts[3+i] + (Slength * W[i]);

		/* Convert angle in degrees */
		*Angle = (*Angle) * 180.0 / M_PI;
	}
	else	{
		geom.num_points = (IGRlong)     2;
		geom.points     = (IGRdouble *) pts;
		cst.geometry    = (IGRchar *)   &geom;
		dblcpy ( &pts[0], prjpt, 3);
		dblcpy ( &pts[3], str.var.point_st.pt, 3);
	}

	/* Create real Sline */
	Sline->objid = NULL_OBJID;
	Sline->osnum = Env->md_id.osnum;
	sts = om$construct ( classid= OPP_GR3dlinestr_class_id,
			     osnum  = Sline->osnum,
			     p_objid= &Sline->objid,
			     msg    = message GRgraphics.GRaltconstruct (&cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(cst.msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :

	/* Delete temporary object */

	if (ctrl) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = ctrl)\n");
#endif
		om$dealloc (ptr = ctrl);
		ctrl = NULL;
	}

	if (TplaneId.objid != NULL_OBJID)
	gr$delete_object ( msg = msg, md_env = Env, object_id = &TplaneId);

	if (RplaneId.objid != NULL_OBJID)
	gr$delete_object ( msg = msg, md_env = Env, object_id = &RplaneId);

	if (SlineId.objid != NULL_OBJID)
	gr$delete_object ( msg = msg, md_env = Env, object_id = &SlineId);

	if (Pt1.objid != NULL_OBJID)
	gr$delete_object ( msg = msg, md_env = Env, object_id = &Pt1);

	if (Pt2.objid != NULL_OBJID)
	gr$delete_object ( msg = msg, md_env = Env, object_id = &Pt2);

	return (sts);
	
/* End of function */
}
/* ========================================================================== */
IGRlong VLcreateTplText ( title, angle, Rpt1, Rpt2, Tsize, inv_norm, tpl_state,
			  Sline, Amark, Line1, Line2, Wpt1_id, Wpt2_id,
			  Env, Cst, text_id, loc_mat, msg)

/*d This function construct the texts associated with a template. */

/*h 19/11/92 : creation by Marc FOURNIER (ISDC). */

		IGRchar		title[];	/*I Template title	*/
		IGRdouble	angle;		/*I Template angle 	*/
		IGRdouble	Rpt1[];		/*I Template R plane pt1*/
		IGRdouble	Rpt2[];		/*I Template R plane pt2*/
		IGRdouble	Tsize;		/*I User text size	*/
		IGRint		inv_norm;	/*I Regular/inversed    */
		IGRint		tpl_state;	/*I Template type	*/
	struct	GRid		*Amark;		/*O Template arrow mark	*/
	struct	GRid		*Line1;		/*O Template weld line1	*/
	struct	GRid		*Line2;		/*O Template weld line2	*/
	struct	GRid		*Sline;		/*I Template S line	*/
	struct	GRid		*Wpt1_id;	/*I Template weld pt 1	*/
	struct	GRid		*Wpt2_id;	/*I Template weld pt 2	*/
	struct	GRvg_construct	*Cst;		/*I Construction list	*/
	struct	GRmd_env	*Env;		/*I Current module env	*/
	struct	GRid		text_id[];	/*O Array of text ID	*/
		IGRdouble	loc_mat[];	/*O Local matrix	*/
		IGRlong		*msg;		/*O Completion code	*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	ret_struct	str;
		IGRpoint	Wpt1, Wpt2;
		IGRchar		txt[DI_PATH_MAX], mac_name[DI_PATH_MAX];
		IGRint		len, i, ang, action, ori=0;
		IGRpoint	cnt;
		IGRvector	xvec, yvec, zvec;
		BSrc		rc;
		IGRdouble	delta[3], W, H, WHmax;
	struct	GRdpb_text_symb	text_symb;
		IGRint		size=sizeof(struct GRdpb_text_symb);
		IGRlong		ret;
		IGRpoint	ept, spt;
		IGRdouble	buffer[9];
	struct	IGRpolyline	poly;
		IGRmatrix	cs_mat;

	/* Initialize */
	poly.points     = (IGRdouble *) buffer;
	poly.num_points = 3;

	/* Retrieve text symbology */
	gr$get_text_symb ( msg    = msg,
			   sizbuf = &size,
			   buffer = &text_symb,
			   nret   = &ret );
	if (Tsize > 0.0) {	text_symb.Active_width  = Tsize;
				text_symb.Active_height = Tsize;	}
	W = text_symb.Active_width;
	H = text_symb.Active_height;
	if (W > H)	WHmax = W;
	else		WHmax = H;

	/* Retrieve weld point 1 structure */
	as$make_source ( go_grid = *Wpt1_id, mod_env = Env, as_grid = Wpt1_id);
	sts = om$send ( msg      = message NDnode.NDgive_structure
							( msg, &str, Env),
			senderid = NULL_OBJID,
			targetid = Wpt1_id->objid,
			targetos = Wpt1_id->osnum);
	as$status ( sts    = sts,
		    msg    = "NDnode.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	dblcpy ( Wpt1, str.var.point_st.pt, 3);
#ifdef TRACE
printf( "Weld Point 1 : (%g,%g,%g)\n", Wpt1[0], Wpt1[1], Wpt1[2]);
#endif
	
	/* Retrieve weld point 2 structure */
	as$make_source ( go_grid = *Wpt2_id, mod_env = Env, as_grid = Wpt2_id);
	sts = om$send ( msg      = message NDnode.NDgive_structure
							( msg, &str, Env),
			senderid = NULL_OBJID,
			targetid = Wpt2_id->objid,
			targetos = Wpt2_id->osnum);
	as$status ( sts    = sts,
		    msg    = "NDnode.NDgive_structure",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	dblcpy ( Wpt2, str.var.point_st.pt, 3);
#ifdef TRACE
printf( "Weld Point 2 : (%g,%g,%g)\n", Wpt2[0], Wpt2[1], Wpt2[2]);
#endif

	/* Create a template coordinate system */
	for ( i=0; i<3; i++) {	xvec[i] = Rpt1[i] - Rpt2[i];
				yvec[i] = Wpt1[i] - Rpt1[i];	}

	BSnorvec ( &rc, xvec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, yvec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BScrossp ( &rc, xvec, yvec, zvec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, zvec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BScrossp ( &rc, zvec, xvec, yvec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }
	BSnorvec ( &rc, yvec);
	if (rc != BSSUCC) { *msg = MSFAIL; goto wrapup; }

	/* Create the local rotation matrix */
	for ( i=0; i<3; i++) {
		loc_mat[4*i+0] = xvec[i];
		loc_mat[4*i+1] = yvec[i];
		loc_mat[4*i+2] = zvec[i];
		loc_mat[4*i+3] = Rpt2[i];
		loc_mat[12+i]  = 0.0;
	}
	loc_mat[15] = 1.0;

	/* Create the title */
	txt[0] = '\0';
	title[80] = '\0';
	sprintf ( txt, "%s", title);
	len = strlen(txt);
	for ( i=0; i<3; i++) cnt[i] = Rpt2[i] + 1*W*xvec[i] + 1*H*yvec[i];
	text_symb.Active_just = LEFT_CENTER;
	sts = co$place_text ( msg		= msg,
			      text_string	= txt,
			      text_length	= &len,
			      lbs_matrix	= loc_mat,
			      origin		= cnt,
			      TextSymb		= &text_symb,
			      mode              = GRbe,
			      flags		= 1,
			      buffer		= &text_id[0] );
	as$status ( sts    = sts,
		    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Try to find main direction of the segment */
	for ( i=0; i<3; i++) delta[i] = fabs (Wpt2[i] - Wpt1[i]);

	if      ( (delta[2] >= delta[1]) && (delta[2] >= delta[0]) )	ori = 1;
	else if ( (delta[1] >= delta[0]) && (delta[1] >= delta[2]) )	ori = 2;
	else if ( Wpt2[0] >= Wpt1[0] )					ori = 3;
	else								ori = 4;

	/* Give direction name */
	switch (ori) {

	case 1:	if (  (inv_norm == INVNORM_OF) || (tpl_state == VAL_TO_SPI) )
			strcpy ( txt, "TOP");
		else	strcpy ( txt, "BOT");
		break;

	case 2:	if (  (inv_norm == INVNORM_OF) || (tpl_state == VAL_TO_SPI) )
			strcpy ( txt, "PRT");
		else	strcpy ( txt, "STB");
		break;

	case 3:	strcpy ( txt, "AFT");
		break;

	case 4:	if (  (inv_norm == INVNORM_OF) || (tpl_state == VAL_TO_SPI) )
			strcpy ( txt, "FWD");
		else	strcpy ( txt, "AFT");
		break;
	}
#ifdef TRACE
printf( "Case %d\tinv_norm=%d\ttpl_state=%d\t<%s>\n",
	ori, inv_norm, tpl_state, txt);
#endif
	sprintf ( mac_name, "%ssymbol", txt);

	/* Create the direction mark */
	for ( i=0; i<3; i++) {
		buffer[0+i] = Wpt1[i] - 2*W*xvec[i] - 1*H*yvec[i];
		buffer[3+i] = Wpt1[i] - 1*W*xvec[i] - 2*H*yvec[i];
		buffer[6+i] = Wpt1[i] - 2*W*xvec[i] - 3*H*yvec[i];
	}
	Cst->geometry   = (IGRchar *) &poly;
	sts = om$construct ( classid = OPP_GR3dlinestr_class_id,
			     osnum   = Amark->osnum,
			     p_objid = &(Amark->objid),
			     msg     = message GRgraphics.GRaltconstruct(Cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(Cst->msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Construct a temporary coordinate system */
	dblcpy ( cs_mat, loc_mat, 16);
	for ( i=0; i<3; i++) {	cs_mat[4*i+0] *= WHmax;
				cs_mat[4*i+1] *= WHmax;
				cs_mat[4*i+2] *= WHmax;	}
	cs_mat[3]  = buffer[3];
	cs_mat[7]  = buffer[4];
	cs_mat[11] = buffer[5];
	
	/* Place the direction text <ACheader> */
	sts = VLplaceRootHeader ( cs_mat, mac_name, Env, &text_id[1], msg);
	as$status ( sts    = sts,
		    msg    = "VLplaceRootHeader()",
		    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the first $ sign */
	txt[0] = '\0';
	sprintf ( txt, "%s", "$");
	len = strlen(txt);
	dblcpy ( cnt, Wpt1, 3);
	text_symb.Active_just = CENTER_CAP;
	sts = co$place_text ( msg		= msg,
			      text_string	= txt,
			      text_length	= &len,
			      lbs_matrix	= loc_mat,
			      origin		= cnt,
			      TextSymb		= &text_symb,
			      mode              = GRbe,
			      flags		= 1,
			      buffer		= &text_id[2] );
	as$status ( sts    = sts,
		    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the first $ line */
	for ( i=0; i<3; i++)	cnt[i] = Wpt1[i] -1.5*H*yvec[i];
	sts = VLcreateLineSeg ( cnt, Wpt1, Env, Cst, Line1, msg);
	as$status ( sts    = sts,
		    msg    = "VLcreateLineSeg()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the second $ sign */
	txt[0] = '\0';
	sprintf ( txt, "%s", "$");
	len = strlen(txt);
	dblcpy ( cnt, Wpt2, 3);
	text_symb.Active_just = CENTER_CAP;
	sts = co$place_text ( msg		= msg,
			      text_string	= txt,
			      text_length	= &len,
			      lbs_matrix	= loc_mat,
			      origin		= cnt,
			      TextSymb		= &text_symb,
			      mode              = GRbe,
			      flags		= 1,
			      buffer		= &text_id[3] );
	as$status ( sts    = sts,
		    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the second $ line */
	for ( i=0; i<3; i++)	cnt[i] = Wpt2[i] - 1.5*H*yvec[i];
	sts = VLcreateLineSeg ( cnt, Wpt2, Env, Cst, Line2, msg);
	as$status ( sts    = sts,
		    msg    = "VLcreateLineSeg()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Exit for spine templates */
	if (Sline->objid == NULL_OBJID)	goto wrapup;

	/* Create the angle */
	txt[0] = '\0';
	ang = angle;
	if ((angle - ang) > 0.5)	ang++;
	sprintf ( txt, "%d DEG", ang);
	len = strlen(txt);
	for ( i=0; i<3; i++) cnt[i] = Rpt1[i] - 1*W*xvec[i] + 1*H*yvec[i];
	text_symb.Active_just = RIGHT_CENTER;
	sts = co$place_text ( msg		= msg,
			      text_string	= txt,
			      text_length	= &len,
			      lbs_matrix	= loc_mat,
			      origin		= cnt,
			      TextSymb		= &text_symb,
			      mode              = GRbe,
			      flags		= 1,
			      buffer		= &text_id[4] );
	as$status ( sts    = sts,
		    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Create the LP text on the S line */
	action = 1;
	Cst->geometry   = (IGRchar *) &poly;
	poly.points = &buffer[0];
	
	sts = om$send ( msg      = message GRlinear.GRgetpolyline (
					msg,
					&Env->md_env.matrix_type,
					Env->md_env.matrix,
					&action,
					&poly ),
			senderid = NULL_OBJID,
			targetid = Sline->objid,
			targetos = Sline->osnum);
	as$status ( sts    = sts,
		    msg    = "GRlinear.GRgetpolyline",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	dblcpy ( spt, &(poly.points[0]), 3);
	dblcpy ( ept, &(poly.points[3]), 3);
	sprintf ( txt, "%s", "L P");
	len = strlen(txt);
	for ( i=0; i<3; i++) 	cnt[i] = (spt[i] + ept[i]) / 2.0;
	text_symb.Active_just = CENTER_CENTER;
	sts = co$place_text ( msg		= msg,
			      text_string	= txt,
			      text_length	= &len,
			      lbs_matrix	= loc_mat,
			      origin		= cnt,
			      TextSymb		= &text_symb,
			      mode              = GRbe,
			      flags		= 1,
			      buffer		= &text_id[5] );
	as$status ( sts    = sts,
		    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
	
/* End of function */
}
/* ========================================================================== */
IGRlong VLdrawFrame ( Ref, Cst, H, W, P, Frm, msg)

/*d This function draws a frame containing a page of templates */

/*h 03/12/92 : creation by Marc FOURNIER (ISDC). */

	struct	GRobj_env	*Ref;	/*I  Coordinate system		*/
	struct	GRvg_construct	*Cst;	/*I  Construction list		*/
		IGRdouble	H;	/*I  Reference window's hight	*/
		IGRdouble	W;	/*I  Reference window's width	*/
		IGRint		P;	/*I  Current page number	*/
	struct	GRid		*Frm;	/*IO Resulting frame object	*/
		IGRlong		*msg;	/*O  Completion code		*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRmatrix	mat;
		IGRshort	one=1, four=4;
		IGRdouble	Ipt[4], Opt[4], pts[15];
	struct	IGRpolyline	geom;
	
	/* Initialize */
	Cst->geometry = (IGRchar *) &geom;

	/* Get matrix from target coordinate system */
	sts = om$send ( msg      = message GRgencs.GRgetmatrix ( msg, mat),
			senderid = NULL_OBJID,
                        targetid = Ref->obj_id.objid,
                        targetos = Ref->obj_id.osnum);
	as$status ( sts    = sts,
		    msg    = "GRgencs.GRgetmatrix",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

/*
printf( "\n\tGround Coordinate System Matrix\n");
printf( "\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n\t[%g,%g,%g,%g]\n",
	mat[0], mat[1], mat[2],  mat[3],  mat[4],  mat[5],  mat[6],  mat[7],
	mat[8], mat[9], mat[10], mat[11], mat[12], mat[13], mat[14], mat[15] );
*/

	/* Compute the corner points */
	Ipt[2] = 0.0;	Ipt[3] = 1.0;

	Ipt[0] = 0.0;	Ipt[1] = P*H;
	MAmulmx ( msg, &four, &four, &one, mat, Ipt, Opt);
	dblcpy ( &pts[0], Opt, 3);

	Ipt[0] = W;	Ipt[1] = P*H;
	MAmulmx ( msg, &four, &four, &one, mat, Ipt, Opt);
	dblcpy ( &pts[3], Opt, 3);

	Ipt[0] = W;	Ipt[1] = (P+1)*H;
	MAmulmx ( msg, &four, &four, &one, mat, Ipt, Opt);
	dblcpy ( &pts[6], Opt, 3);

	Ipt[0] = 0.0;	Ipt[1] = (P+1)*H;
	MAmulmx ( msg, &four, &four, &one, mat, Ipt, Opt);
	dblcpy ( &pts[9], Opt, 3);

	dblcpy ( &pts[12], &pts[0], 3);

/*
printf( "PT 1 : [%g,%g,%g]\n", pts[0], pts[1], pts[2]);
printf( "PT 2 : [%g,%g,%g]\n", pts[3], pts[4], pts[5]);
printf( "PT 3 : [%g,%g,%g]\n", pts[6], pts[7], pts[8]);
printf( "PT 4 : [%g,%g,%g]\n", pts[9], pts[10], pts[11]);
printf( "PT 5 : [%g,%g,%g]\n", pts[12], pts[13], pts[14]);
*/

	geom.num_points = (IGRlong) 5;
	geom.points = (IGRdouble *) pts;
#ifdef TRACE
printf( "om$construct (GR3dorthpoly) on (%d|%d)\n", Frm->osnum, Frm->objid);
#endif
	sts = om$construct ( classid = OPP_GR3dorthpoly_class_id,
			     osnum   = Frm->osnum,
			     p_objid = &Frm->objid,
			     msg     = message GRgraphics.GRaltconstruct(Cst));
	as$status ( sts    = sts,
		    msg    = "om$construct(GRgraphics.GRaltconstruct)",
		    test   = (!(sts & 0x00000001 & (*(Cst->msg)))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
	
/* End of function */
}
/* ========================================================================== */
IGRlong VLupdateXyRange ( Mac, Md_Env, H, W, Page, Wmax, Xrg, Yrg, msg)

/*d This function manages the planar projection of the templates. */

/*h 03/12/92 : creation by Marc FOURNIER (ISDC). */

	struct	GRid		*Mac;  	/*I  Macro occurence Id		*/
	struct  GRmd_env        *Md_Env;/*   Macro Module Env           */
		IGRdouble	H;	/*I  Reference window's hight	*/
		IGRdouble	W;	/*I  Reference window's width	*/
		IGRint		*Page;	/*IO Current page number	*/
		IGRdouble	*Wmax;	/*IO Width max of curr column	*/
		IGRdouble	*Xrg;	/*IO X coordinate placement	*/
		IGRdouble	*Yrg;	/*IO Y coordinate placement	*/
		IGRlong		*msg;	/*O  Completion code		*/

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	GRid		Xrng_id, Yrng_id, cont_id,*CmpLst = NULL;
		IGRdouble	x_range, y_range, Length, Width, 
				Act_Wid=0.0, Gap,d1,d2,
				pt1[3],pt2[3],pt3[3],pt4[3];
		IGRboolean      minrec_possible=TRUE;
		IGRint		NumCmp,NumRetObj;
        	GRclassid       cid;
		BSrc            bsrc;

	/* Ask for X range ID */
	sts = vl$return_foot ( msg    = msg,
			       name   = NAM_TO_CONT,
			       objId  = Mac,
			       footId = &cont_id );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(CONTOUR)",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

        sts  = vl$minrect ( curve   = &cont_id,
                            environ = Md_Env,
                            length  = &Length,
                            width   = &Width,
                            msg     = msg );

        if( !(sts&(*msg)&1) )
        {
	  /******************* Min rec problem  ************************/
          om$get_classid(osnum = cont_id.osnum,
                         objid = cont_id.objid,
                         p_classid = &cid);

	  if( om$is_ancestry_valid( superclassid  = OPP_GRcompcurve_class_id,
                            subclassid    = cid ) == OM_S_SUCCESS ){

             sts = om$send( msg = message GRowner.GRget_number_components(
                                        msg,
                                        &NumCmp ),
                      senderid = NULL_OBJID,
                      targetid = cont_id.objid,
                      targetos = cont_id.osnum );

             #ifdef TRACE
             printf(" Composite curve, NumCmp = %d\n",NumCmp);
             #endif

             if( !(*msg&sts&1) ){
                printf("Error in VLupdateXyRange\n");
                printf("Error message GRowner.GRget_number_components\n");
                goto wrapup;
             }

             /* malloc the list to retrieve all the components */

             CmpLst = _MALLOC( NumCmp, struct GRid ) ;
             if( CmpLst == NULL ){
                printf("Error in VLupdateXyRange\n");
                printf("Error in  malloc TmpRet : Failed\n");
                goto wrapup;
             }
             sts = om$send( msg = message GRowner.GRget_components(
                                        msg,
                                        Md_Env,
                                        CmpLst,
                                        NumCmp,
                                        &NumRetObj,
                                        (IGRint) 0,
                                        OM_K_MAXINT ),
                         senderid = NULL_OBJID,
                         targetid = cont_id.objid,
                         targetos = cont_id.osnum );

             if( !(*msg&sts&1) ){
                printf("Error in VLupdateXyRange\n");
                printf("Error in  GRowner.GRget_components\n");
                goto wrapup;
             }

	     sts = VLendpts(msg,&CmpLst[0] ,Md_Env ,pt1,pt2);
	     if( !(*msg&sts&1) ){
                printf("Error in VLupdateXyRange\n");
                printf("Error in  VLendpts\n");
                goto wrapup;
             }
	     sts = VLendpts(msg,&CmpLst[1] ,Md_Env ,pt3,pt4);
	     if( !(*msg&sts&1) ){
                printf("Error in VLupdateXyRange\n");
                printf("Error in  VLendpts\n");
                goto wrapup;
             }

 	     d1 = BSdistptpt(&bsrc,pt1,pt2);
	     if( bsrc != BSSUCC) goto wrapup;

	     d2 = BSdistptpt(&bsrc,pt3,pt4);
	     if( bsrc != BSSUCC) goto wrapup;

	     if(d1<d2)  Width = d1;
             else     Width = d2;

             minrec_possible = TRUE;

             if( H < 0.0 || H > 100.0 ) Gap = 0.1;
             else                       Gap = H/100;

             Act_Wid = ( 1.0 + Gap ) * Width;

	   }
	}
 	/**********************************************/

	else 
	{
	   minrec_possible = TRUE;

	   if( H < 0.0 || H > 100.0 ) Gap = 0.1;
	   else			   Gap = H/100;

	   Act_Wid = ( 1.0 + Gap ) * Width;
	}

	/* Ask for X range ID */
	sts = vl$return_foot ( msg    = msg,
			       name   = NAM_TO_XRNG,
			       objId  = Mac,
			       footId = &Xrng_id );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(XRNG)",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Find X range value */
	sts = om$send ( msg      = message expression.NDgive_value (&x_range),
			senderid = NULL_OBJID,
			targetid = Xrng_id.objid,
			targetos = Xrng_id.osnum);
	as$status ( sts    = sts,
		    msg    = "expression.NDgive_value",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Ask for Y range ID */
	sts = vl$return_foot ( msg    = msg,
			       name   = NAM_TO_YRNG,
			       objId  = Mac,
			       footId = &Yrng_id );	
	as$status ( sts    = sts,
		    msg    = "vl$return_foot",
               	    test   = (!(sts & 0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

	/* Find Y range value */
	sts = om$send ( msg      = message expression.NDgive_value (&y_range),
			senderid = NULL_OBJID,
			targetid = Yrng_id.objid,
			targetos = Yrng_id.osnum);
	as$status ( sts    = sts,
		    msg    = "expression.NDgive_value",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Next template position management */
	if (x_range > *Wmax) 	*Wmax = x_range;

	if( minrec_possible ) *Yrg += Act_Wid;
	else		      *Yrg += y_range;
 
	if ( (*Yrg + y_range ) > ((*Page) + 1) * H ) {
		(*Page)++;
		*Xrg += *Wmax;
		if( !minrec_possible )	*Yrg = (*Page) * H + (H / 1000);
	}

	/* Next Frame management */
	if ( (*Xrg + x_range) > W ) {
		(*Page)++;
		*Xrg  = 0.0;
		if( !minrec_possible )  *Yrg  = (*Page) * H + (H / 1000);
		*Wmax = 0.0;
	}

wrapup:
        if( CmpLst != NULL)   _FREE(CmpLst);
	return (sts);
	
/* End of function */
}

/* ========================================================================== */
IGRlong VLretrieveIsoOrEdg  (       	IGRlong         *msg,
                                 struct GRobj_env       *Sf,
                                        IGRdouble       *Track,
                                        IGRboolean      trim,
                                        IGRdouble       u,
                                        IGRdouble       v,
                                 struct GRmd_env        *Env,
                                 struct GRvg_construct  *Cst,
					IGRboolean	*Iso,
                                 struct GRid            *Line           )

/*d This function try to construct an isoparametric curve from the plate
    support (trimmed) surface (example: u=-1, v=0.7 ==> isoparam [v=0.7]).
    If the isoparametric curve is out of the surface boundaries and the flag
    trim_to_boundaries is set to TRUE, a external edge is retrieved and copied.
*/
    

/*h 23/02/93 : creation by Marc FOURNIER (ISDC). */

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRboolean	in_udir;
		IGRdouble	parms[1];
		IGRint		numpar=1, edgnum=0;
		IGRlong		isonum=0;
		GRobjid		*isocrv;
		IGRpoint	trk, prj;
	struct	GRparms		parm;
	struct	GRid		*edgcrv;
		IGRint		i;
	struct	GRid		edg_id;
		IGRint		edgidx=0;
		IGRdouble	edgdst=1.0e99, mindst=1.0e99;

	/* Initialize */
	*Iso   = TRUE;
	isocrv = NULL;
	edgcrv = NULL;
	Line->objid = NULL_OBJID;
	Line->osnum = Env->md_id.osnum;

	/* Retrieve isoparametric curve (if any) */
	if (u == -1.0)	{ in_udir = FALSE;	parms[0] = v; }
	else		{ in_udir = TRUE;	parms[0] = u; }
	sts = om$send ( msg = message EMSsubbs.EMisoparcvs (
                                        msg,
                                        &Sf->mod_env.md_env.matrix_type,
                                        Sf->mod_env.md_env.matrix,
                                        Cst,
                                        trim,
                                        numpar,
                                        parms,
                                        in_udir,
                                        &isonum,
                                        &isocrv ),
			senderid = NULL_OBJID,
                        targetid = Sf->obj_id.objid,
                        targetos = Sf->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "EMSsubbs.EMisoparcvs",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "in_udir=%d, parms=%g, isonum=%d\n", in_udir, parms[0], isonum);
#endif
	/* Exit with first isoparametric curve found */
	if (isonum) {	Line->objid = isocrv[0];
			goto wrapup;	}
	else		*Iso = FALSE;

	/* Project input track point on support surface */
	sts = om$send ( msg = message GRbspline.GRptproject (
                                        	msg,
                                        	&Env->md_env.matrix_type,
                                        	Env->md_env.matrix,
                                        	Track,
                                        	trk,
                                        	&parm ),
			senderid = NULL_OBJID,
                        targetid = Sf->obj_id.objid,
                        targetos = Sf->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRbspline.GRptproject",
              	    test   = (!(sts & 0x00000001 & (*msg))),
              	    action = GOTO_VALUE,
               	    value  = wrapup );
#ifdef TRACE
printf( "Track : [%g,%g,%g] --> [%g,%g,%g]\n\tu=%g, v=%g\n",
	Track[0], Track[1], Track[2], trk[0], trk[1], trk[2], parm.u, parm.v);
#endif
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
printf( "edgnum=%d\n", edgnum);
#endif
	/* Find the closest edge to projected track point */
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
	
		/* Project track point on edge */
		sts = om$send ( msg      = message GRbspline.GRptproject (
                                        	msg,
                                        	&Sf->mod_env.md_env.matrix_type,
                                        	Sf->mod_env.md_env.matrix,
                                        	trk,
                                        	prj,
                                        	&parm ),
				senderid = NULL_OBJID,
                                targetid = edg_id.objid,
                                targetos = edg_id.osnum);
		as$status ( sts    = sts,
			    msg    = "GRbspline.GRptproject",
              		    test   = (!(sts & 0x00000001 & (*msg))),
              		    action = GOTO_VALUE,
               		    value  = wrapup );

		/* Evaluate distance between track point and edge */
		edgdst = ((trk[0] - prj[0]) * (trk[0] - prj[0]))
                       + ((trk[1] - prj[1]) * (trk[1] - prj[1]))
                       + ((trk[2] - prj[2]) * (trk[2] - prj[2]));
#ifdef TRACE
printf( "Edge %d Track : [%g,%g,%g] -> [%g,%g,%g]\n\tu=%g|v=%g\tdistance=%g\n",
	i, trk[0], trk[1], trk[2], prj[0], prj[1], prj[2],
	parm.u, parm.v, sqrt(edgdst) );
#endif
                if (edgdst < mindst ) {	edgidx = i;
					mindst = edgdst;
					dblcpy ( Track, prj, 3);	}
	}
#ifdef TRACE
printf( "Edge %d selected : (%d|%d), mindist = %g\n",
	edgidx, edgcrv[edgidx].osnum, edgcrv[edgidx].objid, sqrt(mindst) );
#endif
	/* Retrieve and copy the graphic edge */
	vs$get_graphic_edge ( msg       = msg,
                              edId      = &edgcrv[edgidx],
                              edEnv     = &Sf->mod_env,
                              copy      = TRUE,
                              copyEnv   = Env,
                              grEdge    = Line );
	as$status ( sts    = *msg,
		    msg    = "vs$get_graphic_edge()",
               	    test   = (!(0x00000001 & (*msg))),
               	    action = GOTO_VALUE,
               	    value  = wrapup );

wrapup:
	if (edgcrv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = edgcrv)\n");
#endif
		om$dealloc (ptr = edgcrv);
		edgcrv = NULL;
	}
	if (isocrv) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = isocrv)\n");
#endif
		om$dealloc (ptr = isocrv);
		isocrv = NULL;
	}
	return (sts);
	
/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLgetRollLineTrace  (       	IGRlong         *msg,
                                struct	GRobj_env       *VLrolLine,
					IGRchar		*footname,
				struct	IGRplane	*Splane,
					IGRpoint	*Trace		)
{
		IGRlong		sts=OM_S_SUCCESS;
	struct	GRobj_env	Curve;
		IGRlong		size=-1;
	struct	IGRbsp_curve	*cv;
		IGRint		numSol, i;
		IGRpoint	pt[5];

	/* Initialise */
	cv = NULL;

        /* Get curve object */
        Curve.obj_id.objid = NULL_OBJID;
        Curve.obj_id.osnum = VLrolLine->obj_id.osnum;
        sts = vl$return_foot ( msg     = msg,
                               name    = footname,
                               objId   = &(VLrolLine->obj_id),
                               objEnv  = &(VLrolLine->mod_env),
                               footId  = &(Curve.obj_id),
                               footEnv = &(Curve.mod_env) );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /* Get curve geometry size */
        sts = om$send ( msg      = message GRvg.GRgetsize (
                                        msg,
                                        &Curve.mod_env.md_env.matrix_type,
                                        Curve.mod_env.md_env.matrix,
                                        &size ),
                        senderid = NULL_OBJID,
                        targetid = Curve.obj_id.objid,
                        targetos = Curve.obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRvg.GRgetsize",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /* Allocate curve memory */
        cv = (struct IGRbsp_curve *) om$calloc (size = size);

        /* Get curve geometry */
        sts = om$send ( msg      = message GRvg.GRgetgeom (
                                        msg,
                                        &Curve.mod_env.md_env.matrix_type,
                                        Curve.mod_env.md_env.matrix,
                                        (IGRchar *) cv ),
                        senderid = NULL_OBJID,
                        targetid = Curve.obj_id.objid,
                        targetos = Curve.obj_id.osnum );
        as$status ( sts    = sts,
                    msg    = "GRvg.GRgetgeom",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	sts = VLintCrvPln ( cv, Splane, &numSol, pt, msg );
        as$status ( sts    = sts,
                    msg    = "VLintCrvPln()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	if (numSol > 0) {
		(*Trace)[0]=pt[0][0];
		(*Trace)[1]=pt[0][1];
		(*Trace)[2]=pt[0][2];
	}

        /* Free curve memory */
	if (cv) {
		om$dealloc (ptr = cv);
		cv = NULL;
	}

wrapup:
	return (sts);
	
/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLgetRollLineTraces  (       	IGRlong         *msg,
                                struct	GRobj_env       *VLrolLine,
				struct	GRid		*plane_id,
				struct	GRmd_env	*Env,
					IGRint		*count,
					IGRpoint	**traces	)

/*h 10/02/00 : creation by Marc FOURNIER (COC Shipbuilding, Paris office). */

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
	struct	GRid		dummyID;
		IGRdouble	dVal;
	struct	IGRplane	Splane;
		IGRpoint	point;
		IGRvector	normal;

	/* Initialisation */
	*count = 0;

	/* Validation of inputs */
	if (VLrolLine->obj_id.objid == NULL_OBJID) goto wrapup;

	/* Get roll lines number */
        dummyID.objid = NULL_OBJID;
        dummyID.osnum = VLrolLine->obj_id.osnum;
        sts = vl$return_foot ( msg     = msg,
                               name    = "contents:RolLineNumber",
                               objId   = &(VLrolLine->obj_id),
                               objEnv  = &(VLrolLine->mod_env),
                               footId  = &dummyID );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(contents:RolLineNumber)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        sts = om$send ( msg = message expression.NDgive_value (&dVal),
			senderid = NULL_OBJID,
                        targetid = dummyID.objid,
                        targetos = dummyID.osnum );
        as$status ( sts    = sts,
                    msg    = "expression.NDgive_value(count)",
                    test   = (!(sts & 0x00000001)),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*count = dVal;

	/* Exit if no roll lines */
	if ((*count)<1) goto wrapup;

        /* Retrieve plane ID thru pretend (if any) */
        sts = vl$return_foot ( msg    = msg,
                               objId  = plane_id,
                               footId = &dummyID );
        if (!((*msg)&1&sts))    dummyID = *plane_id;

        /* Retrieve section plane */
	Splane.point  = point;
        Splane.normal = normal;
        sts = om$send ( msg      = message GRvg.GRdetplane (
                                        msg,
                                        &Env->md_env.matrix_type,
                                        Env->md_env.matrix,
                                        &Splane ),
                        senderid = NULL_OBJID,
                        targetid = dummyID.objid,
                        targetos = dummyID.osnum );
        as$status ( sts    = sts,
                    msg    = "GRvg.GRdetplane",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory*/
	(*traces) = om$calloc ( num = *count, structure = IGRpoint);
	
	/* Get 1st roll line */
	sts = VLgetRollLineTrace ( msg,
				   VLrolLine,
				   VLFirstRolName,
				   &Splane,
				   &(*traces)[0] );
        as$status ( sts    = sts,
                    msg    = "VLgetRollLineTrace(VLFirstRolName)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get 2nd roll line (if any) */
	if (*count > 1) {
		sts = VLgetRollLineTrace ( msg,
					   VLrolLine,
					   VLSecondRolName,
					   &Splane,
					   &(*traces)[1] );
	        as$status ( sts    = sts,
       		            msg    = "VLgetRollLineTrace(VLSecondRolName)",
       		            test   = (!(sts & 0x00000001 & (*msg))),
       		            action = GOTO_VALUE,
       		            value  = wrapup );
	}

	/* Get 3rd roll line (if any) */
	if (*count > 2) {
		sts = VLgetRollLineTrace ( msg,
					   VLrolLine,
					   VLThirdRolName,
					   &Splane,
					   &(*traces)[2] );
	        as$status ( sts    = sts,
       		            msg    = "VLgetRollLineTrace(VLThirdRolName)",
       		            test   = (!(sts & 0x00000001 & (*msg))),
       		            action = GOTO_VALUE,
       		            value  = wrapup );
	}

	/* Get 4th roll line (if any) */
	if (*count > 3) {
		sts = VLgetRollLineTrace ( msg,
					   VLrolLine,
					   VLFourthRolName,
					   &Splane,
					   &(*traces)[3] );
	        as$status ( sts    = sts,
       		            msg    = "VLgetRollLineTrace(VLFourthRolName)",
       		            test   = (!(sts & 0x00000001 & (*msg))),
       		            action = GOTO_VALUE,
       		            value  = wrapup );
	}

	/* Get 5th roll line (if any) */
	if (*count > 4) {
		sts = VLgetRollLineTrace ( msg,
					   VLrolLine,
					   VLFifthRolName,
					   &Splane,
					   &(*traces)[4] );
	        as$status ( sts    = sts,
       		            msg    = "VLgetRollLineTrace(VLFifthRolName)",
       		            test   = (!(sts & 0x00000001 & (*msg))),
       		            action = GOTO_VALUE,
       		            value  = wrapup );
	}

wrapup:
	return (sts);
	
/* End of function */
}
/* ========================================================================== */

/* ========================================================================== */
IGRlong VLsetRollLineTraces  (       	IGRlong         *msg,
					IGRpoint	trace,
					IGRdouble	Tsize,
					IGRdouble	loc_mat[],
				struct	GRmd_env	*Env,
				struct	GRvg_construct	*Cst,
				struct	GRid		*markID,
				struct	GRid		*textID	)

/*h 10/02/00 : creation by Marc FOURNIER (COC Shipbuilding, Paris office). */

{
/* Beginning of function */

		IGRlong		sts=OM_S_SUCCESS;
		IGRchar		txt[DI_PATH_MAX];
                IGRdouble       W, H, WHmax;
        struct  GRdpb_text_symb text_symb;
                IGRint          size=sizeof(struct GRdpb_text_symb), len, i;
                IGRlong         ret;
		IGRpoint	cnt;
		IGRvector	yvec;


        /* Retrieve text symbology */
        gr$get_text_symb ( msg    = msg,
                           sizbuf = &size,
                           buffer = &text_symb,
                           nret   = &ret );
        if (Tsize > 0.0) {      text_symb.Active_width  = Tsize;
                                text_symb.Active_height = Tsize;        }
        W = text_symb.Active_width;
        H = text_symb.Active_height;
        if (W > H)      WHmax = W;
        else            WHmax = H;

	/* Place RollLine symbol */
        txt[0] = '\0';
        sprintf ( txt, "%s", "RL");
        len = strlen(txt);
        text_symb.Active_just = CENTER_CAP;
        sts = co$place_text ( msg               = msg,
                              text_string       = txt,
                              text_length       = &len,
                              lbs_matrix        = loc_mat,
                              origin            = trace,
                              TextSymb          = &text_symb,
                              mode              = GRbe,
                              flags             = 1,
                              buffer            = textID );
        as$status ( sts    = sts,
                    msg    = "co$place_text()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Place RoolLine mark */
	yvec[0]=loc_mat[1];
	yvec[1]=loc_mat[5];
	yvec[2]=loc_mat[9];
        for ( i=0; i<3; i++)    cnt[i] = trace[i] -1.5*H*yvec[i];
        sts = VLcreateLineSeg ( cnt, trace, Env, Cst, markID, msg);
        as$status ( sts    = sts,
                    msg    = "VLcreateLineSeg()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup:
	return (sts);
	
/* End of function */
}
/* ========================================================================== */
	
end implementation VLabstract;
