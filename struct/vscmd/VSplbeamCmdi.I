/* $Id: VSplbeamCmdi.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSplbeamCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplbeamCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/01/21  19:00:34  pinnacle
# TR179702512
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      01/21/98 ah     added header
 *      01/21/98 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 ***************************************************************************/

class implementation VSplbeamCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "bserr.h"
#include "bstypes.h"
#include "OMmacros.h"
#include "COBmacros.h"
#include "DImacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "vsglobalmsg.h"
#include "vsattr.h"
#include "vsglobals.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsbeammacros.h"
#include "vsoptdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vsicondef.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vsformmacros.h"
#include "vscmdmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsnamemacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "bsplptnorrg.h"
#include "vsRDBproto.h"
#include "vsfnditmary.h"
#include "vsformproto.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsstrngproto.h"
#include "vsverifyval.h"

extern long VSbeamGetState(struct GRid *beamId, int *state);


#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'

#define VS_K_EXECUTE	(EX_MAX_RESPONSE+1)

extern OMuword OPP_EMSplane_class_id ;

extern long	VSgetHeightOfCrossSectionDef() ;

from ACncpx	import	ACget_STATE ;
from ACdb_info	import	ACset_db_info ;
from GRgraphics	import	GRconstruct ;
from GRvg	import  GRgetattr ;
from IGEgragad	import  DPinquire ,
			convert_pnt ;
