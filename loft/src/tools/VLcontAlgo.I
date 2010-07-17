/* $Id: VLcontAlgo.I,v 1.1.1.1 2001/01/04 21:11:40 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/tools / VLcontAlgo.I
 *
 * Description:	contour and control line functions called by vlcontmacros.h
 *		macros. Override most of VLcontFunk.I functions.
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLcontAlgo.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  2000/01/11  21:28:00  pinnacle
# (No comment)
#
# Revision 1.2  1999/04/09  21:24:54  pinnacle
# Rama Rao SP08
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.8  1998/04/15  09:57:18  pinnacle
# Replaced: src/tools/VLcontAlgo.I for:  by rchennup for loft
#
# Revision 1.7  1998/04/14  14:16:20  pinnacle
# Replaced: src/tools/VLcontAlgo.I for:  by l250_int for loft
#
# Revision 1.6  1998/04/14  10:11:46  pinnacle
# Replaced: src/tools/VLcontAlgo.I for:  by rchennup for loft
#
# Revision 1.5  1998/04/14  09:26:28  pinnacle
# Replaced: src/tools/VLcontAlgo.I for:  by rchennup for loft
#
# Revision 1.2  1998/04/06  08:25:10  pinnacle
# Replaced: src/tools/VLcontAlgo.I for:  by rchennup for loft
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.6  1997/04/11  18:07:26  pinnacle
# Replaced: src/tools/VLcontAlgo.I for: order edges in VLexternalContour() by mfournie for loft
#
# Revision 1.5  1997/04/09  14:20:38  pinnacle
# Replaced: src/tools/VLcontAlgo.I for: error in VLfourEdgesContour() by mfourni
e for loft
#
# Revision 1.3  1997/04/07  13:40:32  pinnacle
# Replaced: src/tools/VLcontAlgo.I for: File header added by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/03/97   mf		file creation.
 *	04/07/97   mf		header creation.
 *	04/09/97   mf		error in VLfourEdgesContour().
 *	04/11/97   mf		order edges in VLexternalContour().
 *	04/14/98   adz/ramu	Change the ENget-edges call().
 *      04/09/99   ah           Rama Rao SP08 Fixes
 *************************************************************************/
class implementation VLabstract;

#include	<stdio.h>
#include	<math.h>
#include	"vlprototype.h"
#include	"OMerrordef.h"
#include	"AS_status.h"
#include	"ACattrib.h"
#include	"EMSlcdef.h"
#include	"msdef.h"
#include	"grmacros.h"
#include	"cotxmacros.h"
#include	"bsparameters.h"
#include	"bserr.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asbox.h"
#include        "EMSopt.h"
#include        "EMSmsgdef.h"

#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsnorvec.h"
#include	"bssfevaln.h"
#include	"bspj_pt_sf.h"
#include	"bsxtractpar.h"

#include	"vsmiscmacros.h"
#include	"vsedgedef.h"
#include	"vsedgemacros.h"
#include	"vsgeommacros.h"

#include	"vlmiscmacros.h"
#include	"vlcontmacros.h"

/*
#define	TRACE
*/

#define	VL_TOL_BAS	0
#define	VL_TOL_CHT	1
#define	VL_TOL_SEA	2
#define	VL_TOL_GAP	3

from    EMSsurface	import		EMgetedges;
from    EMSsubbs	import		EMget_edges;
from    EMSedge		import 		GRcopy, EMgetxyzobj;

