/* $Id: VSmdbeamCmdi.I,v 1.1.1.1 2001/01/04 21:10:23 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSmdbeamCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmdbeamCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/09  21:49:40  pinnacle
# TR179800861
#
# Revision 1.2  1998/01/21  18:59:36  pinnacle
# TR179702512
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/21/98  ah      Added header
 * 01/21/98  ah	     TR179700969 Cardinal Point 
 * 01/21/98  ah      TR179702512 Web Alignment Problem
 * 04/09/98  ah      TR179800861 Changing name should not change directory
 ***************************************************************************/

class implementation VSmdbeamCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "COBmacros.h"
#include "growner.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ACcheckin.h"
#include "vsglobalmsg.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsglobals.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsoptdef.h"
#include "vsbeam.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vsicondef.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "vscmdmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsformmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsRDBproto.h"
#include "vsfnditmary.h"
#include "vsformproto.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

#include "VDobj.h"

from GRgraphics import	GRconstruct,
                        GRchgname;

from GRvg	import	GRgetattr,
			GRgetname,
			GRputattr ,
			GRgetsymb ;
from NDnode	import	NDchange_node ;
from ACncpx	import	ACchg_STATE,
			ACget_STATE ;
from ACdb_info	import	ACget_db_info ,
			ACset_db_info ;
from ACncpx	import	ACget_NV_rep ;
from VSpart	import	VSgetUserEditableAttr,
			VSgetSupports ;
from VSfeature	import	VSregenerate ;
from VSbeam	import	VSgetXdirectionForCrossSectionCS ;

extern long VSbeamGetState(struct GRid *beamId, int *state);

