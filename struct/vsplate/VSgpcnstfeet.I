/* $Id: VSgpcnstfeet.I,v 1.1.1.1 2001/01/04 21:10:53 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsplate/VSgpcnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * 	$Log: VSgpcnstfeet.I,v $
 * 	Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 * 	Initial import to CVS
 * 	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/12/26  11:59:26  pinnacle
# Replaced: vsplate/VSgpcnstfeet.I for:  by manoj for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/24/97 	manoj 		modified for TR #179701926
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSgapPlate ;

#include <stdlib.h>
#include "exmacros.h"
#include "AS_status.h"
#include "EMSmsgdef.h"
#include "grmacros.h"
#include "vsiomacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
#include "bs.h"
/*
 * Includes of function prototypes.
 */
#include "EMSsffmacros.h"
#include "bsplptnorrg.h"
#include "vsdelbndries.h"
#include "vsispntonsrf.h"
#include "vspratpt.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "vsplate.h"

/* 
 * Expression (value is assigned by user ) to solve tolerance specific 
 * problems.
 */

from EMSsurface	import  GRgetrang;
from EMSplane   import	GRdelete;

extern IGRboolean	ASbroadcast_in_progress ;
extern IGRint		IntTwoSrf();
extern OMuword		OPP_EMSplane_class_id;

extern IGRboolean 	_Pathway ,
			_pathway_orient ,
			_pathway_trim ;

/*----------------------------------------------------------------------------*/
long VSgetEliminatingPoint( msg, operandBot, operatorBot, operatorTop,
				cst, point )

long			*msg ;
struct GRobj_env	*operandBot,
			*operatorBot,
			*operatorTop ;
struct GRvg_construct	*cst ;
IGRpoint		point ; {

	long		sts ;
	IGRpoint	midPntB,
			midPntT ;
	int		nbIntsB	= 0,
			nbIntsT = 0 ;
	struct GRid	*intsB 	= NULL,
			*intsT	= NULL ;
	struct GRparms	pjParms ;
	struct GRlc_info
			optrInfo,	/* Arg. to EMintersect_two_...	*/
			opndInfo ;	/* Arg. to EMintersect_two_...	*/
	struct GRobj_env
			*sf		= NULL ;
	double		*midPnt1	= NULL,
			*midPnt2	= NULL ;

	opndInfo.located_obj = operandBot->_grid ;
	opndInfo.module_info = operandBot->mod_env ;
	optrInfo.located_obj = operatorBot->_grid ;
	optrInfo.module_info = operatorBot->mod_env ;

	sts = EMintersect_two_element(	&opndInfo,
					&optrInfo,
					TRUE,
					cst,
					&nbIntsB,
					&intsB,
					msg ) ;
 	 __CheckRC( sts, *msg, "EMintersect_two_element", wrapup ) ;

	if( nbIntsB ) {
		sts = VSptatpr( msg, cst->env_info, intsB[0].objid, 0.5, midPntB ) ;
		__CheckRC( sts, *msg, "VSptatpr", wrapup ) ;

		midPnt1 = midPntB ;
	} else {
		midPnt1 = midPntT ;
		midPnt2 = midPntB ;
		sf	= operatorBot ;	 
	}

	optrInfo.located_obj = operatorTop->_grid ;
	optrInfo.module_info = operatorTop->mod_env ;

	sts = EMintersect_two_element(	&opndInfo,
					&optrInfo,
					TRUE,
					cst,
					&nbIntsT,
					&intsT,
					msg ) ;
 	 __CheckRC( sts, *msg, "EMintersect_two_element", wrapup ) ;

	if( nbIntsT ) {
		sts = VSptatpr( msg, cst->env_info, intsT[0].objid, 0.5, midPntT ) ;
		__CheckRC( sts, *msg, "VSptatpr", wrapup ) ;

		midPnt1 = midPntT ;
	} else {
		midPnt1 = midPntB ;
		midPnt2 = midPntT ;
		sf	= operatorTop ;
	}

	if( !( nbIntsB && nbIntsT ) ) {
		if( !nbIntsB && !nbIntsT ) {
			*msg = EMS_E_NoIntersection ;
			sts  = OM_W_ABORT ;
			goto wrapup ;
		}
		sts = om$send(  msg     = message GRgraphics.GRptproject(
						msg,
						&sf->_matrix_type,
						sf->_matrix,
						midPnt1,
						midPnt2,
						&pjParms ),
				senderid= sf->_objid,
				targetid= sf->_objid,
				targetos= sf->_osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup ) ;
	}

	VSmidpoint( midPntB, midPntT, point ) ;

	wrapup :
		vs$bulk_delete(	count	= nbIntsB,
				grids	= intsB,
				theEnv	= cst->env_info ) ;
		vs$bulk_delete( count	= nbIntsT,
				grids	= intsT,
				theEnv	= cst->env_info ) ;
		if( nbIntsB ) _FREE( intsB ) ;
		if( nbIntsT ) _FREE( intsT ) ;

		return sts ;

} /* VSgetEliminatingPoint */