/* ************************************************************************** */
IGRdouble	VLtol (	IGRint	idx	)
{
	IGRdouble	tol=0.0;
	BSrc		rc=BSSUCC;

	switch (idx) {

		case VL_TOL_BAS:	/* BASE TOLERANCE	*/
			BSxtractpar ( &rc, BSTOLBASIS, &tol);
			break;

		case VL_TOL_CHT:	/* CHORD HEIGHT		*/
			BSxtractpar ( &rc, BSTOLCHRDHT, &tol);
			break;

		case VL_TOL_SEA:	/* SEARCH TOLERANCE	*/
			tol = 5.0 * VLtol (VL_TOL_CHT);
			break;

		case VL_TOL_GAP:	/* PLATE GAP VALUE	*/
			tol = 2.0 * VLtol (VL_TOL_SEA);
			tol = 10.0;
			break;

		default:
			printf( "Unknown request : VLtol (%d)\n", idx );
			break;
	}
	if (rc != BSSUCC)	tol = 0.0;

	return (tol);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLdotProduct

/* -------------------------------------------------------------------- */
/*	This function must be called by the macro vl$dotProduct().	*/
/*	Marc Fournier, INGR-France :	28-MAR-1997 creation		*/
/* -------------------------------------------------------------------- */

(
	IGRlong		*msg,	/* O	Completion code			*/
	IGRvector	ve1,	/* I	Vector 1			*/
struct	GRobj_env	*cv1,	/* I	Curve 1				*/
	IGRpoint	sp1,	/* I	Start point 1			*/
	IGRdouble	sw1,	/* I	Weight start point 1		*/
	IGRpoint	ep1,	/* I	End point 1			*/
	IGRdouble	ew1,	/* I	Weight end point 1		*/
	IGRint		nm1,	/* I	Normalize vector 1 : 1 else 0	*/
	IGRvector	ve2,	/* I	Vector 2			*/
struct	GRobj_env	*cv2,	/* I	Curve 2				*/
	IGRpoint	sp2,	/* I	Start point 2			*/
	IGRdouble	sw2,	/* I	Weight start point 2		*/
	IGRpoint	ep2,	/* I	End point 2			*/
	IGRdouble	ew2,	/* I	Weight end point 2		*/
	IGRint		nm2,	/* I	Normalize vector 2 : 1 else 0	*/
	IGRdouble	*dot	/* O	Dot product vector 1 & vector 2	*/
)
{		
	IGRlong		sts=OM_S_SUCCESS;
	IGRvector	v1, v2;
	IGRpoint	spt, ept;
	IGRint		i;
	IGRboolean	nrm=FALSE;
	BSrc		rc;

	/* Initialize */
	*dot = 0.0;

	/* Treat various entries for 1 */
	if (ve1) {
		for ( i=0; i<3; i++ )	v1[i] = ve1[i];
		if (nm1)		BSnorvec ( &rc, v1 );
	}
	else {
		if (cv1) {
			sts = VLendpts ( msg, &cv1->obj_id, &cv1->mod_env,
					 spt, ept );
			as$status ( sts    = sts,
				    msg    = "VLendpts(curve 1)",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
#ifdef TRACE
printf( "cv1 [%d|%d] from [%g,%g,%g] to [%g,%g,%g]\n",
	cv1->obj_id.osnum, cv1->obj_id.objid,
	spt[0], spt[1], spt[2], ept[0], ept[1], ept[2] );
#endif
		}
		else	for ( i=0; i<3; i++ ) {
				spt[i] = sp1[i];
				ept[i] = ep1[i];	}

		/* Make vector 1 */
		if (nm1 == 1)	nrm = TRUE;
		else		nrm = FALSE;
		sts = VLvector ( msg, spt, ept, sw1, ew1, nrm, v1 );
		as$status ( sts    = sts,
			    msg    = "VLvector(vector 1)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
#ifdef TRACE
printf( "v1 = [%g,%g,%g]\n", v1[0], v1[1], v1[2] );
#endif
	}

	/* Treat various entries for 2 */
	if (ve2) {
		for ( i=0; i<3; i++ )	v2[i] = ve2[i];
		if (nm2)		BSnorvec ( &rc, v2 );
	}
	if (ve2) {	for ( i=0; i<3; i++ )	v2[i] = ve2[i];	}
	else {
		if (cv2) {
			sts = VLendpts ( msg, &cv2->obj_id, &cv2->mod_env,
					 spt, ept );
			as$status ( sts    = sts,
				    msg    = "VLendpts(curve 2)",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
#ifdef TRACE
printf( "cv2 [%d|%d] from [%g,%g,%g] to [%g,%g,%g]\n",
	cv2->obj_id.osnum, cv2->obj_id.objid,
	spt[0], spt[1], spt[2], ept[0], ept[1], ept[2] );
#endif
		}
		else	for ( i=0; i<3; i++ ) {
				spt[i] = sp2[i];
				ept[i] = ep2[i];	}

		/* Make vector 2 */
		if (nm2 == 1)	nrm = TRUE;
		else		nrm = FALSE;
		sts = VLvector ( msg, spt, ept, sw2, ew2, nrm, v2 );
		as$status ( sts    = sts,
			    msg    = "VLvector(vector 2)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
#ifdef TRACE
printf( "v2 = [%g,%g,%g]\n", v2[0], v2[1], v2[2] );
#endif
	}

	/* Evaluate dot product : v1.v2 */
	*dot = BSdotp ( &rc, v1, v2 );
#ifdef TRACE
printf( "dot = %g, rc=%d\n\n", (*dot), rc );
#endif
	if (rc != BSSUCC) {
		printf ( "Error %d in BSdotp()\n", rc );
		*dot = 0.0;
		*msg = MSFAIL;
	}
	
wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRdouble	VLdistance
(
	IGRpoint	p1,
	IGRpoint	p2
)
{
	IGRdouble	dist=0;
	
	dist = sqrt ( ( (p1[0] - p2[0])*(p1[0] - p2[0]) )
		    + ( (p1[1] - p2[1])*(p1[1] - p2[1]) )
		    + ( (p1[2] - p2[2])*(p1[2] - p2[2]) ) );

	return (dist);
}
/* ************************************************************************** */

/* ************************************************************************** */
void	VLalgoNodeEdge
(
	VLalgoNode	*Nod,	/* I/O		Node array		*/
	VLalgoEdge	*Edg,	/* I/O		Edge row		*/
	IGRpoint	*spt,	/* I		Start point		*/
	IGRpoint	*ept,	/* I		End point		*/
	IGRint		*nod	/* I/O		Nodes' number		*/
)
{
	IGRint		i, j;
	IGRpoint	pnt;
	IGRboolean	start=TRUE, found=FALSE;

	/* Initialize */
	if	(spt)
		for ( i=0; i<3; i++ )	pnt[i] = (*spt)[i];
	else if (ept) {
		for ( i=0; i<3; i++ )	pnt[i] = (*ept)[i];
		start = FALSE;
	}
	else	return;

	/* Search point in VLalgoNode */
	for ( i=0; i<(*nod); i++ ) {
		if ( VLdistance ( pnt, Nod[i].Pnt ) <= VLtol(VL_TOL_GAP) ) {
			found = TRUE;
			break;
		}
	}

	if (found) {	/* Node found in VLalgoNode */

		/* Average node value */
		for ( j=0; j<3; j++ )
			Nod[i].Pnt[j] = (pnt[j] + (Nod[i].Cnt * Nod[i].Pnt[j]))
				      / (Nod[i].Cnt + 1);

		/* Reference node in VLalgoEdge */
		if (start)	Edg->Sta = i;
		else		Edg->End = i;

		/* Increment node count */
		Nod[i].Cnt += 1;
	}
	else {	/* Create a new node in VLalgoNode */
		for ( j=0; j<3; j++ )	Nod[*nod].Pnt[j] = pnt[j];
		Nod[*nod].Idx = *nod;
		Nod[*nod].Cnt = 1;

		/* Reference node in VLalgoEdge */
		if (start)	Edg->Sta = *nod;
		else		Edg->End = *nod;

		/* Increment nodes' number */
		(*nod)++;
	}

}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLfindExternal
(
	IGRlong		*msg,	/* O	Completion code			*/
	IGRint		nEdg,	/* I	Number of input edges		*/
struct	GRid		*Edg,	/* I	Array of input edges		*/
struct	GRmd_env	*Env,	/* I	Current environment		*/
	IGRint		*nCnt,	/* O	Number of external contour edges*/
struct	GRobj_env	**Cnt	/* O	Array of external contour edges	*/
)
{
	IGRlong		sts=OM_S_SUCCESS;
	VLalgoNode 	*Node=NULL;
	VLalgoEdge 	*Edge=NULL;
	IGRint		i, j, k, ind, ind1, nod=0, cnt=0;
	IGRpoint	spt, ept;

	/* Initialize */
	*nCnt = 0;
	*Cnt  = NULL;

	/* Check entries */
	if ( (!nEdg) || (!Edg) ) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Allocate memory */
	Node = om$calloc ( num = 2 * nEdg, structure = VLalgoNode );
	Edge = om$calloc ( num = nEdg,     structure = VLalgoEdge );

	/* STEP 1 : fill arrays */
	for ( i=0; i<nEdg; i++ ) {

		/* Get edge endpoints */
		sts = VLendpts ( msg, &Edg[i], Env, spt, ept );
		as$status ( sts    = sts,
			    msg    = "VLendpts(edge)",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		Edge[i].Idx = i;
		Edge[i].Obj = Edg[i];
		Edge[i].Ext = TRUE;

		/* Check start point */
		VLalgoNodeEdge ( Node, &Edge[i], &spt, NULL, &nod );

		/* Check end point */
		VLalgoNodeEdge ( Node, &Edge[i], NULL, &ept, &nod );
	}
#ifdef TRACE
printf( "\n" );
for ( i=0; i<nEdg; i++ )
	printf( "Edge %d from node %d to node %d\n", 
		Edge[i].Idx, Edge[i].Sta, Edge[i].End );
printf( "\n" );
for ( i=0; i<nod; i++ )
	printf( "Node %d is [%g,%g,%g]\n",
		Node[i].Idx, Node[i].Pnt[0], Node[i].Pnt[1], Node[i].Pnt[2] );
#endif
	/* STEP 2 : eliminate internal edges */
	for ( i=0; i<nEdg; i++ ) {
		if (Edge[i].Ext == TRUE) {
			for ( j=0; j<nEdg; j++ ) {
				if( i == j ) continue;	
				if (  (  (Edge[i].Sta == Edge[j].Sta)
				      && (Edge[i].End == Edge[j].End) )
				   || (  (Edge[i].Sta == Edge[j].End)
				      && (Edge[i].End == Edge[j].Sta) ) ) {
					VLalgoEdge temp_edge1, temp_edge2, temp_edge3, temp_edge4;
					IGRint	nb_edges1=0, *edges1=NULL;
					IGRint	nb_edges2=0, *edges2=NULL;
					IGRint	ind1_edge=i, ind2_edge=j;
					IGRboolean to_skip=FALSE;

					temp_edge1.Sta = temp_edge1.End = -1;
					temp_edge2.Sta = temp_edge2.End = -1;
					temp_edge3 = Edge[i];
					temp_edge4 = Edge[j];
skip:
					nb_edges1=nb_edges2=0;
					_FREE( edges1);
					_FREE( edges2);

					edges1 = _MALLOC( nEdg, IGRint );
					edges2 = _MALLOC( nEdg, IGRint );

					for( k=0; k<nEdg; k++ )
					{
			  		  if (Edge[k].Ext == TRUE)
					  if( k!=ind1_edge && k!=ind2_edge )
					  {
					    if( temp_edge3.Sta == Edge[k].Sta )
					    {
						if( temp_edge1.Sta == -1 )
						{
						  temp_edge1.Sta = Edge[k].End;
						  edges1[nb_edges1++] = k;
						}
						else
						{
						  temp_edge1.End = Edge[k].End;
						  edges1[nb_edges1++] = k;
						}
					    }
					    if( temp_edge3.Sta == Edge[k].End )
					    {
						if( temp_edge1.Sta == -1 )
						{
						  temp_edge1.Sta = Edge[k].Sta;
						  edges1[nb_edges1++] = k;
						}
						else
						{
						  temp_edge1.End = Edge[k].Sta;
						  edges1[nb_edges1++] = k;
						}
					    }

					    if( temp_edge3.End == Edge[k].Sta )
					    {
						if( temp_edge2.Sta == -1 )
						{
						  temp_edge2.Sta = Edge[k].End;
						  edges2[nb_edges2++] = k;
						}
						else
						{
						  temp_edge2.End = Edge[k].End;
						  edges2[nb_edges2++] = k;
						}
					    }
					    if( temp_edge3.End == Edge[k].End )
					    {
						if( temp_edge2.Sta == -1 )
						{
						  temp_edge2.Sta = Edge[k].Sta;
						  edges2[nb_edges2++] = k;
						}
						else
						{
						  temp_edge2.End = Edge[k].Sta;
						  edges2[nb_edges2++] = k;
						}
					    }
				          }
					}

					Edge[i].Ext = FALSE;
					Edge[j].Ext = FALSE;


			for ( ind=0; ind<nEdg; ind++ ) {
				if (  (  (temp_edge1.Sta == Edge[ind].Sta)
				      && (temp_edge1.End == Edge[ind].End) )
				   || (  (temp_edge1.Sta == Edge[ind].End)
				      && (temp_edge1.End == Edge[ind].Sta) ) ) {

				   Edge[ind].Ext = FALSE;
				   ind1_edge = ind;
				   temp_edge3 = Edge[ind];
				   temp_edge1.Sta = temp_edge1.End = temp_edge2.Sta = temp_edge2.End = -1;

				   for( ind1=0; ind1<nb_edges1; ++ind1 )
				        Edge[edges1[ind1]].Ext = FALSE;
				   to_skip = TRUE;
				 }
				}


			for ( ind=0; ind<nEdg; ind++ ) {
				if (  (  (temp_edge2.Sta == Edge[ind].Sta)
				      && (temp_edge2.End == Edge[ind].End) )
				   || (  (temp_edge2.Sta == Edge[ind].End)
				      && (temp_edge2.End == Edge[ind].Sta) ) ) {

				   Edge[ind].Ext = FALSE;
				   ind2_edge = ind;
				   temp_edge4 = Edge[ind];
				   temp_edge1.Sta = temp_edge1.End = temp_edge2.Sta = temp_edge2.End = -1;

				   for( ind1=0; ind1<nb_edges2; ++ind1 )
				        Edge[edges2[ind1]].Ext = FALSE;
				   to_skip = TRUE;
				 }
				}
                                if( to_skip )
                                {
                                    to_skip = FALSE;
                                    goto skip;
                                }

				j = nEdg;
				_FREE( edges1 );
				_FREE( edges2 );
			   }
			}
		}
	}
#ifdef TRACE
printf( "\n" );
for ( i=0; i<nEdg; i++ )
	printf( "Edge %d from node %d to node %d, external=%d\n", 
		Edge[i].Idx, Edge[i].Sta, Edge[i].End, Edge[i].Ext );
#endif
	/* STEP 3 : Get external edges */
	for ( i=0; i<nEdg; i++ ) {
		if (Edge[i].Ext == TRUE)	(*nCnt)++;
	}
	/* Allocate memory */
	if ( (*nCnt) <= 0 ) {
		*msg = MSFAIL;
		goto wrapup;
	}
	else	*Cnt = om$calloc ( num	     = (*nCnt),
				   structure = struct GRobj_env );
	/* Fill edges array */
	cnt=0;
	for ( i=0; i<nEdg; i++ ) {
		if (Edge[i].Ext == TRUE) {
			(*Cnt)[cnt].mod_env = *Env;
			sts = gr$copy_object (
					msg	     = msg,
					object_id    = &Edge[i].Obj,
					md_env	     = Env,
					new_env	     = &(*Cnt)[cnt].mod_env,
					new_id	     = &(*Cnt)[cnt].obj_id,
					display_flag = 0 );
			as$status ( sts    = sts,
				    msg    = "gr$copy_object()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
			cnt++;
		}
	}
		
	*msg = MSSUCC;

wrapup:
	if (Node) {	om$dealloc (ptr = Node);	Node = NULL;	}
	if (Edge) {	om$dealloc (ptr = Edge);	Edge = NULL;	}
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLgetSupportSurfaces
(
	IGRlong		*msg,	/* O	Completion code			*/
	IGRint		num,	/* I	Number of VSplates|surfaces	*/
struct	GRobj_env	*srf,	/* I	Array of surfaces		*/
struct	GRobj_env	*plt,	/* I	Array of VSplates		*/
	IGRchar		*side,	/* I	Base or offset surface(s)	*/
struct	GRmd_env	*Env,	/* I	Current environment		*/
struct	GRobj_env	**sup,	/* I	Copies of support surfaces	*/
struct	IGRbsp_surface	***sur	/* O	Array of surfaces geometry	*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
)
{
	IGRlong		sts=OM_S_SUCCESS;
	IGRint		i;
struct	GRobj_env	dummyOE;

	/* Initialize */
	*sup = NULL;
	if (sur)	*sur = NULL;

	/* Check entries */
	if ( (!num) || ( (!plt) && (!srf) ) ) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Allocate memory */
	*sup = om$calloc ( num = num, structure = struct GRobj_env );
	if (sur) *sur = om$calloc ( num	      = num,
				    structure = struct IGRbsp_surface * );

	/* Fill Srf array */
	for ( i=0; i<num; i++ ) {

		if (srf) {

			/* Copy surface to local array */
			(*sup)[i].mod_env	= *Env;
			(*sup)[i].obj_id.objid	= NULL_OBJID;
			(*sup)[i].obj_id.osnum	= Env->md_id.osnum;
			sts = gr$copy_object ( msg	   = msg,
					       object_id   = &srf[i].obj_id,
					       md_env	   = &srf[i].mod_env,
					       new_env	   = &(*sup)[i].mod_env,
					       new_id	   = &(*sup)[i].obj_id,
					       display_flag= 0 );
			as$status ( sts    = sts,
				    msg    = "gr$copy_object()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}

		else if (plt) {

			/* Extract <side> surface from VSplate */
			dummyOE.mod_env		= *Env;
			dummyOE.obj_id.objid	= NULL_OBJID;
			dummyOE.obj_id.osnum	= Env->md_id.osnum;
			sts = vl$return_foot ( msg	= msg,
					       name	= side,
					       objId	= &plt[i].obj_id,
					       objEnv	= &plt[i].mod_env,
					       footId	= &dummyOE.obj_id,
					       footEnv	= &dummyOE.mod_env );
			as$status ( sts    = sts,
				    msg    = "vl$return_foot()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			/* Copy surface to local array */
			(*sup)[i].mod_env	= *Env;
			(*sup)[i].obj_id.objid	= NULL_OBJID;
			(*sup)[i].obj_id.osnum	= Env->md_id.osnum;
			sts = gr$copy_object ( msg	   = msg,
					       object_id   = &dummyOE.obj_id,
					       md_env	   = &dummyOE.mod_env,
					       new_env	   = &(*sup)[i].mod_env,
					       new_id	   = &(*sup)[i].obj_id,
					       display_flag= 0 );
			as$status ( sts    = sts,
				    msg    = "gr$copy_object()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );
		}

		/* Get surface geometry (if needed) */
		if (sur) {
			sts = VLgetGeometry ( &(*sup)[i], FALSE, NULL_OBJID,
					      (IGRchar **) &(*sur)[i], msg );
			as$status ( sts    = sts,
		                    msg    = "VLgetGeometry()",
		              	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}
wrapup:
	return (sts);	
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexternalContour

/* -------------------------------------------------------------------- */
/*	This function computes the external contour of set of surfaces	*/
/*	History :	15-JAN-1997	1st implementation by RC	*/
/*			28-MAR-1997	vl$externalContour by MF	*/
/* -------------------------------------------------------------------- */

(
	IGRlong		*msg,	/* O	Completion code			*/
	IGRint		num,	/* I	Number of VSplates|surfaces	*/
struct	GRobj_env	*srf,	/* I	Array of surfaces		*/
struct	GRobj_env	*plt,	/* I	Array of VSplates		*/
	IGRchar		*side,	/* I	Base or offset surface(s)	*/
struct	GRmd_env	*Env,	/* I	Current environment		*/
	IGRint		*cnt,	/* O	Number of edges of the contour	*/
				/*	Can be a NULL pointer		*/
struct	GRobj_env	**edg,	/* O	Array of edges of the contour 	*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
struct	IGRbsp_curve	***crv,	/* O	Array of edges geometry		*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
struct	GRobj_env	*Cnt,	/* O	External contour		*/
struct	IGRbsp_surface	***sur,	/* O	Array of surfaces geometry	*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
struct	IGRplane	*nrm	/* O	Average plane of surf.|VLplates	*/
)
{
	IGRlong		sts=OM_S_SUCCESS, ret;
	IGRint		i, j, buf_size=0, count=0, nEdg=0, siz=sizeof(struct GRid);
	GRobjid		xyzobj;
struct	GRobj_env	*Srf=NULL, *contOE=NULL, *Icrv=NULL, *Ocrv=NULL;
struct	GRid		*listID=NULL, *edgeID=NULL;
	IGRshort	*Orie=NULL;
	IGRboolean	adj, clo;

	/* Initialize */
	if (cnt)	*cnt = 0;
	if (edg)	*edg = NULL;
	if (crv)	*crv = NULL;
	if (Cnt)	Cnt->obj_id.objid = NULL_OBJID;

	/* Check number of elements */
	if (num <= 0) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Get support surfaces */
	sts = VLgetSupportSurfaces ( msg, num, srf, plt, side, Env,
				     &Srf, sur );
	as$status ( sts    = sts,
		    msg    = "VLgetSupportSurfaces()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Compute average normal (if needed) */
	if ( (nrm) && (nrm->point) && (nrm->normal) ) {
		sts = VLevalAvNor ( Srf, num, nrm->point, nrm->normal, msg );
		as$status ( sts    = sts,
			    msg    = "gr$copy_object()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

	/* Get edges of Srf */
	for ( i=0; i<num; i++ ) {

		/* Free and initialize */
		if (listID) {
			free (listID);
			listID = NULL;
			count  = 0;
		}

		sts = vs$make_natural_boundary( msg         =  msg, 
					        surfaceEnv  =  &Srf[i].mod_env, 
					        surfaceId   =  &Srf[i].obj_id );
		as$status ( sts    = sts,
			    msg    = "vs$get_surface_edges()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		count    = 0;
		buf_size = 0;
/**
		sts = om$send(msg = message EMSsurface.EMgetedges(
                                		msg,
						1,
                                		EMS_OPT_CONNECTABLE,
                                		&listID,
                                		&buf_size,
                                		&count,
                                		NULL,
                                		NULL,
                                		NULL,
                                		NULL),
 **/
		sts = om$send(msg = message EMSsubbs.EMget_edges(
						msg,
						1,	/* Only external */
						EMS_OPT_ALL,
						&Srf[i].mod_env,
						&listID,
						&buf_size,
						&count ),
			senderid = NULL_OBJID,
        		targetid = Srf[i]._objid,
        		targetos = Srf[i]._osnum) ;

		if (!(sts & 1)) {
        	 #ifdef DEBUG
        	 printf("Problem when sending EMSsurface.EMgetedges() message \n") ;
        	 #endif
        	 goto wrapup ;
        	}

		if ( *msg != EMS_S_Success ) {
        	  #ifdef DEBUG
        	     printf("Error in processing EMSsurface.EMgetedges() message \n") ;
        	  #endif
        	  goto quit ;
        	}

	        if (count == 0) {
        	  #ifdef DEBUG
        	    printf("VLexternalContour() : no connectable edge found\n");
        	  #endif
		  goto wrapup;
        	}


		/* Resize memory */
		if (!edgeID)	edgeID = om$calloc ( num = count,
						     structure = struct GRid );
		else	edgeID = (struct GRid *)om$realloc (
						ptr  = (IGRchar *)edgeID,
						size = (nEdg+count) * siz );

		for ( j=0 ; j<count ; ++j )
		{
        	  sts = om$send(msg = message EMSedge.EMgetxyzobj(
                                        msg,
                                        0,
                                        &Srf[i].mod_env.md_env,
                                        NULL,           /* xyzcv     */
                                        NULL,           /* xyzcvtype */
                                        NULL,
                                        NULL,           /* xyzattr   */
                                        Srf[i]._osnum,      /* xyzos     */
                                        &xyzobj ),       /* Output    */
			senderid = NULL_OBJID,
                   	targetid = listID[j].objid,
                   	targetos = listID[j].osnum) ;

		  edgeID[nEdg+j].osnum = Env->md_id.osnum ;

        	  sts = om$send(  msg = message EMSedge.GRcopy( 
							msg,
                                                        &Srf[i].mod_env,
                                                        Env,
                                                        &edgeID[nEdg+j].objid ),
			senderid = NULL_OBJID,
                        targetid = xyzobj,
                        targetos = Srf[i]._osnum) ;

		}
		/* Increment counter */
		nEdg += count;
	}

	/* Find external edges from a bunch of edges */
	count=0;
	sts = VLfindExternal ( msg, nEdg, edgeID, Env, &count, &contOE );
	as$status ( sts    = sts,
		    msg    = "VLfindExternal()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Order external edges */
	Icrv = om$calloc ( num = count, structure = struct GRobj_env );
	for ( i=0; i<count; i++ )	Icrv[i]= contOE[i];
	Ocrv = om$calloc ( num = count, structure = struct GRobj_env );
	Orie = om$calloc ( num = count, structure = IGRshort );
#ifdef TRACE
printf( "\n" );
for ( i=0; i<count; i++ )
printf( "Icrv %d is [%d|%d]\n", i, Icrv[i].obj_id.osnum, Icrv[i].obj_id.objid );
#endif
	sts = OrderCrv ( Icrv, count, VLtol(VL_TOL_GAP), VLtol(VL_TOL_BAS),
			 Ocrv, Orie, &adj, &clo, msg );
	if ((*msg) == BSSUCC)	*msg = MSSUCC;
	else			*msg = MSFAIL;
	as$status ( sts    = sts,
		    msg    = "OrderCrv()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
#ifdef TRACE
printf( "\n" );
for ( i=0; i<count; i++ )
printf( "Ocrv %d is [%d|%d], orient=%d\n",
	i, Ocrv[i].obj_id.osnum, Ocrv[i].obj_id.objid, Orie[i] );
#endif

	/* Build outputs */
	if (cnt)	*cnt = count;
	if (edg) {
		*edg = om$calloc ( num = count, structure = struct GRobj_env );
		for ( i=0; i<count; i++ )	(*edg)[i] = Ocrv[i];
	}
	if (crv) {
		*crv = om$calloc ( num       = count,
				   structure = struct IGRbsp_curve * );
		for ( i=0; i<count; i++ ) {
			sts = VLgetGeometry ( &Ocrv[i], FALSE, NULL_OBJID,
					      (IGRchar **) &(*crv)[i], msg );
			as$status ( sts    = sts,
		                    msg    = "VLgetGeometry()",
		              	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}
	else if (Cnt) {
		struct	GRvg_construct	cst;
		IGRshort		act=3;
		struct	GRlc_info	*Mcrv=NULL;

		/* Build external contour */
		Mcrv = om$calloc ( num = count, structure = struct GRlc_info );
		VLinitCnst (&cst);
		Cnt->mod_env = *Env;
		sts = BuildCrv ( act, Ocrv, count, Orie, adj, clo, Mcrv, &cst,
				 &Cnt->obj_id, msg );
		if ((*msg) == BSSUCC)	*msg = MSSUCC;
		else			*msg = MSFAIL;
		as$status ( sts    = sts,
			    msg    = "BuildCrv()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = quit );
#ifdef TRACE
printf( "\n" );
for ( i=0; i<count; i++ )
printf( "Mcrv %d is [%d|%d]\n",
	i, Mcrv[i].located_obj.osnum, Mcrv[i].located_obj.objid );
printf( "\n" );
printf( "Cnt = [%d|%d]\n", Cnt->obj_id.osnum, Cnt->obj_id.objid );
#endif

quit:
		if (Mcrv) {	om$dealloc (ptr = Mcrv);	Mcrv = NULL; }	
	}

wrapup:
	if (Icrv) {	om$dealloc (ptr = Icrv);	Icrv = NULL; }	
	if (Ocrv) {	om$dealloc (ptr = Ocrv);	Ocrv = NULL; }	
	if (Orie) {	om$dealloc (ptr = Orie);	Orie = NULL; }	
	if (contOE) {
		for ( i=0; i<count; i++ ) {
			if (  ((*msg) != MSSUCC)
			   && (contOE[i].obj_id.objid != NULL_OBJID) )
				gr$delete_object (
					msg	     = &ret,
					md_env       = &contOE[i].mod_env,
					object_id    = &contOE[i].obj_id,
					display_flag = 0 );
		}
		om$dealloc (ptr = contOE);
		contOE = NULL;
	}

	if (listID) {
		free (listID);
		listID = NULL;
	}

	if (edgeID) {
		for ( i=0; i<nEdg; i++ )
			if (edgeID[i].objid != NULL_OBJID)
				gr$delete_object (
					msg	     = &ret,
					md_env       = Env,
					object_id    = &edgeID[i],
					display_flag = 0 );
		om$dealloc (ptr = edgeID);
		edgeID = NULL;
	}

	if (Srf) {	
		for ( i=0; i<num; i++ )
			if (Srf[i].obj_id.objid !=NULL_OBJID)
				gr$delete_object (
					msg	     = &ret,
					md_env       = &Srf[i].mod_env,
					object_id    = &Srf[i].obj_id,
					display_flag = 0 );
		om$dealloc (ptr = Srf);
		Srf = NULL;
	}

	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLfourEdgesContour

/* -------------------------------------------------------------------- */
/*	This function creates a 4 edges contour from a set of plates.	*/
/*	First vl$externalContour() macro is called to get a n edges	*/
/*	contour. After I try to reduce it to a 4 edges contour :	*/
/*		If needed, adjacent edges that are more "colinear"	*/
/*		are merged into a bspline curve.			*/
/*	Marc Fournier, INGR-France :	27-MAR-1997			*/
/* -------------------------------------------------------------------- */

(
	IGRlong		*msg,	/* O	Completion code			*/
	IGRint		num,	/* I	Number of VSplates		*/
struct	GRobj_env	*srf,	/* I	Array of VSplates		*/
struct	GRobj_env	*plt,	/* I	Array of VSplates		*/
	IGRchar		*side,	/* I	Side of VSplates		*/
struct	GRmd_env	*Env,	/* I	Current environment		*/
	IGRint		*cnt,	/* O	Number of edges			*/
				/* 	Can be a NULL pointer		*/
struct	GRobj_env	**edg,	/* O	Array of edge objects		*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
struct	IGRbsp_curve	***crv,	/* O	Array of edge geometries	*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
struct	GRobj_env	*Cnt,	/* O	Composite contour object	*/
				/*	consume Edg objects		*/
				/*	Can be a NULL pointer		*/
struct	IGRbsp_surface	***sur,	/* O	Array of surfaces geometry	*/
				/*	Must be om$dealloc() by caller	*/
				/*	Can be a NULL pointer		*/
struct	IGRplane	*nrm	/* O	Average plane of surf.|VLplates	*/
)
{
	IGRlong		sts=OM_S_SUCCESS, ret=0;
	IGRint		i, j, k, nb_coledges=0, idx=0, count=0, temp_int, siz=sizeof(struct GRobj_env);
struct	GRid		cntID;
struct	DoProd {
	IGRdouble	dot;
	IGRboolean	low;
};
struct	DoProd		*doProd=NULL;
struct	GRobj_env	ordOE[40], newOE[40], *edgOE=NULL, Ocrv[40];
struct	GRlc_info	entLC[4];
struct	GRvg_construct	cst;
	IGRshort	inv[4], act=3;
	IGRdouble	d;
	IGRboolean	adj=TRUE, clo=FALSE;
struct	ToFour {
	IGRboolean		tag;
	struct	GRobj_env	edg;
};
struct	ToFour		*toFour=NULL, *temptoFour=NULL;


	/* Initialize */
	if (cnt) 	*cnt = 0;
	if (edg) {	(*edg) = om$calloc ( num = 4,
					     structure = struct GRobj_env );
			for ( i=0; i<4; i++ ) {
				(*edg)[i].obj_id.objid = NULL_OBJID;
				(*edg)[i].obj_id.osnum = Env->md_id.osnum;
				(*edg)[i].mod_env      = *Env;
			}
	}
	if (crv) 	for ( i=0; i<4; i++ )	(*crv)[i] = NULL;
	if (Cnt) {	Cnt->obj_id.objid = NULL_OBJID;
			Cnt->obj_id.osnum = Env->md_id.osnum;
			Cnt->mod_env      = *Env;
	}
	cntID.objid = NULL_OBJID;
	cntID.osnum = Env->md_id.osnum;
	VLinitCnst (&cst);
	for ( i=0; i<4; i++ ) {
		newOE[i].obj_id.objid = NULL_OBJID;
		newOE[i].obj_id.osnum = Env->md_id.osnum;
		newOE[i].mod_env      = *Env;
	}

	/* Build contour with n edges */
	if 	(srf)
		sts = vl$externalContour ( msg	= msg,
					   num	= num,
					   Surf = srf,
					   Env  = Env,
					   nEdg = &count,
					   Edge = &edgOE,
					   srf  = sur,
					   Norm = nrm );
	else if (plt)
		sts = vl$externalContour ( msg	= msg,
					   num	= num,
					   Plat = plt,
					   side = side,
					   Env  = Env,
					   nEdg = &count,
					   Edge = &edgOE,
					   srf  = sur,
					   Norm = nrm );
	else	*msg = MSFAIL;
	as$status ( sts    = sts,
                    msg    = "vl$externalContour()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );


	/* Check the number of edges of the contour */
	if (count < 4) {
		printf( "VLgetContour() returns only %d edges\n", count );
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Reallocate to repeat first edge in last position */
	edgOE = (struct GRobj_env *) om$realloc ( ptr  = (IGRchar *) edgOE,
					     	  size = (count+1) * siz );
	edgOE[count] = edgOE[0];


	/* Allocate memory for DoProd structure */
	doProd = om$calloc ( num = count, structure = struct DoProd );

	/* Fill DoProd structure with adjacent edge vectors |dot products| */
	for ( i=0; i<count; i++ ) {

		sts = vl$dotProduct ( msg	= msg,
				      crv1	= &edgOE[i],
				      crv2	= &edgOE[i+1],
				      dot	= &d );
		as$status ( sts    = sts,
	                    msg    = "vl$dotProduct()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		doProd[i].dot = fabs (d);
		doProd[i].low = TRUE;
	}

	/* Tag (count - 4) hightest |dot products| */
	for ( i=0; i<count-4; i++ ) {
		if (doProd[i].low == TRUE) {
			idx = i;
			for ( j=0; j<count; j++ ) {
				if ( (j != i)
				&&   (doProd[j].low == TRUE)
				&&   (doProd[j].dot > doProd[idx].dot) )
					idx = j;
			}
			doProd[idx].low = FALSE;
		}
	}
#ifdef TRACE
for ( i=0; i<count; i++ )
	printf( "doProd[%d], dot=%g, low=%d, [%d|%d]\n", i,
		doProd[i].dot, doProd[i].low,
		edgOE[i].obj_id.osnum, edgOE[i].obj_id.objid );
#endif

	/* Allocate memory */
	toFour = om$calloc ( num = count, structure = struct ToFour );

	/* Fill structure */
	if (count == 4) {
		for ( i=0; i<count; i++ ) {
			toFour[i].tag = doProd[i].low;
			toFour[i].edg = edgOE[i];
		}
	}
	else {	/* Search the first tagged edge */
		for ( i=0; i<count; i++ ) {
			if (doProd[i].low == FALSE) {
				idx = i;
				i = count;
			}
		}

		/* Fill ToFour structure beginning with a tagged edge */
		for ( i=idx; i<count; i++ ) {
			toFour[i-idx].tag = doProd[i].low;
			toFour[i-idx].edg = edgOE[i];
		}
		for ( i=0; i<idx; i++ ) {
			toFour[i+count-idx].tag = doProd[i].low;
			toFour[i+count-idx].edg = edgOE[i];
		}

		for ( i=0; i<count; i++ ) {

		  if( i == count-1 ) j = 0;
		  else  	     j = i+1;
		  sts = vl$dotProduct ( msg	= msg,
				      crv1	= &toFour[i].edg,
				      crv2	= &toFour[j].edg,
				      dot	= &d );
		  as$status ( sts    = sts,
	                    msg    = "vl$dotProduct()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
		  if( fabs (d) > 0.5 ) 
		  {
		    toFour[i].tag = FALSE ;
		  }
		  else
		  {
		    toFour[i].tag = TRUE;
		  }
	    }
	}

        for ( i=0; i<count; i++ ) {
            temp_int = i-1;
            if( temp_int < 0 ) temp_int += count ;
            if (toFour[i].tag == FALSE && toFour[temp_int].tag == TRUE )
            {
                idx = i;
                break;
            }
        }

        /* Allocate memory */
        temptoFour = om$calloc ( num = count, structure = struct ToFour );

        for ( i=0; i<count; i++ ) {
                temp_int = idx + i ;
                if( temp_int > (count-1) ) temp_int = idx + i - count;
                temptoFour[i] = toFour[temp_int];
        }
        for ( i=0; i<count; i++ ) {
                toFour[i] = temptoFour[i] ;
        }
        if (temptoFour) { om$dealloc (ptr = temptoFour); temptoFour = NULL;  }

#ifdef TRACE
for ( i=0; i<count; i++ )
	printf( "toFour[%d], tag=%d, [%d|%d]\n",
		i, toFour[i].tag,
		toFour[i].edg.obj_id.osnum, toFour[i].edg.obj_id.objid );
#endif
	

	/* Construct a new contour with 4 edges */
	j=0;
	for ( i=0; i<count; i++ ) {
#ifdef TRACE
printf( "i=%d\n", i);
#endif
		nb_coledges = 1;
		if (toFour[i].tag == FALSE) {

			/* Copy edge i */
			ordOE[0].mod_env = *Env;
			sts = gr$copy_object (
				msg	 	= msg,
				object_id	= &toFour[i].edg.obj_id,
				md_env		= &toFour[i].edg.mod_env,
				new_env		= &ordOE[0].mod_env,
				new_id		= &ordOE[0].obj_id,
				display_flag	= 0 );
			as$status ( sts    = sts,
		                    msg    = "gr$copy_object()",
	              	      	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
#ifdef TRACE
printf( "\tgr$copy_object[%d|%d] = [%d|%d]\n",
	toFour[i].edg.obj_id.osnum, toFour[i].edg.obj_id.objid,
	ordOE[0].obj_id.osnum, ordOE[0].obj_id.objid );
#endif

			for( k=i; k<count; k++ ) {
			 if (toFour[k].tag == TRUE) break;

			/* Copy edge i+1 */
			ordOE[nb_coledges].mod_env = *Env;
			sts = gr$copy_object (
				msg	 	= msg,
				object_id	= &toFour[k+1].edg.obj_id,
				md_env		= &toFour[k+1].edg.mod_env,
				new_env		= &ordOE[nb_coledges].mod_env,
				new_id		= &ordOE[nb_coledges].obj_id,
				display_flag	= 0 );
			as$status ( sts    = sts,
		                    msg    = "gr$copy_object()",
	              	      	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
#ifdef TRACE
printf( "\tgr$copy_object[%d|%d] = [%d|%d]\n",
	toFour[k+1].edg.obj_id.osnum, toFour[k+1].edg.obj_id.objid,
	ordOE[nb_coledges].obj_id.osnum, ordOE[nb_coledges].obj_id.objid );
#endif
			++nb_coledges;
			}

#ifdef TRACE
printf( "\tgr$copy_object[%d|%d] = [%d|%d]\n",
	toFour[i+1].edg.obj_id.osnum, toFour[i+1].edg.obj_id.objid,
	ordOE[1].obj_id.osnum, ordOE[1].obj_id.objid );
#endif
			/* Order curves from edge i and edge i+1 */
#ifdef TRACE
printf( "OrderCrv ( [%d|%d], [%d|%d]\n",
	ordOE[0].obj_id.osnum, ordOE[0].obj_id.objid,
	ordOE[1].obj_id.osnum, ordOE[1].obj_id.objid );
#endif
			sts = OrderCrv ( ordOE, nb_coledges,
					 VLtol(VL_TOL_GAP), VLtol(VL_TOL_BAS),
					 Ocrv, inv, &adj, &clo, msg );
			if ((*msg) == BSSUCC)	*msg = MSSUCC;
			else			*msg = MSFAIL;
			as$status ( sts    = sts,
				    msg    = "OrderCrv()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			/* Build bspline curve from edge i and edge i+1 */
			newOE[j].mod_env = *Env;
			sts = BuildCrv ( 1, Ocrv, nb_coledges, inv, TRUE, FALSE, entLC,
					 &cst, &newOE[j].obj_id, msg );
			if ((*msg) == BSSUCC)	*msg = MSSUCC;
			else			*msg = MSFAIL;
			as$status ( sts    = sts,
		                    msg    = "BuildCrv()",
	              	      	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
#ifdef TRACE
printf( "\tnewOE[%d] is [%d|%d]\n", j,
	newOE[j].obj_id.osnum, newOE[j].obj_id.objid );
#endif
			i+=nb_coledges-1;
			j++;
		}
		else {	/* Copy edge i */
			sts = gr$copy_object (
				msg	 	= msg,
				object_id	= &toFour[i].edg.obj_id,
				md_env		= &toFour[i].edg.mod_env,
				new_env		= &newOE[j].mod_env,
				new_id		= &newOE[j].obj_id,
				display_flag	= 0 );
			as$status ( sts    = sts,
		                    msg    = "gr$copy_object()",
	              	      	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
#ifdef TRACE
printf( "\tj=%d, gr$copy_object[%d|%d] = [%d|%d]\n", j,
	toFour[i].edg.obj_id.osnum, toFour[i].edg.obj_id.objid,
	newOE[j].obj_id.osnum, newOE[j].obj_id.objid );
#endif
			j++;
		}
	}

	/* Fill output arguments */
	if (cnt) 	*cnt = 4;
	if (edg)	for ( i=0; i<4; i++ )	(*edg)[i] = newOE[i];
	if (crv) {
		*crv = om$calloc ( num = 4, structure = struct IGRbsp_curve * );
		for ( i=0; i<4; i++ ) {
#ifdef TRACE
printf( "Final Edge %d is [%d|%d]\n", i,
	newOE[i].obj_id.osnum, newOE[i].obj_id.objid );
#endif
			sts = VLgetGeometry ( &newOE[i], FALSE, NULL_OBJID,
					      (IGRchar **) &(*crv)[i], msg );
			as$status ( sts    = sts,
		                    msg    = "VLgetGeometry()",
		              	    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );
		}
	}
	if (Cnt) {
		sts = OrderCrv ( newOE, 4, VLtol(VL_TOL_GAP), VLtol(VL_TOL_BAS),
				 Ocrv, inv, &adj, &clo, msg );
		if ((*msg) == BSSUCC)	*msg = MSSUCC;
		else			*msg = MSFAIL;
		as$status ( sts    = sts,
			    msg    = "OrderCrv()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		sts = BuildCrv ( act, Ocrv, 4, inv, FALSE, FALSE, entLC, &cst,
			         &Cnt->obj_id, msg );
		if (*msg == BSSUCC)	*msg = MSSUCC;
		else			*msg = MSFAIL;
		as$status ( sts    = sts,
	                    msg    = "BuildCrv()",
		            test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );
	}

	*msg = MSSUCC;
	
wrapup:
	/* Delete n contour external edges */
	if (edgOE) {
		for ( i=0; i<count; i++ ) {
			if (edgOE[i].obj_id.objid != NULL_OBJID) {
				gr$delete_object (
					msg	     = &ret,
					md_env       = &edgOE[i].mod_env,
					object_id    = &edgOE[i].obj_id,
					display_flag = 0 );
			}
		}
		om$dealloc (ptr = edgOE);
		edgOE = NULL;
	}
	
	/* Delete 4 contour external edges (if error) */
	for ( i=0; i<4; i++ ) {
		if (  ((*msg) != MSSUCC)
		   && (newOE[i].obj_id.objid != NULL_OBJID) ) {
			gr$delete_object ( msg		= &ret,
					   md_env	= &newOE[i].mod_env,
					   object_id	= &newOE[i].obj_id,
					   display_flag = 0 );
		}
	}

	if (toFour) {	om$dealloc (ptr = toFour);	toFour = NULL;	}
	if (doProd) {	om$dealloc (ptr = doProd);	doProd = NULL;	}
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLcontrolLine
(
	IGRlong		*msg,		/* O : Completion code		*/
	IGRint		num,		/* I : Number of VSplates	*/
struct	GRobj_env	*srf,		/* I : Array of VSplates	*/
struct	GRobj_env	*plt,		/* I : Array of VSplates	*/
	IGRchar		*side,		/* I : Side of VSplates		*/
struct	GRmd_env	*Env,		/* I : Current environment	*/
	IGRvector	*axe,		/* I : Main axis		*/
	IGRvector	*avn,		/* I : Average normal		*/
struct	BendingLineInfo	*Info,		/* O : Control line info	*/
struct	GRobj_env	*Curv		/* O : Control line object	*/
)
{
	IGRlong		sts=OM_S_SUCCESS, ret;
	IGRint		cnt=0, i, j, idx, nnm;
struct	GRobj_env	*edg=NULL, plnOE, *Srf=NULL, *Icv=NULL, *Ocv=NULL;
	IGRdouble	d, max_dist, *u=NULL, *v=NULL;
	IGRpoint	spt, ept, pnt[4], *p=NULL, np;
struct	IGRbsp_surface	**sur=NULL;
struct	IGRplane	nrmP;
	IGRvector	nn, Axis, nrm, x, y, z, nsf;
	BSrc		rc;
struct	GRvg_construct	cst;
	IGRshort	*inv=NULL, act=1;
	IGRboolean	adj, clo;
struct	GRlc_info	*Mcv=NULL;
struct	EdgeWork {
	struct	GRobj_env	Obj;
	IGRdouble		Dot;
	IGRboolean		Low;
};
struct	EdgeWork	*EW=NULL;

	/* Initialize */
	nrmP.point	= np;
	nrmP.normal	= nn;
	plnOE.obj_id.objid 	= NULL_OBJID;
	plnOE.obj_id.osnum	= Env->md_id.osnum;
	plnOE.mod_env		= *Env;
	Curv->obj_id.objid	= NULL_OBJID;
	Curv->obj_id.osnum	= Env->md_id.osnum;
	Curv->mod_env		= *Env;
	VLinitCnst (&cst);
	if (  (axe) )
/*
	   && ((*axe)[0] != 0.0)
	   && ((*axe)[1] != 0.0)
	   && ((*axe)[2] != 0.0) )
*/
		for ( i=0; i<3; i++ )	Axis[i] = (*axe)[i];
	else {	Axis[0] = 1.0;
		Axis[1] = 0.0;
		Axis[2] = 0.0;	}

	/* Build contour with 4 edges */
	if 	(srf)
		sts = vl$externalContour ( msg	= msg,
					   num	= num,
					   Surf = srf,
					   Env  = Env,
					   Four = TRUE,
					   nEdg = &cnt,
					   Edge = &edg,
					   srf  = &sur,
					   Norm = &nrmP );
	else if (plt)
		sts = vl$externalContour ( msg	= msg,
					   num	= num,
					   Plat = plt,
					   side = side,
					   Env  = Env,
					   Four = TRUE,
					   nEdg = &cnt,
					   Edge = &edg,
					   srf  = &sur,
					   Norm = &nrmP );
	else	*msg = MSFAIL;
	as$status ( sts    = sts,
                    msg    = "vl$externalContour()",
	            test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate and fill EdgeWork structure */
	EW = om$calloc ( num = cnt, structure = struct EdgeWork );
	for ( i=0; i<cnt; i++ ) {

		sts = vl$dotProduct ( msg	= msg,
				      crv1	= &edg[i],
				      vec2	= Axis,
				      dot	= &d );
		as$status ( sts    = sts,
	                    msg    = "vl$dotProduct()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		EW[i].Obj = edg[i];
		EW[i].Dot = fabs (d);
		EW[i].Low = TRUE;
	}

	idx = 0;
	max_dist = -1.0e+10;
	for( i=0; i<cnt; ++i )
	{
	  if( EW[i].Dot > max_dist )
	  {
	      idx = i;
	      max_dist = EW[i].Dot;
	  }
	}
	EW[idx].Low = FALSE;

	idx = 0;
	max_dist = -1.0e+10;
	for( i=0; i<cnt; ++i )
	{
	  if( EW[i].Low == TRUE && ( EW[i].Dot > max_dist ) )
	  {
	      idx = i;
	      max_dist = EW[i].Dot;
	  }
	}
	EW[idx].Low = FALSE;

	/* Evaluate midpoints of 2 edges most parallel to main axis */
	idx = 0;
	for ( i=0; i<cnt; i++ ) {
		if (EW[i].Low == FALSE) {

			/* Get endpoints */
			sts = VLendpts ( msg,
					 &EW[i].Obj.obj_id, &EW[i].Obj.mod_env,
					 spt, ept );
			as$status ( sts    = sts,
				    msg    = "VLendpts()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			for ( j=0; j<3; j++ )
				pnt[idx][j] = 0.5 * (spt[j] + ept[j]);
			idx++;
		}
	}

	/* Evaluate middle point of midlle points */
	for ( i=0; i<3; i++ )	pnt[2][i] = 0.5 * (pnt[0][i] +  pnt[1][i] );
#ifdef TRACE
printf( "pnt[0] is [%g,%g,%g]\n", pnt[0][0], pnt[0][1], pnt[0][2] );
printf( "pnt[1] is [%g,%g,%g]\n", pnt[1][0], pnt[1][1], pnt[1][2] );
printf( "pnt[2] is [%g,%g,%g]\n", pnt[2][0], pnt[2][1], pnt[2][2] );
#endif

	/* Average normal */
	if (  (avn)
	   && ((*avn)[0] != 0.0)
	   && ((*avn)[1] != 0.0)
	   && ((*avn)[2] != 0.0) )
		for ( i=0; i<3; i++ )	nrm[i] = (*avn)[i];
	else	for ( i=0; i<3; i++ )	nrm[i] = nrmP.normal[i];

	/* Project that point on surfaces/VSplates */
	for ( i=0; i<num; i++ ) {
		if (p) {	om$dealloc(ptr = p);	p = NULL;	}
		if (u) {	om$dealloc(ptr = u);	u = NULL;	}
		if (v) {	om$dealloc(ptr = v);	v = NULL;	}
		ret=0;
		BSpj_pt_sf ( sur[i], pnt[2], nrm, &ret, &p, &u, &v, &rc );
#ifdef TRACE
printf( "\ni=%d, BSpj_pt_sf() returns rc=%d\n", i, rc );
for ( j=0; j<ret; j++ )
printf( "\tPoint %d is [%g,%g,%g], u=%g, v=%g\n", j,
	p[j][0], p[j][1], p[j][2], u[j], v[j] );
#endif
		if (ret > 0) {
			for ( j=0; j<3; j++)	pnt[3][j] = p[0][j];
			if( VLsame_point ( pnt[2], pnt[3], 0.00001 ) )
			{
	  		   BSsfevaln( sur[i], u[0], v[0], 1, &nnm, 
				      p[0], &nsf, &rc );
			   for ( j=0; j<3; j++)    pnt[2][j] = nsf[j] ;
			}
			i = num;
		}
	}

	/* Build plane vector */
	sts = VLvector ( msg, pnt[0], pnt[1], 1.0, 1.0, TRUE, x );
	as$status ( sts    = sts,
                    msg    = "VLvector(x)",
	            test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	sts = VLvector ( msg, pnt[3], pnt[2], 1.0, 1.0, TRUE, y );
	as$status ( sts    = sts,
                    msg    = "VLvector(x)",
	            test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	BScrossp ( &rc, x, y, z );
	as$status ( sts    = rc,
                    msg    = "BScrossp(z)",
	            test   = (rc != BSSUCC),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if ( BSdotp ( &rc, z, Axis ) < 0.0 )
		for ( i=0; i<3; i++ )	z[i] *= -1.0;
	BScrossp ( &rc, y, z, x );
	as$status ( sts    = rc,
                    msg    = "BScrossp(x)",
	            test   = (rc != BSSUCC),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Build plane */
	sts = VLcreatePlane ( pnt[3], x, Env, &cst, &plnOE.obj_id, msg );
	as$status ( sts    = sts,
                    msg    = "VLcreatePlane()",
	            test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get support surfaces */
	sts = VLgetSupportSurfaces ( msg, num, srf, plt, side, Env,
				     &Srf, NULL );
	as$status ( sts    = sts,
                    msg    = "VLgetSupportSurfaces()",
	            test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Allocate memory for intersections */
	Icv = om$calloc ( num = num, structure = struct GRobj_env );

	/* Intersect plane with surfaces */
	idx = 0;
	for ( i=0; i<num; i++ ) {

		Icv[i].obj_id.objid = NULL_OBJID;
		Icv[idx].mod_env = *Env;
		sts = VLcreateInter ( msg,
				      &Srf[i].obj_id, &Srf[i].mod_env, 1,
				      &plnOE.obj_id, &plnOE.mod_env, 0,
				      &Icv[idx].obj_id, &Icv[idx].mod_env );
		if (sts & 0x00000001 & (*msg))
			idx++;
	}
	if (!idx) {
		printf( "Control plane don't VLcreateInter() any surface\n" );
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Order curves */
	inv = om$calloc ( num = num, structure = IGRshort );
	Ocv = om$calloc ( num = num, structure = struct GRobj_env );
	for ( i=0; i<num; i++ )	Ocv[i].obj_id.objid = NULL_OBJID;
	sts = OrderCrv ( Icv, idx, VLtol(VL_TOL_GAP), VLtol(VL_TOL_BAS),
			 Ocv, inv, &adj, &clo, msg );
	if ((*msg) == BSSUCC)	*msg = MSSUCC;
	else			*msg = MSFAIL;
	as$status ( sts    = sts,
		    msg    = "OrderCrv()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

/* Verify that the 1st ordered curve is in main axis direction 
	sts = vl$dotProduct ( msg	= msg,
			      crv1	= &Ocv[0],
			      vec2	= Axis,
			      dot	= &d );
	as$status ( sts    = sts,
                    msg    = "vl$dotProduct()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	if (d < 0.0)	for ( i=0; i<3; i++ )	inv[i] *= -1;
*/
	/* Build curve */
	Mcv = om$calloc ( num = num, structure = struct GRlc_info );
	for ( i=0; i<num; i++ )	Mcv[i].located_obj.objid = NULL_OBJID;
	Curv->mod_env = *Env;
	sts = BuildCrv ( act, Ocv, idx, inv, adj, clo, Mcv, &cst,
			 &Curv->obj_id, msg );
	if (*msg == BSSUCC)	*msg = MSSUCC;
	else			*msg = MSFAIL;
	as$status ( sts    = sts,
                    msg    = "BuildCrv()",
	            test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Fill BendingLineInfo (if needed) */
	if (Info) {
		for ( i=0; i<3; i++ ) {
			Info->point1[i] = pnt[0][i];
			Info->point2[i] = pnt[1][i];
			Info->normal[i] = nrm[i];
		}
	}
	
wrapup:
	if ( (*msg) != MSSUCC ) {
		for ( i=0; i<num; i++ ) {
			if (Icv) {
				if (Icv[i].obj_id.objid != NULL_OBJID) {
					gr$delete_object (
						msg	     = &ret,
						md_env       = &Icv[i].mod_env,
						object_id    = &Icv[i].obj_id,
						display_flag = 0 );
					Icv[i].obj_id.objid = NULL_OBJID;
				}
			}
			if (Ocv) {
				if (Ocv[i].obj_id.objid != NULL_OBJID) {
					gr$delete_object (
						msg	     = &ret,
						md_env       = &Ocv[i].mod_env,
						object_id    = &Ocv[i].obj_id,
						display_flag = 0 );
					Ocv[i].obj_id.objid = NULL_OBJID;
				}
			}
			if (Mcv) {
				if (Mcv[i].located_obj.objid != NULL_OBJID) {
					gr$delete_object (
					msg	     = &ret,
					md_env       = &Mcv[i].module_info,
					object_id    = &Mcv[i].located_obj,
					display_flag = 0 );
					Mcv[i].located_obj.objid = NULL_OBJID;
				}
			}
		}
	}
	if (inv) {	om$dealloc (ptr = inv);	inv = NULL;	}
	if (Mcv) {	om$dealloc (ptr = Mcv);	Mcv = NULL;	}
	if (Ocv) {	om$dealloc (ptr = Ocv);	Ocv = NULL;	}
	if (Icv) {	om$dealloc (ptr = Icv);	Icv = NULL;	}

	if (Srf) {
		for ( i=0; i<num; i++ ) {
			if (Srf[i].obj_id.objid != NULL_OBJID)
				gr$delete_object (
					msg	     = &ret,
					md_env       = &Srf[i].mod_env,
					object_id    = &Srf[i].obj_id,
					display_flag = 0 );
		}
		om$dealloc (ptr = Srf);
		Srf = NULL;
	}

	if (plnOE.obj_id.objid != NULL_OBJID)
		gr$delete_object ( msg	        = &ret,
				   md_env       = &plnOE.mod_env,
				   object_id    = &plnOE.obj_id,
				   display_flag = 0 );

	if (edg) {
		for ( i=0; i<cnt; i++ ) {
			if (edg[i].obj_id.objid != NULL_OBJID)
				gr$delete_object (
					msg	     = &ret,
					md_env       = &edg[i].mod_env,
					object_id    = &edg[i].obj_id,
					display_flag = 0 );
		}
		om$dealloc (ptr = edg);
		edg = NULL;
	}

	if (sur) {
		for ( i=0; i<num; i++ ) {
			om$dealloc (ptr = sur[i]);
			sur[i] = NULL;
		}
		om$dealloc (ptr = sur);	sur = NULL;
	}

	if (p) {	om$dealloc(ptr = p);	p = NULL;	}
	if (u) {	om$dealloc(ptr = u);	u = NULL;	}
	if (v) {	om$dealloc(ptr = v);	v = NULL;	}
	if (EW) {	om$dealloc (ptr = EW);	EW = NULL;	}

	return (sts);
}
/* ************************************************************************** */

end implementation VLabstract;