from VSpart	import	VSgetUserEditableAttr ;
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	long		msg ;
	
	om$send( msg	= message VSplbeamCmd.hilight_elem( &msg ),
		 targetid = my_id ) ;

	/*
	 * Hilight profile of beam.
	 */
	if( !(me->flag & VS_K_first_inter_displ) )
	
		/*
		 * Test if beam profile already exists.
		 */
		if( om$is_objid_valid( objid = me->BeamSect._objid,
                	               osnum = me->BeamSect._osnum ) != OM_S_SUCCESS ) {

			me->flag |= VS_K_first_inter_displ ;
			om$send(msg	= message VSplbeamCmd.inter_display( &msg ),
				targetid= my_id ) ;
		} else vs$bulk_display( count  = 1,
					dpmode = GRhd,
					objenvs= &me->BeamSect ) ;

	om$send(msg	= message VSfmbeamCmd.wakeup( pos ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;
		 
	/*
	 * If command stacked, perhaps another 'Place Beam' command was executed
	 * and the current name already exists, so try to find another name.
	 */
	if( me->flag & VS_K_command_stacked ) {
		char 	CurName[DI_PATH_MAX] ;
		
		strcpy( CurName , me->basename ) ;
		VSbuildName( &msg, me->directory, CurName, me->basename ) ;
		
		if( strcmp( CurName , me->basename ) ) {
			FIfld_set_text( me->fm_ptr, VS_K_bm_Name,0, 0, 
					me->basename, FALSE ) ;
		}
	}
	
	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ) {

	int 		notUsed = 0 ;
	enum GRdpmode	dpmode ;

	/*
	 * Delete beam profile.
	 */
	if( !( me->flag & VS_K_first_inter_displ ) ) {
/*
		if( me->flag & VS_K_beam_constructed )	dpmode = GRhe ;
		else					dpmode = GRbehe ;
*/
		if( me->display_ratio == 1 )	dpmode = GRhe ;
		else				dpmode = GRbehe ;
	
		vs$bulk_display( dpmode = dpmode, objenvs = &me->BeamSect ) ;
	        
		vs$bulk_delete( objenvs = &me->BeamSect ) ;
	}
 
	om$send(msg	= message VSfmbeamCmd.delete( notUsed ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	enum GRdpmode	dpmode ;

	/*
	 * Delete profile of beam.
	 */
	if( !( me->flag & VS_K_first_inter_displ ) ) {

		if( me->flag & VS_K_beam_constructed )	dpmode = GRhe ;
		else					dpmode = GRbehe ;

		vs$bulk_display( dpmode = dpmode, objenvs = &me->BeamSect ) ;

		vs$bulk_delete( objenvs = &me->BeamSect ) ;
	}

	me->flag |= ( VS_K_first_inter_displ |
		      VS_K_no_object_located ) ;

	me->flag &= ~VS_K_beam_constructed ;

	me->number_of_beams = 0 ;
	me->ActBeam	    = 0 ;

	FIfld_set_value( me->fm_ptr, VS_K_bm_Number_Of_Beams, 0, 0,
			 (double) me->number_of_beams, FALSE ) ;

	FIf_set_collapse_symbol( me->fm_ptr,
				 VS_K_CLP_SYM_FILE,
				 VS_K_CLP_PlcBeam ) ;

	FIg_erase( me->fm_ptr, VS_K_bm_Roll_Through ) ;
	
	me->detailCard = TRUE ;

	FIg_add_to_group( me->fm_ptr,
			  VS_K_xs_Position,
                          VS_K_bm_Grp_Manipulation ) ;

	
	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method store_surface( int *sts ) {

	struct GRlc_info	*toStore = me->event1.located_object ;

	me->ret = om$send(	
			msg	= message VSlocateCmd.addLocObj(
							&toStore->located_obj,
							&toStore->module_info,
							0 ),
			targetid= my_id ) ;

	me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	return OM_S_SUCCESS ;

} /* method store_surface */
/*----------------------------------------------------------------------------*/
method store_axis( int *sts ) {

	struct GRlc_info	*toStore = me->event1.located_object ;

	me->ret = om$send(	
			msg	= message VSlocateCmd.addLocObj(
							&toStore->located_obj,
							&toStore->module_info,
							me->number_of_beams + 1),
			targetid= my_id ) ;

	if( me->ret & 1 ) {
		me->number_of_beams++ ;

		/*
		 * Display beam count.
		 */
		FIfld_set_value( me->fm_ptr,
				 VS_K_bm_Number_Of_Beams,
				 0, 0, (double) me->number_of_beams, FALSE ) ;

		me->flag &= ~VS_K_no_object_located ;
	}

	me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	return OM_S_SUCCESS;

} /* method store_axis */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	int			nbAxis = 0 ;
	struct GRobj_env	fence,
				*Axis ;

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &me->ret,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count		= &nbAxis,
				p_content	= &Axis,
				response	= me->response,
				response_data	= me->response_data ) ;

	if( *me->response != EX_DATA || !nbAxis ) {
		me->ret = VS_K_NO_FENCE ; goto wrapup ;
	}

	if( me->ret & 1 ) {
		if( nbAxis == 1 ){
			me->number_of_beams++ ;
			me->ret = om$send( 
				msg 	= message VSlocateCmd.addLocObj(
							&Axis[0]._grid,
							&Axis[0].mod_env,
							me->number_of_beams ),
				targetid= my_id ) ;
		}
		else{

		    int			h ;
		    struct	GRid	ownId;

		    /*
		     * Check if there are no owner control components.
		     */
		    for( h = 0 ; h < nbAxis && (me->ret & 1) ; h++ ) {

			ASget_as_owner( & Axis[h]._grid, &ownId );

			if( ! IF_EQ_GRID( ownId, Axis[h]._grid )){
				if( VD_CheckObjInList(	ownId, Axis, nbAxis,
							NULL, 0 )){
					continue ;
				}
			}

			me->number_of_beams++ ;
			me->ret = om$send( 
				msg 	= message VSlocateCmd.addLocObj(
							&Axis[h]._grid,
							&Axis[h].mod_env,
							me->number_of_beams ),
				targetid= my_id ) ;
		    }
		}
		_FREE( Axis ) ;
		/*
		 * Display beam count.
		 */
		FIfld_set_value( me->fm_ptr,
				 VS_K_bm_Number_Of_Beams,
				 0, 0, (double) me->number_of_beams, FALSE ) ;
		me->flag &= ~VS_K_no_object_located ;

		/*
		 * Display 'Roll Through' gadget.
		 */
		if( me->number_of_beams > 1 )
			FIg_display( me->fm_ptr, VS_K_bm_Roll_Through ) ;
	}
	
	/*
	 * Unhilight fence.
	 */
	vs$bulk_display( dpmode = GRhe, objenvs = &fence ) ;

	me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method chain_locate( int *sts ) {

	long	size = sizeof( struct GRevent ) - sizeof( IGRlong ) * 2 ; 
	long	sts1 ;
	int	response ;

	*sts = MSSUCC;

	response = me->event1.response;

	me->event1.num_id = 0 ;
	ex$putque(	msg	= &sts1,
			byte	= &size,
			response= &response,
			buffer	= (char *) &me->event1.event ) ;

	return OM_S_SUCCESS;

} /* method chain_locate */
/*----------------------------------------------------------------------------*/
method enable_form( long *msg ) {

	char	*form = me->fm_ptr ;

	om$send( msg = message VSfmbeamCmd.enable_form( msg ),
		 mode	= OM_e_wrt_message,
		 targetid = my_id ) ;

	if( me->flag & VS_K_no_object_located )
		vs$g_disable_gadgets( form = form,
				      list = `VS_K_bm_Dismiss_Execute,
				              VS_K_bm_Execute,
					      -1` ) ;
	else    vs$g_enable_gadgets( form = form,
		 		     list = `VS_K_bm_Dismiss_Execute,
				 	     VS_K_bm_Execute, 
    					     -1` ) ;	
	return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {

	int	got_data ;	/* TRUE if DPB loaded with beam data */

	VSdpb_loaded_with_beam( &got_data ) ;

	me->directory = me->Cwd ;

	me->matIndex = me->grdIndex = me->famIndex = me->prtIndex = 0 ;

	/*
	 * Retrieve active RDB attributes form DPB; if DPB not loaded (first
	 * time) then query RDB.
	 */
	if( got_data ) {
		char	*actAttr,
			actMat[VS_K_MAXDBNAME],
			actGrd[VS_K_MAXDBNAME],
			actFam[VS_K_MAXDBNAME],
			actPrt[VS_K_MAXDBNAME] ;

		/*
		 * Materials from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_material,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actMat, actAttr ) ;

		/*
		 * Grades from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_grade,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actGrd, actAttr ) ;

		/*
		 * Families from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_type,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actFam, actAttr ) ;

		/*
		 * Sections from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_shape,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actPrt, actAttr ) ;

		om$send(msg	= message VSqryRdbCmd.setActiveItems(
					actMat, actGrd, actFam, actPrt ),
			targetid= my_id ) ;

		om$send(msg	= message VSfmbeamCmd.QueryRDB(
							msg,
							VS_m_mat |
							VS_m_grd |
							VS_m_fam |
							VS_m_prt |
							VS_m_par |
							VS_m_force,
							FALSE ),
			targetid= my_id ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		/*
		 * Stock, source, notes.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_stock,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = VSmsgkey2string( VS_gI_Unknown ) ;
		me->stock = VSstrdup( actAttr ) ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_source,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = VSmsgkey2string( VS_gI_Unknown ) ;
		me->source = VSstrdup( actAttr ) ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_notes,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = "" ;
		me->notes = VSstrdup( actAttr ) ;

		/*
		 * Fireproofing tickness, approval status, construction status.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_fireproofing_thk,
				p_arg	= &me->fireproofing ) ;
		if( !me->fireproofing )	me->fireproofing = 0. ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_apprv_status,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = VSmsgkey2string( VS_gI_NotApprvd ) ;
		me->approval_status = VSstrdup( actAttr ) ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_const_status,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = VSmsgkey2string( VS_gI_NewCstStat ) ;
		me->construction_status = VSstrdup( actAttr ) ;
	
		/*
		 * Base name.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_name_pattern,
				p_arg	= &actAttr ) ;
		if( !actAttr || !*actAttr ) actAttr = "B1" ;
		/*
		 * Find an available name in current directory.
		 */		
		VSbuildName( msg, me->directory, actAttr, me->basename ) ;

		/*
		 * x, y, rotation.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_x_offset,
				p_arg	= &me->X_offset ) ;
		if( !me->X_offset ) me->X_offset = 0. ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_y_offset,
				p_arg	= &me->Y_offset ) ;
		if( !me->Y_offset ) me->Y_offset = 0. ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_rotation,
				p_arg	= &me->rotation ) ;
		if( !me->rotation ) me->rotation = 0. ;

		/*
		 * Reference point, symmetry.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_cardinal_point,
				p_arg	= &me->reference_point ) ;
		if( !me->reference_point ) me->reference_point = VS_e_UPP_LEFT ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_B_symmetry,
				p_arg	= &me->symmetry ) ;
		if( !me->symmetry ) me->symmetry = VS_e_No_Symm ;
		
	} else {
		om$send(msg	= message VSfmbeamCmd.QueryRDB(
							msg,
							VS_m_mat |
							VS_m_grd |
							VS_m_fam |
							VS_m_prt |
							VS_m_par |
							VS_m_force,
							FALSE ),
			targetid= my_id ) ;
		if( !( *msg & 1 ) ) goto wrapup ;

		/*
		 * Stock, source, notes.
		 */
		me->stock	= VSstrdup( VSmsgkey2string( VS_gI_Unknown ) ) ;
		me->source	= VSstrdup( VSmsgkey2string( VS_gI_Unknown ) ) ;
		me->notes	= VSstrdup( "" ) ;

		/*
		 * Fireproofing tickness, approval status, construction status.
		 */
		me->fireproofing 	= 0 ;
		me->approval_status 	= VSstrdup( VSmsgkey2string( VS_gI_NotApprvd ) ) ;
		me->construction_status = VSstrdup( VSmsgkey2string( VS_gI_NewCstStat ) ) ;
		
		/*
		 * Beam name.
		 */
		VSbuildName( msg, me->directory, "B1", me->basename ) ;

		/*
		 * x, y, rotation.
		 */
		me->X_offset = 0. ;
		me->Y_offset = 0. ;
		me->rotation = 0. ;

		/*
		 * Reference point, symmetry.
		 */
		me->reference_point = VS_e_UPP_LEFT ;
		me->symmetry = VS_e_No_Symm ;
	}	

	/*
	 * User attributes.
	 */
	if( me->usrAttCount ) {
		VSfreeList( me->usrAttCount, me->usrNamList ) ;
		VSfreeList( me->usrAttCount, me->usrSynList ) ;
	}

	vs$getActiveUsrAttr( msg	= msg,
			     basename	= VS_K_ActBmUAttr,
			     p_activeUA	= &me->UAid ) ;

	if( !IF_NULL_OBJID( me->UAid.objid ) ) {
		vs$getUsrAttrContent( msg	= msg,
				      UAid	= &me->UAid,
				      p_size	= &me->usrAttCount,
				      p_names	= &me->usrNamList,
				      p_syntaxes= &me->usrSynList ) ;
					      
		if( !( *msg & 1 ) ) goto wrapup ;
	} else {
		me->usrAttCount = 0 ;
		me->usrNamList 	= NULL ;
		me->usrSynList	= NULL ;
	}

	/*
	 * Change number.
	 */
	me->change_number	= 0 ;

	*msg = MSSUCC ;
	me->flag &= ~VS_K_no_attributes ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method load_attributes */
/*----------------------------------------------------------------------------*/
method construct_beam( long *msg ) {

	char			*form = me->fm_ptr ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSpartAttr		part ;
	VSbeamAttr	 	beam ;
	int			i,
				count ;
	char			name[DI_PATH_MAX] ;
	struct GRobj_env	*located = NULL ;
	struct GRobj_env	*parent = NULL ;
	struct GRid		beamId ;
	struct ACdb_info	checkin ;
 	struct GRid		cachedPart ;


	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	/*
	 * Get parents.
	 */
	parent  = _MALLOC( 2, struct GRobj_env ) ; 
	located = _MALLOC( me->number_of_beams + 1, struct GRobj_env ) ;
	if( !located || !parent ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	me->ret = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg,
							me->number_of_beams + 1,
							located ),
				targetid= my_id ) ;
				
	/*
	 * Fill construction list.
	 */
	vs$getBmOrPlCstDefaults(msg		= msg,
				symb_id		= me->ModuleInfo.md_id,
				symb		= &me->ActiveRep,
				memberClass	= me->clsCode[me->clsIndex],
				matchKey	= me->matchKey,
				matchId		= &located[0]._grid,
				path		= me->directory,
				level		= &me->ActiveLevel,
				display		= &me->ActiveDisplay ) ;

	VSfixBeamRep(   me->ActiveRep.representation,
			&me->ActiveRep.representation ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display		= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &vsargs,
				Cnst_list	= cstargs,
				Msg		= msg ) ;

	vsargs.parent_count	= 2 ;
	vsargs.representation	= me->ActiveRep.representation ;
	vsargs.feature_att	= (char *) &part ;
	

	if( ( me->flag & VS_K_change_usr_attr ) && me->usrAttCount ) {
		vs$makeActiveUsrAttr( msg	= &me->ret,
				      basename  = VS_K_ActBmUAttr,
				      nbEntries	= me->usrAttCount,
				      names	= me->usrNamList,
				      syntaxes	= me->usrSynList,
				      p_activeUA= &me->UAid ) ;
		me->flag &= ~VS_K_change_usr_attr ;
	}

	vs$fillBeamAttr(msg		= msg,
			options		= VS_m_All,
			xOffset		= me->X_offset,
			yOffset		= me->Y_offset,
			RotAngle	= me->rotation,
			cardPnt		= (enum VScardinal_point)
						me->reference_point,
			symmetry	= (enum VSsymmetry)
						me->symmetry,
			matType		= me->actMat,
			matGrade	= me->actGrd,
			partFam		= me->actFam,
			partNum		= me->actPrt,
			usrNotes	= me->notes,
			mtoSrc		= me->source,
			FireProofing	= me->fireproofing,
			mtoChgNo	= me->change_number,
			apprvStat	= me->approval_status,
			constStat	= me->construction_status,
			mbrClass	= me->clsCode[me->clsIndex],
			mbrType		= me->typCode[me->typIndex],
			mtoStk		= me->stock,
			usrAttrId	= &me->UAid,
			partAttr	= &part,
			beamAttr	= &beam ) ;

	strcpy( checkin.catalog	, "vssrcbeam" ) ;
	strcpy( checkin.part_num, "vssrcbeam" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;

	if( me->detailCard ) {
		part.Iwant & = ~VS_m_detCard ;
	}
	/*
	 * If family name begins with '#', we have a composite beam.
	 */
	checkin.quantity = *me->actFam != '#'	? STRUCT_BEAM_OBJ
						: STRUCT_PLATE_OBJ  ;

	parent[0] = located[0] ;

	count = me->number_of_beams ;
	vs$load_part_from_RDB(	msg		= &me->ret,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &cachedPart ) ;

	for( i = 0 ; i < count ; i++ ) {
		if( *me->basename ) {
			DIstmcpy( name, me->directory, me->basename, NULL ) ;
		} else {
			/*
			 * Beam unnamed.
			 */
			*name = '\0' ;
		}
		
		cstargs.name		= name ;
		cstargs.newflag 	= FALSE ;
		parent[1]		= located[i + 1] ;
		vsargs.parent_list	= parent ;

		/*
		 * Construct beam, then display it.
		 */
		
		me->ret = om$construct(
			classname	= me->const_class,
			osnum		= me->cstEnv._MD_OS,
			p_objid		= &beamId.objid );
		beamId.osnum	= me->cstEnv._MD_OS ;

		__DBGpr_obj("beam object" , beamId );
		me->ret = om$send( msg	= message GRgraphics.GRconstruct( 
								&cstargs ),
				targetid = beamId.objid ,
				targetos = beamId.osnum );
		if( !( me->ret & 1 & *msg ) ) {
			if( *msg & 1 ) *msg = MSFAIL ;
			ex$message(	msgnumb		= VSgetMsgKey( *msg ),
					field		= ERROR_FIELD,
					justification	= CENTER_JUS,
					time		= 2 ) ;
			goto wrapup ;
		}
		
		
		/*
		 * Store PDU check-in information.
		 */
		om$send(msg	= message ACdb_info.ACset_db_info( msg,
								&checkin ),
			targetid= beamId.objid,
			targetos= beamId.osnum ) ;

		/*
		 * Display beam.
		 */
		vs$bulk_display( count  = 1,
		                 dpmode = GRbd,
	        	         grids  = &beamId,
	        	         theEnv	= &me->cstEnv ) ;
	                 		 
		/*
		 * Must find a new base name.
		 */
		if( *me->basename ) {
			strcpy( name, me->basename ) ;
			VSbuildName( &me->ret, me->directory, name, me->basename ) ;
		}

		/*
		 * Decrease beam count.
 		 */
		FIfld_set_value( form, VS_K_bm_Number_Of_Beams, 0, 0, 
				(double) count -1 -i, FALSE ) ;

	}
	/*
	 * Display new base name.
	 */
	FIfld_set_text( form, VS_K_bm_Name, 0, 0, me->basename, FALSE ) ;

	me->ret = MSSUCC ;

	me->flag |= VS_K_beam_constructed ;

	wrapup :
		_FREE( located ) ;
		_FREE( parent ) ;
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method construct_beam */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmbeam_labels[] = {
	{ VS_K_bm_Dismiss_Execute	, TRUE },
	{ VS_K_bm_Execute		, TRUE },
	{ VS_K_bm_Revert		, TRUE },
	{ VS_K_bm_Dismiss		, TRUE },
	{ VS_K_bm_Roll_Through		, TRUE },
	{ VS_K_bm_Message		, TRUE },
	{ VS_K_bm_Material_Type		, TRUE },
	{ VS_K_bm_Material_Grade	, TRUE },
	{ VS_K_bm_Shape_Name		, TRUE },
	{ VS_K_bm_Section_Name		, TRUE },
	{ VS_K_bm_Directory		, TRUE },
	{ VS_K_bm_Name			, TRUE },
	{ VS_K_bm_Stock_Number		, TRUE },
	{ VS_K_bm_Source		, TRUE },
	{ VS_K_bm_Fireproofing		, TRUE },
	{ VS_K_bm_Approval_Status	, TRUE },
	{ VS_K_bm_Construction_Status	, TRUE },
	{ VS_K_bm_Member_Class		, TRUE },
	{ VS_K_bm_Member_Type		, TRUE },
	{ VS_K_bm_Change_Number		, TRUE },
	{ VS_K_bm_Number_Of_Beams	, TRUE },
	{ VS_K_bm_Comments		, TRUE },
	{ VS_K_bm_Display_Ratio		, TRUE },
	{ VS_K_bm_X_Offset		, TRUE }, 
	{ VS_K_bm_Y_Offset		, TRUE }, 
	{ VS_K_bm_Rotation		, TRUE }, 
	{ VS_K_bm_Section_Length	, TRUE },
	{ VS_K_bm_Section_Area		, TRUE },
	{ VS_K_bm_Top_Left		, TRUE }, 
	{ VS_K_xs_Position		, TRUE },
	{ VS_K_bm_Center_Left		, TRUE }, 
	{ VS_K_bm_Bot_Left		, TRUE }, 
	{ VS_K_bm_Top_Middle		, TRUE }, 
	{ VS_K_bm_Bot_Mid		, TRUE }, 
	{ VS_K_bm_Top_Right		, TRUE }, 
	{ VS_K_bm_Center_Middle		, TRUE }, 
	{ VS_K_bm_Center_Right		, TRUE }, 
	{ VS_K_bm_Bot_Right		, TRUE }, 
	{ VS_K_bm_No_Sym		, TRUE }, 
	{ VS_K_bm_X_Sym		        , TRUE }, 
	{ VS_K_bm_Y_Sym			, TRUE }, 
	{ VS_K_bm_XY_Sym		, TRUE },
	{ VS_K_bm_Parameters		, TRUE },
	{ VS_K_bm_Copy_Params		, TRUE },
	{ VS_K_bm_Definition		, TRUE },
	{ VS_K_bm_Section_Manipulation  , TRUE },
	{ VS_K_bm_Material_Take_Off 	, TRUE },
	{ VS_K_bm_User_Attributes	, TRUE },
	{ VS_K_bm_Mcf_User_Attributes	, TRUE },
	{ -1				, TRUE }	/* End-of-list flag */
} ;

	*msg = MSSUCC ;
	*list = VS_Ga_fmbeam_labels ;

	return OM_S_SUCCESS ;

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long			msg ;
	int			response,
				inter_displ,
				sel_flag,
				r_pos ;
	char			*text ;
	double			*p_value,
				get_value ;
	int			isHere,
				inModel,
				writable ;
	struct GRobj_env	axis ;

#define TELLUSER( msgnumb ) \
	om$send(msg	= message VSfmbeamCmd.tellUser( (msgnumb) ),\
		targetid = my_id ) ;\
	me->flag |= VS_K_message_set 

#define FILL_ASCII_FIELD( text ) \
	FIfld_set_text(	form_ptr, gadget_label, 0, 0, (text), FALSE )

#define FILL_VALUE_FIELD( val ) \
	FIfld_set_value( form_ptr, gadget_label, 0, 0, (double) (val), FALSE )
	
#define SET_LIST_SELECT( index )\
	FIfld_set_list_select( form_ptr, gadget_label, (index), 0, TRUE ) 

#define GET_FIELD_TEXT() VSfld_get_text( form_ptr, gadget_label )

#define QUERY_RDB( a, f ) \
	om$send(msg	= message VSfmbeamCmd.QueryRDB( &msg, (a), (f) ), \
		targetid= my_id )
		
#define DISPLAY_GROUP( grp ) \
	if( VS_K_bm_Grp_##grp != me->ActGrp ) {\
		if( me->ActGrp == VS_K_bm_Grp_Definition ) \
			vs$repaint_gadget( form   = form_ptr,\
					   gadget = VS_K_bm_Area ) ;\
		VSg_replace( form_ptr, me->ActGrp, VS_K_bm_Grp_##grp ) ;\
		me->ActGrp = VS_K_bm_Grp_##grp ;\
	}
#define DRAW_SECTION \
	om$send( msg	= message VSfmbeamCmd.draw_section_on_form( &msg ),\
		 targetid = my_id ) ;
		 
	inter_displ = FALSE ;

	/*
	 * Erase form's message field if set.
	 */	 
	if( me->flag & VS_K_message_set ) {
		TELLUSER( MS_NO_MSG ) ;
		me->flag &= ~VS_K_message_set ;
	}

	switch( gadget_label ) {

	case VS_K_bm_Dismiss_Execute	:
		/*
		 * Construct beam(s), then exit command.
		 */
		response = TERMINATE ;
		goto EXECUTE ;

	case VS_K_bm_Execute		:
		/*
		 * Construct beam, then go to state "start".
		 */
		response = EX_BACK_UP ;
	EXECUTE	:
		vs$isDirUsable(	dirname	= me->directory,
				isHere	= &isHere,
				inModel	= &inModel,
				writable= &writable ) ;

		if( !isHere ) {
			VSfi_msgkeySts( form_ptr, VS_gW_NoSuchDir ) ;
			FIg_set_state_off( form_ptr, gadget_label ) ;
			break ;
		} else if( !inModel ) {
			/*
			 * Cannot construct if not in master file.
			 */
			VSfi_msgkeySts( form_ptr, VS_gW_CwdNtInMod ) ;
			FIg_set_state_off( form_ptr, gadget_label ) ;
			break ;
		} else if( !writable ) {
			VSfi_msgkeySts( form_ptr, VS_gW_CwdNotWritable ) ;
			FIg_set_state_off( form_ptr, gadget_label ) ;
			break ;
		}
		om$send(msg	= message VSplbeamCmd.construct_beam( &msg ),
			targetid= my_id ) ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_bm_Revert		:
		/*
		 * Display active group.
		 */
		if( me->flag & VS_K_no_object_located )
			vs$g_disable_gadgets( form = form_ptr, 
					      list = `VS_K_bm_Dismiss_Execute,
						      VS_K_bm_Execute,
                                                      -1` ) ;
		else inter_displ = TRUE ;
		
		FIg_display( form_ptr, me->ActGrp ) ;

		if( me->ActGrp != VS_K_bm_Grp_Default )
			FIg_set_state_on( form_ptr, me->ActGrp - 100 ) ;
			
		/*
		 * Display 'Roll Through' gadget.
		 */
		if( !(me->flag & VS_K_no_object_located) &&
		     me->number_of_beams > 1 )
			FIg_display( form_ptr, VS_K_bm_Roll_Through ) ;
			
		/*
		 * Free RDB data.
		 */
		om$send( msg      = message VSqryRdbCmd.freeRDBdata(),
			 targetid = my_id ) ;

		/*
		 * Reload form with default values.
		 */
		om$send(msg	= message VSfmbeamCmd.load_attributes( &msg ),
			targetid= my_id ) ;

 		me->clsIndex = 0 ;
 		me->typIndex = 0 ;
		om$send(msg	 = message VSfmbeamCmd.fill_form( &msg ),
			targetid = my_id ) ;

		om$send(msg = message VSfmbeamCmd.set_initial_gadget_attributes( &msg ),
			targetid = my_id ) ;

		DRAW_SECTION ;
		break ;

	case VS_K_bm_Dismiss		:
		/*
		 * Exit command.
		 */
		response = TERMINATE ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_bm_Material_Type	:
		/*
		 * Load new grades, shape name, section and section parameters.
		 */
		text = GET_FIELD_TEXT() ;
		if( !strcmp( text, me->actMat ) ) {
			_FREE( text ) ; break ;
		}
		om$send(msg	= message VSqryRdbCmd.saveActiveItems(),
			targetid= my_id ) ;
		msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
						text, NULL, NULL, NULL ),
				targetid= my_id ) ;

		if( msg != OM_I_NOMATCH ) {
			QUERY_RDB( 	VS_m_grd | 
					VS_m_fam |
					VS_m_prt |
					VS_m_par |
					VS_m_force,
					TRUE ) ;
			if( msg & 1 ) {
				inter_displ = TRUE ;
				DRAW_SECTION ;
			} else {
				om$send(msg	= message VSqryRdbCmd.restoreActiveItems(),
					targetid= my_id ) ;
				 FILL_ASCII_FIELD( me->actMat ) ;
			}
		}
		_FREE( text ) ;
		break ;

	case VS_K_bm_Roll_Through	:
		/*
		 * Highlight old axis.
		 */
		om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
								&msg,
								me->ActBeam+1,
								&axis ),
			 targetid = my_id ) ;

		vs$bulk_display( count  = 1,
	                 	 dpmode = GRhd,
	                 	 objenvs= &axis ) ;
		/*
		 * Unhilight new axis.
		 */		
		me->ActBeam++ ;
		if( me->ActBeam == me->number_of_beams ) me->ActBeam = 0 ;

		om$send( msg      = message VSlocateCmd.getLocObjAtIndex(
								&msg,
								me->ActBeam+1,
								&axis ),
			 targetid = my_id ) ;

		vs$bulk_display( count  = 1,
	                 	 dpmode = GRhe,
	                 	 objenvs= &axis ) ;

		inter_displ = TRUE ;
		break ;
	
	case VS_K_bm_Material_Grade	:
		text = GET_FIELD_TEXT() ;
		if( strcmp( text, me->actGrd ) ) {
			om$send(msg	= message VSqryRdbCmd.setActiveItems(
						NULL, text, NULL, NULL ),
				targetid= my_id ) ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_bm_Shape_Name		:
		/*
		 * Load new section and section parameters.
		 */
		text = GET_FIELD_TEXT() ;
		if( !strcmp( text, me->actFam ) ) {
			_FREE( text ) ; break ;
		}

		om$send(	msg	= message VSqryRdbCmd.saveActiveItems(),
				targetid= my_id ) ;
		msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
						NULL, NULL, text, NULL ),
				targetid= my_id ) ;
		if( msg != OM_I_NOMATCH ) {
			QUERY_RDB( 	VS_m_prt |
					VS_m_par |
					VS_m_force,
					TRUE ) ;

			if( !( msg & 1 ) ) {
				/*
				 * Restore active shape name.
				 */
				om$send(msg	= message VSqryRdbCmd.restoreActiveItems(),
					targetid= my_id ) ;
				FILL_ASCII_FIELD( me->actFam ) ;
				SET_LIST_SELECT( me->famIndex ) ;
			} else {
				inter_displ = TRUE ;
				DRAW_SECTION ;
			}
		}
		_FREE( text ) ;
		break ;

	case VS_K_bm_Section_Name	:
		/*
		 * Load new section parameters.
		 */
		text = GET_FIELD_TEXT() ;
		if( !strcmp( text, me->actPrt ) ) {
			_FREE( text ) ; break ;
		}
		om$send(	msg	= message VSqryRdbCmd.saveActiveItems(),
				targetid= my_id ) ;
		msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
						NULL, NULL, NULL, text ),
				targetid= my_id ) ;
		if( msg != OM_I_NOMATCH ) {
			QUERY_RDB( 	VS_m_par |
					VS_m_force ,
					TRUE ) ;
		
			if( !( msg & 1 ) ) {
				/*
				 * Restore active section name.
				 */
				om$send(msg	= message VSqryRdbCmd.restoreActiveItems(),
					targetid= my_id ) ;
				FILL_ASCII_FIELD( me->actPrt ) ;
				SET_LIST_SELECT( me->prtIndex ) ;
			} else {
				inter_displ = TRUE ;
			}
		}
		_FREE( text ) ;
		break ;
	
	case  VS_K_bm_X_Offset 		:
	case  VS_K_bm_Y_Offset  	:
		if( gadget_label == VS_K_bm_X_Offset ) p_value = &me->X_offset ;
		else p_value = &me->Y_offset ;

		/*
		 * Read user input, convert it to a numeric value,
		 * re-translate it to units then fill field (user may have
		 * entered a unit expression).
		 */

		vs$processUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= gadget_label,
					osnum	= me->cstEnv._MD_OS,
					oldValue= *p_value,
					newValue= p_value ) ;
	
		inter_displ = TRUE ;
		break ;

	case  VS_K_bm_Rotation  	:
		p_value = &me->rotation ;
		/*
		 * Read user input, convert it to a numeric value,
		 * re-translate it to units then fill field (user may have
		 * entered a unit expression).
		 */

		vs$processUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= gadget_label,
					osnum	= me->cstEnv._MD_OS,
					type	= GRIO_ANGLE,
					oldValue= *p_value,
					newValue= p_value ) ;
		inter_displ = TRUE ;
		break ;

	case VS_K_bm_Name		:
		text = GET_FIELD_TEXT() ;
		if( text ) {
			if( *text ) {
				char	NewName[DI_PATH_MAX] ;
				VSbuildName( &msg, me->directory,text, NewName);
					     
				if( strcmp( text, NewName ) ) {
					char buffer[MS_MAX_MSG_LENGTH],
					     bufTel[MS_MAX_MSG_LENGTH] ;
					     
					ex$message( msgnumb = VS_gW_NameAlrExist,
					            buff    = buffer ) ;
					     
					sprintf( bufTel, "%s : %s", text, 
						 buffer ) ;

					VSfi_msg( form_ptr, bufTel ) ;

					me->flag |= VS_K_message_set ;
				
					FILL_ASCII_FIELD( me->basename ) ;
				} else {
					strcpy( me->basename, text ) ;
				}
			} else *me->basename = '\0' ;
			_FREE( text ) ;
		} 
		break ;

	case VS_K_bm_Change_Number	:
		/*
		 * Change request number must be >= 0.
		 */
		FIfld_get_value( form_ptr, gadget_label, 0, 0, &value,
				 &sel_flag, &r_pos ) ;	

		if( value < 0. )	FILL_VALUE_FIELD( me->change_number ) ;
		else			me->change_number = (int) value ;
		break ;

	case VS_K_bm_Fireproofing	:
		/*
		 * Fireproofing thickness must be >= 0.
		 */
		vs$processUnitField(	msg	= &msg,
					form	= form_ptr,
					field	= gadget_label,
					osnum	= me->cstEnv._MD_OS,
					verify	= VSisDblPositive,
					oldValue= me->fireproofing,
					newValue= &me->fireproofing ) ;

		break ;

	case VS_K_bm_Display_Ratio	:
		/*
		 * Display Ratio must be > 0.
		 */
		FIfld_get_value( form_ptr, gadget_label, 0, 0, &get_value,
				 &sel_flag, &r_pos ) ;
		if( get_value <= 0. )	FILL_VALUE_FIELD( me->display_ratio ) ;
		else {
			me->display_ratio = get_value ;
			inter_displ = TRUE ;
		}
		break ;

	case VS_K_bm_Stock_Number	:
		_FREE( me->stock )	; me->stock	= GET_FIELD_TEXT() ;
		break ;

	case VS_K_bm_Source		:
		_FREE( me->source )	; me->source	= GET_FIELD_TEXT() ;
		break ;

	case VS_K_bm_Approval_Status	:
		_FREE( me->approval_status ) ; 
	        me->approval_status 	= GET_FIELD_TEXT() ;
		break ;

	case VS_K_bm_Construction_Status: 
		_FREE( me->construction_status ) ; 
	        me->construction_status = GET_FIELD_TEXT() ;
		break ;
		
	case VS_K_bm_Member_Class	:
		me->clsIndex = VSgetSelectedRow( form_ptr, gadget_label ) ;
		om$send(msg	= message VSfmbeamCmd.getCnstDefaults(),
			targetid= my_id ) ;
		break ;

	case VS_K_bm_Member_Type	:
		me->typIndex = VSgetSelectedRow( form_ptr, gadget_label ) ;
		break ;

	case VS_K_bm_Comments		:
		_FREE( me->notes )	;
		me->notes = VSfld_get_lines( form_ptr, gadget_label ) ;
		break ;

		/*
		 * Reference points.
		 */
	case VS_K_bm_Top_Left		:
		me->reference_point = VS_e_UPP_LEFT ; 		
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Top_Middle		:
		me->reference_point = VS_e_TOP_MIDD ; 		
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Top_Right		:
		me->reference_point = VS_e_UPP_RGHT ; 		
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Center_Left	:
		me->reference_point = VS_e_LFT_MIDD ; 		
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Center_Middle	:
		me->reference_point = VS_e_GEO_CENT ; 		
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Center_Right	:
		me->reference_point = VS_e_RGH_MIDD ;
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Bot_Left		:
		me->reference_point = VS_e_BOT_LEFT ;
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Bot_Mid		:
		me->reference_point = VS_e_BOT_MIDD ;
		inter_displ = TRUE ;
 		break ;
	case VS_K_bm_Bot_Right		:
		me->reference_point = VS_e_BOT_RGHT ;
		inter_displ = TRUE ;
 		break ;

		/*
		 * Symmetry.
		 */
	case VS_K_bm_X_Sym		:
		me->symmetry = VS_e_X_Symm ; inter_displ = TRUE ; break ;
	case VS_K_bm_Y_Sym		:
		me->symmetry = VS_e_Y_Symm ; inter_displ = TRUE ; break ;
	case VS_K_bm_XY_Sym		:
		me->symmetry = VS_e_XY_Symm ;inter_displ = TRUE ; break ;
	case VS_K_bm_No_Sym		:
		me->symmetry = VS_e_No_Symm ;inter_displ = TRUE ; break ;
	
	case VS_K_xs_Position	:
		
		if( (int)value == 1) {
			me->detailCard = TRUE ;
		} else {
			me->detailCard = FALSE ;
		}
		inter_displ = TRUE ;
		break ;
		/*
		 * Modify section.
		 */
	case VS_K_bm_Copy_Params	:
		/*
		 * WARNING: Cannot identify a beam if the system is in the
		 * accept process of locate filter.
		 */
		 
		if( me->stack.num_entries == 0 ) {
			dp$erase_hilite( msg = &msg ) ;
			response = VS_K_LOAD_ATTR ;
			ex$putque( msg = &msg, response = &response ) ;
		}
 		break ;
 		
 	case VS_K_bm_Mcf_User_Attributes:
		if( me->usrAttCount ) {
			VSfreeList( me->usrAttCount, me->usrNamList ) ;
			VSfreeList( me->usrAttCount, me->usrSynList ) ;
		}
		me->usrNamList = VSmcf_get_list_text(	form_ptr, 
							gadget_label,
							0 ) ;
		me->usrSynList = VSmcf_get_list_text(	form_ptr, 
							gadget_label,
							1 ) ;
						
		FIfld_get_num_rows( form_ptr, gadget_label, &me->usrAttCount ) ;

		me->flag |= VS_K_change_usr_attr ;
		break ;
 		
 	case VS_K_bm_Definition		  :
 		DISPLAY_GROUP( Definition ) ; DRAW_SECTION ; break ;
 		
 	case VS_K_bm_Section_Manipulation :
 		DISPLAY_GROUP( Manipulation ) ;	break ;
 	
 	case VS_K_bm_Material_Take_Off  :
 		DISPLAY_GROUP( MTO ) ; break ;
 		
 	case VS_K_bm_User_Attributes  	:
 		DISPLAY_GROUP( UA ) ; break ;

	default				:
		break ;
	
	}

	if( inter_displ ) 
		 om$send(msg	= message VSplbeamCmd.inter_display( &msg ),
			targetid= my_id ) ;

	FIg_set_state(me->fm_ptr, VS_K_xs_Position, me->detailCard );
		          
