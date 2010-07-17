/* $Id: VSplretnfoot.I,v 1.3 2001/05/11 20:13:47 jayadev Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:      vsplate/VSplretnfoot.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplretnfoot.I,v $
 *      Revision 1.3  2001/05/11 20:13:47  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/05/02 16:39:16  jayadev
 *      recover lost feet
 *
 *
 * History:
 * MM/DD/YY  AUTHOR   DESCRIPTION
 * 05/02/01  Jayadev  TR#MP5207  
 *************************************************************************/

/*
	I/STRUCT
*/
class implementation VSplate ;

#include <string.h>
#include "nddef.h"
#include "asmacros.h"
#include "EMSutlmacros.h"
#ifndef EMSopt_include
#	include "EMSopt.h"
#endif
#include "vsattr.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsvcmpmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsvirtualinf.h"

extern IGRboolean		ASbroadcast_in_progress ;
extern struct GRid		NULL_GRID ;

from	EMSsurface	import	EMrevorient ;
/*----------------------------------------------------------------------------*/
method ACreturn_foot(	long		*succ ;
			char		*nmOfOutp ;
			struct GRid	*idOfOutp ;
			short		*mxType ;
			IGRmatrix	mx ) {

	long			sts,		/* OM return code	*/
				msg,		/* Completion code	*/
				amConsumed ;	/* Am I consumed ?	*/
	int			what,		/* What Am I asked for ?*/
				offset,		/* Must offset ?	*/
				edge ;		/* Comp. # of edge side	*/
	VSpartAttr		myAttr ;	/* Part attrs of plate	*/
	VSplateAttr		myInfo ;	/* Plate-specific attrs	*/
	GRname			edgePath ;	/* Pathname of edge side*/
	struct GRmd_env		myEnv,testEnv;  /* My module environment*/
	struct GRvg_construct   cst ;		/* Const list for ghosts*/
	int			isNatNorm ;	/* Use natural normal ?	*/
	IGRboolean		saveBroadcast ;
	struct GRid		sourceId , testId;

#define WANT_ME		0
#define WANT_TOP	1
#define WANT_BOT	2
#define WANT_TOPabs	3
#define WANT_BOTabs	4
#define WANT_OTHER	5
#define WANT_EDG	6

	edge = 0 ; *edgePath = '\0' ;

	idOfOutp->objid = NULL_OBJID ;
        testId.objid     = NULL_OBJID ;

        /*
         * TR#5207 Recompute yourself to recover lost graphics
         */
        MAidmx( &msg, testEnv._MATRIX ) ;
        testEnv._MATRIX_TYPE = MAIDMX ;
        testEnv._MD_OS    = OM_Gw_current_OS ;
        testEnv._MD_ID    = NULL_OBJID ; 

        sts = om$send(  msg  = message ACncpx.ACreturn_foot( succ,
                                                             VS_K_plGrCmpName,
                                                             &testId,
                                                             NULL,
                                                             NULL),
                        mode    = OM_e_wrt_message,
                        targetid= my_id ) ;
        if( !(sts&1) || (testId.objid == NULL_OBJID))
        {
           sts = om$send(msg = message NDnode.NDs_compute_node(
                                        &msg, ND_COMP, &testEnv ),
                        targetid = my_id );
	   __CheckRC( sts, 1, "NDnode.NDs_compute_node", wrapup ) ;
        }
	sts = om$send(	msg	= message NDmacro.ACtest_consumed( &amConsumed),
			targetid= my_id ) ;
	__CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;

	/*
	 * Find out what sender wants.
	 */
	     if( !*nmOfOutp )				    what = WANT_ME ;
	else if( !strcmp( nmOfOutp, VS_K_plBotSfPath	) ) what = WANT_BOT ;
	else if( !strcmp( nmOfOutp, VS_K_plTopSfPath	) ) what = WANT_TOP ;
	else if( !strcmp( nmOfOutp, VS_K_plBotSfPathABS ) ) what = WANT_BOTabs ;
	else if( !strcmp( nmOfOutp, VS_K_plTopSfPathABS ) ) what = WANT_TOPabs ;
	else if( !strncmp( nmOfOutp, "plate:$", 7 )	  ) {
		/*
		 * Edge side wanted.
		 */
		what = WANT_EDG ;
		edge = atol( nmOfOutp + 7 ) ;
		strcpy( edgePath, nmOfOutp ) ;
	}
	else						    what = WANT_OTHER ;

	/*
	 * Get attributes for some cases.
	 * IMPORTANT NOTE: if I have been copied-to-root by the Associative
	 * System, I cannot get my attributes any longer (since I lost my
	 * parent data collection), hence the following message is bound to
	 * fail. When I am copied-to-root, the only return-foot messages which
	 * I receive are with an empty output's name (ie. myself), hence the test
	 * before getting the attributes (which I don't need if I must return
	 * myself).
	 */
	switch( what ) {

	case WANT_BOTabs :
	case WANT_TOPabs :
	case WANT_TOP	 :
	case WANT_EDG	 :

		*succ = FALSE ;
		myAttr.Iwant = VS_m_Thickness | VS_m_Orientation ;

		myAttr.specific	= (void *) &myInfo ;
		sts = om$send(	msg	= message GRvg.GRgetattr(
						&msg, (char *) &myAttr ),
				targetid= my_id ) ;
		__CheckRC( sts, msg, "GRvg.GRgetattr", wrapup ) ;
	}

	/*
	 * If asked for absolute outputs i.e. disregarding the orientation of
	 * the plate, swap top and bottom.
	 */
	switch( what ) {

	case WANT_BOTabs :

		switch( myInfo.orientation ) {
			case VS_K_USE_REV_NORM : nmOfOutp = VS_K_plTopSfPath ;
						 what	  = WANT_TOP ;
						 break ;
			case VS_K_USE_NAT_NORM : nmOfOutp = VS_K_plBotSfPath ;
						 what	  = WANT_BOT ;
						 break ;
		}
		break ;

	case WANT_TOPabs :

		switch( myInfo.orientation ) {
			case VS_K_USE_REV_NORM : nmOfOutp = VS_K_plBotSfPath ;
						 what	  = WANT_BOT ;
						 break ;
			case VS_K_USE_NAT_NORM : nmOfOutp = VS_K_plTopSfPath ;
						 what	  = WANT_TOP ;
						 break ;
		}
		break ;
	}

	/*
	 * Use ancestor's return-foot. If it fails, then I must be consumed
	 * (NDmacro.ACtest_consumed cannot be used at this stage).
	 * If I am consumed and the wanted output is a side of the solid,
	 * then I fake it for the bottom and top surfaces.
	 */
	sts = om$send(	msg	= message VSfeature.ACreturn_foot(
								succ,
								nmOfOutp,
								idOfOutp,
								mxType,
								mx ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;

	if( ( sts & 1 ) && *succ ) goto wrapup ;

	/*
	 * Here VSfeature.ACreturn_foot has failed.
	 */
	switch( what ) {
		case WANT_EDG :
		case WANT_BOT : offset = FALSE ; break ;
		case WANT_TOP : offset = TRUE  ; break ;
		default	      :
	    		/*
	  	  	 * Not VS_K_plBotSfPath and not VS_K_plTopSfPath:
	  	  	 * don't know: exit.
	 	   	 */
			goto wrapup ;
	}

	/*
	 * Get surface output.
	 */
	sts = om$send(	msg	= message ACncpx.ACreturn_foot(	succ,
								VS_K_plGrCmpName,
								idOfOutp,
								mxType,
								mx ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *succ != 0, "ACncpx.ACreturn_foot", wrapup ) ;

	if( what == WANT_EDG ) {
		struct GRid		myGRid,
					offSolid,
					edgeId ;
		OM_S_CHANSELECT		toCmps ;

		*succ = 0 ;

		offSolid.objid	= NULL_OBJID ;

		MAidmx( &msg, myEnv._MATRIX ) ;
		myEnv._MATRIX_TYPE = MAIDMX ;
		myEnv._MD_OS	= OM_Gw_current_OS ;
		myEnv._MD_ID	= NULL_OBJID ; /* Construct out of R-tree */

		vs$fill_cnst_list(	Cnst_list	= cst,
					Properties	= 0,
					Msg		= &msg,
					Env_info	= &myEnv ) ;


		switch( myInfo.orientation ) {
			default		       : /* Should not get here */
			case VS_K_USE_NAT_NORM : isNatNorm = TRUE  ; break ;
			case VS_K_USE_REV_NORM : isNatNorm = FALSE ; break ;
		}
		saveBroadcast = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE ;

		sts = vs$offset_surface_to_solid(
					msg		= &msg,
					surfEnv		= &myEnv,
					surfId		= idOfOutp,
					offset		= myInfo.thickness,
					isNatNorm	= isNatNorm,
					isPlanar 	= DONT_KNOW,
					cst		= &cst,
					offSolId 	= &offSolid ) ;
		ASbroadcast_in_progress = saveBroadcast ;
		__CheckRC( sts, msg, "vs$offset_surface_to_solid", wrapup ) ;

	        ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		             chan_selector = &toCmps ) ;
		sts = om$get_objid_at_index(	objid	     = offSolid.objid,
						osnum	     = offSolid.osnum,
						p_chanselect = &toCmps,
						index	     = edge,
						objidaddr    = &edgeId.objid,
						osnumaddr    = &edgeId.osnum ) ;
		__CheckRC( sts, 1, "om$get_objid_at_index", endSolid ) ;

		sts = vs$grCopy(	msg	= &msg,
					frObj	= &edgeId,
					frEnv	= cst.env_info,
					toEnv	= cst.env_info,
					toObj	= idOfOutp ) ;
		__CheckRC( sts, msg, "vs$grCopy", endSolid ) ;

		/*
		 * Create a support-only source object, since we have created
		 * a new one and want the system to get rid of it when no
		 * longer needed ie. childless.
		 */
		myGRid.objid = my_id ;
		myGRid.osnum = OM_Gw_current_OS ;
		sts = vs$makeVirtualComponent(	msg	= &msg,
						modEnv	= &myEnv,
						owner	= &myGRid,
						grObj	= idOfOutp,
						path	= edgePath,
						virtCmp	= &sourceId ) ;
		__CheckRC( sts, msg, "vs$makeVirtualComponent", endOffset ) ;

		endSolid :
			vs$bulk_delete(	grids	= &offSolid,
					theEnv	= cst.env_info ) ;

		*succ = sts & 1 & msg ? 1 : 0 ;

	}
	if( offset ) {
		struct GRid		myGRid,
					offSf ;
		struct GRobj_env	ghost ;

		*succ = 0 ;

		MAidmx( &msg, myEnv._MATRIX ) ;
		myEnv._MATRIX_TYPE = MAIDMX ;
		myEnv._MD_OS	= OM_Gw_current_OS ;
		myEnv._MD_ID	= NULL_OBJID ; /* Construct out of R-tree */

		vs$fill_cnst_list(	Cnst_list	= cst,
					Properties	= 0,
					Msg		= &msg,
					Env_info	= &myEnv ) ;

		saveBroadcast = ASbroadcast_in_progress;
		ASbroadcast_in_progress = TRUE ;
		sts = vs$make_offset_surface(
					msg		= &msg,
					surfEnv		= &myEnv,
					surfId		= idOfOutp,
					offset		= myInfo.thickness,
					isNatNorm	= TRUE,
					isPlanar 	= DONT_KNOW,
					cst		= &cst,
					offSurfId 	= &offSf ) ;
		ASbroadcast_in_progress = saveBroadcast ;
		__CheckRC( sts, msg, "vs$make_offset_surface", wrapup ) ;

		/*
		 * Offset surface has reverse orientation.
		 */
		sts = om$send(	msg	= message EMSsurface.EMrevorient( &msg),
				targetid= offSf.objid,
                		targetos= offSf.osnum ) ;
		__CheckRC( sts, msg, "EMSsurface.EMrevorient", next ) ;

		next : ;
		/*
		 * Create a support-only source object, since we have created
		 * a new one and want the system to get rid of it when no
		 * longer needed ie. childless.
		 */
		*idOfOutp = offSf ;

		myGRid.objid = my_id ;
		myGRid.osnum = OM_Gw_current_OS ;
		sts = vs$makeVirtualComponent(	msg	= &msg,
						modEnv	= &myEnv,
						owner	= &myGRid,
						grObj	= idOfOutp,
						path	= VS_K_plTopSfPath,
						virtCmp	= &sourceId ) ;
		__CheckRC( sts, msg, "vs$makeVirtualComponent", endOffset ) ;

		/*
		 * Put created offset surface in store should another
		 * child ask for it.
		 */
		ghost._grid	= *idOfOutp ;
		ghost.mod_env	= myEnv ;

		endOffset :
			*succ = sts & 1 & msg ? 1 : 0 ;
 	}

	wrapup :
		/*
		 * Must return OM_S_SUCCESS !
		 */
		sts = OM_S_SUCCESS ;
		return sts ;
	
} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/
 
end implementation VSplate ;
