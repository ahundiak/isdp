/* $Id: SMExtBound.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMExtBound.I
 *
 * Description:
 *
 *      This file implements functions used to retrieve the external
 *	boundaries of a surface (that is used for the drawing 
 *	of a compartment).
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMExtBound.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/04/29  08:49:04  pinnacle
# Replaced: smcomp/func/SMExtBound.I for:  by ksundar for vds.240
#
# Revision 1.2  1995/10/26  21:46:06  pinnacle
# Replaced: ./smcomp/func/SMExtBound.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      05/17/93	Raju	Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

/* #define DEBUG 	1	*/ /* for debugging purpose */
/* #define DEBUGPLUS 	1	*/ /* for debugging purpose */

#define EPSILON		1.0E-2

#include <stdio.h>
#include <stdlib.h>
%safe
#include <math.h>
%endsafe

#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "growner.h"
#include "dp.h"
#include "OMmacros.h"


#include "msdef.h"
#include "nddef.h"
#include "macro.h"
#include "grmacros.h"  
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "VDmem.h"

#include "AS_status.h"

extern  GRdisplay_object() ;	/* temporary */
extern	ASget_active_symb();
extern  pr_mat() ;		/* see $ASSRC/gopara */
extern OMuword OPP_GRcompcurve_class_id;
extern  int	UI_status();

struct GRmd_env MOD_ENV ; 

/* Definition of edges_info_def structure (this file only) */

struct edges_info_def {
   IGRboolean  phy_closed ; 	/* 0 => edge is not physically closed    */
   IGRboolean  in_usage   ;	/* 1 => edge has been "treated"          */
   IGRpoint    point1 	  ;	/* First  end point of edge */
   IGRpoint    point2     ;	/* Second end point of edge */
   IGRpoint    bout	  ;	/* either point1 or point 2 */
   } ;


from	GRcompcurve	import	EMmakecomp;
from	EMSsubbs	import	EMmk_nat_bdry;
from	GRgraphics	import	GRcopy, GRgetprops;
from	EMSsurface	import	EMgetedges;
from	EMSedge		import	EMgetxyzobj;
from	GRvg		import	GRgeomprops, GRdelete, GRchgprops, GRputsymb;
from	GRcurve		import	GRendpts;

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMmake_loopset

  Abstract

	This function creates the natural boundary on the given surface,
	if it has no loopset.
	We suppose that a surface of EMScompsurf class has a loopset for
	each of its sub-surfaces of EMSsubbs class. (Nothing done for
	composite surface).


  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
IGRlong SMmake_loopset(OBJptr, OBJ_ENVptr)
	struct GRid	*OBJptr     ; /* I Surface object */
	struct GRmd_env	*OBJ_ENVptr ; /* I Surface mod env*/
/*
-fi */
{
IGRlong			sts, msg ;
OMuword			surf_cl  ;
OMuint			count_loop ;
OM_S_CHANSELECT 	to_loopset ;


sts = om$get_classid(	osnum		= OBJptr->osnum,
			objid		= OBJptr->objid,
			p_classid	= &surf_cl) ;
if (sts != OM_S_SUCCESS) {
	#ifdef DEBUG
	om$report_error(sts = sts) ;
	printf("SMmake_loopset() : error in om$get_classid() \n") ;
	#endif
	return 0 ; /* error */
}

if (om$is_ancestry_valid(superclassname = "EMSsubbs",
		         subclassid   = surf_cl) == OM_S_SUCCESS) {
	count_loop = 0 ;
	to_loopset.type       = OM_e_name ;
	to_loopset.u_sel.name = "EMSsubbs.to_loopset" ; 	
	sts = om$get_channel_count(osnum	= OBJptr->osnum,
				objid 		= OBJptr->objid,
				p_chanselect 	= &to_loopset,
				count		= &count_loop) ;
	if (sts != OM_S_SUCCESS) {
		#ifdef DEBUG
		printf("objid/osnum = %d/%d \n", OBJptr->objid, OBJptr->osnum) ; 
		/* */
		om$report_error(sts = sts) ;
		printf("SMmake_loopset() : error in om$get_channel_count() \n") ;
		#endif
		return 0 ; /* error */
	}
	if (! count_loop) {
		#ifdef DEBUG
		printf("---> make a loopset \n") ;
		#endif
		sts = om$send(	msg = message EMSsubbs.EMmk_nat_bdry(&msg,
						&OBJ_ENVptr->md_env,
						NULL),
				senderid = NULL_OBJID,
				targetid = OBJptr->objid,
				targetos = OBJptr->osnum) ;
		as$status(sts = sts) ;
	}
 } /* if EMSsubbs */ 

/* else : Object is of EMScompsurf class => NOP */

return 1 ; 

} /* SMmake_loopset() */


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMnext_suitable_edge

  Abstract

	This function returns the index of the next edge which is available 
	(in_usage == 0) and not physically closed (phy_closed == 0), from a 
	given origine in the list edges_info.

	This function is used by SMfind_compcurve_edges(). 

	Convention : if no suitable edge has been found, num_edges is returned
		(this indicates that the list has been scrolled).


  Returns
	index of the next suitable edge, or num_edges if no suitable
	edge has been found.
 -------------------------------------------------------------------------