#undef TELLUSER
#undef FILL_ASCII_FIELD
#undef FILL_VALUE_FIELD
#undef SET_LIST_SELECT
#undef GET_FIELD_TEXT
#undef QUERY_RDB
#undef DISPLAY_GROUP
#undef DRAW_SECTION

 	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method inter_display( long *msg ) {

	struct GRvg_construct	cstargs ;
	struct GRobj_env	parent[2] ;
	
	if( me->flag & VS_K_no_object_located ) goto wrapup ;

	ex$message( msgnumb = VS_gI_Processing, justification = CENTER_JUS ) ;

	/*
	 * Get surface.
	 */
	me->ret = om$send(msg	= message VSlocateCmd.getLocObjAtIndex( 
							msg, 0, &parent[0] ),
 			  targetid = my_id ) ;
 			   
	/*
	 * Get axis.
	 */
	me->ret = om$send( msg	= message VSlocateCmd.getLocObjAtIndex( 
					msg, me->ActBeam+1, &parent[1] ),
 			   targetid = my_id ) ;

	vs$getBmOrPlCstDefaults(msg		= msg,
				symb_id		= me->ModuleInfo.md_id,
				symb		= &me->ActiveRep,
				memberClass	= me->clsCode[me->clsIndex],
				matchKey	= me->matchKey,
				matchId 	= &parent[0]._grid,
				path		= me->cnstDir,
				level		= &me->ActiveLevel,
				display		= &me->ActiveDisplay ) ;

	/*
	 * Do not use PWD any longer.
	 */
	me->directory = me->cnstDir ;

	if( !(me->flag & VS_K_first_inter_displ) ) {
		
		/*
		 * Delete old section ( should be done when interactive
		 * display does not come from wakeup ).
		 */
		vs$bulk_display( dpmode = GRbehe, objenvs= &me->BeamSect ) ;
		vs$bulk_delete( objenvs = &me->BeamSect ) ;
	} else {
		/*
		 * Display suggested name.
		 */
		GRname name ;

		if( *me->basename ) {
			strcpy( name, me->basename ) ;
			VSbuildName( msg, me->directory, name, me->basename ) ;
			FIfld_set_text( me->fm_ptr, VS_K_bm_Name, 0, 0, 
					me->basename, FALSE ) ;
		}
	}
	FIfld_set_text( me->fm_ptr, VS_K_bm_Directory,0, 0, 
					me->directory, FALSE ) ;
		
	/*
	 * Fill construction list.
	 */
	me->BeamSect.mod_env = me->cstEnv ;
		
	VSfixBeamRep(   me->ActiveRep.representation,
			&me->ActiveRep.representation ) ;

	vs$fill_cnst_list(	Env_info 	= &me->cstEnv,
				Display 	= &me->ActiveDisplay,
				Level 		= me->ActiveLevel,
				Cnst_list	= cstargs,
				Properties	= GRIS_DISPLAYABLE,
				Msg		= msg ) ;
	me->ret = 
	vs$place_cross_section( msg	= msg,
				xMat	= me->actMat,
				xFam	= me->actFam,
				xName	= me->actPrt,
				searchOS= me->cstEnv.md_id.osnum,
				xOffset	= me->X_offset,
				yOffset	= me->Y_offset,
				rotation= me->rotation,
				profOpt = &me->detailCard,
				cardinal= (enum VScardinal_point)
						me->reference_point,
				symmetry= (enum VSsymmetry)
						me->symmetry,
				surface = &parent[0],
				axis	= &parent[1],
				dspRatio= me->display_ratio,
				dspRep  = me->ActiveRep.representation,
				cst	= &cstargs,
				xSect	= &me->BeamSect._grid ) ;
	if( !( me->ret & 1 & *msg ) ) {
		*msg = MSFAIL ; me->number_of_beams = 0 ; goto wrapup ;
	}

	/*
	 *   Highlight section of beam.
	 */
	vs$bulk_display( dpmode = GRhd, objenvs = &me->BeamSect ) ;
	                 
	me->flag &= ~VS_K_first_inter_displ ;
	me->ret = MSSUCC ;

	wrapup :
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;
		return OM_S_SUCCESS ;

} /* method inter_display */
/*----------------------------------------------------------------------------*/
method hilight_elem( long *msg ) {

	/*
	 * Hilighted elements should be support surface and all axes, except
	 * axis supporing the beam profile.
	 */
	 
	long 			sts ;
	struct GRobj_env	*element = NULL ;
	
	/*
	 * Get elements
	 */
	element  = _MALLOC( me->number_of_beams + 1, struct GRobj_env ) ; 
	if( !element ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	
	if( me->flag & VS_K_no_object_located ) goto wrapup ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg,
							me->number_of_beams + 1,
							element ),
				targetid= my_id ) ;
	
	vs$bulk_display( count  = me->number_of_beams + 1,
	                 dpmode = GRhd,
	                 objenvs= element ) ;
	                 
	vs$bulk_display( dpmode = GRhe, objenvs = &element[me->ActBeam+1] ) ;

	*msg = MSSUCC ;

	wrapup :	
		_FREE( element ) ;
		return OM_S_SUCCESS ;

} /* method hilight_elem */
/*----------------------------------------------------------------------------*/
method unhilight_elem( long *msg ) {

	struct GRobj_env	*element = NULL ;
	
	/*
	 * Get elements
	 */
	element  = _MALLOC( me->number_of_beams + 1, struct GRobj_env ) ; 
	if( !element ) {
		*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	 
	om$send( msg	= message VSlocateCmd.getLocObjs(
							msg,
							me->number_of_beams + 1,
							element ),
	   	 targetid= my_id ) ;
	   	 
	vs$bulk_display( count  = me->number_of_beams + 1,
	                 dpmode = GRhe,
	                 objenvs= element ) ;
	                 
	*msg = MSSUCC ;

	wrapup :
		_FREE( element ) ;
		return OM_S_SUCCESS ;

} /* method unhilight_elem */
/*----------------------------------------------------------------------------*/
method load_attributes_from_beam( long *msg ) {

	char			*form = me->fm_ptr ;
	long			sts ;
	struct GRid		LocatedBeam ;
	VSpartAttr		attr ;
	VSbeamAttr		info ;
	unsigned long		attrMask,
				type ;

#define SET_LIST_SELECT( gadget, index )\
	FIfld_set_list_select( form, (gadget), (index), 0, TRUE ) 
	
	LocatedBeam = me->event1.located_object[0].located_obj ;
	
	attr.Iwant	= VS_m_All ;
	attr.specific	= (void *) &info ;
	
	sts = om$send( msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
		       targetid = LocatedBeam.objid,
		       targetos = LocatedBeam.osnum ) ;	
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

/*
 * Set the toggle according to the detaildCard value.
 * TR179700969
 * TR179702512 
 * Take origin and cardinal point into account.
 * I am not sure if this method ever gets called for non-src beams
 * But if it does, then we are covered
*/
  {
    int state;

    VSbeamGetState(&LocatedBeam,&state);

    if( state & VS_m_NdState) me->detailCard = TRUE ;
    else                      me->detailCard = FALSE;
	
  }

	me->change_number	= attr.mto.chgnum ;
	me->stock		= VSstrdup( attr.mto.stock	) ;
	me->source		= VSstrdup( attr.mto.source	) ;
	
	om$send(msg	 = message VSqryRdbCmd.freeRDBdata(),
		targetid = my_id ) ;

	om$send(msg	= message VSqryRdbCmd.setActiveItems(
							attr.info.material,
							attr.info.grade,
							attr.info.family,
							attr.info.partNum ),
		targetid= my_id ) ;
	
	me->approval_status 	= VSstrdup( attr.info.apprvstat ) ;
	me->construction_status = VSstrdup( attr.info.conststat	) ;
	me->fireproofing	= attr.info.fpthickness ;
	me->notes		= VSstrdup( attr.info.notes	) ;
	me->X_offset		= info.xoff ;
	me->Y_offset		= info.yoff ;
	me->rotation		= info.rotat ;
	me->reference_point	= info.card ;
	me->symmetry		= info.sym ;
	
	/*
	 * If located beam is a stiffener and its symmetry is 'XY' or 'X',
	 * substract the height of the cross section from Y offset.
	 */
	if( me->symmetry == VS_e_XY_Symm || me->symmetry == VS_e_X_Symm  ) {
		sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
						    msg, &type, &attrMask ),
			       targetid = LocatedBeam.objid,
			       targetos = LocatedBeam.osnum ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;
	
		if( type == VS_m_STF_BEAM ) {
		   struct GRid 	sectDef ;
		   double	height ;

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
						       &height ) ;
		   if( !( sts & 1 & *msg ) ) *msg = MSFAIL ;
		   __CheckRC( sts, *msg, "VSgetHeightOfCrossSectionDef", wrapup ) ;
		   
		  me->Y_offset -= height ;
		}
	}

	/*
	 * Retrieve index for member class.
	 */
	VSfind_item_in_array( attr.info.memberClass, 
			      me->clsCode, 
			      VS_rdb_MAXCLASSES,
			      &me->clsIndex ) ;
	if( me->clsIndex == -1 ) me->clsIndex = 0 ;
	
	/*
	 * Retrieve index for member type.
	 */
	VSfind_item_in_array( attr.info.memberType, 
			      me->typCode, 
			      VS_rdb_MAXBMTYPES,
			      &me->typIndex ) ;
	if( me->typIndex == -1 ) me->typIndex = 0 ;
	
	/*
	 * Retrieve User Attributes.
	 */
	me->UAid	= attr.usrAttr ;
	
	if( me->usrAttCount ) {
		VSfreeList( me->usrAttCount, me->usrNamList ) ;
		VSfreeList( me->usrAttCount, me->usrSynList ) ;
	}

	if( !IF_NULL_OBJID( me->UAid.objid ) ) {
		vs$getUsrAttrContent( msg	= msg,
				      UAid	= &me->UAid,
				      p_size	= &me->usrAttCount,
				      p_names	= &me->usrNamList,
				      p_syntaxes= &me->usrSynList ) ;
					      
		if( !( *msg & 1 ) ) goto wrapup ;
	} else {
		me->usrAttCount = 0 ;
		me->usrNamList 	= NULL ;
		me->usrSynList	= NULL ;
	}
	me->flag |= VS_K_change_usr_attr ;
	
	om$send( msg	= message VSfmbeamCmd.QueryRDB( &sts,
							VS_m_mat |
							VS_m_fam |
							VS_m_grd | 
							VS_m_prt | 
							VS_m_par,
							FALSE ),
		 targetid = my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;
	
	SET_LIST_SELECT( VS_K_bm_Material_Type 		, me->matIndex ) ;
	SET_LIST_SELECT( VS_K_bm_Material_Grade 	, me->grdIndex ) ;
	SET_LIST_SELECT( VS_K_bm_Shape_Name		, me->famIndex ) ;
	SET_LIST_SELECT( VS_K_bm_Section_Name		, me->prtIndex ) ;
	SET_LIST_SELECT( VS_K_bm_Member_Class		, me->clsIndex ) ;
	SET_LIST_SELECT( VS_K_bm_Member_Type		, me->typIndex ) ;
	
	wrapup :
		/*
		 * Unhilight located beam.
		 */
		vs$bulk_display(
			grids	= &LocatedBeam,
			theEnv	= &me->event1.located_object[0].module_info,
			dpmode	= GRhe ) ;
 			 
		/*
		 * Abort command on memory allocation failure.
		 */
		if( !me->stock || !me->source || !me->notes ||
		    !me->approval_status || !me->construction_status ) {
			_FREE( me->stock		) ;
			_FREE( me->source		) ;
			_FREE( me->notes		) ;
			_FREE( me->approval_status 	) ;
			_FREE( me->construction_status 	) ;
			*msg = MSFAIL ;
		}
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

#undef SET_LIST_SELECT
	
		return OM_S_SUCCESS ;

} /* method load_attributes_from_beam */
/*----------------------------------------------------------------------------*/
method place_plane( int *sts ) {

	long 			msg ,
				sts ;

	OM_S_OBJID		window_id ;
	OMuword 		window_os  ;
	double 			min[3] ,	    /* min and max defining   */
				max[3] ;	    /* range of the plane     */	       
	double			dit_clip_range[6] ; /* dit clip range in screens
						       units relative to the 
						       window origin.
						       min are 0,1,2
						       max are 3,4,5
						       
						min
						    ------------------------
						    !			   !
						    !			   !
						    !			   !
						    !			   !
						    ------------------------  
						    			    max
						   use method convert_pnt to
						   have point in world
						   coordinate system.
						   			    
						     			      */
						     
	struct var_list		varlist[3] ;	     /* Arguments ...         */
	long			i,		     /*			      */
				errno ;		     /*	... for DPinquire     */
	long			bsRC ;
	struct	EX_button	point ;		     /* Arguments ...         */
	int			resp ;		     /*	... for convert_pnt   */
	double			point_on_view[3],    /* Pt on view plane      */
				normal_of_view[3] ;  /* View plane normal     */
	struct IGRplane		plane_of_view ;
	struct GRid		plane ;		     /* plane to place        */
	struct GRvg_construct	arglist ;	     /* struct for plane      */
	double			poles[4][3],	     /* Arguments ...         */
				u_knots[4],	     /*	... for ...           */
				v_knots[4] ;         /*			      */
	struct IGRbsp_surface	surface ;	     /*	... construct.	      */
	IGRboolean		in_range ;
	char			path[DI_PATH_MAX],
				path_buf[DI_PATH_MAX] ;
	struct GRid		mod ;
	int			size = sizeof( struct EX_button ) ;
	

	if( me->event1.response == EX_DATA ) {
		window_id = me->event1.event.button.objid ;
		window_os = me->event1.event.button.osnum ;
	} else {
		ex$get_cur_mod( id = &mod.objid, osnum = &mod.osnum ) ;
				
		di$give_pathname( osnum	= mod.osnum, pathname = path ) ;
				  
		DIstmcpy( path_buf, path,"views","regviews","GRviews", NULL ) ;
		
		sts = di$translate( objname	= me->event1.event.keyin,
	 			    path    	= path_buf,
				    p_objid	= &window_id,
				    p_osnum	= &window_os  ) ;
				    
               if( sts == DIR_W_NAME_NOT_FOUND ) {
               		ex$message( msgnumb       = VS_gE_InvWindName,
				    justification = CENTER_JUS ) ;
               		me->ret = VS_K_NO_WINDOW ;
               		return OM_S_SUCCESS ;
               }
        }

	/*
	 * Prepare query of window.
	 */
	plane_of_view.point	= &point_on_view[0] ;
	plane_of_view.normal	= &normal_of_view[0] ;
	
	varlist[0].var			= DIT_CLIP_RANGE ;
	varlist[0].var_ptr		= ( char * ) &dit_clip_range[0] ;
	varlist[0].num_bytes		= sizeof( double ) * 6 ;
	varlist[0].bytes_returned	= &i ;
	
	varlist[1].var			= VIEW_PLANE ;
	varlist[1].var_ptr		= ( char * ) &plane_of_view ;
	varlist[1].num_bytes		= sizeof( plane_of_view ) ;
	varlist[1].bytes_returned	= &i ;
	
	varlist[2].var			= END_PARAM ;
	
	sts = om$send( msg	= message IGEgragad.DPinquire(
							&msg, &errno, varlist ),
		       targetid = window_id,
		       targetos = window_os ) ;
	__CheckRC( sts, msg, "IGEgragad.DPinquire", wrapup ) ;

	/*
	 * Convert the point in world coordinate system.
	 */
	point.x = dit_clip_range[0] ;
	point.y = dit_clip_range[1] ;
	point.z = dit_clip_range[2] ;
	
	/*
	 * WARNING : the method IGEgragad.convert_pnt puts the result
	 * point at the back of the software input queue.
	 */	 
	sts = om$send( msg	= message IGEgragad.convert_pnt(
							&msg, &resp, &point ),
		       targetid = window_id,
		       targetos = window_os ) ;
	__CheckRC( sts, msg, "IGEgragad.convert_pnt", wrapup ) ;
	
	ex$getque( msg 		= &msg,
		   response	= &resp,
		   byte		= &size,
		   buffer	= (char *) &point ) ;

	min[0] = point.x ;
	min[1] = point.y ;
	min[2] = point.z ;
	
	point.x = dit_clip_range[3] ;
	point.y = dit_clip_range[4] ;
	point.z = dit_clip_range[5] ;

	/*
	 * WARNING : the method IGEgragad.convert_pnt puts the result
	 * point at the back of the software input queue.
	 */
	sts = om$send( msg	= message IGEgragad.convert_pnt(
							&msg, &resp, &point ),
		       targetid = window_id,
		       targetos = window_os ) ;
	__CheckRC( sts, msg, "IGEgragad.convert_pnt", wrapup ) ;
	
	ex$getque( msg 		= &msg,
		   response	= &resp,
		   byte		= &size,
		   buffer	= (char *) &point ) ;
		   
	max[0] = point.x ;
	max[1] = point.y ;
	max[2] = point.z ;
	
	/*
	 * Construct plane.
	 */
	surface.poles	= (double *) poles ;
	surface.u_knots	= u_knots ;
	surface.v_knots	= v_knots ;

	(void)	BSplptnorrg(	min ,
				max ,
				point_on_view ,
				normal_of_view ,
				1.0 ,
				&in_range ,
				&surface ,
				&bsRC ) ;

	if( BSERROR( bsRC ) ) { msg = MSFAIL ; goto wrapup ; }

	vs$cnstDefaults(	 msg		= &msg,
				 symb_id	= me->ModuleInfo.md_id,
				 symb		= &me->ActiveRep,
				 level		= &me->ActiveLevel,
				 display	= &me->ActiveDisplay ) ;
	
	vs$fill_cnst_list( Env_info 	= &me->cstEnv,
			   Display	= &me->ActiveDisplay,
			   Level	= me->ActiveLevel,
			   Cnst_list	= arglist,
			   Msg		= &msg ) ;
			   
	plane.osnum	= me->cstEnv.md_id.osnum ;

	sts = om$construct(	classid	= OPP_EMSplane_class_id,
				osnum 	= plane.osnum,
				p_objid	= &plane.objid ) ;
	__CheckRC( sts, 1, "om$construct", wrapup ) ;
	
	arglist.geometry	= ( char * ) &surface ;

	sts = om$send( msg	= message GRgraphics.GRconstruct( &arglist ),
		       mode	= OM_e_wrt_object,
		       targetid = plane.objid,
		       targetos = plane.osnum ) ;
		       
	if( !( sts & 1 & *arglist.msg ) ) {
		om$send( msg	= message Root.delete(1),
			 mode	= OM_e_wrt_object,
			 targetid = plane.objid,
			 targetos = plane.osnum ) ;
		goto wrapup ;
	}		
		   
	vs$bulk_display( dpmode = GRbd, grids = &plane, theEnv = &me->cstEnv ) ;
	                 
	/*
	 * Store surface.
	 */
	sts = om$send(	msg	= message VSlocateCmd.addLocObj(	
						&plane, &me->cstEnv, 0 ),
			targetid= my_id ) ;
	
	wrapup :
		me->ret = sts & 1 & msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method place_plane */
/*----------------------------------------------------------------------------*/

end implementation VSplbeamCmd ;