/*----------------------------------------------------------------------------
IntSrfPlInf() function computes the intersection between an infinite plane
and a general surface only (in particular, the bounded or infinite planes are 
not considered as a general surface).
A return code of 1 indicates a successful processing.

After having got the range of the general surface, this function builds an 
intermediate bounded plane in the given range, and calls the IntTwoSrf() 
function which implements JLL algorithm to compute intersection.
----------------------------------------------------------------------------*/

IGRlong IntSrfPlInf(	trim_option, app_option,
		plane_lc_ptr, srf_lc_ptr, cst_ptr, nb_int_ptr, int_sol) 
IGRboolean		trim_option, app_option ;		    /* I */
struct GRlc_info 	*plane_lc_ptr ;	/* infine  plane   */ 	    /* I */
struct GRlc_info	*srf_lc_ptr   ;	/* general surface */       /* I */	
struct  GRvg_construct	*cst_ptr      ; 			    /* I */
IGRint			*nb_int_ptr   ;	/* number of intersection*/ /* O */
struct GRid		*int_sol      ;	/* list of intersection  */ /* O */
{
   struct  GRvg_construct cstbis ;

   struct GRlc_info	trav_obj  ;
   IGRdouble		t_plan[6], scale ;
   IGRdouble		pl_poles[12]   ; /* 4 poles   */
   IGRdouble		pl_u_knots[12] ; /* 4 u_knots */
   IGRdouble		pl_v_knots[12] ; /* 4 v_knots */
   struct IGRplane	plane        ;
   struct IGRbsp_surface new_plane   ;
   IGRboolean		world, in_range ;
   GRrange		range     ;

   BSrc			rc        ; /* rc of BSplptnorrg() */
   IGRint		rc_int    ; /* rc of this function */
   IGRlong 		sts, msg  ;


   *nb_int_ptr  = 0 ;
   cstbis 	= *cst_ptr ; /* re-copy whole construction list structure */ 

   /*
	Get plane info
    */

   plane.point  = &t_plan[0] ;   	
   plane.normal = &t_plan[3] ;   	
   sts = om$send(msg =	message GRvg.GRdetplane(&msg,
				&plane_lc_ptr->module_info.md_env.matrix_type,
				plane_lc_ptr->module_info.md_env.matrix,
				&plane),
		senderid = NULL_OBJID,
		targetid = plane_lc_ptr->located_obj.objid,
	 	targetos = plane_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}

   /*
	Get surface range in world coordinates
    */