*/

IGRint SMnext_suitable_edge(num_edges, edges_info, origine)
	IGRint			num_edges;   /* I nb of edges in the list*/
	struct edges_info_def	*edges_info; /* I list of edges          */
	IGRint			origine;     /* I index of the origine   */ 
/*
-fi */
{
IGRint	iedge ;

if (origine >= num_edges) {
	return num_edges ;	/* convention */
	}
for (iedge = origine ; iedge < num_edges ; iedge = iedge + 1) {
	if ((edges_info[iedge].in_usage   == 0) &&
	    (edges_info[iedge].phy_closed == 0)) {
		break ; 	/* next suitable edge */
		}
	}
return iedge ;
} /* SMnext_suitable_edge() */


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMfind_compcurve_edges

  Abstract

	also known as "bout a bout" (French expression).

	Given a list of edges, this function creates the list composed of
	the first next available edges which are not physically closed,
	in order to build later a composite curve.


  Returns
         1 if there is a solution.
         0 if fails or no solution.
 -------------------------------------------------------------------------
*/

IGRlong SMfind_compcurve_edges
		(num_edges, build_edges, edges_info, compcurve_edges, iptr)
	IGRint			num_edges	 ; /* I nb of edges */
	struct GRlc_info 	*build_edges     ; /* I edge objects*/
	struct edges_info_def	*edges_info	 ; /* I edge info   */
	struct GRlc_info 	*compcurve_edges ; /* O constructed edges */
	IGRint			*iptr		 ; /* O Number of constructed */
						   /*   edges */
