/* $Id: VSspcnstfeet.I,v 1.1.1.1 2001/01/04 21:10:53 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsplate/VSspcnstfeet.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VSspcnstfeet.I,v $
 * Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/24  20:18:22  pinnacle
# ah Piece Marks
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/24/98  ah      Add hook to VDbtAfterConstructFeet
 *
 ***************************************************************************/

class implementation VSsrcPlate ;

#include "EMSmsgdef.h"
#ifndef   EMSopt_include
#include "EMSopt.h"
#endif
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"

extern IGRboolean	ASbroadcast_in_progress ;

from	EMSsurface	import	EMrevorient ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts,		/* OM return code	*/
				amConsumed ;	/* Am I consumed ?	*/
	struct GRvg_construct   cst ;		/* Construction list	*/
	struct GRid		myOutput,		/* Constructed foot	*/
        	              	offSf ;		/* If offset wanted	*/
	struct GRobj_env	surf ;		/* Support surface 	*/
	IGRboolean		saveBroadcast ;
	VSpartAttr		myAttr ;	/* My part attributes	*/
	VSplateAttr		myInfo ;	/* Some attributes	*/
	double			myOffset ;	/* For offset solid	*/
	short			action,		/* For change-props	*/
				props ;		/* For change-props	*/
	VSdspRep		myRep ;		/* Display repres.	*/
	int			isNatNorm,	/* Is normal natural ?	*/
				delOffset ;	/* Delete after use	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

        *msg		= MSSUCC ;
        offSf.objid	= NULL_OBJID ;
	myOutput.objid	= NULL_OBJID ;
        delOffset	= TRUE ;

	/*
	 * ASbroadcast to be set to TRUE so that GRgraphics.GRcopy does NOT
	 * copy the graph.
	 */
	saveBroadcast = ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

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
	 * Get input graphic objects: first parent only.
	 */
        sts = om$send( msg	= message VScpx.VSget_graphic_input( msg, 
						     1, listOfInputs, &surf ),
                       targetid = my_id );
        __CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	/*
	 * Get display representation.
	 */
	sts = om$send(	msg     = message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep( inRep = myRep, outRep = &myRep ) ;

	/*
	 * Get attributes.
	 */
	myAttr.Iwant	= VS_m_Thickness | VS_m_Orientation
			| VS_m_CutOff	 | VS_m_Offset ;
	myAttr.specific	= (void *) &myInfo ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &myAttr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	switch( myInfo.orientation ) {
		default		       : /* Should never get here */
		case VS_K_USE_NAT_NORM : isNatNorm = TRUE  ; break ;
		case VS_K_USE_REV_NORM : isNatNorm = FALSE ; break ;
	}

	/*
	 * Whatever the representation setting, the simplified one is used if
	 * I am consumed so those who consume me can be sure they will get a
	 * surface-foot when they send me an NDmacro.ACconsume message.
	 */
	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;

	if( amConsumed & 1 ) {
		om$send(msg	= message VSfeature.VSgetConsumedRep( &myRep ),
			targetid= my_id ) ;
		if( !myRep ) myRep = AC_2D_REP ;
	}

	myOutput.osnum = myEnv->md_id.osnum ;

	if( myInfo.offset != 0. ) {
 		/*
		 * Create an offset surface, which becomes the new surface to
		 * be acted upon. It will have to be deleted in the cases where
		 * it is no longer needed.
		 */

		sts = vs$make_offset_surface(
					msg		= msg,
					surfEnv		= &surf.mod_env,
					surfId		= &surf._grid,
					offset		= myInfo.offset,
					isNatNorm	= isNatNorm,
					isPlanar 	= DONT_KNOW,
					cst		= &cst,
					offSurfId 	= &offSf ) ;
		__CheckRC( sts, *msg, "vs$make_offset_surface", wrapup ) ;

		surf._grid = offSf ;
		surf.mod_env = *myEnv;

	}

	switch( myRep ) {

	case AC_3D_REP		:	myOffset = myInfo.thickness ;
					goto OFFSET_SURF ;

	case AC_ENV_REP		:	myOffset = myInfo.cut_off ;

	OFFSET_SURF		:
		sts = vs$offset_surface_to_solid(
					msg		= msg,
					surfId		= &surf._grid,
					surfEnv		= &surf.mod_env,
					offset		= myOffset,
					isNatNorm	= isNatNorm,
					cst		= &cst,
					isPlanar	= DONT_KNOW,
					offSolId	= &myOutput ) ;
	        __CheckRC( sts, *msg, "vs$offset_surface_to_solid", wrapup ) ;
		break ;

	case VS_m_2dWCompute	:
	case AC_2D_REP		:
		if( myInfo.offset == 0. ) {
			sts = vs$grCopy(	msg	= msg,
						frEnv	= &surf.mod_env,
						frObj	= &surf._grid,
						toEnv	= cst.env_info,
						toObj	= &myOutput,
						symb	= &mySymb ) ;
	        	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

		} else {
		       	/*
	        	 * We keep the offset surface.
	        	 */
			delOffset	= FALSE ;
			myOutput.objid	= surf._objid ;
		}

		if( !isNatNorm ) {

			om$send(msg	= message EMSsurface.EMrevorient( msg ),
				targetid= myOutput.objid,
               	                targetos= myOutput.osnum ) ;

               	}
		break ;

	default		:	/* Bad representation */
				*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
        }

	/*
	 * After copying, set right properties ...
	 */
	action	= 1 ;
	props	= cst.properties ;
	sts = om$send(	msg      = message GRgraphics.GRchgprops(
							msg, &action, &props ),
			targetid = myOutput.objid,
			targetos = myOutput.osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;

	*countOfOutputs  = 1 ;
	listOfOutputs[0] = myOutput ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	/* -------------------------------------------------
	 * 24 Apr 1998 Hook into post processor for
	 * production purposes
	 */
	{
	  struct GRobj_env myOE;

	  myOE.obj_id.objid = my_id;
	  myOE.obj_id.osnum = OM_Gw_current_OS;
	  myOE.mod_env      = *myEnv;
	  
	  VDbtAfterConstructFeet(&myOE,purpose);
	}
	
        wrapup :
		ASbroadcast_in_progress = saveBroadcast ;

        	if( delOffset ) {
			vs$bulk_delete(	count	= 1,
					grids	= &offSf,
					theEnv	= cst.env_info ) ;
         	}
        	if( ! ( sts & 1 & *msg ) ) {
	    		/*
	    		 * Placement : failure. Compute : degraded state.
	    		 */
	    		if( purpose & VS_K_InitialPlacement ) {
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
                return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSsrcPlate ;
