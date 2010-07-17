/*
	I/STRUCT
*/
class implementation VSplstifCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "COBmacros.h"
#include "bserr.h"
#include "dpmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "parametric.h"
#include "expression.h"
#include "expmacros.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vspart.h"
#include "vsattr.h"
#include "vssectiondef.h"
#include "vsbeam.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vsicondef.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vsbeammacros.h"
#include "vsbmaxisdef.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vsstfnrdef.h"
#include "vsstfnr.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsformmacros.h"
#include "vsmeasmacros.h"
#include "ACcheckin.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASsupport.h" 
#include "vsRDBproto.h"
#include "vschgsymb.h"
#include "vsformproto.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsgdplcgpdtc.h"
#include "vsverifyval.h"
#include "vsvecmxproto.h"

#include "vsbmsuppdef.h"

#define VS_K_ROT_DEFN_FILE		"VStwsDefn.fm"
#define VS_K_surface_constructed	0x80000

extern long	VSgetHeightOfCrossSectionDef() ;
extern OMuword	OPP_EMSsubbs_class_id ;
extern OMuword	OPP_VStwsBeam_class_id ;
extern OMuword	OPP_VSstfBeam_class_id ;
extern OMuword	OPP_VSbeamSupp_class_id ;

from GRgraphics import GRconstruct ;
from ACdb_info	import ACset_db_info ;
from NDnode	import NDchg_state ;
from NDmacro	import ACreturn_foot ;
from VSbeamAxis import VSgetConstructionType,
		       VSgeneratePerpSfToParentSf,
		       VSgetXdirectionForCrossSectionCS ;
from VSfeature	import VSforwardToOriginal ;
from VSstfBeam	import VSgetConstructionType ;

%safe
static  int                     GlobeFlag;
%endsafe