/*
-fi */
{
IGRint ipass, istart, inext, icur, icomp, flag, origine ;

#ifdef DEBUGPLUS
printf("Call to SMfind_compcurve_edges() \n") ;
#endif

istart = SMnext_suitable_edge(num_edges, edges_info, 0) ;
if (istart == num_edges) {
	/* no more suitable edge */
	return 0 ; /* no solution */
	}

edges_info[istart].bout[0] = edges_info[istart].point2[0] ; /* choice */
edges_info[istart].bout[1] = edges_info[istart].point2[1] ; 
edges_info[istart].bout[2] = edges_info[istart].point2[2] ; 

icomp   = 0 ;
edges_info[istart].in_usage = 1 ;
compcurve_edges[icomp] = build_edges[istart] ;
icomp   = icomp + 1  ;
icur    = istart     ;
origine = icur + 1   ;

for (ipass = 0 ; ipass < num_edges-1 ; ipass = ipass+1) {

	#ifdef DEBUGPLUS
	printf("--------------- Pass number %d \n", ipass+1) ;
	#endif

   while (1) {
	flag = 0 ; /* reset flag */
	inext = SMnext_suitable_edge(num_edges, edges_info, origine) ;

	if (inext == num_edges) {
		break ; /* break while() */
	}

	if (
 (fabs(edges_info[inext].point1[0] - edges_info[icur].bout[0]) < EPSILON) &&
 (fabs(edges_info[inext].point1[1] - edges_info[icur].bout[1]) < EPSILON) &&
 (fabs(edges_info[inext].point1[2] - edges_info[icur].bout[2]) < EPSILON) ) { 
		edges_info[inext].bout[0] = edges_info[inext].point2[0] ; 
		edges_info[inext].bout[1] = edges_info[inext].point2[1] ; 
		edges_info[inext].bout[2] = edges_info[inext].point2[2] ; 
		flag = 1 ; 
		}

	if (
 (fabs(edges_info[inext].point2[0] - edges_info[icur].bout[0]) < EPSILON) &&
 (fabs(edges_info[inext].point2[1] - edges_info[icur].bout[1]) < EPSILON) &&
 (fabs(edges_info[inext].point2[2] - edges_info[icur].bout[2]) < EPSILON) ) { 
		edges_info[inext].bout[0] = edges_info[inext].point1[0] ; 
		edges_info[inext].bout[1] = edges_info[inext].point1[1] ; 
		edges_info[inext].bout[2] = edges_info[inext].point1[2] ; 
		flag = 1 ; 
		}

	if (flag) {
		/* "bout a bout" possible with this inext */
		#ifdef DEBUGPLUS
		printf("Bout a bout possible for edges %d and %d\n", icur, inext) ;
		#endif
		if (icomp >= num_edges) {
			#ifdef DEBUG
			printf("Error in SMfind_compcurve_edges() \n") ;
			#endif
			return 0 ; /* error */
			}
		edges_info[inext].in_usage = 1 ; /* mark up */
		compcurve_edges[icomp] = build_edges[inext] ;
		icomp = icomp + 1 ;
		icur  = inext ;
		origine = icur+1 ;
	} /* if flag */
	else {
		origine = origine + 1 ; /* look at next of next in this pass */
	}
      } /* while (1) */

   if (
 (fabs(edges_info[istart].point1[0] - edges_info[icur].bout[0]) < EPSILON) &&
 (fabs(edges_info[istart].point1[1] - edges_info[icur].bout[1]) < EPSILON) &&
 (fabs(edges_info[istart].point1[2] - edges_info[icur].bout[2]) < EPSILON) ) { 
	/* => We are ready to build a closed composite curve */
	break ;       /* => break for () */
   }
   else {
	origine = 0 ; /* => start another pass */
   }

}    /* for ()    */

*iptr = icomp ;
return 1 ; /* There is a solution */
} /* SMfind_compcurve_edges() */


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMevaluate_xbound

  Abstract

	This function gets the external boundaries of a given
	surface (EMSsurface), and builds a composite curve (class
	GRcompcurve) from the EMS_OPT_CONNECTABLE edges of a 
	composite surface (EMScompsurf) or of a simple surface
	(EMSsubbs).
		
	Uses EMSsurface.EMgetedges() message which works for both
	the EMSsubbs class and both the EMScompsurf class.

	A boundary is either a composite curve or a physically closed edge.

  Algorithm


	- get the nb of elements on the to_owners channel of the surface.
	- if count (surf is owned) copy the surface
	- create the natural boundary on the surface
	- Get the EMS_OPT_CONNECTABLE edges of the surface. (if none return 0)
	- for all the edges:

		- EMSedge.EMgetxyzobj (get objid of edge in uv)
		- copy that edge.
		- fill the structure build_edges[i] with it (the copy).
		- Get the geometry properties of the edge
		- edges_info[i].phy_closed = properties.phy_closed
		- edges_info[i].in_usage = 0
		- get the end points in xyz and fill edges_info[i].point1
		  and edges_info[i].point2
	- num_sol = 0 (	nb of external boundaries returned)
	- while (1)
		for iedge = 0 to num_edges 
			if edges_info[iedge].in_usage == 0 break
		if iedge = num_edge break (no more edge)
		if edges_info[iedge].phy_closed
			edges_info[iedge].in_usage = 1
			if(num_sol < max_bound)
				BOUNDtab[num_sol++] = build_edges[iedge]
			else return 0 (exceed max nb of boundaries)
		else 
			SMfind_compcurve_edges (compcurve_edges is the list
				of consecutive edges)

			construct a GRcompcurve (EMmakecomp(compcurve_edges))
			put the graphic properties on it
			if(num_sol < max_bound)
				BOUNDtab[num_sol++] = the composite curve
			else return 0 (exceed max nb of boundaries)
	- *nb_bound = num_sol
	- for i=num_sol to max_bound BOUNDtab[i] = NULL_OBJID
	- return 1;

	
  Notes/Remarks

    Main internal variables :
	num_edges	number of found edges (EMS_OPT_CONNECTABLE)
	num_sol		number of solutions (= number of boundaries)
	edges_list	list of edges in the UV  space
	build_edges	list of constructed edges in the XYZ space
	edges_info	list of associated information about edges
	compcurve_edges list of "suitable" edges to make a composite curve

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

