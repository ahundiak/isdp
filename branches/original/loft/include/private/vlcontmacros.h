/* $Id: vlcontmacros.h,v 1.1.1.1 2001/01/04 21:11:12 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/include/private / vlcontmacros.h
 *
 * Description:	macros for contour and control line creation.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vlcontmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:12  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:05:56  pinnacle
 * Loft 250
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	03/28/97   MF		creation.
 *	04/08/97   MF		prototype error in VLexternalContour().
 *************************************************************************/

#ifndef vlcontmacros_include
#define	vlcontmacros_include

/* ************************************************************************** */
/*				Functions prototypes			      */
/* ************************************************************************** */

#include	"gr.h"
#include	"igrdp.h"
#include	"go.h"
#include	"macro.h"
#include	"dp.h"
#include	"nddef.h"
#include	"OMminimum.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VLcontAlgo.I */
IGRlong	VLdotProduct	__((			IGRlong		*msg,
						IGRvector	ve1,
					struct	GRobj_env	*cv1,
						IGRpoint	sp1,
						IGRdouble	sw1,
						IGRpoint	ep1,
						IGRdouble	ew1,
						IGRint		nm1,
						IGRvector	ve2,
					struct	GRobj_env	*cv2,
						IGRpoint	sp2,
						IGRdouble	sw2,
						IGRpoint	ep2,
						IGRdouble	ew2,
						IGRint		nm2,
						IGRdouble	*dot	));

IGRlong VLexternalContour	__((		IGRlong		*msg,
						IGRint		num,
					struct	GRobj_env	*srf,
					struct	GRobj_env	*plt,
						IGRchar		*side,
					struct	GRmd_env	*Env,
						IGRint		*cnt,
					struct	GRobj_env	**edg,
					struct	IGRbsp_curve	***crv,
					struct	GRobj_env	*Cnt,
					struct	IGRbsp_surface	***sur,
					struct	IGRplane	*nrm	));

IGRlong VLfourEdgesContour	__((		IGRlong		*msg,
						IGRint		num,
					struct	GRobj_env	*srf,
					struct	GRobj_env	*plt,
						IGRchar		*side,
					struct	GRmd_env	*Env,
						IGRint		*cnt,
					struct	GRobj_env	**edg,
					struct	IGRbsp_curve	**crv,
					struct	GRobj_env	*Cnt,
					struct	IGRbsp_surface	**sur,
					struct	IGRplane	*nrm	));

IGRlong VLcontrolLine		__((		IGRlong		*msg,
						IGRint		num,
					struct	GRobj_env	*srf,
					struct	GRobj_env	*plt,
						IGRchar		*side,
					struct	GRmd_env	*Env,
						IGRvector	*axe,
						IGRvector	*avn,
					struct	BendingLineInfo	*Info,
					struct	GRobj_env	*Curv	));
					

#if defined(__cplusplus)
}
#endif

/* ************************************************************************** */
/*				Macro : vl$dotProduct ()		      */
/* ************************************************************************** */
/*
Abstract :
	Evaluate a dot product from various entries ( vector, curve, points )
	with a normalization option. 
	For curve and for start point + end point entries, a weight can be
	given for each point.

Arguments :
	OUT		IGRlong		*msg	 	Completion code.
	IN		IGRvector	vec1		1st vector.
	IN	struct	GRobj_env	*crv1		1st curve.
	IN		IGRpoint	sPnt1		1st start point.
	IN		IGRdouble	sWgt1		1st start point weight.
	IN		IGRpoint	ePnt1		1st end point.
	IN		IGRdouble	eWgt1		1st end point weight.
	IN		IGRint		nor1		1 : normalize resulting
							vector 1.
							0 : don't normalize.
	IN		IGRvector	vec2		2nd vector.
	IN	struct	GRobj_env	*crv2		2nd curve.
	IN		IGRpoint	sPnt2		2nd start point.
	IN		IGRdouble	sWgt2		2nd start point weight.
	IN		IGRpoint	ePnt2		2nd end point.
	IN		IGRdouble	eWgt2		2nd end point weight.
	IN		IGRint		nor2		1 : normalize resulting
							vector 2.
							0 : don't normalize.
	OUT		IGRdouble	*dot		resulting dot product.

Notes:	If (vec# == NULL)	try crv#
	If (crv# == NULL)	try sPnt# & ePnt#
	Additional weight arguments sWgt# & eWgt# aren't used if (vec# != NULL)
*/

#omdef vl$dotProduct (	msg,
			vec1=NULL ^ crv1=NULL ^ sPnt1=NULL,
			sWgt1	= 1.0,
			ePnt1	= NULL,
			eWgt1	= 1.0,
			nor1	= 1,
			vec2=NULL ^ crv2=NULL ^ sPnt2=NULL,
			sWgt2	= 1.0,
			ePnt2	= NULL,
			eWgt2	= 1.0,
			nor2	= 1,
			dot	)

#if ( (om$specified(sPnt1)) && (!om$specified(ePnt1)) )
	printf( "Error : end point lacks for 1st element\n" )
#else
#	if ( (om$specified(sPnt2)) && (!om$specified(ePnt2)) )
		printf( "Error : end point lacks for 2nd element\n" )