   world = 1 ;
   sts = om$send(msg = message EMSsurface.GRgetrang(&msg,
				&srf_lc_ptr->module_info.md_env.matrix_type,
				srf_lc_ptr->module_info.md_env.matrix,
				&world,
				range),
		senderid = NULL_OBJID,
		targetid = srf_lc_ptr->located_obj.objid,
	 	targetos = srf_lc_ptr->located_obj.osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Compute an intermediate plane in the surface range
    */

   scale = 2 ; 
   new_plane.poles   = &pl_poles[0]   ;
   new_plane.u_knots = &pl_u_knots[0] ;
   new_plane.v_knots = &pl_v_knots[0] ;
   new_plane.weights = NULL ;
   new_plane.bdrys   = NULL ;


   BSplptnorrg(	&range[0], &range[3],
		plane.point, plane.normal,
		scale,
		&in_range,
		&new_plane,			/* bounded B-spline plane */
		&rc) ;

   if (rc != BSSUCC) {
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

   /*
	Construct the new plane
    */

   cstbis.geometry = (char *)&new_plane  ;   
   cstbis.msg = &msg ;

   trav_obj.located_obj.objid    = NULL_OBJID ;
   trav_obj.located_obj.osnum    = cst_ptr->env_info->md_id.osnum ;
   trav_obj.module_info          = *cst_ptr->env_info ;
   
   ex$get_modid(mod_osnum = trav_obj.module_info.md_id.osnum,
	        mod_id    = &trav_obj.module_info.md_id.objid) 		;

   cstbis.env_info = &trav_obj.module_info ;

   sts = om$construct(classid = OPP_EMSplane_class_id,
                      p_objid = &trav_obj.located_obj.objid,
                      osnum   = trav_obj.located_obj.osnum,
                      msg     = message GRgraphics.GRconstruct(&cstbis));

   msg = *(cstbis.msg) ;
   as$status(sts = sts)  ;
   if (!(sts & msg & 1)) {
		rc_int = 0 ; /* failure */
		goto quit  ;
		}
#ifdef DEBUG
   gr$display_object(object_id = &trav_obj.located_obj,
		md_env  = &trav_obj.module_info,
		mode	= GRbd) ;
#endif

   /*
    * Intersect the intermediate plane with the general surface
    * works better with the tolerance when the surface is intersecting
    * on the plane and the inverse. ( Diff is variation of 0.0001
    * Oct'95: adz
    *
    * sts = IntTwoSrf(trim_option, app_option, srf_lc_ptr, &trav_obj, 
    */

   sts = IntTwoSrf(trim_option, app_option, &trav_obj, srf_lc_ptr, 
		cst_ptr, nb_int_ptr, int_sol, &msg) ;
		/*
if (vsDEBUG){
   gr$display_object(object_id = int_sol,
		md_env  = &trav_obj.module_info,
		mode	= GRbd) ;
}
*/
   if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("IntSrfPlInf() : error when calling IntTwoSrf() \n") ;
	#endif
	rc_int = 0 ; /* failure */
	goto quit  ;
	}

rc_int = 1 ; /* success */

quit:

	if( trav_obj.located_obj.objid != NULL_OBJID ) {
		#ifdef DEBUG
		printf("Delete the intermediate constructed plane \n") ;
		#endif
		sts = om$send(msg = message EMSplane.GRdelete(&msg,
					&trav_obj.module_info),
			senderid = NULL_OBJID,
			targetid = trav_obj.located_obj.objid,
	 		targetos = trav_obj.located_obj.osnum) ;
		if (!(sts & msg & 1)) {
			#ifdef DEBUG
			printf("IntSrfPlInf() : warning - delete of intermediate plane not done \n") ;
			#endif
			/* continue however */
			}
		}
	return rc_int ;

} /* IntSrfPlInf() */

/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct  GRid 	*listOfOutputs ) {

	long		sts,		/* OM return code		*/
			rc ;		/* Aux. return code 		*/
	struct GRobj_env
			operand,	/* ... of this operation	*/
			parentOutput,	/* My parent plate's output	*/
			botSf,		/* Bottom sf. of operator plate	*/
			topSf,		/* Top sf. of operator plate	*/
			reSplit ;	/* Sub-surface to split again	*/
	struct GRvg_construct
			cst ;		/* ... of make-face		*/
	int		i,		/* Loop index			*/
			j,
			nbIntwbot,	/* # of intersections w/ bot sf.*/
			nbIntwtop ;	/* # of intersections w/ top sf.*/
	struct GRsymbology	
			mySymb ;	/* My symbology			*/
	struct GRid 	intwbot[10],	/* Intersections w/ bottom sf.	*/
			intwtop[10],	/* Intersections w/ top    sf.	*/
			sfCopy,		/* Copy of top or bot. sf. w/o
					   boundaries.			*/
			opndCopy,	/* Copy of operand surface	*/
			subSurfs[2],	/* Results of splitting op.	*/
			virtParent1 ;	/* Virtual parent #1		*/
	struct GRlc_info
			optrInfo,	/* Arg. to EMintersect_two_...	*/
			opndInfo ;	/* Arg. to EMintersect_two_...	*/
	unsigned	myMask ;	/* My mask of sub-plates	*/
	int		maxSubPlates,	/* Max. # of sub-plates		*/
			botWasCopied,	/* Was bottom surface copied ?	*/
			topWasCopied,	/* Was top    surface copied ?	*/
			opnWasCopied,	/* Was operand copied ?		*/
			splWthBotFailed,/* Split w/ bot surface failed ?*/
			splWthTopFailed;/* Split w/ top surface failed ?*/
	VSdspRep	oldRep ;	/* Of parent before consume	*/
	IGRpoint	ptBwnBotTop ;	/* Point on operand between bot
					    and top of operator		*/
	IGRboolean	saveBroadcast ;	/* Inhibits copy-graph		*/
	VSpartAttr	operatorAttr ;	/* Operator's attributes	*/
	VSplateAttr	operatorInfo ;	/* Operator's attributes	*/

	/*
	 * What is painfully done here:
	 *
	 * The first plate (parent #0 : low-priority plate = operand) is going
	 * to be traversed by the second plate (parent #1 : high-priority
	 *  plate = operator). The first plate is consumed.
	 *
	 * The operand plate HP is supposed horizontal in the desrciption
	 * and the operator plate VP vertical:
	 * 
	 *		+-+ VP
	 *		| |
	 *	+-------|-|-----+ HP
	 *	|	| |	|
	 *	|	| |	| HPbot
	 *	+-------|-|-----+
	 *	   VPbot| | VPtop
	 *		+-+
	 *
	 * HP's bottom side, HPbot is first split by VP's bottom side into
	 * two surfaces S1 and S2. The one to be split again is found out, say
	 * S1 which is then split by VP's top side, VPtop, into S3 and S4, the
	 * the one to delete between S3, and S4 is found out.
	 *
	 * The following case are troublesome :
	 *
	 * CASE 1			   CASE 2
	 *		      +-+ VP			      +-+ VP
	 *		      | |			      | |
	 *	+-------------|-| HP		+-------------|-| HP
	 *	|	      |	|		|	      |	|
	 *	|	      |	| HPbot		|	      |	| HPbot
	 *	+-------------|-|		+-------------|-|
	 *		 VPbot| | VPtop			 VPtop| | VPbot
	 *		      +-+			      +-+
	 *
	 * CASE 3			   CASE 4
	 *	+-+ VP				+-+ VP	
	 *	| |				| |
	 *	|-|-------------+ HP		|-|-------------+ HP	
	 *	| |		|		| |		|
	 *	| |		| HPbot		| |		| HPbot
	 *	|-|-------------+		|-|-------------+
	 * VPbot| | VPtop		   VPtop| | VPbot
	 *	+-+				+-+
	 *
	 * Since :
	 * CASE 2, 3 : splitting with VPbot will fail
	 * CASE 1, 4 : re-splitting with VPtop will fail.
	 *
	 * To handle those case, the following will be done:
	 * If splitting with VPbot fails (2,3), then go on to splitting with
	 * VPtop, eliminate unnneed surface.
	 * If splitting with VPbot succeeds but splitting with VPtop fails (1,4)
	 * just eliminate unneeded surface.
	 */


	if( !countOfInputs ) { 
		*msg = MSINARG ; return OM_W_ABORT ; 
	}

	nbIntwbot		= nbIntwtop	= 0 ;
	parentOutput._objid	= reSplit._objid= NULL_OBJID ;
	topWasCopied		= botWasCopied	= opnWasCopied = FALSE ;

	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress	= TRUE ;

	VSsetGRids( myEnv->_MD_OS, 2, subSurfs ) ;	
	VSsetGRids( myEnv->_MD_OS, 2, listOfOutputs ) ;	

	/*
	 * The operand is the parent I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * We need parent to have a surface output.
	 */
	sts = om$send(	msg	= message VSmodPlate.VSforceParentRep(
	 					msg,
						myEnv,
	 					&operand._grid,
	 					AC_3D_REP,
						AC_ENV_REP,
						VS_m_2dWCompute,
						VS_m_2dWCompute,
						&oldRep ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSmodPlate.VSforceParentRep", wrapup );

	/*
	 * Consume parent plate, and get an image of its graphic member upon
	 * which we are going to act. The following call will set
	 * `operand.mod_env'.
	 */
  	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				nbfeet	= 1,
				objEnv	= &operand.mod_env,
				feet	= &parentOutput._grid ) ;
 	 __CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	opndInfo.located_obj = parentOutput._grid ;
	opndInfo.module_info = parentOutput.mod_env = *myEnv ;

	/*
	 * Get bottom and top surface of operator plate.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plBotSfPath,
							&botSf._grid,
							&botSf._matrix_type,
							botSf._matrix ),
			targetid= listOfInputs[1].objid,
			targetos= listOfInputs[1].osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	
	botSf._md_os = botSf._osnum ;
	ex$get_modid( mod_osnum = botSf._md_os, mod_id = &botSf._md_id ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_plTopSfPath,
							&topSf._grid,
							&topSf._matrix_type,
							topSf._matrix ),
			targetid= listOfInputs[1].objid,
			targetos= listOfInputs[1].osnum ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	
	topSf._md_os = topSf._osnum ;
	ex$get_modid( mod_osnum = topSf._md_os, mod_id = &topSf._md_id ) ;

	/*
	 * Bottom and top surface may have holes on them, if high-priority
	 * plate has undergone impose-boundaries operation of if its support
	 * had holes in it. This holes may give several intersection curves
	 * which we don't want: we remove the boundaries if any, since we
	 * cannot alter those surfaces directly (they belong to the high-
	 * priority plate), a copy will be returned if there was boundaries
	 * which have been removed. Those copies are deleted upon exit.
	 * If they were not copied (no boundaries), the following function
	 * returns the input surface.
	 */
	sts = VSdelete_inside_bdrs_if_any( msg,
					   &botSf.mod_env,
					   &botSf._grid,
					   myEnv,
					   &sfCopy,
					   &botWasCopied ) ;
	__CheckRC( sts, *msg, "VSdelete_inside_bdrs_if_any", wrapup ) ;

	if( botWasCopied ) {
		botSf.mod_env = *myEnv ; botSf._grid = sfCopy ;
	}
	sts = VSdelete_inside_bdrs_if_any( msg,
					   &topSf.mod_env,
					   &topSf._grid,
					   myEnv,
					   &sfCopy,
					   &topWasCopied ) ;
	__CheckRC( sts, *msg, "VSdelete_inside_bdrs_if_any", wrapup ) ;
	if( topWasCopied ) {
		topSf.mod_env = *myEnv ; topSf._grid = sfCopy ;
	}

	/*
	 * If operand (low-priority) plate has boundaries, we may also get
	 * several intersections if top or bottom surface of operator (high-
	 * priority) plate crosses a boundary. Since the intesections lines
	 * are only used to split, we must arrange to compute them with a
	 * boundaryless operand surface, deleted upon exit.
	 */
	sts = VSdelete_inside_bdrs_if_any( msg,
					   &parentOutput.mod_env,
					   &parentOutput._grid,
					   myEnv,
					   &opndCopy,
					   &opnWasCopied ) ;
	__CheckRC( sts, *msg, "VSdelete_inside_bdrs_if_any", wrapup ) ;
	if( opnWasCopied ) {
		opndInfo.located_obj = opndCopy ;
		opndInfo.module_info = *myEnv ;
	} else {
		opndInfo.located_obj = parentOutput._grid ;
		opndInfo.module_info = parentOutput.mod_env ;
	}

	/*
	 * `ptBwnBotTop' is only used if either `splWthBotFailed' or
	 * `splWthTopFailed' is TRUE. But since the needed surfaces to compute
	 * it will no longer be here when we need it, we have to compute it
	 * now.
	 */
	{ struct GRobj_env pf ;
	pf._grid = opndInfo.located_obj ; pf.mod_env = opndInfo.module_info ;
	sts = VSgetEliminatingPoint( msg, &pf, &botSf, &topSf, &cst,
				     ptBwnBotTop ) ;
	__CheckRC( sts, *msg, "VSgetEliminatingPoint", wrapup ) ;
	}

	/*
	 * Intersect operand's surface with operator's bottom surface.
	 */
	optrInfo.located_obj	= botSf._grid ;
	optrInfo.module_info	= botSf.mod_env ;

	if( vs$is_ancestry_valid( object  = &optrInfo.located_obj, 
				  classid = OPP_EMSplane_class_id  ))
	{
	   sts = IntSrfPlInf(     	   FALSE,
					   TRUE,
					   &optrInfo,
					   &opndInfo,
					   &cst,
					   &nbIntwbot,
					   intwbot	);
	   if( !( sts & 1 ) )	goto ems_intersect_bot;
	}
	else{
	   ems_intersect_bot:
	   sts = EMintersect_two_element( &opndInfo,
					   &optrInfo,
					   FALSE,
					   &cst,
					   &nbIntwbot,
					   &intwbot,
					   msg ) ;
	}

	if( !( sts & 1 ) ) {
		/*
		 * CASE 2 or 3.
		 */
		splWthBotFailed = TRUE ;
	} else {
				
		if( !nbIntwbot ) {
			/*
			 * CASE 2 or 3.
			 */
			splWthBotFailed = TRUE ;
		} else {
			splWthBotFailed = FALSE ;
		}
	}

	/*
	 * Intersect operand's surface with operator's top surface.
	 */
	optrInfo.located_obj	= topSf._grid ;
	optrInfo.module_info	= topSf.mod_env ;

	if( vs$is_ancestry_valid( object  = &optrInfo.located_obj, 
			   	  classid = OPP_EMSplane_class_id  ))
	{
	   sts = IntSrfPlInf(     	   FALSE,
					   TRUE,
					   &optrInfo,
					   &opndInfo,
					   &cst,
					   &nbIntwtop,
					   intwtop	);

	   if( !( sts & 1 ) )	goto ems_intersect_top;
	}
	else{
	   ems_intersect_top:
	   sts = EMintersect_two_element ( &opndInfo,
					   &optrInfo,
					   FALSE,
					   &cst,
					   &nbIntwtop,
					   &intwtop,
					   msg ) ;
	}

	if( !( sts & 1 ) ) {
		/*
		 * CASE 1 or 4.
		 */
		splWthTopFailed = TRUE ;
	} else {
		if( !nbIntwtop ) {
			/*
			 * CASE 1 or 4.
			 */
			splWthTopFailed = TRUE ;
		} else {
			splWthTopFailed = FALSE ;

		}
	}

	if( splWthBotFailed && splWthTopFailed ) {
		*msg = EMS_E_NoSolution ; sts = OM_W_ABORT ; goto wrapup ;
	}
		
	if( !splWthBotFailed  ) {
		double	*testPoint ;

		__DBGpr_obj(" parent Output ", parentOutput._grid ) ;

      
       		//block forced to introduce local viriables 
		{
		/* 
	 	* starts : Added to solve TR #179701926 (match A1)
         	*          (soln. is to change tolerance for the operation only)
	 	*/
		/*
	 	* tolerance value changed (temporarily). Save current pathway values
	 	*/
		IGRboolean pw_trim   = _pathway_trim;
		IGRboolean pw_orient = _pathway_orient;


		struct {
			int 	flag          ;
			double 	orgCht, orgBas;
			double 	newCht, newBas;
			double 	adjust;
		} tol ;

		tol.flag = VSgetVariableTolerance( VS_K_PwP, &tol.adjust ) ;
 
        	if(tol.flag) {
			gr$get_chord_height_tolerance(	sizbuf = sizeof( tol.orgCht ), 
						buffer = &tol.orgCht );

			tol.newCht = tol.orgCht * tol.adjust;

			gr$get_basis_tolerance(	sizbuf = sizeof( tol.orgBas ), 
					buffer = &tol.orgBas  );

			tol.newBas = tol.orgBas * tol.adjust;
 		}

		if(_Pathway) {
  			_pathway_trim   = 1;
  			_pathway_orient = 1;
		}

		if (tol.flag) {
 	        	gr$put_chord_height_tolerance(	sizbuf = sizeof(tol.newCht),
							buffer = &tol.newCht );

  			gr$put_basis_tolerance( sizbuf = sizeof( tol.newBas ),
						buffer = &tol.newBas );
        	}
        	//ends : Added to solve TR #179701926 (match A1)

	  	/*
	   	 * Split operand's plate surface with intersection curve with
	   	 * operator's bottom surface.
	   	 */
		sts = vs$split_surface_with_curve(
					msg		= msg,
					surfId		= &parentOutput._grid,
					surfEnv		= &parentOutput.mod_env,
					curveId		= intwbot + 0,
					curveEnv	= myEnv,
					resultSymb	= &mySymb,
					resultList	= subSurfs );

		__CheckRC( sts, *msg, "vs$split_surface_with_curve", wrapup ) ;

        	/*
	 	* Added to solve TR #179701926 starts : match A2
         	* Now recover the original.   
	 	*/

		if (tol.flag) {
  			gr$put_chord_height_tolerance(  sizbuf = sizeof(tol.orgCht),
							buffer = &tol.orgCht );

  			gr$put_basis_tolerance(	sizbuf = sizeof(tol.orgBas),
						buffer = &tol.orgBas );
		}

        	if (_Pathway) {
			_pathway_trim   = pw_trim   ;
			_pathway_orient = pw_orient ;
        	}
        	//ends : Added to solve TR #179701926  (match A2)       
		}

		if( !( sts & 1 & *msg ) ) {
			splWthBotFailed		= TRUE ;
			listOfOutputs[0].objid	= NULL_OBJID ;
			reSplit		  	= parentOutput ;
			goto next1 ;
		}

		sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					  msg, 
					  &myMask, 
					  &i, 
					  &maxSubPlates ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSdivFeature.VSgetSubMask", wrapup ) ;

		/*
		 * Find out on which sub-surface is mid-point of intersection curve
		 * #1, to decide which sub-surface will be resplit.
		 */
		testPoint = ptBwnBotTop ;
		j = -1 ;

		for( i = 0 ; i < 2 ; i++ ) {

			int isInside ;

			sts = VSisPointOnSurface(
						msg,
						&parentOutput.mod_env,
						subSurfs + i,
						TRUE,
						testPoint,
						&isInside ) ;
			__CheckRC( sts, *msg, "VSisPointOnSurface", wrapup ) ;
			if( isInside ) { j = i ; break ; }
		}

		switch( j ) {
			case  0 : reSplit._grid    = subSurfs[0] ;
				  listOfOutputs[0] = subSurfs[1] ; break ;
			case  1 : reSplit._grid    = subSurfs[1] ;
				  listOfOutputs[0] = subSurfs[0] ; break ;
			case -1 : /* Cannot find sub-surf. to keep */
				  *msg = EMS_E_NoSolution ; sts = OM_W_ABORT ;
			  	  goto wrapup ;
		}
		reSplit.mod_env = parentOutput.mod_env ;
	} else {
		listOfOutputs[0].objid = NULL_OBJID ;
		reSplit		       = parentOutput ;
	}
next1 :
	VSsetGRids( myEnv->_MD_OS, 2, subSurfs ) ;


	if( !splWthTopFailed ) {
		double *testPoint ;
		__DBGpr_obj(" reSplit._grid= ", reSplit._grid); 

	 	/*
          	* Value of tolerance chnaged (temporarily).
	  	*/
		{
        	/* starts: Added to solve TR #179701926 (match B1)
         	*/
         	IGRboolean pw_trim   = _pathway_trim;
         	IGRboolean pw_orient = _pathway_orient;

         	struct {
			int    flag	    ;
			double orgCht,orgBas;
			double newCht,newBas;
			double adjust       ;
         	} tol;

        	tol.flag = VSgetVariableTolerance( VS_K_PwP, &tol.adjust );
 
        	if (tol.flag) {

           	gr$get_chord_height_tolerance(
					sizbuf = sizeof(tol.orgCht), 
					buffer = &tol.orgCht);

           				tol.newCht = tol.orgCht * tol.adjust;

           	gr$get_basis_tolerance(
				sizbuf = sizeof(tol.orgBas), 
				buffer = &tol.orgBas );

           	tol.newBas = tol.orgBas * tol.adjust;
        	}

		if (_Pathway) {
  			_pathway_trim   = 1;
  			_pathway_orient = 1;
		}

		if (tol.flag) {
 	       	 gr$put_chord_height_tolerance(
					sizbuf = sizeof(tol.newCht),
					buffer = &tol.newCht);

  		 gr$put_basis_tolerance( sizbuf = sizeof(tol.newBas),
		      	   		 buffer = &tol.newBas );
					  
        	}

        	//ends : to solve TR #179701926 (match B1)

		sts = vs$split_surface_with_curve(
					msg		= msg,
					surfId		= &reSplit._grid,
					surfEnv		= &reSplit.mod_env,
					curveId		= intwtop + 0,
					curveEnv	= myEnv,
					resultSymb	= &mySymb,
					resultList	= subSurfs ) ;


       		/*
		* Added to solve TR #179701926:starts : match B2 
        	* Now restore the original tolerance.
        	*/

		if (tol.flag) {
  			gr$put_chord_height_tolerance(	
						sizbuf = sizeof(tol.orgCht),
						buffer = &tol.orgCht ) ;

  			gr$put_basis_tolerance(	sizbuf = sizeof(tol.orgBas),
						buffer = &tol.orgBas);
		}

        	if (_Pathway) {
          		_pathway_trim   = pw_trim;
          		_pathway_orient = pw_orient;
        	}
        	//ends: Added to solve TR #179701926 (match B2)
		}


		if( !( sts & 1 & *msg ) ) {
			splWthTopFailed = TRUE ;
			listOfOutputs[1].objid = NULL_OBJID ;
			goto next2 ;
		}
		__CheckRC( sts, *msg, "vs$split_surface_with_curve", wrapup ) ;

		reSplit._objid = NULL_OBJID ; /* This object now gone */

		/*
		 * Of two new sub-surfaces, decide which one will be deleted:
		 * the one containing the middle of the mid-points.
		 */
		testPoint = ptBwnBotTop ;
		j = - 1 ;

		for( i = 0 ; i < 2 ; i++ ) {
			int isInside ;

			sts = VSisPointOnSurface(	msg,
							&parentOutput.mod_env,
							subSurfs + i,
							TRUE,
							testPoint,
							&isInside ) ;
			__CheckRC( sts, *msg, "VSisPointOnSurface", wrapup ) ;

			if( isInside ) { j = i ; break ; }
		}

		switch( j ) {
			case  0 : listOfOutputs[1] = subSurfs[1] ; goto _DELETE;
			case  1 : listOfOutputs[1] = subSurfs[0] ; 
			_DELETE	:	  
				  /*
				   * I must erase first since make-face message
				   * in vs$split_surface... displays everybody.
				   */
				  vs$bulk_display(	count	= 1,
				  			grids	= subSurfs + j,
			  				theEnv	= &parentOutput.mod_env,
			  				dpmode	= GRbe ) ;
				  vs$bulk_delete(	count	= 1,
							grids	= subSurfs + j,
							theEnv	= &parentOutput.mod_env ) ;
				  break ;
			case -1 : /* Cannot find sub-surf to delete */
				  *msg = EMS_E_NoSolution ; sts = OM_W_ABORT ;
				  goto wrapup ;
		}
	} else {
		listOfOutputs[1].objid = NULL_OBJID ;
	}
next2 :
	if( splWthBotFailed && splWthTopFailed ) {
		*msg = EMS_E_NoSolution ; sts = OM_W_ABORT ; goto wrapup ;
	}

	*countOfOutputs = 2 ;

	/*
	 * Get orientation of operator plate and swap output #0 and output #1
	 * if need be: if operator plate has a reversed orientation, left
	 * and right have been interchanged because the parametrizations
	 * the intersection curves computed by EMintersect... have been
	 * reversed, if we do not not do so, the sub-plates will be swapped
	 * when the operator plate is edited and its orientation is changed:
	 * their names will be swapped and if there is only one sub-plate,
	 * it will jump from one side of the operator plate to the other...
	 */
	operatorAttr.Iwant	= VS_m_Orientation ;
	operatorAttr.specific	= (void *) &operatorInfo ;

	/*
	 * Note: if parent #1 (high priority plate) is a pretend, it will not
	 * understand the following message, get virtual parent.
	 */

	sts = VSgetVirtualInfo( msg, listOfInputs + 1, NULL, &virtParent1 ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	sts = om$send(	msg	= message GRvg.GRgetattr(
						msg, (char *) &operatorAttr ),
			targetid= virtParent1.objid,
			targetos= virtParent1.osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	switch( operatorInfo.orientation ) {
		struct GRid	tmp ;
		case VS_K_USE_NAT_NORM : break ;
		case VS_K_USE_REV_NORM : 
			tmp		 = listOfOutputs[1] ;
			listOfOutputs[1] = listOfOutputs[0] ;
			listOfOutputs[0] = tmp ; break ;
	}

	if( splWthBotFailed || splWthTopFailed ) {
		if( IF_NULL_OBJID( listOfOutputs[0].objid ) ) {
			i = 0 ;
		} else if( IF_NULL_OBJID( listOfOutputs[1].objid ) ) {
			i = 1 ;
		}
		om$send(	msg	= message VSdivFeature.VSsetSubMask(
						msg, VS_K_REM_BITS, 1 << i ),
				targetid= my_id ) ;
	} else {
		/*
		 * Sub-plates may have been deleted purposedly by user: do not
		 * put them  back.
		 */
		for( i = 0 ; i < maxSubPlates ; i++ ) {
			if( myMask & ( 1 << i ) ) {
				/* Keeping result: NO-OP */
			} else {
				vs$bulk_delete(	count 	= 1,
						grids	= listOfOutputs + i,
						theEnv	= myEnv ) ;
			}
		}
	}

	vs$dotsInStsFld( dots = clear ) ;

	wrapup :

	if( !( sts & 1 & *msg ) ) {

		vs$bulk_delete( count = 1, objenvs = &reSplit ) ;
		vs$bulk_delete(	count	= 2,
				grids   = subSurfs,
				theEnv	= &parentOutput.mod_env ) ;
		vs$bulk_delete(	count	= 2,
				grids	= listOfOutputs,
				theEnv	= myEnv ) ;
			
     		/*
	    	 * Placement : failure. Compute : degraded state.
    		 */
		if( purpose & VS_K_InitialPlacement ) {
		  	/*
		  	 * Restore things since method failed.
	  		 */
			vs$unconsume(	msg	= &rc,
					object	= &operand._grid,
					mod_env	= &operand.mod_env,
					rep	= oldRep,
					compute	= TRUE ) ;
			if( *msg & 1 ) *msg = MSFAIL ;
			sts = OM_W_ABORT ;
    		} else {
			if( *msg & 1 ) *msg = EMS_E_NoSolution ;
			sts = OM_S_SUCCESS ;
		}
	} else {
		/*
		 * Update plate tag, don't check return code: will be
		 * OM_W_NOTTAGGED if object has no tag connection.
		 */
		om$change_tag_version() ;
	}
	/*
	 * Delete copies of top, bottom and operand surfaces if any.
	 */
	if( opnWasCopied ) {
		vs$bulk_delete(	count = 1, grids = &opndCopy, theEnv = myEnv ) ;
	}
	if( botWasCopied ) {
		vs$bulk_delete(	count = 1, objenvs = &botSf ) ;
	}
	if( topWasCopied ) {
		vs$bulk_delete(	count = 1, objenvs = &topSf ) ;
	}

	/*
	 * Delete objects created when computing intersections.
	 */
	vs$bulk_delete( count = nbIntwbot, grids = intwbot, theEnv = myEnv ) ;
	vs$bulk_delete( count = nbIntwtop, grids = intwtop, theEnv = myEnv ) ;

	ASbroadcast_in_progress	= saveBroadcast ;

	return sts ;

} /* method ACconstruct_feet */
/*------------------------------------------------------------------------*/
end implementation VSgapPlate ;