IGRlong SMevaluate_xbound(compute_flag, surf_obj, surf_md_env, BOUNDtab, 
			  max_bound, nb_bound)
	IGRboolean  	compute_flag ; /* I : FALSE (place), TRUE (compute) */
	struct GRid	surf_obj;      /* I : surface to be processed	    */
	struct GRmd_env *surf_md_env;  /* I : module env. of surface	    */
	struct GRid 	BOUNDtab[];    /* O : list of external boundaries   */
	IGRint		max_bound;     /* I : size of BOUNDtab		    */	
        IGRint		*nb_bound;     /* O : no. of boundaries found	    */  
/*
-fi */
{
IGRlong rc_evaluate, sts, msg, option, rotten  ;
IGRint	i=0, buf_size, iedge, num_edges, num_sol ;
IGRint			surf_copy ; /* flag */
OMuint			count     ;
OM_S_CHANSELECT		to_owners ;
GRobjid			newobjid  ;
IGRshort		active_level   ;
struct IGRdisplay	active_display ;
struct GRlc_info	*build_edges     ;
struct GRlc_info 	*compcurve_edges ; 
struct GRid		*edges_list  ;
struct GRid		OBJ, CURVE   ;
struct GRmd_env		OBJ_ENV ;

struct edges_info_def 	*edges_info ;

GRobjid			xyzobj  ; 	/* EMSedge.EMgetxyzobj() */
struct GRsymbology	xyzsymb ; 	/* EMSedge.EMgetxyzobj() */
struct GRprops		properties ;	/* GRvg.GRgeomprops()    */

IGRshort		action, macro_props, comp_props ; /* 92/07/03 */

#if 0
	printf("\n") ;
/*	printf("   macro id/osnum    = %d/%d \n", CI_MACRO_ID.objid, CI_MACRO_ID.osnum) ;  
*/	printf("   modulenv id/osnum = %d/%d \n", MOD_ENV.md_id.objid, MOD_ENV.md_id.osnum) ;  
	printf("   modulenv mattype  = %d \n\n",  MOD_ENV.md_env.matrix_type)  ;
	pr_mat("   modulenv matrix            ",  4, 4, MOD_ENV.md_env.matrix) ;
#endif


/* Initialization */

rc_evaluate  = 0 ;
num_sol      = 0 ; 		     /* Number of solutions (boundaries)   */
option       = EMS_OPT_CONNECTABLE ; /* Option for EMSsurface.EMgetedges() */
edges_list   = NULL ;
build_edges  = NULL ;
edges_info   = NULL ;
compcurve_edges = NULL;

OBJ.objid = surf_obj.objid;
OBJ.osnum = surf_obj.osnum;

MOD_ENV = *surf_md_env;
OBJ_ENV = MOD_ENV;

/* --------------------------------------------------------------------
	0) Copy of the parent surface in order to get a "pure" surface 
	   (not attached to a solid for example) if this is a owned
	   surface.  Otherwise, EMS_OPT_CONNECTABLE gets confused... 
   --------------------------------------------------------------------
 */

to_owners.type		= OM_e_name ;
to_owners.u_sel.name 	= "GRconnector.to_owners" ;
count     = 0 ;
surf_copy = 0 ;

sts = om$get_channel_count(	osnum		= OBJ.osnum,
				objid		= OBJ.objid,
				p_chanselect	= &to_owners,
				count		= &count) ;
if (sts != OM_S_SUCCESS) {
	#ifdef DEBUG
	om$report_error(sts = sts) ;
	printf("SMevaluate_xbound() : om$get_channel_count() failed \n") ;
	#endif
	rc_evaluate = 0 ; /* error */
	goto quit ;
}

/* if ((count != 0) || (OBJ.osnum != MOD_ENV.md_id.osnum)) { */
if (count != 0) {
	/* 
	   Surface is owned (e.g. face of a solid) => just copy it
	 */
	#ifdef DEBUG
	printf("objid/osnum of input surface is %d/%d \n", OBJ.objid,
							   OBJ.osnum) ;
	#endif
	sts = om$send(	msg = message EMSsurface.GRcopy(&msg,
							&OBJ_ENV,
							&MOD_ENV,
							&newobjid),
			senderid = NULL_OBJID,
			targetid = OBJ.objid, 
			targetos = OBJ.osnum) ;
	if (sts & msg & 1) {	/* success */
		OBJ.objid = newobjid ;
		OBJ.osnum = MOD_ENV.md_id.osnum ;
		/* */
		OBJ_ENV.md_id.objid = MOD_ENV.md_id.objid ;
		OBJ_ENV.md_id.osnum = MOD_ENV.md_id.osnum ;
		OBJ_ENV.md_env.matrix_type = MOD_ENV.md_env.matrix_type ;
		for (i = 0 ; i < 16 ; i = i+1) {
			OBJ_ENV.md_env.matrix[i] = MOD_ENV.md_env.matrix[i] ;
			}
		/* */
		surf_copy = 1        ; /* flag */
		#ifdef DEBUG
		printf("objid/osnum of copied surface is %d/%d \n", OBJ.objid,
								    OBJ.osnum) ;
		#endif
	}
	else {
		#ifdef DEBUG
		om$report_error(sts = sts) ;
		printf("SMevaluate_xbound() : EMSsurface.GRcopy() failed\n") ;
		#endif
 		sts = 0 ; as$status(sts = sts) ; /* go on however */
		}
 } /* if count or surface in another OS */



/* --------------------------------------------------------------------
	1) Loopset check (make natural boundaries if necessary)
   --------------------------------------------------------------------
 */

sts = SMmake_loopset(&OBJ, &OBJ_ENV) ;
if (!(sts & 1)) {
	#ifdef DEBUG
	printf("Warning : function SMmake_loopset() unsuccessful \n") ;
	#endif
	}

/* --------------------------------------------------------------------
	2) Get the surface edges (option EMS_OPT_CONNECTABLE) in (U, V) 
	space, and convert them into the XYZ space.
   --------------------------------------------------------------------
 */

num_edges = 0;
buf_size = 0;

sts = om$send(msg = message EMSsurface.EMgetedges(
				&msg,
				option,
				&edges_list,
				&buf_size,
				&num_edges,
				NULL,
 				NULL,
				NULL,
				NULL),
	senderid = NULL_OBJID,
	targetid = OBJ.objid, 
	targetos = OBJ.osnum) ;
as$status(sts = sts);

if (!(sts & 1)) {
	#ifdef DEBUG
	printf("Problem when sending EMSsurface.EMgetedges() message \n") ;
	#endif
	rc_evaluate = 0 ;
	goto quit ;
}

if (msg != EMS_S_Success) {
	#ifdef DEBUG
	printf("Error in processing EMSsurface.EMgetedges() message \n") ;
	#endif
	rc_evaluate = 0 ;
	goto quit ;
}

#ifdef DEBUG
printf("\n");
printf("nb edges found : %d\n", num_edges);
#endif

/* */
if (num_edges == 0) {
	#ifdef DEBUG
	printf("SMevaluate_xbound() : no connectable edge found\n");
	#endif
	UI_status(" extract bound : no connectable edge found\n") ;
	rc_evaluate = 0 ; goto quit ;
}

/* --------- Conversion to the XYZ space ------------ */

/*
buf_size = sizeof( IGRshort );
sts = gr$get_active_layer( msg = &msg, sizbuf = &buf_size,
			   buffer = &active_level );


*/

sts = ASget_active_symb(&active_level, &active_display) ;
if (!(sts & 1)) {
	#ifdef DEBUG
	printf("SMevaluate_xbound() : ASget_active_symb() failed... \n") ;
	#endif
	/* continue however */
}

build_edges     = _MALLOC (num_edges, struct GRlc_info) ;
edges_info      = _MALLOC (num_edges, struct edges_info_def) ;
compcurve_edges = _MALLOC (num_edges, struct GRlc_info) ;

if ( (build_edges == NULL) || 
     (edges_info == NULL)  || (compcurve_edges == NULL) ) {
	#ifdef DEBUG
	printf("SMevaluate_xbound() : malloc error for build_edges or edges_info or compcurve_edges \n") ;
	#endif
	rc_evaluate = 0 ; /* error */
	goto quit ;
}

#ifdef DEBUG
/* our surface */
printf("OBJ_ENV %d %d\n",OBJ_ENV.md_id.objid,OBJ_ENV.md_id.osnum);
printf("mat_type %d\n",OBJ_ENV.md_env.matrix_type);
pr_mat("OBJ_ENV",4,4,OBJ_ENV.md_env.matrix);
#endif

for (iedge = 0 ; iedge < num_edges ; iedge = iedge+1) {

	xyzsymb.level        = active_level   ;
	xyzsymb.display_attr = active_display ; 
	sts = om$send(msg = message EMSedge.EMgetxyzobj(
					&msg,
					0,		/* options   */
					&OBJ_ENV.md_env,/* xyzinfo   */
					NULL,		/* xyzcv     */
					NULL,		/* xyzcvtype */
					&xyzsymb,	/* xyzsymb   */
					NULL,		/* xyzattr   */
					OBJ.osnum,	/* xyzos     */
					&xyzobj),	/* Output    */
		senderid = NULL_OBJID,
		targetid = edges_list[iedge].objid,
		targetos = edges_list[iedge].osnum) ;
	if (! (sts & msg & 1)) {
		sts = 0 ; as$status(sts = sts) ;
		#ifdef DEBUG
		printf("SMevaluate_xbound() : EMSedge.EMgetxyzobj() failed for edge n %d... \n", iedge) ;
		#endif
		rc_evaluate = 0 ; goto quit ;
	}
	/* */
	sts = om$send(	msg = message EMSedge.GRcopy(&msg,
							&OBJ_ENV,
							&MOD_ENV,
							&newobjid),
			senderid = NULL_OBJID,
			targetid = xyzobj, 
			targetos = OBJ.osnum) ;
	if (!(sts & msg & 1)) {
		sts = 0 ; as$status(sts = sts) ;
		#ifdef DEBUG
		printf("SMevaluate_xbound() : EMSedge.GRcopy() failed for edge n %d... \n", iedge) ;
		#endif
		rc_evaluate = 0 ; goto quit ;
	}
	
	build_edges[iedge].located_obj.objid = newobjid ;
	build_edges[iedge].located_obj.osnum = MOD_ENV.md_id.osnum ;
	build_edges[iedge].module_info       = MOD_ENV ;

	/* Mark closed edges : 	0   ---> edge is not physically closed */
	/* 			> 0 ---> edge is physically closed     */

	sts = om$send(	msg	 = message GRvg.GRgeomprops(&msg,
		&(build_edges[iedge].module_info.md_env.matrix_type),
		build_edges[iedge].module_info.md_env.matrix,
		&properties),
			senderid = NULL_OBJID,
			targetid = build_edges[iedge].located_obj.objid,
			targetos = build_edges[iedge].located_obj.osnum ) ;
	if (!(sts & msg & 1)) {
		sts = 0 ; as$status(sts = sts) ;
		#ifdef DEBUG
		printf("SMevaluate_xbound() : GRvg.GRgeomprops() failed for edge n %d... \n", iedge) ;
		#endif
		rc_evaluate = 0 ; goto quit ;
	}

	edges_info[iedge].phy_closed = properties.phy_closed ;
	edges_info[iedge].in_usage   = 0 ;

	/* Get end points for each edge in the XYZ space */
	sts = om$send(msg = message GRcurve.GRendpts(&msg,
			&build_edges[iedge].module_info.md_env.matrix_type,
			build_edges[iedge].module_info.md_env.matrix,
			edges_info[iedge].point1,
			edges_info[iedge].point2),
		senderid = NULL_OBJID,
		targetid = build_edges[iedge].located_obj.objid,
		targetos = build_edges[iedge].located_obj.osnum) ;
	if (!(sts & msg & 1)) {
		sts = 0 ; as$status(sts = sts) ;
		#ifdef DEBUG
		printf("SMevaluate_xbound() : GRcurve.GRendpts() failed \n") ;
		#endif
		rc_evaluate = 0 ; /* error */
		goto quit ;
	}

#if 0
	/* useless */
	gr$display_object(object_id	= &build_edges[iedge].located_obj,
			  md_env	= &MOD_ENV,
			  mode 		= GRhd)     ;	/* highlight draw */
	printf("Build edge n %d : id/osnum   = %d/%d \n", iedge, build_edges[iedge].located_obj.objid,
						         build_edges[iedge].located_obj.osnum) ;
	printf("                  phy_closed = %d \n", edges_info[iedge].phy_closed) ;
	printf("                  point1     = %f, %f, %f \n", 
edges_info[iedge].point1[0], edges_info[iedge].point1[1], edges_info[iedge].point1[2]) ;
	printf("                  point2     = %f, %f, %f \n", 
edges_info[iedge].point2[0], edges_info[iedge].point2[1], edges_info[iedge].point2[2]) ;
	sleep(2) ;
#endif

 } /* for iedge */

/* --------------------------------------------------------------------
	3) Handle the list of edges, and make composite curve,
	   and store eventually closed edge (for instance circles 
	   for a cylindric surface)

	Note : the numbering of the boundaries respects the order with which
		the edges has been found in the list.
   --------------------------------------------------------------------
 */

	while (1) {

		for (iedge = 0 ; iedge < num_edges ; iedge = iedge + 1) {
			if (edges_info[iedge].in_usage == 0) {
				break ; 	/* next available edge */
				}
			}
		if (iedge == num_edges) {
			break ; /* no more available edge => break while */
			}

		if (edges_info[iedge].phy_closed) {
			/* 
			   => Closed edge 
			 */
			edges_info[iedge].in_usage = 1 ;
			if (num_sol < max_bound) {
				BOUNDtab[num_sol] = build_edges[iedge].located_obj ;
				num_sol = num_sol + 1 ;
				}
			else {
				printf("Maximum number of boundaries exceeded \n") ;
				rc_evaluate = 0 ; /* error */
				goto quit ;
				}
			} /* if phy_closed */

		else {
			/* 
			   => Make a closed composite curve with edges which
			   are available (in_usage == 0) and non phy_closed 
			 */	
			sts = SMfind_compcurve_edges(num_edges, 
						build_edges, 
						edges_info, 
						compcurve_edges, 
						&i) ;

			if (!(sts & 1)) {
				/* Just in case to avoid infinite loop */
				#ifdef DEBUG
				printf("Echec pour SMfind_compcurve_edges() \n");
				#endif
				break ; /* break while */
				}

#if 0
			for (j = 0 ; j < i ; j = j+1) {
				printf("id/osnum = %d/%d \n", 
					compcurve_edges[j].located_obj.objid, 
					compcurve_edges[j].located_obj.osnum) ; 
				}
#endif

			/* 
				- Get graphic properties of macro (needed only
				  if the foot is a composite curve - 92/07/03).
				- Construct the composite curve. 
			 */

/*		if (compute_flag) {
			sts = om$send(	msg = message GRgraphics.GRgetprops(
							&msg, 
							&macro_props),
					senderid = NULL_OBJID,
					targetid = CI_MACRO_ID.objid,
					targetos = CI_MACRO_ID.osnum) ; 
			as$status(sts = sts) ;
			if (!(sts & msg & 1)) {
				rc_evaluate = 0 ; goto quit ;
				}
			
			#ifdef DEBUG
			if (macro_props & GRIS_DISPLAYABLE)
				write("ci macro is diplayable \n") ;
			else
				write("ci macro is not diplayable \n") ;
			#endif
			} 
*/  /* if compute */
/* Raju */	macro_props = 0;
		macro_props =  GRIS_DISPLAYABLE | GRIS_LOCATABLE;

		/* Construct the composite curve */
/*			CURVE.objid	= NULL_OBJID ;
			CURVE.osnum	= MOD_ENV.md_id.osnum ;
*/ /*
			sts = om$send(	msg = message GRcompcurve.EMmakecomp(
				    &msg,
				    &MOD_ENV,
				    i,	             /* number of edges 
				    compcurve_edges, /* struct GRlc_info
				    &rotten ),
					senderid = NULL_OBJID,
					targetid = CURVE.objid,
					targetos = CURVE.osnum )  ;
*/
			sts = om$construct( classid = OPP_GRcompcurve_class_id,
				    p_objid = &CURVE.objid,
				    osnum = MOD_ENV.md_id.osnum );
			CURVE.osnum	= MOD_ENV.md_id.osnum ;
			as$status(sts = sts);
			if (!(sts & 1)) { rc_evaluate = 0 ; goto quit ; }

			sts = om$send(	msg = message GRcompcurve.EMmakecomp(
				    &msg,
				    &MOD_ENV,
				    i,	             /* number of edges */
				    compcurve_edges, /* struct GRlc_info * */
				    &rotten ),
				 senderid = NULL_OBJID,
				 targetid = CURVE.objid,
				 targetos = CURVE.osnum
					 )  ;
			as$status(sts = sts);
			if (!(sts & 1)) { rc_evaluate = 0 ; goto quit ; }

			if (msg != MSSUCC) {
				#ifdef DEBUG
				printf("Failure for message GRcompcurve.EMmakecomp() \n") ;
				printf("rotten_one = %d \n", rotten) ; 
				/* entry that made compositing not possible */
				#endif
				rc_evaluate = 0 ; goto quit ;
				} 

			sts = om$send(	msg = message GRvg.GRputsymb(
				    			&msg, &xyzsymb),
				senderid = NULL_OBJID,
				targetid = CURVE.objid,
				targetos = CURVE.osnum )  ; /* 92/11/11 */
			as$status(sts = sts) ;

		/* Put graphic properties to the composite (92/07/03) */

		if (compute_flag) {

			comp_props = GRIS_DISPLAYABLE ;
			if (macro_props & GRIS_DISPLAYABLE)
				action = 1 ; /* set with mask */
			else
				action = 0 ; /* clear with mask */
			sts = om$send(	msg = message GRvg.GRchgprops(
				    		&msg, &action, &comp_props),
				senderid = NULL_OBJID,
				targetid = CURVE.objid,
				targetos = CURVE.osnum ); as$status(sts = sts);
			if (!(sts & msg & 1)) { 
				sts = om$send(	msg	 = message GRvg.GRdelete(&msg, &MOD_ENV),
					senderid = NULL_OBJID,
					targetid = CURVE.objid,
					targetos = CURVE.osnum ) ;
				as$status(sts = sts);
				rc_evaluate = 0 ; goto quit ; 
				}

			comp_props = GRIS_LOCATABLE ;
			if (macro_props & GRIS_LOCATABLE)
				action = 1 ; /* set with mask */
			else
				action = 0 ; /* clear with mask */
			sts = om$send(	msg = message GRvg.GRchgprops(
				    		&msg, &action, &comp_props),
				senderid = NULL_OBJID,
				targetid = CURVE.objid,
				targetos = CURVE.osnum ); as$status(sts = sts);
			if (!(sts & msg & 1)) { 
				sts = om$send(	msg	 = message GRvg.GRdelete(&msg, &MOD_ENV),
						senderid = NULL_OBJID,
						targetid = CURVE.objid,
						targetos = CURVE.osnum )  ;
				rc_evaluate = 0 ; goto quit ; 
				}

			#ifdef DEBUG
			sts = om$send(	msg = message GRgraphics.GRgetprops(
							&msg, 
							&comp_props),
				senderid = NULL_OBJID,
				targetid = CURVE.objid,
				targetos = CURVE.osnum) ; 
				as$status(sts = sts) ;
			if (!(sts & msg & 1)) { rc_evaluate = 0 ; goto quit ; }
			if (comp_props & GRIS_DISPLAYABLE)
				printf("composite curve is diplayable \n") ;
			else
				printf("composite curve is not diplayable \n") ;
			#endif

			} /* if compute */

			/* 
				=> Update list of boundaries 
			 */

			if (num_sol < max_bound) {
				BOUNDtab[num_sol] = CURVE ;
				num_sol = num_sol + 1 ;
				}
			else {
				printf("Maximum number of boundaries exceeded for macro \n") ;
				sts = om$send(	msg	 = message GRvg.GRdelete(&msg, &MOD_ENV),
						senderid = NULL_OBJID,
						targetid = CURVE.objid,
						targetos = CURVE.osnum )  ;
				as$status(sts = sts);
				rc_evaluate = 0 ; /* error */
				goto quit ;
				}

			} /* else */
		} /* while (1) */

/* --------------------------------------------------------------------
	4) Set the rest of boundaries (max_bound) to NULL_OBJID 
   --------------------------------------------------------------------
 */

#ifdef DEBUG
	printf("Number of solution is %d\n", num_sol) ;
#endif
  
	*nb_bound = num_sol ;

	for (i = num_sol ; i < max_bound ; i = i+1) {
		BOUNDtab[i].objid = NULL_OBJID ;
		BOUNDtab[i].osnum = MOD_ENV.md_id.osnum ;
		}

	rc_evaluate = 1 ; /* OK */

quit :

	_FREE (edges_list) ;
	_FREE (build_edges) ;
	_FREE (edges_info) ;
	_FREE (compcurve_edges) ;
	if (surf_copy == 1) {
		/* Delete copy of owned surface */
		sts = om$send(	msg	 = message EMSsurface.GRdelete(
				    &msg,
				    &OBJ_ENV),
				senderid = NULL_OBJID,
				targetid = OBJ.objid,
				targetos = OBJ.osnum )  ;
		as$status(sts = sts);
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("Warning : EMSsurface.GRdelete() failed\n") ;
			#endif
			}
		}

	#ifdef DEBUG
	printf("End of SMevaluate_xbound()\n") ;
	#endif

	return rc_evaluate ;
} /* SMevaluate_xbound() */

end implementation Root;