/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

	enum GRdpmode	dpmode ;

	/*
	 * Delete beam section.
	 */
	if( !( me->flag & VS_K_first_inter_displ ) ) {

		if(     ( me->flag & VS_K_beam_constructed )
		    || !( me->flag & VS_K_modify_form ) ) dpmode = GRhe ;
		else					  dpmode = GRbehe ;

		vs$bulk_display( dpmode = dpmode, count = 1, objenvs = &me->BeamSect ) ;

		vs$bulk_delete( count  = 1, objenvs= &me->BeamSect ) ;
	}

	me->flag |= ( VS_K_no_object_located	|
		      VS_K_first_inter_displ	 ) ;
	me->flag &= ~( VS_K_modify_form 	|
		       VS_K_change_usr_attr	|
		       VS_K_beam_constructed	 ) ;

	me->number_of_beams = 0 ;
	me->ActBeam	    = 0 ;

	me->nameModified = FALSE ;

	FIfld_set_value( me->fm_ptr, VS_K_bm_Number_Of_Beams, 0, 0,
			 (double) me->number_of_beams, FALSE ) ;

	FIf_set_collapse_symbol( me->fm_ptr,
				 VS_K_CLP_SYM_FILE,
				 VS_K_CLP_ModBeam ) ;
	me->detailCard	= FALSE ;

	FIg_add_to_group( me->fm_ptr,
			  VS_K_xs_Position,
                          VS_K_bm_Grp_Manipulation ) ;

	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method setFormTitle() {

	if( !( me->flag & VS_K_init_failed ) ) {
		ex$message(	field	= ERROR_FIELD,
				in_buff = "" ) ;
		VSg_replace( me->fm_ptr,
			     VS_K_bm_Placement,
			     VS_K_bm_Modification ) ;
	}

	return OM_S_SUCCESS ;

} /* method setFormTitle */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	long			msg ;
	enum GRdpmode		dpmode ;

	om$send( msg	= message VSfmbeamCmd.wakeup( pos ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;

	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	om$send( msg	= message VSmdbeamCmd.hilight_elem( &msg ),
		 targetid = my_id ) ;

	/*
	 * Hilight section of beam.
	 */
	if( !(me->flag & VS_K_first_inter_displ) ) {
		/*
		 * Test if beam section already exists.
		 */
		if( om$is_objid_valid( objid = me->BeamSect._objid,
				       osnum = me->BeamSect._osnum )
			!= OM_S_SUCCESS ) {
			/* Beam section was deleted - probably by naughty user */
			 me->flag |= VS_K_first_inter_displ ;
			 om$send( msg	= message VSplbeamCmd.inter_display( &msg ),
				 targetid = my_id ) ;
		} else {
			if( !(me->flag & VS_K_modify_form) ) dpmode = GRhd ;
			else dpmode = GRbehd ;

			vs$bulk_display( dpmode = dpmode,
					 count	= 1,
					 objenvs= &me->BeamSect ) ;
		}
	}

	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	/*
	 * Disable Gadget Dismiss.
	 */
	if( !( me->flag & VS_K_init_failed ) ) {
		if( me->flag & VS_K_no_object_located )
			FIg_disable( me->fm_ptr, VS_K_bm_Dismiss ) ;
	}

	om$send( msg	= message VSfmbeamCmd.sleep( pos ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ) {

	enum GRdpmode		dpmode ;

	if( me->flag & VS_K_init_failed ) return OM_S_SUCCESS ;

	/*
	 * Delete beam section.
	 */
	if( !(me->flag & VS_K_first_inter_displ) ) {

		if( ( me->flag & VS_K_beam_constructed) ||
		   !( me->flag & VS_K_modify_form) )	dpmode = GRhe ;
		else					dpmode = GRbehe ;

		vs$bulk_display( dpmode = dpmode,
				 count	= 1,
				 objenvs= &me->BeamSect ) ;

		vs$bulk_delete( count  = 1,
				objenvs= &me->BeamSect ) ;
	}

	om$send( msg	= message VSfmbeamCmd.delete( f_defer_flag ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method store_beam( int *sts ) {

	struct GRlc_info	*toStore = me->event1.located_object ;

	me->ret = om$send(
			msg	= message VSlocateCmd.addLocObj(
							&toStore->located_obj,
							&toStore->module_info,
							me->number_of_beams ),
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

	return OM_S_SUCCESS ;

} /* method store_beam */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {

	long			sts ;
	struct GRobj_env	beam ;
	VSpartAttr		attr ;
	VSbeamAttr		info ;
	char			pathName[DI_PATH_MAX] ;

	me->modAttr = 0 ;

	sts = om$send( msg  = message VSlocateCmd.getLocObjAtIndex( msg,
								    me->ActBeam,
								    &beam ),
		       targetid = my_id ) ;

	if( sts == OM_E_INVINDEX ) {
		me->flag |= VS_K_no_attributes ;
		me->ret = VS_K_ACT_SUCCESS ;
		return OM_S_SUCCESS ;
	}
	me->flag &= ~VS_K_no_attributes ;

	attr.Iwant	= VS_m_All ;

	attr.specific	= (void *) &info ;

	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
			targetid= beam._objid,
			targetos= beam._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

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

	me->approval_status	= VSstrdup( attr.info.apprvstat ) ;
	me->construction_status = VSstrdup( attr.info.conststat ) ;
	me->fireproofing	= attr.info.fpthickness ;
	me->notes		= VSstrdup( attr.info.notes	) ;
	me->X_offset		= info.xoff ;
	me->Y_offset		= info.yoff ;
	me->rotation		= info.rotat ;
	me->reference_point	= info.card ;
	me->symmetry		= info.sym ;

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
	 * Retrieve user attributes.
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
		me->usrNamList	= NULL ;
		me->usrSynList	= NULL ;
	}
	/*
	 * Set the toggle according to the detaildCard value.
	 */

/* TR179700969
 * TR179702512 
 * Take origin and cardinal point into account.
 * I am not sure if this method ever gets called for non-src beams
 * But if it does, then we are covered
*/
  {	
    int state;
    
    VSbeamGetState(&beam.obj_id,&state);

    if( state & VS_m_NdState )  me->detailCard = TRUE ;
    else                        me->detailCard = FALSE;
  }

	FIg_set_state(me->fm_ptr, VS_K_xs_Position, me->detailCard );
	/*
	 * Get name.
	 */
	sts = om$send(	msg	= message GRvg.GRgetname( msg, pathName ),
			targetid= beam._objid,
			targetos= beam._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetname", wrapup ) ;
	if( *pathName ) {
		di$split(	pathname	= pathName,
				dirname 	= me->beamDir,
				name		= me->basename ) ;
	} else {
		*me->basename = *me->beamDir = '\0' ;
	}
	me->directory = me->beamDir ;

	/*
	 * Retrieve section parameters.
	 */
	om$send( msg	= message VSfmbeamCmd.QueryRDB( &sts, VS_m_prt |
							VS_m_par, FALSE ),
		 targetid = my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	wrapup :
		/*
		 * Abort command on memory allocation failure.
		 */
		if( !me->stock || !me->source || !me->notes ||
		    !me->approval_status || !me->construction_status ) {
			_FREE( me->stock		) ;
			_FREE( me->source		) ;
			_FREE( me->notes		) ;
			_FREE( me->approval_status	) ;
			_FREE( me->construction_status	) ;
			*msg = MSFAIL ;
		}
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method load_attributes */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	long			sts,
				msg ;
	int			nbBeams ;
	struct GRobj_env	fence,
				*Beams ;

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count 	= &nbBeams,
				p_content	= &Beams,
				response	= me->response,
				response_data	= me->response_data ) ;

	if( *me->response != EX_DATA || !nbBeams ) {
		me->ret = VS_K_NO_FENCE ; goto wrapup ;
	}

	if( msg & 1 ) {
		int h ;

		sts = MSSUCC ;

		for( h = 0 ; h < nbBeams && (sts & 1) ; h++ ) {
			sts = om$send(
				msg	= message VSlocateCmd.addLocObj(
							&Beams[h]._grid,
							&Beams[h].mod_env,
							me->number_of_beams ),
				targetid= my_id ) ;
			me->number_of_beams++ ;
		}
		_FREE( Beams ) ;

		if( !me->number_of_beams ) {
			me->ret = VS_K_NO_FENCE ;
			goto wrapup ;
		}
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
	} else {
		sts = OM_W_ABORT ;
	}

	me->ret = sts & 1 & msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmbeam_labels[] = {
	{ VS_K_bm_Dismiss_Execute	, TRUE },
	{ VS_K_bm_Execute		, TRUE },
	{ VS_K_bm_Revert		, TRUE },
	{ VS_K_bm_Dismiss		, TRUE },
	{ VS_K_bm_Roll_Through		, TRUE },
	{ VS_K_bm_Message		, TRUE },
	{ VS_K_bm_Material_Type 	, TRUE },
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
	{ VS_K_bm_Change_Number 	, TRUE },
	{ VS_K_bm_Number_Of_Beams	, TRUE },
	{ VS_K_bm_Comments		, TRUE },
	{ VS_K_bm_Display_Ratio 	, TRUE },
	{ VS_K_bm_X_Offset		, TRUE },
	{ VS_K_bm_Y_Offset		, TRUE },
	{ VS_K_xs_Position		, TRUE },
	{ VS_K_bm_Rotation		, TRUE },
	{ VS_K_bm_Section_Length	, TRUE },
	{ VS_K_bm_Section_Area		, TRUE },
	{ VS_K_bm_Top_Left		, TRUE },
	{ VS_K_bm_Center_Left		, TRUE },
	{ VS_K_bm_Bot_Left		, TRUE },
	{ VS_K_bm_Top_Middle		, TRUE },
	{ VS_K_bm_Bot_Mid		, TRUE },
	{ VS_K_bm_Top_Right		, TRUE },
	{ VS_K_bm_Center_Middle 	, TRUE },
	{ VS_K_bm_Center_Right		, TRUE },
	{ VS_K_bm_Bot_Right		, TRUE },
	{ VS_K_bm_No_Sym		, TRUE },
	{ VS_K_bm_X_Sym 		, TRUE },
	{ VS_K_bm_Y_Sym 		, TRUE },
	{ VS_K_bm_XY_Sym		, TRUE },
	{ VS_K_bm_Copy_Params		, TRUE },
	{ VS_K_bm_Parameters		, TRUE },
	{ VS_K_bm_Definition		, TRUE },
	{ VS_K_bm_Section_Manipulation	, TRUE },
	{ VS_K_bm_Material_Take_Off	, TRUE },
	{ VS_K_bm_User_Attributes	, TRUE },
	{ VS_K_bm_Mcf_User_Attributes	, TRUE },
	{ -1				, TRUE }	/* End-of-list flag */
} ;
	long				sts ;
	struct GRobj_env		beam ;
	unsigned long			attrMask,
					type ;
	register struct VSgadget	*l ;

#define NO_EDIT( attr ) !( attrMask & VS_m_##attr )
#define SET_NO_EDIT( gadget )\
	VSsetGadgetModifiable(	VS_Ga_fmbeam_labels,\
				VS_K_bm_##gadget,\
				FALSE )

	for( l = VS_Ga_fmbeam_labels ; l->label != -1 ; l++ ) {
		l->touchable = TRUE ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
							msg,
							me->ActBeam,
							&beam ),
			targetid= my_id ) ;
	if( sts == OM_S_SUCCESS ) {
		sts  = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attrMask ),
				targetid= beam._objid,
				targetos= beam._osnum ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;
		if( !attrMask ) {
			/*
			 * Beam not editable at all.
			 */
			for( l = VS_Ga_fmbeam_labels ; l->label != -1 ; l++ ) {
				l->touchable = FALSE ;
			}
			om$send(msg	= message VSfmbeamCmd.tellUser(
							VS_gW_PartNtEdit ),
				targetid= my_id ) ;
		} else {
			if( NO_EDIT( MatType		) ) {
				SET_NO_EDIT( Material_Type	) ;
			}
			if( NO_EDIT( MatGrade		) ) {
				SET_NO_EDIT( Material_Grade	) ;
			}
			if( NO_EDIT( Notes		) ) {
				SET_NO_EDIT( Comments		) ;
			}
			if( NO_EDIT( PartFam		) ) {
				SET_NO_EDIT( Shape_Name 	) ;
			}
			if( NO_EDIT( PartNum		) )
				SET_NO_EDIT( Section_Name	) ;

			if( NO_EDIT( Symmetry		) ) {
				SET_NO_EDIT( X_Sym		) ;
				SET_NO_EDIT( Y_Sym		) ;
				SET_NO_EDIT( No_Sym		) ;
				SET_NO_EDIT( XY_Sym		) ;
			}

			if( NO_EDIT( cardPnt		) ) {
				SET_NO_EDIT( Top_Left		) ;
				SET_NO_EDIT( Top_Middle 	) ;
				SET_NO_EDIT( Top_Right		) ;
				SET_NO_EDIT( Center_Left	) ;
				SET_NO_EDIT( Center_Middle	) ;
				SET_NO_EDIT( Center_Right	) ;
				SET_NO_EDIT( Bot_Left		) ;
				SET_NO_EDIT( Bot_Mid		) ;
				SET_NO_EDIT( Bot_Right		) ;
			}

			if( NO_EDIT( xOffset		) )
				SET_NO_EDIT( X_Offset		) ;

			if( NO_EDIT( yOffset		) )
				SET_NO_EDIT( Y_Offset		) ;

			if( NO_EDIT( RotAngle		) )
				SET_NO_EDIT( Rotation		) ;

			if( NO_EDIT( MtoStk		) ) {
				SET_NO_EDIT( Stock_Number	) ;
			}
			if( NO_EDIT( MtoSrc		) )
				SET_NO_EDIT( Source		) ;

			if( NO_EDIT( MbrClass		) )
				SET_NO_EDIT( Member_Class	) ;

			if( NO_EDIT( MbrType		) )
				SET_NO_EDIT( Member_Type	) ;

			if( NO_EDIT( AppStat		) )
				SET_NO_EDIT( Approval_Status	) ;

			if( NO_EDIT( CstStat		) )
				SET_NO_EDIT( Construction_Status) ;

			if( NO_EDIT( FpThck		) )
				SET_NO_EDIT( Fireproofing	) ;

			if( NO_EDIT( ChgNum		) )
				SET_NO_EDIT( Change_Number	) ;

			if( NO_EDIT( UsrAttr		) )
				SET_NO_EDIT( Mcf_User_Attributes) ;

			/*
			 * We do not want the name to be changed from this
			 * form.
			 */
			if( me->number_of_beams != 1 ) SET_NO_EDIT( Name ) ;
		}
	}

	*msg = MSSUCC ;
	*list = VS_Ga_fmbeam_labels ;

	wrapup :
		return OM_S_SUCCESS ;

#undef NO_EDIT
#undef SET_NO_EDIT

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method construct_beam( long *msg ) {

	long			sts ;
	VSpartAttr		part ;
	VSbeamAttr		beam ;
	int			i,
				count,
				needRecompute ;
	struct GRobj_env	*beamList = NULL ;
	struct GRid		cachedPart ;
	struct ACdb_info	dbInfo ;
	int			quantity ;

	ex$message( msgnumb	  = VS_gI_Processing,
		    justification = CENTER_JUS ) ;

	/*
	 * Get parents.
	 */
	beamList = _MALLOC( me->number_of_beams, struct GRobj_env ) ;
	if( !beamList ) {
		sts  = OM_W_ABORT ; *msg = EMS_E_NoDynamicMemory ; goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg,
							me->number_of_beams,
							beamList ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Change name of beam 
	 */
	 if( me->number_of_beams == 1 )
         {
		if ( me->nameModified ) 
		{
		  // TR179800861
		  sts = vdobj$ChgName(msg = msg, objOE = &beamList[0], name = me->basename, keepDir = 1);
		  /*
		    sts = om$send(  msg = message GRgraphics.GRchgname (
		    msg,
		    &beamList[0].mod_env,
		    me->basename),
		    targetid = beamList[0]._objid,
		    targetos = beamList[0]._osnum ) ;
				 */
                }
	 }

	/*
	 * Will only set modified attributes if one beam is located else all
	 * attributes will set for each beams.
	 */
	if( me->number_of_beams == 1 )	part.Iwant = me->modAttr ;
	else				part.Iwant = VS_m_All ;

	if( part.Iwant == VS_m_All ) {
		me->modAttr = VS_m_PartNum ;
		me->flag   |= VS_K_change_usr_attr ;
	}

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
			options 	= part.Iwant,
			xOffset 	= me->X_offset,
			yOffset 	= me->Y_offset,
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
			partAttr	= &part,
			beamAttr	= &beam ) ;
	/*
	 * Load beam from RDB if something changed.
	 */
	if( me->modAttr & VS_m_PartNum ) {
		vs$load_part_from_RDB(	msg		= msg,
					material	= me->actMat,
					family		= me->actFam,
					part		= me->actPrt,
					osnum		= me->cstEnv._MD_OS,
					object		= &cachedPart ) ;
		__CheckRC( 1, *msg, "vs$load_part_from_RDB", wrapup ) ;
	}

	needRecompute = me->modAttr & (    VS_m_PartNum
					 | VS_m_xOffset
					 | VS_m_yOffset
					 | VS_m_RotAngle
					 | VS_m_cardPnt
					 | VS_m_Symmetry ) ;

	if( me->flag & VS_K_change_cnst_type ) needRecompute = TRUE ;

	/*
	 * Unhighlight section beam.
	 */

	vs$bulk_display( count	= 1,
			 dpmode = GRhe,
			 objenvs= &me->BeamSect ) ;

	count = me->number_of_beams ;

	needRecompute = TRUE ;
	for( i = 0 ; i < count ; i++ ) {

		if( me->detailCard ){

			sts = om$send(msg = message ACncpx.ACchg_STATE(  
								VS_m_NdState,
								VS_m_NdState ),
				targetid= beamList[i]._objid,
				targetos= beamList[i]._osnum );
		} else {
			sts = om$send(msg = message ACncpx.ACchg_STATE( 
								VS_m_NdState,
								ND_DEFAULT ),
                                targetid= beamList[i]._objid,
                                targetos= beamList[i]._osnum );
		}
							
		sts = om$send(	msg	= message GRvg.GRputattr( msg,
							(char *) &part ),
				targetid= beamList[i]._objid,
				targetos= beamList[i]._osnum ) ;

		if( !( sts & 1 & *msg ) ) { *msg = MSFAIL ; goto wrapup ; }

		/*
		 * Change quantity according to family name.
		 */
		om$send( msg	  = message ACdb_info.ACget_db_info( msg,
								     &dbInfo ),
			 targetid = beamList[i]._objid,
			 targetos = beamList[i]._osnum ) ;

		quantity = *me->actFam != '#'	? STRUCT_BEAM_OBJ
						: STRUCT_PLATE_OBJ  ;

		if( quantity != dbInfo.quantity ) {

			dbInfo.quantity = quantity ;
			om$send( msg	  = message ACdb_info.ACset_db_info(
								      msg,
								      &dbInfo ),
				 targetid = beamList[i]._objid,
				 targetos = beamList[i]._osnum ) ;
		}

		if( needRecompute ) {
			/*
			 * Put beam to batch Q.
			 */
			sts = om$send(
				msg	= message VSfeature.VSregenerate(),
				targetid = beamList[i]._objid,
				targetos = beamList[i]._osnum ) ;

		}
		/*
		 * Decrease beam count.
		 */
		FIfld_set_value( me->fm_ptr, VS_K_bm_Number_Of_Beams, 0, 0,
				 (double) count -1 -i, FALSE ) ;
	}

	if( count ) {
		int mode ;
		nd$mod_batch(	request 	= ND_GET,
				p_ret_mode	= &mode ) ;
		if( mode != ND_DEFER ) nd$exec_batch() ;
	}

	me->flag |= VS_K_beam_constructed ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		if( me->ret == VS_K_ACT_SUCCESS )
				me->flag |= VS_K_no_attributes ;

		_FREE( beamList ) ;
		ex$message(	field	= ERROR_FIELD,
				in_buff = "" ) ;

		return OM_S_SUCCESS ;

} /* method construct_beam */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long			sts ;
	struct GRobj_env	beam ;

	switch( gadget_label ) {
	case VS_K_bm_Dismiss_Execute	:
	case VS_K_bm_Execute		:
	case VS_K_bm_Revert		:
	case VS_K_bm_Roll_Through	: break ;
	default :
		sts = om$send(	msg	= message VSplbeamCmd.form_notification(
						form_label, gadget_label,
						value, form_ptr ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	if( ( gadget_label != VS_K_bm_Execute			) &&
	    ( gadget_label != VS_K_bm_Dismiss_Execute		) &&
	    ( gadget_label != VS_K_bm_Revert			) &&
	    ( gadget_label != VS_K_bm_Dismiss			) &&
	    ( gadget_label != VS_K_bm_Definition		) &&
	    ( gadget_label != VS_K_bm_Section_Manipulation	) &&
	    ( gadget_label != VS_K_bm_User_Attributes		) &&
	    ( gadget_label != VS_K_bm_Material_Take_Off 	) &&
	    ( gadget_label != VS_K_bm_Roll_Through		) )
				me->flag |= VS_K_modify_form ;

	switch( gadget_label ) {

	int	response ;
	long	msg ;

	case VS_K_bm_Dismiss_Execute	:
		/*
		 * Modify beam(s), then exit command.
		 */
		response = TERMINATE ;
		goto EXECUTE ;

	case VS_K_bm_Execute		:
		/*
		 * Construct beams, then go to state "start".
		 */
		response = EX_BACK_UP ;
	EXECUTE :
		if( (me->flag & VS_K_modify_form) || me->number_of_beams > 1 ) {
			om$send(msg	= message VSplbeamCmd.construct_beam(
									&msg ),
				targetid= my_id ) ;
			ex$putque( msg = &msg, response = &response ) ;
		} else {
			om$send(msg	= message VSplbeamCmd.tellUser(
								VS_gI_BmNoMod ),
				targetid= my_id ) ;
			FIg_set_state_off( form_ptr, gadget_label ) ;
		}
		break ;

	case VS_K_bm_Revert		:
		response = EX_BACK_UP ;
		om$send(msg	= message VSqryRdbCmd.freeRDBdata(),
			targetid= my_id ) ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_bm_Roll_Through	:
		/*
		 * Delete profile of beam.
		 */
		vs$bulk_display( dpmode = GRhe,
				 count	= 1,
				 objenvs= &me->BeamSect ) ;

		vs$bulk_delete( count = 1, objenvs= &me->BeamSect ) ;

		/*
		 * Highlight old active beam.
		 */
		om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						&msg, me->ActBeam, &beam ),
			targetid= my_id ) ;

		vs$bulk_display( count	= 1, dpmode = GRhd, objenvs = &beam ) ;

		me->ActBeam++ ;
		if( me->ActBeam == me->number_of_beams ) me->ActBeam = 0 ;

		/*
		 * Load attributes from new active beam and fill form.
		 */
		om$send(msg	= message VSmdbeamCmd.load_attributes( &msg ),
			targetid= my_id ) ;
		om$send(msg	= message VSmdbeamCmd.fill_form( &msg ),
			targetid= my_id ) ;

		/*
		 * Unhighlight new active beam.
		 */
		om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						&msg, me->ActBeam, &beam ),
			targetid= my_id ) ;

		vs$bulk_display( count = 1, dpmode = GRhe, objenvs = &beam ) ;

		me->flag |= VS_K_first_inter_displ ;
		me->flag &= ~VS_K_modify_form ;

		/*
		 * Show new section beam on window and form.
		 */
		om$send(msg	= message VSmdbeamCmd.inter_display( &msg ),
			targetid= my_id ) ;
		om$send(msg	= message VSmdbeamCmd.draw_section_on_form(
									&msg ),
			targetid= my_id ) ;
		break ;

	case VS_K_bm_Material_Type	: me->modAttr |= VS_m_MatType	;
	case VS_K_bm_Material_Grade	: me->modAttr |= VS_m_MatGrade	;
	case VS_K_bm_Shape_Name 	: me->modAttr |= VS_m_PartFam	;

	case VS_K_bm_Section_Name	: me->modAttr |= VS_m_PartNum	; break;
	case VS_K_bm_X_Sym		:
	case VS_K_bm_Y_Sym		:
	case VS_K_bm_XY_Sym		:
	case VS_K_bm_No_Sym		: me->modAttr |= VS_m_Symmetry	; break;
	case VS_K_bm_Top_Left		:
	case VS_K_bm_Top_Middle 	:
	case VS_K_bm_Top_Right		:
	case VS_K_bm_Center_Left	:
	case VS_K_bm_Center_Middle	:
	case VS_K_bm_Center_Right	:
	case VS_K_bm_Bot_Left		:
	case VS_K_bm_Bot_Mid		:
	case VS_K_bm_Bot_Right		: me->modAttr |= VS_m_cardPnt	; break;
	case VS_K_bm_X_Offset		: me->modAttr |= VS_m_xOffset	; break;
	case VS_K_bm_Y_Offset		: me->modAttr |= VS_m_yOffset	; break;
	case VS_K_bm_Rotation		: me->modAttr |= VS_m_RotAngle	; break;

	case VS_K_bm_Stock_Number	: me->modAttr |= VS_m_MtoStk	; break;
	case VS_K_bm_Source		: me->modAttr |= VS_m_MtoSrc	; break;

	case VS_K_bm_Member_Class	: me->modAttr |= VS_m_MbrClass	; break;
	case VS_K_bm_Member_Type	: me->modAttr |= VS_m_MbrType	; break;
	case VS_K_bm_Comments		: me->modAttr |= VS_m_Notes	; break;

	case VS_K_bm_Copy_Params	: me->modAttr = VS_m_All	; break;

	case VS_K_bm_Approval_Status	: me->modAttr |= VS_m_AppStat	; break;
	case VS_K_bm_Construction_Status: me->modAttr |= VS_m_CstStat	; break;
	case VS_K_bm_Fireproofing	: me->modAttr |= VS_m_FpThck	; break;
	case VS_K_bm_Change_Number	: me->modAttr |= VS_m_ChgNum	; break;

	case VS_K_bm_Mcf_User_Attributes: me->modAttr |= VS_m_UsrAttr	; break;
	
	case VS_K_bm_Name		: me->nameModified = TRUE  	; break;

	default 			: break ;
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method inter_display( long *msg ) {

	struct GRobj_env	beamLocated ;
	VSsuppList		support ;
	int			suppCount,
				haveDir ;
	IGRvector		xDir ;
	enum GRdpmode		dpmode ;
	struct GRsymbology	Symb ;
	struct GRvg_construct	cstargs ;
	VSdspRep		rep ;

	me->surfaceOfCS._objid = NULL_OBJID ;

	ex$message( msgnumb	  = VS_gI_Processing,
		    justification = CENTER_JUS ) ;

	if( !(me->flag & VS_K_first_inter_displ) ) {
		/*
		 * Delete old section ( should be done when interactive
		 * display does not come from wakeup ).
		 */
		vs$bulk_display( dpmode = GRhe,
				 count	= 1,
				 objenvs= &me->BeamSect ) ;
		vs$bulk_delete( count = 1, objenvs= &me->BeamSect ) ;
	}

	/*
	 * Get active beam located.
	 */
	me->ret = om$send( msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &beamLocated ),
			   targetid = my_id ) ;

	/*
	 * Retrieve parents of the active beam.
	 */
	me->ret = om$send(msg	= message VSpart.VSgetSupports(
							msg,
							&beamLocated.mod_env,
							&suppCount,
							support ) ,
			   targetid= beamLocated._objid,
			   targetos= beamLocated._osnum ) ;
	__CheckRC( me->ret, *msg, "VSpart.VSgetSupports", wrapup ) ;

	me->surfaceOfCS = support[0] ;

	me->ret = om$send(	msg	= message GRvg.GRgetsymb( msg, &Symb ),
				targetid= beamLocated._objid,
				targetos= beamLocated._osnum ) ;
	__CheckRC( me->ret, *msg, "GRvg.GRgetsymb", wrapup ) ;

	me->BeamSect.mod_env = me->cstEnv ;

	vs$fill_cnst_list(	Env_info	= &me->cstEnv,
				Display 	= &Symb.display_attr,
				Level		= Symb.level,
				Cnst_list	= cstargs,
				Properties	= GRIS_DISPLAYABLE,
				Msg		= msg ) ;

	/*
	 * Retrieve representation of the active beam located.
	 */
	om$send(msg	= message ACncpx.ACget_NV_rep( &rep ),
		targetid= beamLocated._objid,
		targetos= beamLocated._osnum ) ;

	/*
	 * Get X direction of cross section.
	 */
	me->ret = om$send( msg	    =
		      message VSbeam.VSgetXdirectionForCrossSectionCS( msg,
								       &haveDir,
								       xDir ),
			   targetid = beamLocated._objid,
			   targetos = beamLocated._osnum ) ;

	if( !( me->ret & 1 & *msg ) ) {
		*msg = MSFAIL ; me->number_of_beams = 0 ; goto wrapup ;
	}

	/*
	 * Construct section beam.
	 */
	me->ret =
	vs$place_cross_section( msg	= msg,
				xMat	= me->actMat,
				xFam	= me->actFam,
				xName	= me->actPrt,
				searchOS= me->cstEnv.md_id.osnum,
				xOffset = me->X_offset,
				yOffset = me->Y_offset,
				rotation= me->rotation,
				profOpt = &me->detailCard,
				cardinal= (enum VScardinal_point)
						me->reference_point,
				symmetry= (enum VSsymmetry)
						me->symmetry,
				surface = support + 0,
				axis	= support + 1,
				xDir	= haveDir ? xDir : NULL,
				dspRatio= me->display_ratio,
				dspRep	= rep,
				cst	= &cstargs,
				xSect	= &me->BeamSect._grid ) ;
	if( !( me->ret & 1 & *msg ) ) {
		*msg = MSFAIL ; me->number_of_beams = 0 ; goto wrapup ;
	}

	/*
	 *   Highlight Section Beam.
	 */
	if(  ( me->flag & VS_K_first_inter_displ) ||
	    !( me->flag & VS_K_modify_form) )	dpmode = GRhd ;
	else					dpmode = GRbehd ;

	vs$bulk_display( dpmode = dpmode, count	= 1, objenvs= &me->BeamSect ) ;

	me->ret = MSSUCC ;
	me->flag &= ~VS_K_first_inter_displ ;

	wrapup :
		ex$message(	field	= ERROR_FIELD,
				in_buff = "" ) ;

	return OM_S_SUCCESS ;

} /* method inter_display */
/*----------------------------------------------------------------------------*/
method resetForm( int *sts ) {

	char		*form = me->fm_ptr ;
	long		msg ;

	FIf_reset( form ) ;

	/*
	 * Erase section draw on form.
	 */
	if( me->ActGrp == VS_K_bm_Grp_Definition )
		vs$repaint_gadget( form   = form,
				   gadget = VS_K_bm_Area ) ;

	VSg_replace( form, VS_K_bm_Placement, VS_K_bm_Modification ) ;

	me->ActGrp = VS_K_bm_Grp_Default ;

	FIg_display( form, me->ActGrp ) ;

	om$send(msg = message VSplbeamCmd.set_initial_gadget_attributes( &msg ),
		targetid = my_id ) ;


	return OM_S_SUCCESS ;

} /* method resetForm */
/*----------------------------------------------------------------------------*/
method hilight_elem( long *msg ) {

	/*
	 * Elements hilighted should be all the axis located, execpt the active
	 * beam which supported section beam.
	 */

	long			sts ;
	struct GRobj_env	*element = NULL ;


	/*
	 * Get elements
	 */
	element  = _MALLOC( me->number_of_beams + 1, struct GRobj_env ) ;
	if( !element ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	if( me->flag & VS_K_no_object_located ) goto wrapup ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
					msg, me->number_of_beams + 1, element ),
			targetid= my_id ) ;

	vs$bulk_display( count	= me->number_of_beams + 1,
			 dpmode = GRhd,
			 objenvs= element ) ;

	vs$bulk_display( count	= 1,
			 dpmode = GRhe,
			 objenvs= &element[me->ActBeam] ) ;

	*msg = MSSUCC ;

	wrapup :
		_FREE( element ) ;
		return OM_S_SUCCESS ;

} /* method hilight_elem */
/*----------------------------------------------------------------------------*/
method ActivateDismissGadget( int *sts ) {

	/*
	 * Activate dismiss gadget.
	 */
	FIg_enable( me->fm_ptr, VS_K_bm_Dismiss ) ;

	return OM_S_SUCCESS ;

} /* method ActivateDismissGadget */
/*----------------------------------------------------------------------------*/
method draw_section_on_form( long *msg ) {

	char			*form = me->fm_ptr ;
	struct GRid		sectionDef ;
	struct GRobj_env	beam ;
	VSdspRep		rep ;

	/*
	 * The section will draw on the form if the active group is Definition.
	 */
#define weight 1

	if( me->ActGrp != VS_K_bm_Grp_Definition ) goto wrapup ;

	ex$message( msgnumb	  = VS_gI_Processing,
		    justification = CENTER_JUS ) ;

	/*
	 * Get the section definition.
	 */
	vs$load_part_from_RDB(	msg		= msg,
				material	= me->actMat,
				family		= me->actFam,
				part		= me->actPrt,
				osnum		= me->cstEnv._MD_OS,
				object		= &sectionDef ) ;

	/*
	 * Retrieve the representation of the active beam located.
	 */
	om$send(msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActBeam, &beam ),
		targetid= my_id ) ;

	om$send(msg	= message ACncpx.ACget_NV_rep( &rep ),
		targetid= beam._objid,
		targetos= beam._osnum ) ;

	/*
	 * Erase the old section draw on the form.
	 */
	vs$repaint_gadget( form	= form, gadget = VS_K_bm_Area ) ;

	/*
	 * Draw the section on the form.
	 */
	vs$draw_section_on_form( msg		= msg,
				 form		= form,
				 gadget 	= VS_K_bm_Area,
				 representation = rep,
				 weight 	= weight,
				 mod_env	= &me->cstEnv,
				 sectDef	= &sectionDef ) ;

	/*
	 * Display section on the form.
	 */
	FIg_display( form, VS_K_bm_Area ) ;

	ex$message( field = ERROR_FIELD, in_buff = "" ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method draw_section_on_form */
/*----------------------------------------------------------------------------*/

end implementation VSmdbeamCmd ;