#	else
	VLdotProduct (	(msg),
			(vec1),
			(crv1),
			(sPnt1),
			(sWgt1),
			(ePnt1),
			(eWgt1),
			(nor1),
			(vec2),
			(crv2),
			(sPnt2),
			(sWgt2),
			(ePnt2),
			(eWgt2),
			(nor2),
			(dot)	)
#	endif
#endif

#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*				Macro : vl$externalContour ()		      */
/* ************************************************************************** */
/*
Abstract :
	Extract contour edges of a group of surfaces (or VSplates).
	Find the external edges.
	Outputs are a copy of the external contour edges or a closed
	composite curve built on these edges.

Arguments :
	OUT		IGRlong		*msg	Completion code.
	IN		IGRint		num	Number of surfaces|VSplates.
	IN	struct	GRobj_env	*Surf	Array of surfaces.
	IN	struct	GRobj_env	*Plat	Array of VSplates.
	IN		IGRchar		side	Path to surface, for VSplates.
	IN	struct	GRmd_env	*Env	Current environment.
	IN		IGRboolean	Four	Four edges if possible.
	OUT		IGRint		*nEdg	Number of ext. cont. edges.
	OUT	struct	GRobj_env	**Edge	Array of ext. cont. edges.
						Must be freed by caller with
						om$dealloc().
	OUT	struct	IGRbsp_curve	***crv	Geometry of (Edge).
						Must be freed by caller with
						om$dealloc().
	OUT	struct	GRid		*Cont	Composite contour curve.
	OUT	struct	IGRbsp_surface	***srf	Geom. of (Surf) or (Plat):(side)
						Must be freed by caller with
						om$dealloc().
	OUT	struct	IGRplane	*Norm	Average normal plane.

Notes :
	if (Surf) isn't NULL and (Plat) is NULL, work is done on (Surf).
	if (Plat) isn't NULL and (Surf) is NULL, work is done on (Plat):(side).

	To deallocate (crv) :

	call :	struct	IGRbsp_curve	**geom=NULL;
		IGRint			count=0;
		vl$externalContour ( ...
				     num = &count,
				     crv = &geom,
				     ... );
			:
			:
		if (crv) {
			for ( i=0; i<count; i++ ) {
				if (crv[i]) {
					om$dealloc (ptr = crv[i]);
					crv[i] = 0;
				}
			}
			om$dealloc (ptr = crv);
			crv = NULL;
		}

	To deallocate (srf) see "To deallocate (crv)".
*/

#omdef vl$externalContour (	msg,
				num,
				Surf=NULL ^ Plat=NULL,
				side="",
				Env,
				Four=FALSE,
				nEdg=NULL,
				Edge=NULL,
				crv=NULL,
				Cont=NULL,
				srf=NULL,
				Norm=NULL	)
#if om$equal ( Four, FALSE )
	VLexternalContour (	(msg),
				(num),
				(Surf),
				(Plat),
				(side),
				(Env),
				(nEdg),
				(Edge),
				(crv),
				(Cont),
				(srf),
				(Norm)	)
#else
	VLfourEdgesContour (	(msg),
				(num),
				(Surf),
				(Plat),
				(side),
				(Env),
				(nEdg),
				(Edge),
				(crv),
				(Cont),
				(srf),
				(Norm)	)
#endif

#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*				Macro : vl$controlLine ()		      */
/* ************************************************************************** */
/*
Abstract :
	Creates the control line of a group of surfaces (or VSplates).
	Find the external edges. Convert to 4 edges contour.
	Creates a Bspline curve (Curv) and an optional structure (Info).

Arguments :
	OUT		IGRlong		*msg	Completion code.
	IN		IGRint		num	Number of surfaces|VSplates.
	IN	struct	GRobj_env	*Surf	Array of surfaces.
	IN	struct	GRobj_env	*Plat	Array of VSplates.
	IN		IGRchar		side	Path to surface, for VSplates.
	IN	struct	GRmd_env	*Env	Current environment.
	IN		IGRvector	*Axis	Main axis of the control line.
	IN		IGRvector	*Norm	Normal of the control line.
	OUT	struct	BendingLineInfo	*Info	Internal infos.
	OUT	struct	GRobj_env	*Curv	Resulting control line.

Notes :
	if (Surf) isn't NULL and (Plat) is NULL, work is done on (Surf).
	if (Plat) isn't NULL and (Surf) is NULL, work is done on (Plat):(side).
	if (Axis) is NULL, [1,0,0] is taken.
	if (Norm) is NULL, average normal of (Surf) or (Plat):(side) is taken.
	(Info) is optional.
*/

#omdef vl$controlLine (	msg,
			num,
			Surf=NULL ^ Plat=NULL,
			side="",
			Env,
			Axis=NULL,
			Norm=NULL,
			Info=NULL,
			Curv	)

	VLcontrolLine (	(msg),
			(num),
			(Surf),
			(Plat),
			(side),
			(Env),
			(Axis),
			(Norm),
			(Info),
			(Curv)	)

#endomdef
/* ************************************************************************** */

#endif