/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	long	msg ;

	if(    ! ( me->flag & VS_K_init_failed )
	    && !IF_NULL_OBJID( me->SideObj._objid ) ) {

		vs$bulk_display( dpmode = GRheo, objenvs = &me->SideObj ) ;

		VSdisplaySurfaceNormal( &msg,
					&me->SideObj,
					TRUE,
					&me->ActiveDisplay,
					GRhe ) ;
	}

	om$send( msg	= message VSplbeamCmd.sleep( pos ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ) {

	int	notUsed ;
	long	rc, msg ;
	double	StfnNrmlToSd ;

	if( !( me->flag & VS_K_init_failed ) ) {
		/*
		 * Delete beam axis, if no beam(s) constructed.
		 */
		om$send( msg	= message VSplstifCmd.delete_axis( &notUsed ),
			 targetid = my_id ) ;

		_FREE( me->SurfLineObj ) ;

		/*
		 * Delete beam support surface, if no beam(s) constructed.
		 */
		om$send( msg = message VSplstifCmd.delete_surface(
							&msg ),
				targetid = my_id );
	}

	if ( me->rotDefForm ) FIf_delete( me->rotDefForm ) ;

	switch( me->position ) {
		default 			:
		case VS_K_stNormalToSide	: StfnNrmlToSd = 1 ; break ;
		case VS_K_stUseSurfOfPrj	: StfnNrmlToSd = 0 ; break ;
	}
	vs$putDpbCollAttr(	msg	= &rc,
				name	= VS_K_dpbActStfnNrmlToSd,
				value	= &StfnNrmlToSd ) ;

	om$send( msg	= message VSplbeamCmd.delete( notUsed ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	int	msg ;
	char	*form = me->fm_ptr ;

	/*
	 * Init argument TypeSide to have "plate:ABSoffset".
	 */
	me->TypeSide = VS_K_baOnTopOfPlate ;

	/*
	 * Init Start and End surfaces limit to NULL_OBJID.
	 */
	me->EndObj._objid	= me->StartObj._objid	= NULL_OBJID ;
	me->EndObj._osnum	= me->StartObj._osnum	= OM_Gw_current_OS ;
	me->EndObj.mod_env	= me->StartObj.mod_env	= me->cstEnv ;

	/*
	 * Init SideObj to NULL_OBJID, so we know there is no input side.
	 */
	me->SideObj._objid = NULL_OBJID ;
	me->SideObj._osnum = OM_Gw_current_OS ;

	_FREE( me->SurfLineObj ) ;

	me->SurfLineObj   = NULL ;
	me->CanPlacedAlPl = FALSE ;
	me->InternalYOff  = 0. ;

	/*
	 * Initialise the reference types and start/end angles
	 */
	me->refType[0] = 'N' ;
	me->refType[1] = 'N' ;
	me->angle[0] = 0 ;
	me->angle[1] = 0 ;
	
	me->flag &= ~VS_K_surface_constructed ;

	me->exp.objid = NULL_OBJID ;

	GlobeFlag = 0 ;
        vs$bulk_display( dpmode = GRheo, objenvs = &me->PlateObj ) ;

	om$send( msg	= message VSplbeamCmd.init_cmd( &msg ),
		 mode = OM_e_wrt_message,
		 targetid = my_id ) ;

	FIf_set_collapse_symbol( form,
				 VS_K_CLP_SYM_FILE,
				 VS_K_CLP_PlcStfn ) ;

	FIg_erase( form, VS_K_bm_Roll_Through ) ;

	return OM_S_SUCCESS ;

} /* method init_cmd  */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	int			nbSurfLine ;
	struct GRobj_env	fence,
				*SurfLine ;

	me->number_of_beams = 0 ;

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &me->ret,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count 	= &nbSurfLine,
				p_content	= &SurfLine,
				response	= me->response,
				response_data	= me->response_data ) ;

	if( *me->response != EX_DATA || !nbSurfLine ) {
		me->ret = VS_K_NO_FENCE ; goto wrapup ;
	}

	if( me->ret & 1 ) {
		if( nbSurfLine == 1 ) {
			_FREE( me->SurfLineObj ) ;
			me->SurfLineObj = _MALLOC(nbSurfLine, struct GRobj_env);
			if( SurfLine[0]._objid != me->SideObj._objid ) {
				me->SurfLineObj[me->number_of_beams] = SurfLine[0] ;
				me->number_of_beams++ ;
			}

		} else {

			int h ;
			struct      GRid    ownId;
			
			/*
	                 * Check if there are no owner control components.
                         */
			for( h = 0 ; h < nbSurfLine && (me->ret & 1) ; h++ ) {
			   
			   ASget_as_owner( & SurfLine[h]._grid, &ownId );
			   
			   if( ! IF_EQ_GRID( ownId, SurfLine[h]._grid )){
                		if( VD_CheckObjInList(  ownId, SurfLine, nbSurfLine,
                                                        NULL, 0 )){
                                        continue ;
	                         }
        	           }


			   _FREE( me->SurfLineObj ) ;
			   me->SurfLineObj = _MALLOC( nbSurfLine, struct GRobj_env ) ;
			   if( !me->SurfLineObj ) {
				me->ret = EMS_E_NoDynamicMemory ; goto wrapup ;
			   }


			  /*
			   * Keep all elements different from side.
			   */
			  if( SurfLine[h]._objid != me->SideObj._objid ) {

				me->SurfLineObj[me->number_of_beams] = SurfLine[h] ;
				me->number_of_beams++ ;

		  		}
			}
		}
		_FREE( SurfLine ) ;

		if( !me->number_of_beams ) {
			me->ret = VS_K_NO_FENCE ; goto wrapup ;
		}
	}

	me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method store_element( long *msg; int index ) {

	/*
	 * Initialize instance data.
	 */

	int			i ;
	struct GRlc_info	*toStore = me->event1.located_object ;

#define OBJID_EQUAL( obj, msgkey ) \
	if(  toStore->located_obj.objid == (obj) ) {\
		*msg = VS_K_OBJONCHEXIST ;\
		ex$message( msgnumb	  = (msgkey),\
			    justification = CENTER_JUS ) ;\
		break ;\
	}

	*msg = VS_K_ACT_SUCCESS ;

	switch( index ) {

		case 0 : me->PlateObj.obj_id  = toStore->located_obj ;
			 me->PlateObj.mod_env = toStore->module_info ;
			 break ;

		case 1 : me->SideObj.obj_id  = toStore->located_obj ;
			 me->SideObj.mod_env = toStore->module_info ;
			 break ;

		case 2 : /*
			  * Test if not equal to side.
			  */
			  OBJID_EQUAL( me->SideObj._objid,
				       VS_gE_DiffFromSide ) ;

			 if( *msg == VS_K_OBJONCHEXIST ) break ;
			 else me->number_of_beams = 1 ;

			 _FREE( me->SurfLineObj ) ;
			 me->SurfLineObj = _MALLOC( 1, struct GRobj_env ) ;
			 if( !me->SurfLineObj ) {
				*msg = EMS_E_NoDynamicMemory ;
				break ;
			 }

			 me->SurfLineObj[0].obj_id  = toStore->located_obj ;
			 me->SurfLineObj[0].mod_env = toStore->module_info ;
			 break ;

		case 3 : /*
			  * Test if not equal to side and surface(s).
			  */
			 OBJID_EQUAL( me->SideObj._objid,
				      VS_gE_DiffFromSide ) ;

			 for( i=0; i<me->number_of_beams || (*msg == VS_K_OBJONCHEXIST);
			      i++ )
				OBJID_EQUAL( me->SurfLineObj[i]._objid,
					     VS_gE_DiffFromSurf ) ;

			 if( *msg == VS_K_OBJONCHEXIST ) break ;

			 me->StartObj.obj_id  = toStore->located_obj ;
			 me->StartObj.mod_env = toStore->module_info ;
			 break ;

		case 4 :
			 /*
			  * Test if not equal to side, surface(s) and start.
			  */
			 OBJID_EQUAL( me->SideObj._objid,
				      VS_gE_DiffFromSide ) ;

			 for( i=0; i<me->number_of_beams || (*msg == VS_K_OBJONCHEXIST);
			      i++ )
				OBJID_EQUAL( me->SurfLineObj[i]._objid,
					     VS_gE_DiffFromSurf ) ;

			 OBJID_EQUAL( me->StartObj._objid,
				      VS_gE_DiffFromStart ) ;

			 if( *msg == VS_K_OBJONCHEXIST ) break ;

			 me->EndObj.obj_id  = toStore->located_obj ;
			 me->EndObj.mod_env = toStore->module_info ;

			 /*
			  * End surface is the last object located and still
			  * hilighted, so unhilight.
			  */
			 vs$bulk_display(	dpmode = GRhe,
						objenvs= &me->EndObj ) ;
			 break ;

		default : break ;
	}

	return OM_S_SUCCESS ;

} /* method store_element */
/*----------------------------------------------------------------------------*/
method store_null_objid( int index ) {

	switch( index ) {

		case 0 : me->PlateObj._objid  = NULL_OBJID ;
			 me->PlateObj._osnum  = OM_Gw_current_OS ;
			 me->PlateObj.mod_env = me->cstEnv ;
			 break ;

		case 1 : me->SideObj._objid  = NULL_OBJID ;
			 me->SideObj._osnum  = OM_Gw_current_OS ;
			 me->SideObj.mod_env = me->cstEnv ;
			 break ;

		case 2 : _FREE( me->SurfLineObj ) ;
			 break ;

		case 3 : me->StartObj._objid  = NULL_OBJID ;
			 me->StartObj._osnum  = OM_Gw_current_OS ;
			 me->StartObj.mod_env = me->cstEnv ;
			 break ;

		case 4 : me->EndObj._objid  = NULL_OBJID ;
			 me->EndObj._osnum  = OM_Gw_current_OS ;
			 me->EndObj.mod_env = me->cstEnv ;
			 break ;

		default : break ;
	}

	return OM_S_SUCCESS ;

} /* method store_null_objid */
/*----------------------------------------------------------------------------*/
method hilight_side( int *sts ) {

	long	msg ;

	/*
	 * Unhilight old side and normal.
	 */
	dp$erase_hilite( msg = &msg ) ;

	/*
	 * Hilight side selected.
	 */
	vs$bulk_display( dpmode = GRhdo, objenvs = &me->SideObj ) ;

	/*
	 * Display normal.
	 */
	VSdisplaySurfaceNormal( &msg,
				&me->SideObj,
				TRUE,
				&me->ActiveDisplay,
				GRhd ) ;

	return OM_S_SUCCESS ;

} /* method hilight_side */
/*----------------------------------------------------------------------------*/
method unhilight_side( int *sts ) {

	long	msg ;

	vs$bulk_display( dpmode = GRheo, objenvs = &me->SideObj ) ;

	VSdisplaySurfaceNormal( &msg,
				&me->SideObj,
				TRUE,
				&me->ActiveDisplay,
				GRhe ) ;

	return OM_S_SUCCESS ;

} /* method unhilight_side */
/*----------------------------------------------------------------------------*/
method swap_side( int *sts ) {

	long			sts,
				msg ;
	char			*sidename ;

	/*
	 * Get the opposite side.
	 */
	if( me->TypeSide == VS_K_baOnTopOfPlate ) {
		me->TypeSide	= VS_K_baOnBotOfPlate ;
		sidename	= VS_K_plBotSfPathABS ;
	} else	{
		me->TypeSide	= VS_K_baOnTopOfPlate ;
		sidename	= VS_K_plTopSfPathABS ;
	}

	sts = om$send( msg	= message NDmacro.ACreturn_foot(
						&msg,
						sidename,
						&me->SideObj.obj_id,
						&me->SideObj._matrix_type,
						me->SideObj._matrix ),
		       targetid = me->PlateObj._objid,
		       targetos = me->PlateObj._osnum ) ;
	__CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup ) ;

	VSmulmx( me->SideObj._matrix, me->PlateObj._matrix,
		 me->SideObj._matrix, &me->SideObj._matrix_type ) ;

	me->SideObj.mod_env.md_id = me->PlateObj.mod_env.md_id ;

	wrapup :

	me->ret = ( sts & msg & 1 ) ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
	return OM_S_SUCCESS ;

} /* method swap_side */
/*----------------------------------------------------------------------------*/
method construct_axis( long *msg ) {

	char			*form = me->fm_ptr ;
	long			sts = OM_S_SUCCESS ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	struct GRid		beamAxis ;
	struct GRobj_env	parents[4] ;
	struct GRobj_env	feetAxis ;
	int			i_axis,
				nbfail = 0,
				cst_type ;

	/*
	 * Fill construction list.
	 */
	vs$cnstDefaults(	msg	= msg,
				symb_id = me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				level	= &me->ActiveLevel,
				display = &me->ActiveDisplay ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display 	= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &vsargs,
				Cnst_list	= cstargs,
				Msg		= msg ) ;

	cstargs.newflag		= FALSE ;
	cstargs.name		= '\0' ;

	vsargs.representation	= AC_NO_REP ;
	vsargs.feature_att	= (char *) &me->TypeSide ;

	/*
	 * Add parents to construction list.
	 */
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;
	vsargs.parent_list[0]	= me->PlateObj ;

	if( !IF_NULL_OBJID( me->StartObj._objid ) ) {
		vsargs.parent_count	= 4 ;
		vsargs.parent_list[2]	= me->StartObj ;
		vsargs.parent_list[3]	= me->EndObj ;
	}

	/*
	 * Store side support to construct stiffener.
	 */
	om$send( msg	= message VSlocateCmd.addLocObj(
							&me->SideObj.obj_id,
							&me->SideObj.mod_env,
							0 ),
		 targetid = my_id ) ;

	/*
	 * Construct macro beam axis.
	 */
	for( i_axis = 0 ; i_axis < me->number_of_beams ; i_axis++ ) {

	  vsargs.parent_list[1] = me->SurfLineObj[i_axis] ;

	  sts = om$construct( classname	= me->const_class,
			      osnum	= me->cstEnv._MD_OS,
			      p_objid 	= &beamAxis.objid,
			      msg = message GRgraphics.GRconstruct( &cstargs ));

	  if( !( sts & 1 & *msg ) ) {
	    if( me->number_of_beams == 1 ) {
		__CheckRC( sts, *msg, "om$construct", wrapup ) ;
	    } else {
		nbfail++ ; continue ;
	    }

	  } else *msg = VS_K_ACT_SUCCESS ;

	  beamAxis.osnum = me->cstEnv._MD_OS ;

	  /*
	   * Retrieve output of macro.
	   */
	  sts = om$send( msg	= message NDmacro.ACreturn_foot(
					msg, VS_K_baBmAxis, &feetAxis.obj_id,
					NULL, NULL ),
			 targetid = beamAxis.objid,
			 targetos = beamAxis.osnum ) ;

	  if( !( sts & *msg & 1 ) ) {
	    if( me->number_of_beams == 1 ) {
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	    } else {
		nbfail++ ; continue ;
	    }
	  }

	  feetAxis.mod_env = me->cstEnv ;

	  /*
	   * Display output ( axis ).
	   */
	  vs$bulk_display( dpmode = GRbd, objenvs = &feetAxis ) ;

	  /*
	   * Store axis to construct stiffener.
	   */
	  om$send( msg      = message VSlocateCmd.addLocObj(
					&feetAxis.obj_id, &feetAxis.mod_env,
					i_axis +1 -nbfail ),
	           targetid = my_id ) ;

	  /*
	   * See if stiffener can be placed along plane.
	   */
	  if( !me->CanPlacedAlPl ) {
	    om$send( msg      = message VSbeamAxis.VSgetConstructionType(
							    msg, &cst_type ),
		     targetid = beamAxis.objid,
		     targetos = beamAxis.osnum ) ;

	     if( cst_type == VS_K_baIntersection )
	       me->CanPlacedAlPl = TRUE ;
	     }
	}

	/*
	 * Display number of stiffeners if successfull construction.
	 */
	if( nbfail != me->number_of_beams ) {

		me->flag &= ~VS_K_no_object_located ;

		me->number_of_beams -= nbfail ;

		FIfld_set_value( form, VS_K_bm_Number_Of_Beams,
				 0, 0, (double) me->number_of_beams, FALSE ) ;

		/*
		 * Display 'Roll Through' gadget.
		 */
		if( me->number_of_beams > 1 )
			FIg_display( form, VS_K_bm_Roll_Through ) ;

		/*
		 * Enable gadget 'Position' if stiffener can be placed
		 * along plane.
		 */
		if( me->CanPlacedAlPl ) {
			long	rc ;
			double	StfnNrmlToSd ;

			vs$getDpbCollAttr(
					msg	= &rc,
					name	= VS_K_dpbActStfnNrmlToSd,
					p_value = &StfnNrmlToSd ) ;
			if( !( rc & 1 ) ) StfnNrmlToSd = 1 ;
			if( (int) StfnNrmlToSd ) {
				me->position = VS_K_stNormalToSide ;
			} else {
				me->position = VS_K_stUseSurfOfPrj ;
				FIg_enable( form,VS_K_bm_AccessToGapDetctGrp ) ;
			}
			FIg_set_state( form, VS_K_sf_Position, me->position ) ;
			FIg_enable( form, VS_K_sf_Position ) ;
		} else {
			me->position = VS_K_stNormalToSide ;
			FIg_set_state( form, VS_K_sf_Position, me->position ) ;
		}
	} else {
		/*
		 * All constructions failed, remove support surface.
		 */
		 om$send( msg = message VSlocateCmd.rmLastLocObjs(0),
			  targetid = my_id ) ;
		 goto wrapup ;
	}

	/*
	 * If more than one construction failed, tell to user there is a
	 * problem to construct axis.
	 */
	if( nbfail > 0 ) {
		char buffer[MS_MAX_MSG_LENGTH],
		     bufTel[MS_MAX_MSG_LENGTH] ;

		ex$message( msgnumb = VS_gI_ConstFail, buff = buffer ) ;
		sprintf( bufTel, "%d %s", nbfail, buffer ) ;
		VSfi_msg( form, bufTel ) ;

		me->flag |= VS_K_message_set ;

		sts = OM_S_SUCCESS ;
		*msg = MSSUCC ;
	}

	wrapup :

	if( !( sts & *msg & 1 ) )
		om$send( msg      = message VSlocateCmd.rmLastLocObjs(0),
			 targetid = my_id ) ;

	me->ret = ( sts & *msg & 1 ) ? VS_K_ACT_SUCCESS : *msg ;

	return OM_S_SUCCESS ;

} /* method construct_axis */
/*----------------------------------------------------------------------------*/
method delete_axis( int *sts ) {

	long			msg ;
	struct GRobj_env	*feetAxis = NULL ;
	struct GRid		beamAxis ;
	int			i ;

	/*
	 * Delete all beam axes constructed, if no beams placed.
	 */
	if( !( me->flag & VS_K_beam_constructed ) &&
	    !( me->flag & VS_K_no_object_located ) ) {

		/*
		 * Retrieve feet axis.
		 */
		feetAxis = _MALLOC( me->number_of_beams+1, struct GRobj_env ) ;

		om$send( msg	= message VSlocateCmd.getLocObjs(
							&msg,
							me->number_of_beams + 1,
							feetAxis ),
			targetid= my_id ) ;

		for( i=1; i<me->number_of_beams+1; i++ ) {

			/*
			 * Retrieve macro occurrence.
			 */
			 ASget_as_owner( &feetAxis[i]._grid, &beamAxis ) ;

			/*
			 * Erase macro.
			 */
			vs$bulk_display( dpmode = GRbehe,
					 grids	= &beamAxis,
					 theEnv = &feetAxis[i].mod_env ) ;

			/*
			 * Delete macro.
			 */
			 vs$bulk_delete( grids	= &beamAxis,
					 theEnv = &feetAxis[i].mod_env ) ;
		}

		_FREE( feetAxis ) ;
	}

	return OM_S_SUCCESS ;

} /* method delete_axis */
/*----------------------------------------------------------------------------*/
method construct_surface( long *msg ) {

	long			sts ;
	int			size ;
	int			axisCnt,
				i_surf,
				nbfail = 0 ;
	struct GRvg_construct	cstargs;
	struct GRobj_env	*parents = NULL ,
				feetSupp ,
				axisObj ;
	struct VScnst_list	vsargs ;
	struct GRid		beamSupp ;
 	char			*form = me->fm_ptr ;

	sts = MSSUCC ;
	if( me->flag & VS_K_no_object_located ) goto wrapup ;
	if( me->flag & VS_K_surface_constructed) {
		sts = om$send( msg = message VSplstifCmd.delete_surface(
						msg),
				targetid = my_id );
	}
	me->CanPlacedAlPl = FALSE ;
	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	/*
	 * validate the objects 
	 */
	if ( ( me->exp.objid == NULL_OBJID ) ) {
		char 		expObjVal[80] ;
		struct GRid	expObj ;

		if( (me->refType[0] == 'N') && (me->refType[1] == 'N') && 
			((int)me->angle[0] == 0 ) && ((int)me->angle[1] == 0) ) 
		{
			me->flag &= ~VS_K_surface_constructed ;
			sts = *msg = MSSUCC ; 
			goto wrapup ;
		}
		sprintf( expObjVal, "%c|%g|%c|%g", 
					me->refType[0],me->angle[0],
					me->refType[1],me->angle[1] );

		sts = exp$create(	exp_name  = 0,
					exp_syntax= expObjVal,
					p_exp_id  = &expObj.objid,
					osnum     = me->cstEnv._MD_OS ,
					p_osnum   = &expObj.osnum,
					type_rq   = EXP_TEXT);
		if(!( sts & 1 ) ) { 
			expObj.objid = NULL_OBJID ; 
			return MSFAIL ; 
		}
		me->exp.objid = expObj.objid ;
		me->exp.osnum = expObj.osnum ;
	}

	/*
	 * Fill construction list.
	 */
	vs$cnstDefaults(	msg	= msg,
				symb_id = me->ModuleInfo.md_id,
				symb	= &me->ActiveRep,
				level	= &me->ActiveLevel,
				display = &me->ActiveDisplay ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display 	= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &vsargs,
				Cnst_list	= cstargs,
				Msg		= msg ) ;

	cstargs.newflag		= FALSE ;
	cstargs.name		= '\0' ;

	size = 2;
	parents	= _MALLOC( size, struct GRobj_env ) ;

	vsargs.representation	= AC_NO_REP ;
	vsargs.feature_att	= (char *) &me->TypeSide ;
	
	/*
	 * Add parents to construction list.
	 */
	vsargs.parent_count	= size;
	vsargs.parent_list	= parents ;

	parents[1]._grid =me->exp ;

	/*
	 * Get axis.
	 */
	axisCnt = me->number_of_beams  ;

	/*
	 * Construct macro beam axis.
	 */
	for( i_surf = 0 ; i_surf < me->number_of_beams ; i_surf++ ) {
		me->ret = om$send( msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, 
						(i_surf+1),
						&axisObj ),
				   targetid = my_id ) ;
		__CheckRC( 1, *msg, "VSlocateCmd.getLocObjAtIndex", wrapup );

		parents[0]= axisObj ;

		sts = om$construct( classid	= OPP_VSbeamSupp_class_id ,
			            osnum	= me->cstEnv._MD_OS,
			            p_objid 	= &beamSupp.objid,
				    msg     	= message GRgraphics.GRconstruct(
								&cstargs ));
	        if( !( sts & 1 & *msg ) ) {
	            if( me->number_of_beams == 1 ) {
			__CheckRC( sts, *msg, "om$construct", wrapup ) ;
	            } else {
		    	nbfail++ ; continue ;
	            }
		} else *msg = VS_K_ACT_SUCCESS ;

		beamSupp.osnum = me->cstEnv._MD_OS ;

		  /*
        	   * Retrieve output of macro.
		   */
        	  sts = om$send( msg    = message NDmacro.ACreturn_foot(
                	                        msg, 
						VS_K_bsBmSupp, 
						&feetSupp.obj_id,
                                        	NULL, 
						NULL ),
				targetid = beamSupp.objid,
				targetos = beamSupp.osnum ) ;

		feetSupp.mod_env = me->cstEnv ;
		/*						
		 * Display output ( beam support  )
	         */
	          vs$bulk_display( dpmode = GRbd, objenvs = &feetSupp) ;

        	  /*
	           * Store support to construct stiffener.
        	   */
		__DBGpr_obj(" beam support", beamSupp );
		__DBGpr_obj(" Feet support", feetSupp._grid );
		{
		int locIndex ;
		locIndex = i_surf + me->number_of_beams + 1 -nbfail ;

        	  om$send( msg      = message VSlocateCmd.addLocObj(
                	                        	&feetSupp.obj_id, 
							&feetSupp.mod_env,
							locIndex),
	                   targetid = my_id ) ;
		}
	}
	/*
         * Display number of stiffeners if successfull construction.
         */
        if( nbfail != me->number_of_beams ) {

                me->flag &= ~VS_K_no_object_located ;

		me->flag |= VS_K_surface_constructed ;

                me->number_of_beams -= nbfail ;

                FIfld_set_value( form, VS_K_bm_Number_Of_Beams,
                                 0, 0, (double) me->number_of_beams, FALSE ) ;

                /*
                 * Display 'Roll Through' gadget.
                 */
                if( me->number_of_beams > 1 )
                        FIg_display( form, VS_K_bm_Roll_Through ) ;
	} else {
                /*
                 * All constructions failed, remove support surface.
                 */
                 om$send( msg = message VSlocateCmd.rmLastLocObjs(0),
                          targetid = my_id ) ;
                 goto wrapup ;
        }
	/*
         * If more than one construction failed, tell to user there is a
	 * problem to construct axis.
         */
        if( nbfail > 0 ) {
                char buffer[MS_MAX_MSG_LENGTH],
                     bufTel[MS_MAX_MSG_LENGTH] ;

                ex$message( msgnumb = VS_gI_ConstFail, buff = buffer ) ;
                sprintf( bufTel, "%d %s", nbfail, buffer ) ;
                VSfi_msg( form, bufTel ) ;

                me->flag |= VS_K_message_set ;

                sts = OM_S_SUCCESS ;
	        *msg = MSSUCC ;
	}
wrapup :

	_FREE( parents );
	if( !( sts & *msg & 1 ) ) {
		om$send( msg      = message VSlocateCmd.rmLastLocObjs(0),
			 targetid = my_id ) ;
	}
	me->ret = ( sts & *msg & 1 ) ? VS_K_ACT_SUCCESS : *msg ;

	return OM_S_SUCCESS ;

} /* method construct_surface */
/*----------------------------------------------------------------------------*/
method delete_surface( long  *msg ) {
	long			sts ;
	struct GRobj_env	*feetSupp = NULL ;
	struct GRid		beamSupp ;
	int			i, supp_index ;

	/*
	 * Delete all beam supprt surface constructed, if no beams placed.
	 */
	if( !( me->flag & VS_K_beam_constructed ) &&
	    !( me->flag & VS_K_no_object_located) &&
	     ( me->flag & VS_K_surface_constructed ) ){

		/*
		 * Retrieve feet support surface
		 */
		feetSupp = _MALLOC((2*me->number_of_beams+1),struct GRobj_env );

		sts = om$send( msg	= message VSlocateCmd.getLocObjs(
						msg,
						2*me->number_of_beams + 1,
						feetSupp ),
			targetid= my_id ) ;

		supp_index = me->number_of_beams+1;

		for( i=supp_index ;i<(me->number_of_beams+supp_index); i++ ) {

			/*
			 * Retrieve macro occurrence.
			 */
			 ASget_as_owner( &feetSupp[i]._grid, &beamSupp ) ;

			/*
			 * Erase macro.
			 */
			vs$bulk_display( dpmode = GRbehe,
					 grids	= &beamSupp,
					 theEnv = &feetSupp[i].mod_env ) ;

			/*
			 * Delete macro.
			 */
			 vs$bulk_delete( grids	= &beamSupp,
					 theEnv = &feetSupp[i].mod_env ) ;
		}
		me->flag &= ~VS_K_surface_constructed ;
		_FREE( feetSupp ) ;
	}

	return OM_S_SUCCESS ;

} /* method delete_surface */
/*----------------------------------------------------------------------------*/
method form_notification( int form_label ; int gadget_label ; double value ;
			  char *form_ptr ) {

#define DISPLAY_GROUP( grp ) \
	if( VS_K_bm_Grp_##grp != me->ActGrp ) {\
		if( me->ActGrp == VS_K_bm_Grp_Definition ) \
			vs$repaint_gadget( form   = form_ptr,\
					   gadget = VS_K_bm_Area ) ;\
		VSg_replace( form_ptr, me->ActGrp, VS_K_bm_Grp_##grp ) ;\
		me->ActGrp = VS_K_bm_Grp_##grp ;\
	}

	long	msg ;
	int	FillMaxGapFld	= FALSE ;
	double	gapDetectionEnabled ;
	double	maxAdmGap ;
	int     response ;
	int	x_pos, y_pos ;

	if( form_label == VS_K_tws_Rotation ) {
		om$send( msg = message VSplstifCmd.sub_form_notification(
							me->rotDefForm, 
							gadget_label ),
			targetid = my_id );
	} else {

	switch( gadget_label ) {
	 	case VS_K_tws_Rotation 		:
		case VS_K_sf_Position		:
		case VS_K_bm_AccessToGapDetctGrp:
	  	case VS_K_bm_GapDetection_Toggle:
	  	case VS_K_bm_GapDetection_MaxFld: break ;

		default	:
		om$send( msg	 = message VSplbeamCmd.form_notification(
					   form_label, gadget_label,
					   value, form_ptr ),
			 mode	 = OM_e_wrt_message,
			 targetid= my_id ) ;
	}

	switch( gadget_label ) {

	  case VS_K_tws_Rotation :
		if ( me->rotDefForm ) {
			int disp_sts ;
			FIf_is_displayed( me->rotDefForm, &disp_sts ) ;

			if(!( disp_sts ) )
				FIf_display( me->rotDefForm );
		} else {
			VSf_sub_form(	form_ptr,
					gadget_label,
					VS_K_ROT_DEFN_FILE,
					&me->rotDefForm ) ;

			FIf_get_location( form_ptr, &x_pos, &y_pos ) ;
			FIf_set_location( me->rotDefForm, 
					  x_pos+480, 
					  y_pos+260 ) ;		

			FIf_display( me->rotDefForm) ;
		}
		FIg_disable( form_ptr, VS_K_sf_Position ) ;
		break ;

	  case VS_K_bm_Revert		:
		/*
		 * Init form for stiffener placement.
		 */
		om$send( msg = message VSplstifCmd.initForm( (int *) &msg ),
			 targetid = my_id ) ;

		response = VS_K_GOTO_PLATE ;
                ex$putque( msg = &msg, response = &response ) ;

		break ;

	  case VS_K_sf_Position		:
		if( 1 == (int) value ) {
		  me->position = VS_K_stUseSurfOfPrj ;
		  FIg_enable( form_ptr, VS_K_bm_AccessToGapDetctGrp ) ;
		} else {
		  me->position = VS_K_stNormalToSide ;
		  FIg_disable( form_ptr, VS_K_bm_AccessToGapDetctGrp ) ;
		}
		FIg_disable( form_ptr, VS_K_tws_Rotation ) ;
		om$send( msg	  = message VSplstifCmd.inter_display( &msg ),
			 targetid = my_id ) ;
		break ;

	  case VS_K_bm_AccessToGapDetctGrp:
	  	FIg_set_state_off( form_ptr, VS_K_bm_Section_Manipulation ) ;
		DISPLAY_GROUP( GapDetection ) ;
		FIg_disable( form_ptr, VS_K_bm_GapDetection_ValFld ) ;

		vs$getDpbCollAttr(	msg	= &msg,
					name	= VS_K_dpbActGapDetection,
					p_value	= &gapDetectionEnabled ) ;

		if( 0 == gapDetectionEnabled ) {
	  	  FIg_set_state_off( form_ptr, VS_K_bm_GapDetection_Toggle ) ;
		  FIg_disable( form_ptr, VS_K_bm_GapDetection_MaxFld ) ;
		} else {
	  	  FIg_set_state_on( form_ptr, VS_K_bm_GapDetection_Toggle ) ;
		  FIg_enable( form_ptr, VS_K_bm_GapDetection_MaxFld ) ;
		  FillMaxGapFld = TRUE ;
		}
		break ;

	  case VS_K_bm_GapDetection_Toggle:
		if( 1 == (int) value ) {
		  FIg_enable( form_ptr, VS_K_bm_GapDetection_MaxFld ) ;
		  FillMaxGapFld = TRUE ;
		} else {
		  value = 0 ;
		  FIg_disable( form_ptr, VS_K_bm_GapDetection_MaxFld ) ;
		}
		vs$putDpbCollAttr(	msg	= &msg,
					name	= VS_K_dpbActGapDetection,
					value	= &value ) ;
	  	break ;

	  case VS_K_bm_GapDetection_MaxFld:
		/*
		 * Maximum gap value must be >= 0.
		 */
		vs$processUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= gadget_label,
					osnum	= me->cstEnv._MD_OS,
					verify	= VSisDblPositive,
					oldValue= maxAdmGap,
					newValue= &maxAdmGap ) ;
		vs$putDpbCollAttr(	msg	= &msg,
					name	= VS_K_dpbActMaxAdmGapVal,
					value	= &maxAdmGap ) ;
		break ;

	  default 			: break ;
	}

	if( FillMaxGapFld ) {
		  vs$getDpbCollAttr(	msg	= &msg,
					name	= VS_K_dpbActMaxAdmGapVal,
					p_value	= &maxAdmGap ) ;
		  vs$fillUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= VS_K_bm_GapDetection_MaxFld,
					value	= maxAdmGap ) ;
	}
	}
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
void VSinitStiffenerEditionForm( char *form ) {

	int	x = 0,
		y = 0,
		x1,
		y1 ;

	/*
	 * Change all gadgets with word 'Beam' by gadgets with word 'Stiffener'.
	 */
	VSg_replace( form,
		     VS_K_bm_txt_Number_Of_Beams,
		     VS_K_sf_txt_Number_Of_Stiff ) ;

	VSg_replace( form,
		     VS_K_bm_txt_Name,
		     VS_K_sf_txt_Name ) ;

	FIg_delete( form, VS_K_bm_txt_Beam_Type ) ;

	FIg_add_to_group( form,
			  VS_K_sf_txt_Stiffener_Type,
			  VS_K_bm_Grp_Def_Gadget ) ;

	/*
	 * For stiffener, no y offset and rotation. Change location of x offset
	 * and add position gadget.
	 */
	FIg_get_location( form, VS_K_bm_Rotation, &x, &y ) ;
	if( x && y ) {
		int X, Y ;
		FIg_get_location( form, VS_K_bm_X_Offset,     &X,  &Y  ) ;
		FIg_set_location( form, VS_K_bm_X_Offset,     x,   y   ) ;
		FIg_get_location( form, VS_K_bm_txt_X_Offset, &x1, &y1 ) ;
		FIg_set_location( form, VS_K_bm_txt_X_Offset, x1,  y   ) ;
		x = y = 0 ;

		FIg_set_location( form, VS_K_bm_Y_Offset,     X,   Y   ) ;
		FIg_get_location( form, VS_K_bm_txt_Y_Offset, &x1, &y1 ) ;
		FIg_set_location( form, VS_K_bm_txt_Y_Offset, x1,  Y   ) ;
	}

	FIg_add_to_group( form,
			  VS_K_sf_Position,
			  VS_K_bm_Grp_Manipulation ) ;
	FIg_add_to_group( form,
			  VS_K_bm_AccessToGapDetctGrp,
			  VS_K_bm_Grp_Manipulation ) ;
	FIg_disable( form, VS_K_bm_AccessToGapDetctGrp ) ;

	vs$g_delete_gadgets( form = form,
			     list = `VS_K_bm_txt_Rotation,
				     VS_K_bm_Rotation,
				     -1` ) ;

	/*
	 * Disable gadgets reference point.
	 */
	vs$g_disable_gadgets( form = form,
			      list = `VS_K_bm_Center_Left,
				      VS_K_bm_Top_Left,
				      VS_K_bm_Top_Middle,
				      VS_K_bm_Center_Middle,
				      VS_K_bm_Center_Right,
				      VS_K_bm_Top_Right,
				      -1` ) ;

} /* VSinitStiffenerEditionForm */
/*----------------------------------------------------------------------------*/
method initForm( int *sts ) {

	char	*form = me->fm_ptr ;
	int	x = 20, y = 280 ;

	VSg_replace( form, VS_K_bm_Placement, VS_K_sf_Placement ) ;

	VSinitStiffenerEditionForm( form ) ;

	if( me->CanPlacedAlPl ) FIg_enable(  form, VS_K_sf_Position ) ;
	else			FIg_disable( form, VS_K_sf_Position ) ;


	FIg_add_to_group( form,
			  VS_K_tws_Rotation,
			  VS_K_bm_Grp_Definition );
	FIg_set_location ( form, VS_K_tws_Rotation, x, y );

	if ( me->rotDefForm)  {
		FIf_delete( me->rotDefForm ) ; 
		me->rotDefForm = NULL ;
	}

	return OM_S_SUCCESS ;

} /* method initForm */
/*----------------------------------------------------------------------------*/
int VSgetRowIndex( form, gadget_label )
char    *form ;
int     gadget_label ; {

	int	i,
		num_rows,
		selected,
		index = 0 ;

	FIfld_get_list_num_rows( form, gadget_label, 0, &num_rows ) ;

	for( i = 0 ; i < num_rows ; i++ ) {
		FIfld_get_list_select( form, gadget_label, i, 0, &selected ) ;

		if( selected ) { 
			index = i ; 
			break ; 
		}
	}

	return index ;

} /* VSgetRowIndex */
/*----------------------------------------------------------------------------*/
method sub_form_notification( char *form_ptr ; int gadget_label ) {

	long		sts, 
			msg ;
	char		expObjVal[80];
	struct GRid	expObj ;
	int		index=0 , 
			response ;
	char		*form = me->fm_ptr ;

	switch (gadget_label ) {

		case VS_K_bm_Dismiss		:

			if( me->CanPlacedAlPl ) 
				FIg_enable(  form, VS_K_sf_Position ) ;
			FIf_erase( me->rotDefForm );
			break ;

		case VS_K_bm_Dismiss_Execute :

			FIf_erase( me->rotDefForm);

			if((me->refType[0] == 'N') && (me->refType[1] == 'N') &&
			   ((int)me->angle[0] == 0) && ((int)me->angle[1] == 0)) 
			{
				me->flag &= ~VS_K_surface_constructed ;
				return OM_S_SUCCESS  ;
			}
			sprintf( expObjVal, "%c|%g|%c|%g", 
						me->refType[0],me->angle[0],
						me->refType[1],me->angle[1] );

			sts = exp$create(	exp_name  = 0,
						exp_syntax= expObjVal,
						p_exp_id  = &expObj.objid,
						osnum     = me->cstEnv._MD_OS ,
						p_osnum   = &expObj.osnum,
						type_rq   = EXP_TEXT);
			if(!( sts & 1 ) ) { 
				expObj.objid = NULL_OBJID ; 
				return MSFAIL ; 
			}
			me->exp.objid = expObj.objid ;
			me->exp.osnum = expObj.osnum ;

			sts = om$send ( msg = message 
					VSplstifCmd.construct_surface(
							&msg ),
					targetid = my_id );
			if( !( sts & msg & 1 ) ) {
				response = EX_BACK_UP ;
				ex$putque( msg = &msg, 
					   response = &response ) ;
			}
			sts = om$send ( msg = message 
					VSplstifCmd.inter_display(
							&msg ),
					targetid = my_id );
			break ;

		case VS_K_tws_StRefType : 	
			index = 0 ;
			goto CREATE_TXT_EXP ;

		case VS_K_tws_EdRefType :	
			index = 1 ;

		CREATE_TXT_EXP : 
			{
			int 	actRow ;

			actRow = VSgetRowIndex ( form_ptr, gadget_label ) ;

			switch( actRow ) {
				case 0 :
					me->refType[index] = 'N';
					break;
				case 1 :
					me->refType[index] = 'F';
					break;
				case 2 :
					me->refType[index] = 'B';
					break;
				case 3 :
					me->refType[index] = 'W';
					break;

				default : break ;
			}
			}
			break ;
			
		case VS_K_tws_StAngle:
			index = 0;
			goto CREATE_DBL_EXP ;
			
		case VS_K_tws_EdAngle:
			index = 1;

		CREATE_DBL_EXP : 
			{
			int	sel_flag, r_pos  ;

			FIfld_get_value(form_ptr, gadget_label, 0, 0,
					&me->angle[index], &sel_flag, &r_pos );

			}
			break ;
	}

	return OM_S_SUCCESS ;	

}/* method sub_form_notification */
/*----------------------------------------------------------------------------*/
method SetLastPlSiId( long *msg ) {

        char    *form = me->fm_ptr ;
        enum GRdpmode   dpmode ;

        if( GlobeFlag == 1 ) {

        /*
         * Delete profile of beam.
         */
        if( !( me->flag & VS_K_first_inter_displ ) ) {

                if( me->flag & VS_K_beam_constructed )  dpmode = GRhe ;
                else                                    dpmode = GRbehe ;

                vs$bulk_display( dpmode = dpmode, objenvs = &me->BeamSect ) ;

                vs$bulk_delete( objenvs = &me->BeamSect ) ;
        }

        me->flag |= ( VS_K_first_inter_displ |
                      VS_K_no_object_located ) ;

	me->flag &= ~VS_K_beam_constructed ;

        me->number_of_beams = 0 ;
        me->ActBeam         = 0 ;

        _FREE( me->SurfLineObj ) ;

        me->SurfLineObj   = NULL ;
        me->CanPlacedAlPl = FALSE ;

        om$send( msg      = message VSplbeamCmd.enable_form( msg ),
                 mode     = OM_e_wrt_message,
                 targetid = my_id ) ;

        /*
         * Enable gadget position if stiffener can be placed along plane.
         */
        if( me->CanPlacedAlPl ) FIg_enable(  form, VS_K_sf_Position ) ;
        else                    FIg_disable( form, VS_K_sf_Position ) ;


        }

	GlobeFlag = 1;

        return OM_S_SUCCESS ;

}  /*   Method SetLastPlSiId    */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmbeam_labels[] = {
	{ VS_K_bm_Dismiss_Execute	, TRUE	},
	{ VS_K_bm_Execute		, TRUE	},
	{ VS_K_bm_Revert		, TRUE	},
	{ VS_K_bm_Dismiss		, TRUE	},
	{ VS_K_bm_Roll_Through		, TRUE	},
	{ VS_K_bm_Message		, TRUE	},
	{ VS_K_bm_Material_Type 	, TRUE	},
	{ VS_K_bm_Material_Grade	, TRUE	},
	{ VS_K_bm_Shape_Name		, TRUE	},
	{ VS_K_bm_Section_Name		, TRUE	},
	{ VS_K_bm_Directory		, TRUE	},
	{ VS_K_bm_Name			, TRUE	},
	{ VS_K_bm_Stock_Number		, TRUE	},
	{ VS_K_bm_Source		, TRUE	},
	{ VS_K_bm_Fireproofing		, TRUE	},
	{ VS_K_bm_Approval_Status	, TRUE	},
	{ VS_K_bm_Construction_Status	, TRUE	},
	{ VS_K_bm_Member_Class		, TRUE	},
	{ VS_K_bm_Member_Type		, TRUE	},
	{ VS_K_bm_Change_Number 	, TRUE	},
	{ VS_K_bm_Number_Of_Beams	, TRUE	},
	{ VS_K_bm_Comments		, TRUE	},
	{ VS_K_bm_Display_Ratio 	, TRUE	},
	{ VS_K_bm_X_Offset		, TRUE	},
	{ VS_K_bm_Y_Offset		, TRUE  },
	{ VS_K_tws_Rotation		, TRUE	},
	{ VS_K_sf_Position		, TRUE	},
	{ VS_K_xs_Position		, TRUE	},
	{ VS_K_bm_Rotation		, FALSE },
	{ VS_K_bm_Section_Length	, TRUE	},
	{ VS_K_bm_Section_Area		, TRUE	},
	{ VS_K_bm_Top_Left		, FALSE },
	{ VS_K_bm_Center_Left		, FALSE },
	{ VS_K_bm_Bot_Left		, TRUE	},
	{ VS_K_bm_Top_Middle		, FALSE },
	{ VS_K_bm_Bot_Mid		, TRUE	},
	{ VS_K_bm_Top_Right		, FALSE },
	{ VS_K_bm_Center_Middle 	, FALSE },
	{ VS_K_bm_Center_Right		, FALSE },
	{ VS_K_bm_Bot_Right		, TRUE	},
	{ VS_K_bm_No_Sym		, TRUE	},
	{ VS_K_bm_X_Sym 		, TRUE	},
	{ VS_K_bm_Y_Sym 		, TRUE	},
	{ VS_K_bm_XY_Sym		, TRUE	},
	{ VS_K_bm_Parameters		, TRUE	},
	{ VS_K_bm_Copy_Params		, TRUE	},
	{ VS_K_bm_Definition		, TRUE	},
	{ VS_K_bm_Section_Manipulation	, TRUE	},
	{ VS_K_bm_Material_Take_Off	, TRUE	},
	{ VS_K_bm_User_Attributes	, TRUE	},
	{ VS_K_bm_Mcf_User_Attributes	, TRUE	},
	{ VS_K_bm_AccessToGapDetctGrp	, TRUE	},
	{ VS_K_bm_GapDetection_Toggle	, TRUE	},
	{ VS_K_bm_GapDetection_ValFld	, TRUE	},
	{ VS_K_bm_GapDetection_MaxFld	, TRUE	},
	{ -1				, TRUE	}	/* End-of-list flag */
} ;


	*msg = MSSUCC ;
	*list = VS_Ga_fmbeam_labels ;

	return OM_S_SUCCESS ;

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {

	char		*form = me->fm_ptr ;

	om$send( msg	= message VSplbeamCmd.load_attributes( msg ),
		 mode	= OM_e_wrt_message,
		 targetid = my_id ) ;

	/*
	 * For stiffener, no rotation available.
	 */
	me->rotation = 0. ;

	/*
	 * For stiffener, just reference point bottom middle, bottom left and
	 * bottom right are availables.
	 */
	if( me->reference_point != VS_e_BOT_LEFT &&
	    me->reference_point != VS_e_BOT_MIDD &&
	    me->reference_point != VS_e_BOT_RGHT ) {
		me->reference_point = VS_e_BOT_LEFT ;
		FIg_set_state_on( form, VS_K_bm_Bot_Left ) ;
	}

	/*
	 * Default position normal to the side of plate.
	 */
	me->position = VS_K_stNormalToSide ;
	FIg_set_state( form, VS_K_sf_Position, me->position ) ;

	return OM_S_SUCCESS ;

} /* method load_attributes */
/*----------------------------------------------------------------------------*/
method load_attributes_from_beam( long *msg ) {

	struct GRid	LocatedStif = me->event1.located_object[0].located_obj ;
	char		*form = me->fm_ptr ;

	om$send( msg	= message VSplbeamCmd.load_attributes_from_beam( msg ),
		 mode	= OM_e_wrt_message,
		 targetid = my_id ) ;

	/*
	 * For stiffener, no rotation available.
	 */
	me->rotation = 0. ;

	/*
	 * For stiffener, just reference point bottom middle, bottom left and
	 * bottom right are availables.
	 */
	if( me->reference_point != VS_e_BOT_LEFT &&
	    me->reference_point != VS_e_BOT_MIDD &&
	    me->reference_point != VS_e_BOT_RGHT ) {
		me->reference_point = VS_e_BOT_LEFT ;
		FIg_set_state_on( form, VS_K_bm_Bot_Left ) ;
	}

	/*
	 * Retrieve construction type of located stiffener.
	 */
	if( me->CanPlacedAlPl ) {
		om$send( msg	  = message VSfeature.VSforwardToOriginal(
					msg,
					OM_e_wrt_object,
					message VSstfBeam.VSgetConstructionType(
							       msg,
							       &me->position )),
			 targetid = LocatedStif.objid,
			 targetos = LocatedStif.osnum ) ;

		FIg_set_state( form, VS_K_sf_Position, me->position ) ;
	}

	return OM_S_SUCCESS ;

} /* method load_attributes_from_beam */
/*----------------------------------------------------------------------------*/
method construct_beam( long *msg ) {

	char			*form = me->fm_ptr ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSstfnrAttr		stfnr ;
	VSbeamAttr		beam ;
	int			i,
				count,
				cst_type ;
	char			name[DI_PATH_MAX] ;
	struct GRobj_env	*located = NULL ;
	struct GRobj_env	*parent = NULL ;
	struct GRid		stifId ;
	struct ACdb_info	checkin ;
	struct GRid		cachedPart ;
	struct GRid		beamAxis ;
	int			wantGapDetection ;
	double			maxAdmGap ;
	struct GRobj_env	bmSupp ;
	struct GRid		beamSupp ;
	OMuword			const_classid ;

	ex$message( msgnumb  = VS_gI_Processing, justification = CENTER_JUS ) ;

	{
	  double tmp ;
	  vs$getDpbCollAttr(	msg	= msg,
				name	= VS_K_dpbActGapDetection,
				p_value	= &tmp ) ;
	  wantGapDetection = tmp != 0 ;
	  if( wantGapDetection ) {
		vs$getDpbCollAttr(	msg	= msg,
					name	= VS_K_dpbActMaxAdmGapVal,
					p_value	= &maxAdmGap ) ;
	  }
	}

	/*
	 * Get parents.
	 */
	parent	= _MALLOC( 2, struct GRobj_env ) ;
	if( me->flag & VS_K_surface_constructed ) {
		located = _MALLOC( 2 * me->number_of_beams + 1, 
					struct GRobj_env ) ;
	} else {
		located = _MALLOC( me->number_of_beams +1, struct GRobj_env );
	}
	if( !located || !parent ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	if( me->flag & VS_K_surface_constructed ) {
		me->ret = om$send( msg	= message VSlocateCmd.getLocObjs(
					msg, 
					(2*me->number_of_beams + 1), 
					located ),
			   targetid= my_id ) ;
		for ( i =0 ; i < (2*me->number_of_beams + 1) ; i++ )
		__DBGpr_obj(" located Obj", located[i]._grid );

	}else {
		me->ret = om$send( msg	= message VSlocateCmd.getLocObjs(
						msg, 
						me->number_of_beams + 1, 
						located ),
				   targetid= my_id ) ;
	}
	/*
	 * Fill construction list.
	 */
	vs$getBmOrPlCstDefaults(msg		= msg,
				symb_id 	= me->ModuleInfo.md_id,
				symb		= &me->ActiveRep,
				matchKey	= me->matchKey,
				memberClass	= me->clsCode[me->clsIndex],
				matchId 	= &me->PlateObj._grid,
				path		= me->cnstDir,
				level		= &me->ActiveLevel,
				display 	= &me->ActiveDisplay ) ;
	me->directory = me->cnstDir ;

	VSfixBeamRep(	me->ActiveRep.representation,
			&me->ActiveRep.representation ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display 	= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &vsargs,
				Cnst_list	= cstargs,
				Msg		= msg ) ;

	vsargs.parent_count	= 2 ;
	vsargs.representation	= me->ActiveRep.representation ;
	vsargs.feature_att	= (char *) &stfnr ;

	if( ( me->flag & VS_K_change_usr_attr ) && me->usrAttCount ) {
		vs$makeActiveUsrAttr( msg	= &me->ret,
				      basename	= VS_K_ActBmUAttr,
				      nbEntries = me->usrAttCount,
				      names	= me->usrNamList,
				      syntaxes	= me->usrSynList,
				      p_activeUA= &me->UAid ) ;
		me->flag &= ~VS_K_change_usr_attr ;
	}

	vs$fillBeamAttr(msg		= msg,
			options 	= VS_m_All,
			xOffset 	= me->X_offset,
			yOffset 	= me->Y_offset + me->InternalYOff,
			RotAngle	= me->rotation,
			cardPnt 	= (enum VScardinal_point)
						me->reference_point,
			symmetry	= (enum VSsymmetry)
						me->symmetry,
			matType 	= me->actMat,
			matGrade	= me->actGrd,
			partFam 	= me->actFam,
			partNum 	= me->actPrt,
			usrNotes	= me->notes,
			mtoSrc		= me->source,
			FireProofing	= me->fireproofing,
			mtoChgNo	= me->change_number,
			apprvStat	= me->approval_status,
			constStat	= me->construction_status,
			mbrClass	= me->clsCode[me->clsIndex],
			mbrType 	= me->typCode[me->typIndex],
			mtoStk		= me->stock,
			usrAttrId	= &me->UAid,
			partAttr	= &stfnr.attr,
			beamAttr	= &beam ) ;


	strcpy( checkin.catalog , "vssrcbeam" ) ;
	strcpy( checkin.part_num, "vssrcbeam" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;

	if( me->detailCard ) {
		stfnr.attr.Iwant & = ~VS_m_detCard ;
	}

	/*
	 * If family name begins with '#', we have a composite stiffener.
	 */
	checkin.quantity = *me->actFam != '#'	? STRUCT_BEAM_OBJ
						: STRUCT_PLATE_OBJ  ;

	parent[0] = me->PlateObj ;

	count = me->number_of_beams ;

	vs$load_part_from_RDB(	msg		= &me->ret,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &cachedPart ) ;

	stfnr.onWhichSideOfPlate = me->TypeSide ;

	for( i = 0 ; i < count ; i++ ) {

		if( *me->basename ) {
			DIstmcpy( name, me->directory, me->basename, NULL ) ;
		} else {
			/*
			 * Beam unnamed.
			 */
			*name = '\0' ;
		}


		if( me->flag & VS_K_surface_constructed ) {
			int locIndex ;
			locIndex = i+count + 1;

			me->ret = om$send( msg = message VSlocateCmd.getLocObjAtIndex(
							msg, 
							locIndex,
							&bmSupp ),
				   targetid = my_id ) ;
			__DBGpr_obj("beam supp ",bmSupp._grid );

			parent[0]		= bmSupp ;			
		}

		cstargs.name		= name ;
		cstargs.newflag		= FALSE ;
		parent[1]		= located[i + 1] ;
		vsargs.parent_list	= parent ;

		__DBGpr_obj("Parent 0", parent[0]._grid ) ;
		__DBGpr_obj("Parent 1", parent[1]._grid ) ;

		/*
		 * Give stiffener axis same symbology as stiffener (May be
		 * different if translation table was used).
		 */
		vs$bulk_display( objenvs = &parent[1], dpmode = GRbe ) ;
		VSchangeSymbology(	msg,
					&parent[1]._grid,
					me->ActiveLevel,
					&me->ActiveDisplay ) ;
		vs$bulk_display( objenvs = &parent[1], dpmode = GRbd ) ;

		/*
		 * Set construction type of the stiffener.
		 */
		ASget_as_owner( &vsargs.parent_list[1]._grid, &beamAxis ) ;

		if( me->CanPlacedAlPl ) {
			om$send(msg	= message VSbeamAxis.VSgetConstructionType(
							    msg, &cst_type ),
				targetid= beamAxis.objid,
				targetos= beamAxis.osnum ) ;

			if( cst_type == VS_K_baIntersection )
				stfnr.constructType = me->position ;
			else	stfnr.constructType = VS_K_stNormalToSide ;

		} else stfnr.constructType = VS_K_stNormalToSide ;


		const_classid = ( me->flag & VS_K_surface_constructed ) ? 
					OPP_VStwsBeam_class_id : 
					OPP_VSstfBeam_class_id ;

		/*
		 * Construct stiffener, then display it.
		 */
		me->ret = om$construct(
			classid		= const_classid,
			osnum		= me->cstEnv._MD_OS,
			p_objid 	= &stifId.objid,
			msg		= message GRgraphics.GRconstruct( &cstargs ));

		if( !( me->ret & 1 & *msg ) ) {
			if( *msg & 1 ) *msg = MSFAIL ;
			ex$message(	msgnumb 	= VSgetMsgKey( *msg ),
					field		= ERROR_FIELD,
					justification	= CENTER_JUS,
					time		= 2 ) ;
			goto wrapup ;
		}

		stifId.osnum	= me->cstEnv._MD_OS ;

		/*
		 * Store PDU check-in information.
		 */
		om$send(msg	= message ACdb_info.ACset_db_info( msg,
								&checkin ),
			targetid= stifId.objid,
			targetos= stifId.osnum ) ;

		/*
		 * Display stiffener.
		 */
		vs$bulk_display( dpmode = GRbd,
				 grids	= &stifId,
				 theEnv = &me->cstEnv ) ;

		/*
		 * Must find a new base name.
		 */
		if( *me->basename ) {
			strcpy( name, me->basename ) ;
			VSbuildName( &me->ret, me->directory, name, me->basename ) ;
		}
		if( me->flag & VS_K_surface_constructed ) {
		  	/*
			 * Get the beam support object
			 */
			ASget_as_owner( &vsargs.parent_list[0]._grid,
					&beamSupp ) ;			
			/*
			 * Change state of macro beam axis, so if stiffener 
			 * was deleted corresponding beam support will 
			 * be deleted when session ends.
			 */
			om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH,
								  ND_DEL_NO_CH),
				targetid = beamSupp.objid,
				targetos = beamSupp.osnum ) ;
		}
		/*
		 * Change state of macro beam axis, so if stiffener was deleted
		 * corresponding axis will be deleted when session ends.
		 */
		om$send( msg	= message NDnode.NDchg_state(	ND_DEL_NO_CH,
								ND_DEL_NO_CH ),
			 targetid = beamAxis.objid,
			 targetos = beamAxis.osnum ) ;

		/*
		 * Place a gap detector if requested and possible.
		 */
		if( VS_K_stUseSurfOfPrj == me->position && wantGapDetection ) {
			struct GRid gdId ;
			UI_status( "Placing gap detector" ) ;
			*msg = VSplaceGapDetector( &stifId, &me->cstEnv,
						  maxAdmGap, &cstargs, &gdId ) ;
			if( *msg ) {
				vs$bulk_display( dpmode = GRbd,
						 grids	= &gdId,
				 		 theEnv = &me->cstEnv ) ;
			}
		}

		/*
		 * Decrease stiffener count.
		 */
		FIfld_set_value( form, VS_K_bm_Number_Of_Beams, 0, 0,
				 (double) (count - 1 - i), FALSE ) ;
	}
	/*
	 * Display new base name.
	 */
	FIfld_set_text( form, VS_K_bm_Name, 0, 0, me->basename, FALSE ) ;

	me->ret = MSSUCC ;

	me->flag |= VS_K_beam_constructed ;
	me->flag &= ~VS_K_change_usr_attr ;

	wrapup :
		_FREE( located ) ;
		_FREE( parent ) ;
		ex$message(	field	= ERROR_FIELD,
				in_buff = "" ) ;
		return OM_S_SUCCESS ;

} /* method construct_beam */
/*----------------------------------------------------------------------------*/
method enable_form( long *msg ) {

	char	*form = me->fm_ptr ;

	om$send( msg	  = message VSplbeamCmd.enable_form( msg ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	/*
	 * Enable gadget position if stiffener can be placed along plane.
	 */
	if( me->CanPlacedAlPl ) FIg_enable(  form, VS_K_sf_Position ) ;
	else			FIg_disable( form, VS_K_sf_Position ) ;

	/*
	 * Enable gadget for stiffener twist rotation angles and reference
	 * types
	 */
	if( me->flag & VS_K_no_object_located )
		FIg_disable( form, VS_K_tws_Rotation );
	else 	
		FIg_enable( form, VS_K_tws_Rotation );

	return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method inter_display( long *msg ) {

	long			sts ;
	int			useSfPrj = FALSE,
				cst_type,
				haveDir ;
	IGRvector		xDir ;
	double			length,
				width ;
	struct GRvg_construct	cstargs,
				cstsurf ;
	struct GRobj_env	parent[2],
				surfObj ;
	struct GRid		beamAxis,
				sectDef ;
	char			*form = me->fm_ptr ;


	if( me->flag & VS_K_no_object_located ) goto wrapup ;

	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	if( me->flag & VS_K_surface_constructed ) {
		/*
		 * Get support surface
		 */
		me->ret = om$send( msg = message VSlocateCmd.getLocObjAtIndex(
					   msg, 
					   me->number_of_beams + me->ActBeam+1, 
					   &surfObj ),
				   targetid = my_id ) ;

	} else {
		/*
		 * Get plate, to find directory and symbology.
		 */
		me->ret = om$send( msg = message VSlocateCmd.getLocObjAtIndex(
							 msg, 0, &surfObj ),
				   targetid = my_id ) ;
	}
	/*
	 * Get active representation.
	 */
	vs$getBmOrPlCstDefaults(msg		= msg,
				symb_id 	= me->ModuleInfo.md_id,
				symb		= &me->ActiveRep,
				level		= &me->ActiveLevel,
				matchKey	= me->matchKey,
				memberClass	= me->clsCode[me->clsIndex],
				matchId 	= &surfObj._grid,
				path		= me->cnstDir,
				display 	= &me->ActiveDisplay ) ;
	/*
	 * Do not use PWD any longer.
	 */
	me->directory = me->cnstDir ;

	/*
	 * Get axis.
	 */
	me->ret = om$send( msg	    = message VSlocateCmd.getLocObjAtIndex(
					msg, me->ActBeam+1, &parent[1] ),
			   targetid = my_id ) ;

	/*
	 * If stiffener to place is along plane, generate a surface of
	 * projection perpendicular to the axis, otherwise use the side of
	 * plate for parent #0.
	 */
	ASget_as_owner( &parent[1]._grid, &beamAxis ) ;

	if( me->CanPlacedAlPl && me->position == VS_K_stUseSurfOfPrj ) {
		om$send( msg	  = message VSbeamAxis.VSgetConstructionType(
							    msg, &cst_type ),
			 targetid = beamAxis.objid,
			 targetos = beamAxis.osnum ) ;

		if( cst_type == VS_K_baIntersection ) {

			int	plateSideUsed = FALSE ;

			vs$fill_cnst_list( Env_info  = &me->cstEnv,
					   Display   = &me->ActiveDisplay,
					   Level     = me->ActiveLevel,
					   Cnst_list = cstsurf,
					   Properties= 0,
					   Msg	     = msg ) ;

			sts = vs$getSfDimensions(
					   msg	     = msg,
					   surfId    = &me->SideObj.obj_id,
					   surfEnv   = &me->SideObj.mod_env,
					   width     = &width,
					   length    = &length ) ;

			if( !(sts & 1 & *msg) ) width = 1000. ;
			else width *= 0.5 ;

			sts = om$send( msg	=
				 message VSbeamAxis.VSgeneratePerpSfToParentSf(
							    msg,
							    &cstsurf,
							    width,
							    &parent[0],
							    &plateSideUsed ),
				  targetid = beamAxis.objid,
				  targetos = beamAxis.osnum ) ;

			if( (sts & 1 & *msg) ) {
				useSfPrj = !plateSideUsed ;
			} else {
				parent[0]._objid = NULL_OBJID ;
			}
		}
	}
	if( !useSfPrj ) parent[0] = me->SideObj ;

	if( me->flag & VS_K_surface_constructed ) {	
		parent[0] = surfObj ;
	}

	if( !(me->flag & VS_K_first_inter_displ) ) {

		/*
		 * Delete old section ( should be done when interactive
		 * display does not come from wakeup ).
		 */

		vs$bulk_display( dpmode = GRbehe, objenvs = &me->BeamSect ) ;
		vs$bulk_delete( objenvs= &me->BeamSect ) ;
	} else {
		GRname name ;

		if( *me->basename ) {
			strcpy( name, me->basename ) ;
			VSbuildName( msg, me->directory, name, me->basename ) ;
			FIfld_set_text( form, VS_K_bm_Name,0, 0,
					me->basename, FALSE ) ;
		}
	}
	FIfld_set_text( form, VS_K_bm_Directory,0, 0, me->directory, FALSE ) ;

	/*
	 * Fill construction list.
	 */
	me->BeamSect.mod_env = me->cstEnv ;

	VSfixBeamRep(	me->ActiveRep.representation,
			&me->ActiveRep.representation ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display 	= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Cnst_list	= cstargs,
				Properties	= GRIS_DISPLAYABLE,
				Msg		= msg ) ;

	/*
	 * Get X direction of cross section.
	 */
	me->ret = om$send( msg	    =
		  message VSbeamAxis.VSgetXdirectionForCrossSectionCS(
							msg, &haveDir, xDir ),
			   targetid = beamAxis.objid,
			   targetos = beamAxis.osnum ) ;
	if( !( me->ret & 1 & *msg ) ) { *msg = MSFAIL ; goto wrapup ; }

	/*
	 * For symmetries 'XY' and 'X', set Y offset to height of cross section
	 * to have the stiffener outside of plate.
	 */
	if( me->symmetry == VS_e_XY_Symm || me->symmetry == VS_e_X_Symm  ) {

	   sts = vs$load_part_from_RDB( msg	= msg,
					material= me->actMat,
					family	= me->actFam,
					part	= me->actPrt,
					osnum	= me->cstEnv._MD_OS,
					object	= &sectDef ) ;
	   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
	   __CheckRC( sts, *msg, "vs$load_part_from_RDB", wrapup ) ;

	   /*
	    * Get height of cross section.
	    */
           sts = VSgetHeightOfCrossSectionDef( msg,
					       &sectDef,
					       &me->cstEnv,
					       &me->InternalYOff ) ;
	   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
	   __CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;

	} else me->InternalYOff = 0. ;

	me->ret =
	vs$place_cross_section( msg	= msg,
				xMat	= me->actMat,
				xFam	= me->actFam,
				xName	= me->actPrt,
				searchOS= me->cstEnv.md_id.osnum,
				xOffset = me->X_offset,
				yOffset = me->Y_offset + me->InternalYOff,
				rotation= me->rotation,
				profOpt = &me->detailCard,
				cardinal= (enum VScardinal_point)
						me->reference_point,
				symmetry= (enum VSsymmetry)
						me->symmetry,
				surface = &parent[0],
				axis	= &parent[1],
				xDir	= haveDir ? xDir : NULL,
				dspRatio= me->display_ratio,
				dspRep	= me->ActiveRep.representation,
				cst	= &cstargs,
				xSect	= &me->BeamSect._grid ) ;
	if( !( me->ret & 1 & *msg ) ) { *msg = MSFAIL ; goto wrapup ; }

	/*
	 * Highlight Section Beam.
	 */
	vs$bulk_display( count	= 1,
			 dpmode = GRhd,
			 objenvs= &me->BeamSect ) ;

	me->flag &= ~VS_K_first_inter_displ ;
	me->ret = MSSUCC ;

	wrapup :
		if( useSfPrj ) {
			 vs$bulk_delete( objenvs= &parent[0] ) ;
		}
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method inter_display */
/*----------------------------------------------------------------------------*/

end implementation VSplstifCmd ;
