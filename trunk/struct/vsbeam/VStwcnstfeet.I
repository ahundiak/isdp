/*
	I/STRUCT
*/ 
class implementation VStwsBeam ;

#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*MyEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRvg_construct 	cst ;		/* My construction list	*/
	struct GRobj_env	supports[2] ;	/* 0: surface, 1: curve	*/
	struct GRid		xsId ;		/* Id of cross-section	*/
	VSdspRep		myRep ;		/* My representation	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	vs$dotsInStsFld( dots = 0 ) ;

	/*
	 * NOTE: the AC system has initialized all the "listOfOutputs[k].objid"
	 * to NULL_OBJID.
	 */
        xsId.objid = NULL_OBJID;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= MyEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Get support surface and axis, disregard parent collection.
	 * The following message will return the graphics of the parent surface
	 * (parent #0) and the parent axis( parent #1)
	 */
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, 2, listOfInputs, supports ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	vs$dotsInStsFld() ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;

	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep( inRep = myRep, outRep = &myRep ) ;

        sts = om$send(	msg	= message VSbeam.VSextractProfile(
					msg, MyEnv, supports + 0,
					supports + 1, 0.0, &cst, myRep, &xsId ),
                        targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	switch( myRep ) {

	case AC_2D_REP		:
		sts = om$send( msg	= message VSsrcBeam.VScnst_line_rep(
                					msg,
                					MyEnv,
							supports,
							&cst,
							&xsId,
							listOfOutputs + 0 ),
                                targetid = my_id ) ;
		__CheckRC( sts, *msg, "VSsrcBeam.VScnst_line_rep", wrapup ) ;
		break ;

	case VS_m_3dWFillet	:
	case VS_m_2dSurface	:
	case AC_3D_REP		:
	case AC_ENV_REP		:

		sts = om$send( msg	= message VSsrcBeam.VScnst_solid_rep(
							msg,
							MyEnv,
							&cst,
                					&supports[0],
							&supports[1],
							&xsId,
							listOfOutputs + 0 ),
				targetid= my_id ) ;

		if( !( sts & 1 & *msg ) ) {
			goto wrapup ;
		}
                break ;

           default :
           	/* Bad representation */
           	*msg = MSINARG ; sts	= OM_W_ABORT ; goto wrapup ;
	}

	*countOfOutputs = 1 ;
	wrapup :

		/*
		 * Except in linear case (pure AC_2D_REP), where the section
		 * is part of feet, the section curve has to be deleted.
		 */
		if( myRep != AC_2D_REP ) {
			vs$bulk_delete(	count	= 1,
					grids	= &xsId,
					theEnv	= MyEnv ) ;
		}

		if( sts & 1 & *msg ) {
			/*
			 * Update beam tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;
		} else {
			/*
			 * Delete feet.
			 */
			vs$bulk_delete(	count	= *countOfOutputs,
					grids	= listOfOutputs,
					theEnv	= MyEnv ) ;
			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
			}
		}

		vs$dotsInStsFld( dots = clear ) ;
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VStwsBeam ;
