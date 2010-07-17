/* $Id */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSplplatCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplplatCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/02/19  20:34:26  pinnacle
# tr179900100
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/19/99  ah      TR179900100 Core dump if plate has lost it's parents
 *                   Added debug statements and header, problem was elsewhere
 ***************************************************************************/

class implementation VSplplatCmd ;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "COBmacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "growner.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "vsglobalmsg.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsplatedef.h"
#include "vsplatmacros.h"
#include "vsplate.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vsicondef.h"
#include "vsdbgmacros.h"
#include "vscmdmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsformmacros.h"
#include "vsnamemacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsRDBproto.h"
#include "vsfnditmary.h"
#include "vsformproto.h"
#include "vsgetmsgkey.h"
#include "vsioproto.h"
#include "vsnameproto.h"
#include "vsstrngproto.h"
#include "vsverifyval.h"

#define vdsDEBUGx 1

#define STRNCPY( To, From )\
	strncpy( (To), (From), VS_K_MAXDBNAME-1 )[VS_K_MAXDBNAME-1] = '\0'

from GRgraphics	import	GRconstruct ;
from GRvg	import	GRgetattr ;
from ACdb_info	import	ACset_db_info ;
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	long	msg ;

	om$send( msg 	= message VSfmplatCmd.wakeup( pos ),
		 mode 	= OM_e_wrt_message,
		 targetid= my_id ) ;

	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	/*
	 * If command stacked, perhaps another 'Place Plate' command was 
	 * executed and the current name already exists, so try to find another
	 * name.
	 */
	if( me->flag & VS_K_command_stacked ) {
		char 	CurName[DI_PATH_MAX] ;

		strcpy( CurName, me->basename ) ;
		VSbuildName( &msg, me->directory, CurName, me->basename ) ;

		if( strcmp( CurName, me->basename ) ) {
			
			FIfld_set_text( me->fm_ptr, VS_K_pl_Name, 0, 0, 
					me->basename, FALSE ) ;
		}
	}
	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	me->flag |= VS_K_no_object_located ;

	me->number_of_plates = 0 ;

	FIfld_set_value( me->fm_ptr, VS_K_pl_Number_Of_Plates, 0, 0,
			 (double) me->number_of_plates, FALSE ) ;

	FIf_set_collapse_symbol( me->fm_ptr,
				 VS_K_CLP_SYM_FILE,
				 VS_K_CLP_PlcPlat ) ;
	
	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	int			nbSurfaces ;
	struct GRobj_env	fence,
				*Surfaces ;
				
	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &me->ret,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count		= &nbSurfaces,
				p_content	= &Surfaces,
				response	= me->response,
				response_data	= me->response_data ) ;
	if( *me->response != EX_DATA || !nbSurfaces ) {
		me->ret = VS_K_NO_FENCE ; goto wrapup ;
	}
	if( me->ret & 1 ) {
		int h ;

		for( h = 0 ; h < nbSurfaces && (me->ret & 1) ; h++ ) {

			me->ret = om$send(
				msg	= message VSlocateCmd.addLocObj(
							&Surfaces[h]._grid,
							&Surfaces[h].mod_env,
							me->number_of_plates ),
				targetid= my_id ) ;
			me->number_of_plates++ ;
		}
		_FREE( Surfaces ) ;
		
		if( !me->number_of_plates ) {
			me->ret = VS_K_NO_FENCE ; goto wrapup ;
		}	
		/*
		 * Display plate count.
		 */
		FIfld_set_value( me->fm_ptr,
				 VS_K_pl_Number_Of_Plates,
				 0, 0, (double) me->number_of_plates, FALSE ) ;

		me->flag &= ~VS_K_no_object_located ;
	}

	me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method store_support( int *sts ) {

	struct  GRobj_env       surface;
	struct  GRid            as_grid ;
	int                     count, status ;
	struct GRlc_info	*toStore = me->event1.located_object ;

	surface._grid = me->event1.located_object[0].located_obj;
        surface.mod_env = me->event1.located_object[0].module_info ;

        as$make_source( go_grid         = surface._grid,
                        mod_env         = &surface.mod_env,
                        as_os           = surface._osnum,
                        as_grid         = &as_grid ) ;

	status = VSgetElementsOnSupport( sts, &as_grid, VS_m_SRC_PLATE,
                                                    FALSE, &count, NULL ) ;
        if ( !( count ) ) {
		me->ret = om$send(	
				msg	= message VSlocateCmd.addLocObj(
							&toStore->located_obj,
							&toStore->module_info,
							me->number_of_plates ),
				targetid= my_id ) ;
		if( me->ret & 1 ) {
			me->number_of_plates++ ;

			/*
			 * Display plate count.
			 */
			FIfld_set_value( me->fm_ptr,
					 VS_K_pl_Number_Of_Plates,
					 0, 0, (double) me->number_of_plates, 
					FALSE ) ;

			me->flag &= ~VS_K_no_object_located ;

		}
		me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
	} else {
		char    *mesg = "Element not found";
		me->ret = VS_K_NO_OBJ;
                ex$message (    field         = ERROR_FIELD,
                                justification = CENTER_JUS,
                                in_buff       = mesg );
	}

	return OM_S_SUCCESS ;

} /* method store_support */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {
	
	int	got_data ;	/* TRUE if DPB loaded with plate data */
	double	parVal ;

	VSdpb_loaded_with_plate( &got_data ) ;

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
				param	= VS_e_dpb_P_material,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actMat, actAttr ) ;

		/*
		 * Grades from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_grade,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
 		STRNCPY( actGrd, actAttr ) ;

		/*
		 * Families from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_type,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actFam, actAttr  ) ;

		/*
		 * Thicknesses from DPB.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_thkname,
				p_arg	= &actAttr ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		STRNCPY( actPrt, actAttr ) ;


		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_thickness,
				p_arg	= &parVal ) ;
		if( !( *msg & 1 ) ) goto wrapup ;
		me->actPar = parVal ;

		om$send(msg	= message VSqryRdbCmd.setActiveItems(
					actMat, actGrd, actFam, actPrt ),
			targetid= my_id ) ;

		om$send(msg	= message VSfmplatCmd.QueryRDB(
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
				param	= VS_e_dpb_P_stock,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = VSmsgkey2string( VS_gI_Unknown ) ;
		me->stock = VSstrdup( actAttr ) ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_source,
				p_arg	= &actAttr ) ;
		if( !actAttr ) actAttr = VSmsgkey2string( VS_gI_Unknown ) ;
		me->source = VSstrdup( actAttr ) ;

		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_notes,
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
				param	= VS_e_dpb_P_name_pattern,
				p_arg	= &actAttr ) ;
		if( !actAttr || !*actAttr ) actAttr = "P1" ;
		/*
		 * Find an available name in current directory.
		 */		
		VSbuildName( msg, me->directory, actAttr, me->basename ) ;

		/*
		 * Plate orientation.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_orientation,
				p_arg	= &me->orientation ) ;

		/*
		 * Plate offset.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_offset,
				p_arg	= &me->offset ) ;

		/*
		 * Cut-off thickness.
		 */
		vs$get_act_pm(	msg	= msg,
				param	= VS_e_dpb_P_cut_off,
				p_arg	= &me->cut_off ) ;

		if( me->cut_off == me->actPar ) me->flag |= VS_K_deflt_cutoff ;
		else				me->flag &= ~VS_K_deflt_cutoff ;
	} else {
		om$send(msg	= message VSfmplatCmd.QueryRDB(
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
		 * Plate name.
		 */
		VSbuildName( msg, me->directory, "P1", me->basename ) ;

		/*
		 * Plate orientation.
		 */
		me->orientation = VS_K_USE_NAT_NORM ;

		/*
		 * Plate offset.
		 */
		me->offset = 0. ;

		/*
		 * Cut-off thickness ( default = active thickness ).
		 */
		me->flag |= VS_K_deflt_cutoff ;
		me->cut_off = me->parVal[me->prtIndex] ;
	}	

	/*
	 * User attributes.
	 */
	if( me->usrAttCount ) {
		VSfreeList( me->usrAttCount, me->usrNamList ) ;
		VSfreeList( me->usrAttCount, me->usrSynList ) ;
	}

	vs$getActiveUsrAttr( msg	= msg,
			     basename	= VS_K_ActPlUAttr,
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
method construct_plate( long *msg ) {

	char			*form = me->fm_ptr ;
	long			sts ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	int			i,
				count ;
	char			name[DI_PATH_MAX] ;
	struct GRobj_env	*parents = NULL ;
	struct GRid		plateId ;
	struct ACdb_info	checkin ;
	struct GRid		cachedPart ;

	/*
	 * Get parents.
	 */
	parents = _MALLOC( me->number_of_plates, struct GRobj_env ) ;
	if( !parents ) {
		sts  = OM_E_NODYNMEM ; *msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
					msg, me->number_of_plates, parents ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	VSfixPlateRep(   me->ActiveRep.representation,
			&me->ActiveRep.representation ) ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display		= &me->ActiveDisplay,
				Level		= me->ActiveLevel,
				Class_attr	= &vsargs,
				Cnst_list	= cstargs,
				Msg		= msg ) ;

	vsargs.parent_count	= 1 ;
	vsargs.representation	= me->ActiveRep.representation ;
	vsargs.feature_att	= (char *) &part ;

	if( ( me->flag & VS_K_change_usr_attr ) && me->usrAttCount ) {
		vs$makeActiveUsrAttr( msg	= &me->ret,
				      basename  = VS_K_ActPlUAttr,
				      nbEntries	= me->usrAttCount,
				      names	= me->usrNamList,
				      syntaxes	= me->usrSynList,
				      p_activeUA= &me->UAid ) ;
		me->flag &= ~VS_K_change_usr_attr ;
	}

	sts = vs$fillPlateAttr(	msg		= msg,
				options		= VS_m_All,
				partFam		= me->famList[me->famIndex],
				matType		= me->matList[me->matIndex],
				matGrade	= me->grdList[me->grdIndex],
				partNum		= me->prtList[me->prtIndex],
				usrNotes	= me->notes,
				mtoSrc		= me->source,
				mtoStk		= me->stock,
				FireProofing	= me->fireproofing,
				mtoChgNo	= me->change_number,
				apprvStat	= me->approval_status,
				constStat	= me->construction_status,
				mbrClass	= me->clsCode[me->clsIndex],
				mbrType		= me->typCode[me->typIndex],
				orientation	= me->orientation,
				cutOff		= me->cut_off,
				offset		= me->offset,
				thickness	= me->parVal[me->prtIndex],
				usrAttrId	= &me->UAid,
				partAttr	= &part,
				plateAttr	= &plate ) ;

	strcpy( checkin.catalog	, "VSsrcPlate" ) ;
	strcpy( checkin.part_num, "VSsrcPlate" ) ;
	strcpy( checkin.revision, "1" ) ;
	strcpy( checkin.usage	, "..." ) ;
	checkin.quantity = STRUCT_PLATE_OBJ ;

	/*
	 * Load plate from RDB.
	 */
	vs$load_part_from_RDB(	msg		= msg,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &cachedPart ) ;
	if( !( *msg & 1 ) ) {
		om$send(msg	= message VSfmplatCmd.tellUser(
							VS_gE_ErrEncCmdRst ),
			targetid= my_id ) ;
		goto wrapup ;
	}

	count = me->number_of_plates ;
	for( i = 0 ; i < count ; i++ ) {

		/*
		 * Must get construction defaults generated by each parent.
		 */
		vs$getBmOrPlCstDefaults(
				msg		= msg,
				symb_id		= me->ModuleInfo.md_id,
				symb		= &me->ActiveRep,
				matchKey	= me->matchKey,
				memberClass	= me->clsCode[me->clsIndex],
				matchId		= &parents[i]._grid,
				path		= me->directory,
				level		= &me->ActiveLevel,
				display		= &me->ActiveDisplay ) ;

		if( *me->basename ) {
			DIstmcpy( name, me->directory, me->basename, NULL ) ;
		} else {
			/*
			 * Plate unnamed.
			 */
			*name = '\0' ;
		}
		
		cstargs.name = name ;
		vsargs.parent_list = parents + i ;

		/*
		 * Unhighlight parent support.
		 */
		vs$bulk_display( count  = 1,
		                 dpmode = GRhe,
	        	         objenvs= &parents[i] ) ;

		/*
		 * Construct plate, then display it.
		 */
		sts = om$construct(
			classname= me->const_class,
			osnum	 = me->cstEnv._MD_OS,
			p_objid	 = &plateId.objid,
			msg	 = message GRgraphics.GRconstruct( &cstargs ) );

		if( !( sts & 1 & *msg ) ) {
			if( *msg & 1 ) *msg = MSFAIL ;

			ex$message(	msgnumb		= VSgetMsgKey( *msg ),
					field		= ERROR_FIELD,
					justification	= CENTER_JUS,
					time		= 2 ) ;

			me->number_of_plates = 0 ;
			goto wrapup ;
		}
	
		plateId.osnum = me->cstEnv._MD_OS ;
		 
		/*
		 * Store PDU check-in information.
		 */
		om$send(msg	= message ACdb_info.ACset_db_info( msg,
								&checkin ),
			targetid= plateId.objid,
			targetos= plateId.osnum ) ;

		/*
		 * Display plate.
		 */
	 	vs$bulk_display( count  = 1,
	 	                 dpmode = GRbd,
	 	                 grids  = &plateId,
	 	                 theEnv	= &me->cstEnv ) ;
		 	                
		/*
		 * Must find a new base name.
		 */
		if( *me->basename ) {
			strcpy( name, me->basename ) ;
			VSbuildName( msg, me->directory, name, me->basename ) ;
		}

		/*
		 * Decrease plate count.
		 */
		me->number_of_plates-- ;
		FIfld_set_value( form,
				 VS_K_pl_Number_Of_Plates,
				 0, 0, (double) me->number_of_plates, FALSE ) ;
	}
	/*
	 * Display new base name.
	 */
	FIfld_set_text( form, VS_K_pl_Name,
			0, 0, me->basename, FALSE ) ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		om$send(msg	= message VSfmplatCmd.display_support_normal(
									 GRhe ),
			targetid= my_id ) ;

		_FREE( parents ) ;

	return OM_S_SUCCESS ;

} /* method construct_plate */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmplat_labels[] = {
	{ VS_K_pl_Dismiss_Execute	, TRUE },
	{ VS_K_pl_Execute		, TRUE },
	{ VS_K_pl_Revert		, TRUE },
	{ VS_K_pl_Dismiss		, TRUE },
	{ VS_K_pl_Message		, TRUE },
	{ VS_K_pl_Material_Type		, TRUE },
	{ VS_K_pl_Material_Grade	, TRUE },
	{ VS_K_pl_Plate_Type		, TRUE },
	{ VS_K_pl_Thickness		, TRUE },
	{ VS_K_pl_Cut_Off		, TRUE },
	{ VS_K_pl_Offset		, TRUE },
	{ VS_K_pl_Directory		, TRUE },
	{ VS_K_pl_Name			, TRUE },
	{ VS_K_pl_Stock_Number		, TRUE },
	{ VS_K_pl_Source		, TRUE },
	{ VS_K_pl_Fireproofing		, TRUE },
	{ VS_K_pl_Approval_Status	, TRUE },
	{ VS_K_pl_Construction_Status	, TRUE },
	{ VS_K_pl_Member_Class		, TRUE },
	{ VS_K_pl_Member_Type		, TRUE },
	{ VS_K_pl_Change_Number		, TRUE },
	{ VS_K_pl_Orientation		, TRUE },
	{ VS_K_pl_Number_Of_Plates	, TRUE },
	{ VS_K_pl_Comments		, TRUE },
	{ VS_K_pl_Copy_Params		, TRUE },
	{ VS_K_pl_Definition		, TRUE },
	{ VS_K_pl_Plate_Manipulation  	, TRUE },
	{ VS_K_pl_Material_Take_Off	, TRUE },
	{ VS_K_pl_User_Attributes	, TRUE },
	{ VS_K_pl_Mcf_User_Attributes	, TRUE },
	{ -1				, TRUE }	/* End-of-list flag */
} ;
	*msg = MSSUCC ;
	*list = VS_Ga_fmplat_labels ;

	return OM_S_SUCCESS ;

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		msg ;
	int		r_pos,
			sel_flag,
			response ;
	char		*text ;
	double		*p_value,
			val ;
	int		isHere,
			inModel,
			writable ;
	char		buf[50],
			*Unit ;

#define TELLUSER( msgnumb ) \
	om$send(msg	= message VSfmplatCmd.tellUser( (msgnumb) ),\
		targetid = my_id ) ;\
	me->flag |= VS_K_message_set 

#define FILL_ASCII_FIELD( text ) \
	FIfld_set_text(	form_ptr, gadget_label, 0, 0, (text), FALSE )

#define FILL_VALUE_FIELD( val ) \
	FIfld_set_value( form_ptr, gadget_label, 0, 0, (double) (val), FALSE )

#define SET_LIST_SELECT( index )\
	FIfld_set_list_select( form_ptr,gadget_label, (index), 0, TRUE ) 

#define GET_FIELD_TEXT() VSfld_get_text( form_ptr, gadget_label )

#define QUERY_RDB( a, f ) \
	om$send(msg	= message VSfmplatCmd.QueryRDB( &msg, (a), (f) ), \
		targetid= my_id )

#define UPDATE_CUTOFF( v ) \
	om$send( msg	= message VSfmplatCmd.updCutOff( &msg , (v) ),\
		 targetid = my_id ) ;
		 
#define DISPLAY_GROUP( grp ) \
	if( VS_K_pl_Grp_##grp != me->ActGrp ) {\
		VSg_replace( form_ptr, me->ActGrp, VS_K_pl_Grp_##grp ) ;\
		me->ActGrp = VS_K_pl_Grp_##grp ;\
	}

	/*
	 * Erase form's message field if set.
	 */
	if( me->flag & VS_K_message_set ) {
		TELLUSER( MS_NO_MSG ) ;
		me->flag &= ~VS_K_message_set ;
	}
	
	switch( gadget_label ) {

	case VS_K_pl_Dismiss_Execute	:
		/*
		 * Construct plate(s), then exit command.
		 */
		response = TERMINATE ;
		goto EXECUTE ;

	case VS_K_pl_Execute		:
		/*
		 * Construct plates, then go to state "start".
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

		om$send(msg	= message VSplplatCmd.construct_plate( &msg ),
			targetid= my_id ) ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_pl_Revert		:
		/*
		 * Display actif group.
		 */
		if( me->flag & VS_K_no_object_located )
			vs$g_disable_gadgets( form = form_ptr,
					      list = `VS_K_pl_Dismiss_Execute,
						      VS_K_pl_Execute,
						      VS_K_pl_Orientation,
						      -1` ) ;

		if( (me->ActGrp == VS_K_pl_Grp_MTO) ||
		    (me->ActGrp == VS_K_pl_Grp_UA) )
			FIg_erase( form_ptr, VS_K_pl_Grp_Comments ) ;
		if( me->ActGrp != VS_K_pl_Grp_Default ) {
			FIg_display( form_ptr, me->ActGrp ) ;
			FIg_set_state_on( form_ptr, me->ActGrp - 100 ) ;
		}
		/*
		 * Erase normal.
		 */
		if( !( me->flag & VS_K_no_object_located ) ) 
			om$send(msg= message VSfmplatCmd.display_support_normal(
									 GRhe ),
				targetid= my_id ) ;
		/*
		 * Reload form with default values.
		 */
		om$send(msg	= message VSqryRdbCmd.freeRDBdata(),
			targetid= my_id ) ;
		om$send(msg	= message VSfmplatCmd.overrideForm(),
			targetid= my_id ) ;
		om$send(msg	= message VSfmplatCmd.load_attributes( &msg ),
			targetid= my_id ) ;
		me->clsIndex = 0 ;
		me->typIndex = 0 ;
		om$send(msg	= message VSfmplatCmd.fill_form( &msg ),
			targetid= my_id ) ;
		/*
		 * Display normal.
		 */
		if( !( me->flag & VS_K_no_object_located ) ) 
			om$send(msg= message VSfmplatCmd.display_support_normal(
									 GRhd ),
				targetid= my_id ) ;
		break ;

	case VS_K_pl_Dismiss		:
		/*
		 * Exit command.
		 */
		response = TERMINATE ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_pl_Material_Type	:
		/*
		 * Load new grades, plate families and thicknesses.
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
			if( !( msg & 1 ) ) {
				om$send(msg	= message VSqryRdbCmd.restoreActiveItems(),
					targetid= my_id ) ;
				 FILL_ASCII_FIELD( me->actMat ) ;
			}
		}
		_FREE( text ) ;
		break ;

	case VS_K_pl_Material_Grade	:
		text = GET_FIELD_TEXT() ;
		if( strcmp( text, me->actGrd ) ) {
			om$send(msg	= message VSqryRdbCmd.setActiveItems(
						NULL, text, NULL, NULL ),
				targetid= my_id ) ;
		}
		_FREE( text ) ;
		break ;

	case VS_K_pl_Plate_Type		:
		/*
		 * Load new thicknesses.
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
			}
		}
		_FREE( text ) ;
		break ;

	case VS_K_pl_Thickness		:
		text = GET_FIELD_TEXT() ;
		if( !strcmp( text, me->actPrt ) ) {
			_FREE( text ) ; break ;
		}
		msg = om$send(	msg	= message VSqryRdbCmd.setActiveItems(
						NULL, NULL, NULL, text ),
				targetid= my_id ) ;
		if( msg != OM_I_NOMATCH ) {
			if( msg & 1 ) {
				UPDATE_CUTOFF( me->cut_off ) ;
			}
		}
		vs$system_to_unit(	msg	= &msg,
					value	= me->actPar,
					osnum	= me->cstEnv.md_id.osnum,
					p_unit	= &Unit ) ;
		sprintf( buf, "%s : %s", me->actPrt, Unit ) ;

		VSfi_msg( form_ptr, buf ) ;

		me->flag |= VS_K_message_set ;

		_FREE( text ) ;
		break ;

	case VS_K_pl_Cut_Off		:
		/*
		 * Cut-off should be superior to thickness.
		 */
		text = GET_FIELD_TEXT() ;
		vs$unit_to_system(	msg	= &msg,
					unit	= text,
					p_value	= &val ) ;
		_FREE( text ) ;
		me->flag &= ~VS_K_deflt_cutoff ;
		UPDATE_CUTOFF( val ) ;
		break ;

	case VS_K_pl_Offset		:
		p_value = &me->offset ;

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
		break ;

	case VS_K_pl_Name		:
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

					VSfi_msg( form_ptr,  bufTel ) ;

					me->flag |= VS_K_message_set ;
				
					FILL_ASCII_FIELD( me->basename ) ;
				} else {
					strcpy( me->basename, text ) ;
				}
			} else *me->basename = '\0' ;
			_FREE( text ) ;
		} 
		break ;

	case VS_K_pl_Change_Number	:
		/*
		 * Change request number must be >= 0.
		 */
		FIfld_get_value( form_ptr, gadget_label, 0, 0, &value,
				 &sel_flag, &r_pos ) ;	

		if( value < 0. )	FILL_VALUE_FIELD( me->change_number ) ;
		else			me->change_number = (int) value ;
		break ;

	case VS_K_pl_Fireproofing	:
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

	case VS_K_pl_Stock_Number	:
		_FREE( me->stock )	; me->stock	= GET_FIELD_TEXT() ;
		break ;

	case VS_K_pl_Source		:
		_FREE( me->source )	; me->source	= GET_FIELD_TEXT() ;
		break ;

	case VS_K_pl_Approval_Status	:
		_FREE( me->approval_status ) ; 
	        me->approval_status 	= GET_FIELD_TEXT() ;
		break ;

	case VS_K_pl_Construction_Status: 
		_FREE( me->construction_status ) ; 
	        me->construction_status = GET_FIELD_TEXT() ;
		break ;
		
	case VS_K_pl_Member_Class	:
		me->clsIndex = VSgetSelectedRow( form_ptr, gadget_label ) ;
		om$send(msg	= message VSfmplatCmd.getCnstDefaults(),
			targetid= my_id ) ;
		break ;

	case VS_K_pl_Member_Type	:
		me->typIndex = VSgetSelectedRow( form_ptr, gadget_label ) ;
		break ;

	case VS_K_pl_Orientation	:
		om$send(msg	= message VSfmplatCmd.display_support_normal(
									 GRhe ),
			targetid= my_id ) ;
		me->orientation = (int) value == 1 ? VS_K_USE_REV_NORM
						   : VS_K_USE_NAT_NORM ;
		om$send(msg	= message VSfmplatCmd.display_support_normal(
									 GRhd ),
			targetid= my_id ) ;
		break ;

	case VS_K_pl_Comments		:
		_FREE( me->notes )	;
		me->notes = VSfld_get_lines( form_ptr, gadget_label ) ;
		break ;
		
 	case VS_K_pl_Definition		:
		FIgrp_add_to_group( form_ptr,
				    VS_K_pl_Grp_Comments,
				    VS_K_pl_Grp_Definition ) ;
 		DISPLAY_GROUP( Definition ) ;
 		break ;
 		
 	case VS_K_pl_Plate_Manipulation :
		FIgrp_add_to_group( form_ptr,
				    VS_K_pl_Grp_Comments,
				    VS_K_pl_Grp_Manipulation ) ;
 		DISPLAY_GROUP( Manipulation ) ;
 		break ;
 	
 	case VS_K_pl_Material_Take_Off 	:
 		DISPLAY_GROUP( MTO ) ;
 		break ;
 		
 	case VS_K_pl_User_Attributes 	:
 		DISPLAY_GROUP( UA ) ;
 		break ;
 		
 	case VS_K_pl_Mcf_User_Attributes:
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

	case VS_K_pl_Copy_Params	:
		/*
		 * WARNING: Cannot identify a plate if the system is in the
		 * accept process of locate filter.
		 */
		 
		if( me->stack.num_entries == 0 ) {
			dp$erase_hilite( msg = &msg ) ;
			response= VS_K_LOAD_ATTR ;
			ex$putque( msg = &msg, response = &response ) ;
		}
 		break ;

	default				:
		break ;
	}
	
#undef TELLUSER
#undef FILL_ASCII_FIELD
#undef FILL_VALUE_FIELD
#undef SET_LIST_SELECT
#undef GET_FIELD_TEXT
#undef QUERY_RDB
#undef UPDATE_CUTOFF
#undef DISPLAY_GROUP 

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method enable_form( long * msg ) {

	char	*form = me->fm_ptr ;
	long 	msg ;

#if vdsDEBUG
	printf(">>> VSplplatCmd.enable_form\n");
#endif

	om$send( msg = message VSfmplatCmd.enable_form( &msg ),
		 mode	= OM_e_wrt_message,
		 targetid = my_id ) ;

	if( me->flag & VS_K_no_object_located )
	     vs$g_disable_gadgets( form = form,
				   list = `VS_K_pl_Dismiss_Execute,
					   VS_K_pl_Execute,
					   VS_K_pl_Orientation,
					   -1` ) ;
	else vs$g_enable_gadgets( form = form,
			          list = `VS_K_pl_Dismiss_Execute,
					  VS_K_pl_Execute,
					  VS_K_pl_Orientation,
					  -1` ) ;
	
#if vdsDEBUG
	printf("@@@ VSplplatCmd.enable_form\n");
#endif
	return OM_S_SUCCESS ;

} /* method enable_form */
/*----------------------------------------------------------------------------*/
method load_attributes_from_plate( long *msg ) {
	
	char			*form = me->fm_ptr ;
	long			sts ;
	struct GRid		LocatedPlate ;
	VSpartAttr		attr ;
	VSplateAttr		info ;

#define SET_LIST_SELECT( gadget, index )\
	FIfld_set_list_select( form, (gadget), (index), 0, TRUE ) 
	
	LocatedPlate = me->event1.located_object[0].located_obj ;
	
	attr.Iwant	= VS_m_All ;
	attr.specific	= (void *) &info ;
	sts = om$send( msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
		       targetid = LocatedPlate.objid,
		       targetos = LocatedPlate.osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	me->change_number	= attr.mto.chgnum ;
	me->stock		= VSstrdup( attr.mto.stock	) ;
	me->source		= VSstrdup( attr.mto.source	) ;
	
	om$send( msg      = message VSqryRdbCmd.freeRDBdata(),
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
	me->orientation 	= info.orientation ;
	me->actPar		= info.thickness ;
	me->cut_off		= info.cut_off ;
	me->offset		= info.offset ;
		
	if( me->cut_off == me->actPar ) me->flag |= VS_K_deflt_cutoff ;
	else				me->flag &= ~VS_K_deflt_cutoff ;

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
			      VS_rdb_MAXPLTYPES,
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

	om$send( msg	= message VSfmplatCmd.QueryRDB( &sts,
							VS_m_mat |
							VS_m_fam |
							VS_m_grd | 
							VS_m_prt | 
							VS_m_par,
							FALSE ),
		 targetid = my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;
	
	SET_LIST_SELECT( VS_K_pl_Material_Type 		, me->matIndex ) ;
	SET_LIST_SELECT( VS_K_pl_Material_Grade 	, me->grdIndex ) ;
	SET_LIST_SELECT( VS_K_pl_Plate_Type		, me->famIndex ) ;
	SET_LIST_SELECT( VS_K_pl_Thickness		, me->prtIndex ) ;
	SET_LIST_SELECT( VS_K_pl_Member_Class		, me->clsIndex ) ;
	SET_LIST_SELECT( VS_K_pl_Member_Type		, me->typIndex ) ;

	wrapup :
	
		/*
		 * Unhilight plate located.
		 */
		vs$bulk_display(	
			grids	= &LocatedPlate,
			theEnv	= &me->event1.located_object[0].module_info,
			dpmode	= GRhe ) ;
			 
		/*
		 * Abort command on memory allocation failure.
		 */
		if( !me->stock || !me->source || !me->notes ||
		    !me->approval_status || !me->construction_status) {
			_FREE( me->stock		) ;
			_FREE( me->source	 	) ;
			_FREE( me->notes		) ;
			_FREE( me->approval_status 	) ;
			_FREE( me->construction_status 	) ;
			*msg = MSFAIL ;
		}
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

#undef SET_LIST_SELECT
	
		return OM_S_SUCCESS ;

} /* method load_attributes_from_plate */
/*----------------------------------------------------------------------------*/

end implementation VSplplatCmd ;








