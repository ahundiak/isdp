/* $Id: VSmdplatCmdi.I,v 1.1.1.1 2001/01/04 21:10:23 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSmdplatCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmdplatCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:23  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/02/19  20:34:26  pinnacle
# tr179900100
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/09  21:49:40  pinnacle
# TR179800861
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/98  ah      TR179800861 Changing name should not change directory
 * 02/19/99  ah      TR179900100 Core dump if plate has lost it's parents
 *                   Added debug statements
 ***************************************************************************/

class implementation VSmdplatCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "COBmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsglobalmsg.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsoptdef.h"
#include "vsplate.h"
#include "vsplatmacros.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vscmddef.h"
#include "vsicondef.h"

#define    vsDEBUGx 1
#define   vdsDEBUGx 1
#include "vsdbgmacros.h"
#include "vsuattdef.h"
#include "vsuattmacros.h"
#include "vsslcdef.h"
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

from GRgraphics	import	GRchgname;
from GRvg	import	GRgetattr,
			GRgetname,
			GRputattr ;
from NDnode	import	NDchange_node ;
from VSpart	import	VSgetUserEditableAttr,
			VSshowOrientation ;
from VSfeature	import	VSregenerate ;
/*----------------------------------------------------------------------------*/
method setFormTitle() {

#if vdsDEBUG
	printf(">>> VSmdplatCmd.setFormTitle\n");
#endif
	if( !( me->flag & VS_K_init_failed ) ) {
		ex$message( field = ERROR_FIELD, in_buff = "" ) ;
		VSg_replace(	me->fm_ptr,
				VS_K_pl_Placement,
				VS_K_pl_Modification ) ;
		me->directory = "" ;
	}

#if vdsDEBUG
	printf("@@@ VSmdplatCmd.setFormTitle\n");
#endif
	return OM_S_SUCCESS ;
	
} /* method setFormTitle */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

#if vdsDEBUG
	printf(">>> VSmdplatCmd.sleep\n");
#endif
	if( me->fm_ptr && !( me->flag & VS_K_init_failed ) ) {
		/*
		 * Disable Gadget Dismiss.
		 */
	 
		if( me->flag & VS_K_no_object_located )
			FIg_disable( me->fm_ptr, VS_K_pl_Dismiss ) ;
	}

	om$send(msg	= message VSfmplatCmd.sleep( pos ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;
		 
#if vdsDEBUG
	printf("@@@ VSmdplatCmd.sleep\n");
#endif
	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method init_cmd( int *sts ) {

#if vdsDEBUG
	printf(">>> VSmdplatCmd.init_cmd\n");
#endif

	me->flag |=  VS_K_no_object_located ;
	
	me->flag &= ~( VS_K_change_usr_attr	|
		       VS_K_modify_form 	 ) ;

	me->number_of_plates = 0 ;
	me->ActPlate	     = 0 ;

	FIfld_set_value( me->fm_ptr, VS_K_pl_Number_Of_Plates, 0, 0,
			 (double) me->number_of_plates, FALSE ) ;

	FIf_set_collapse_symbol(	me->fm_ptr,
					VS_K_CLP_SYM_FILE,
					VS_K_CLP_ModPlat ) ;

	me->nameModified = FALSE; 

#if vdsDEBUG
	printf("@@@ VSmdplatCmd.init_cmd\n");
#endif
	return OM_S_SUCCESS ;

} /* method init_cmd */
/*----------------------------------------------------------------------------*/
method load_attributes( long *msg ) {

	long			sts ;
	struct GRobj_env	plate ;
	VSpartAttr		attr ;
	VSplateAttr		info ;
	char			pathName[DI_PATH_MAX] ;

#if vdsDEBUG
	printf(">>> VSmdplatCmd.load_attributes\n");
#endif
	me->modAttr = 0 ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActPlate, &plate ),
			targetid= my_id ) ;

	if( sts == OM_E_INVINDEX ) {
		me->flag |= VS_K_no_attributes ;
		me->ret = VS_K_ACT_SUCCESS ;

#if vdsDEBUG
	printf("@1@ VSmdplatCmd.load_attributes\n");
#endif

		return OM_S_SUCCESS ;
	}

#if vdsDEBUG
	vdobj$Print(objOE = &plate);
#endif

	me->flag &= ~VS_K_no_attributes ;

	attr.Iwant	= VS_m_All ;
	attr.specific	= (void *) &info ;

	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
			targetid= plate._objid,
			targetos= plate._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

#if vdsDEBUG
	printf("Got VS_m_All attributes\n");
#endif

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

	me->actPar		= info.thickness ;
	me->approval_status 	= VSstrdup( attr.info.apprvstat ) ;
	me->construction_status = VSstrdup( attr.info.conststat	) ;
	me->fireproofing	= attr.info.fpthickness ;
	me->notes		= VSstrdup( attr.info.notes	) ;
	me->orientation		= me->initialOrientation = info.orientation ;
	me->cut_off		= info.cut_off ;
	me->offset		= info.offset	;

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
		me->usrNamList 	= NULL ;
		me->usrSynList	= NULL ;
	}

	/*
	 * Get name.
	 */
	*pathName = 0;
	sts = om$send(	msg	= message GRvg.GRgetname( msg, pathName ),
			targetid= plate._objid,
			targetos= plate._osnum ) ;
#if vdsDEBUG
	printf("    GRgetname '%s'\n",pathName);
#endif

	__CheckRC( sts, *msg, "GRvg.GRgetname", wrapup ) ;
	if( *pathName ) {
		di$split(	pathname	= pathName,
				dirname		= me->plateDir,
				name		= me->basename ) ;	
	} else {
		*me->basename = *me->plateDir = '\0' ;
	}
	me->directory = me->plateDir ;

	wrapup :
		/*
		 * Abort command on memory allocation failure.
		 */
		if( !me->stock || !me->source || !me->notes ||
		    !me->approval_status || !me->construction_status ) {
			_FREE( me->stock		) ;
			_FREE( me->source		) ;
			_FREE( me->notes		) ;
			_FREE( me->approval_status 	) ;
			_FREE( me->construction_status	) ;
			*msg = MSFAIL ;
		}

		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

#if vdsDEBUG
	if (me->ret != VS_K_ACT_SUCCESS) printf("    FAILED!!!\n");
	printf("@@@ VSmdplatCmd.load_attributes\n");
#endif

		return OM_S_SUCCESS ;

} /* method load_attributes */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	long			sts,
				msg ;
	int			nbPlates ;
	struct GRobj_env	fence,
				*Plates ;

#if vdsDEBUG
	printf(">>> VSmdplatCmd.process_fence\n");
#endif
				
	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count		= &nbPlates,
				p_content	= &Plates,
				response	= me->response,
				response_data	= me->response_data ) ;

	if( *me->response != EX_DATA || !nbPlates ) {
		me->ret = VS_K_NO_FENCE ; goto wrapup ;
	}
	if( msg & 1 ) {
		int h ;

		sts = OM_S_SUCCESS ;
		for( h = 0 ; h < nbPlates && (sts & 1) ; h++ ) {

			sts = om$send(
				msg	= message VSlocateCmd.addLocObj(
							&Plates[h]._grid,
							&Plates[h].mod_env,
							me->number_of_plates ),
				targetid= my_id ) ;
			me->number_of_plates++ ;
		}
		_FREE( Plates ) ;
		
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

		/*
		 * Display 'Roll Through' gadget.
		 */
		if( me->number_of_plates > 1 )
			FIg_display( me->fm_ptr, VS_K_pl_Roll_Through ) ;
		
	} else {
		sts = OM_W_ABORT ;
	}

	me->ret = sts & 1 & msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :

#if vdsDEBUG
	printf("@@@ VSmdplatCmd.process_fence\n");
#endif
		return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method display_support_normal( enum GRdpmode mode ) {

	long			sts,		/* OM return code	*/
				msg ;		/* Completion code	*/
	struct GRobj_env	plate ;		/* active plate		*/

#if vdsDEBUG
	printf(">>> VSmdplatCmd.display_support_normal\n");
#endif
	sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
						&msg, me->ActPlate, &plate ),
			targetid= my_id ) ;
	if( sts == OM_E_INVINDEX ) { goto wrapup ; }

	sts = om$send(	msg	= message VSpart.VSshowOrientation(
				      &msg,
				      &plate.mod_env,
				      me->orientation != me->initialOrientation,
				      mode,
				      &me->ActiveDisplay ),
			targetid= plate._objid,
			targetos= plate._osnum ) ;

	wrapup :
		me->ret = VS_K_ACT_SUCCESS ;
#if vdsDEBUG
	printf("@@@ VSmdplatCmd.display_support_normal\n");
#endif
		return OM_S_SUCCESS ;

} /* method display_support_normal */
/*----------------------------------------------------------------------------*/
method get_modifiable_gadgets( long *msg ; struct VSgadget **list ) {

static struct VSgadget VS_Ga_fmplat_labels[] = {
	{ VS_K_pl_Dismiss_Execute	, TRUE },
	{ VS_K_pl_Execute		, TRUE },
	{ VS_K_pl_Revert		, TRUE },
	{ VS_K_pl_Dismiss		, TRUE },
	{ VS_K_pl_Roll_Through		, TRUE },
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
	long				sts ;
	struct GRobj_env		plate ;
	unsigned long			attrMask,
					type ;
	register struct VSgadget	*l ;

#define NO_EDIT( attr ) !( attrMask & VS_m_##attr )
#define SET_NO_EDIT( gadget )\
	VSsetGadgetModifiable(	VS_Ga_fmplat_labels,\
				VS_K_pl_##gadget,\
				FALSE )

#if vdsDEBUG
	printf(">>> VSmdplatCmd.get_modifiable_gadgets\n");
#endif

	for( l = VS_Ga_fmplat_labels ; l->label != -1 ; l++ ) {
		l->touchable = TRUE ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjAtIndex(
						msg, me->ActPlate, &plate ),
			targetid= my_id ) ;
	if( sts == OM_S_SUCCESS ) {
		sts  = om$send(	msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attrMask ),
				targetid= plate._objid,
				targetos= plate._osnum ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;
		if( !attrMask ) {
			/*
			 * Plate not editable at all.
			 */
			for( l = VS_Ga_fmplat_labels ; l->label != -1 ; l++ ) {
				l->touchable = FALSE ;
			}
			om$send(msg	= message VSfmplatCmd.tellUser(
							VS_gW_PartNtEdit ),
				targetid= my_id ) ;
		} else {
			if( NO_EDIT( MatType		) )  
				SET_NO_EDIT( Material_Type	) ; 
			 
 			if( NO_EDIT( MatGrade		) )  
				SET_NO_EDIT( Material_Grade	) ;
			 
 			if( NO_EDIT( Notes		) )  
				SET_NO_EDIT( Comments		) ;
			 
 			if( NO_EDIT( PartFam		) )  
				SET_NO_EDIT( Plate_Type		) ;
			 
 			if( NO_EDIT( MtoStk		) ) {
				SET_NO_EDIT( Stock_Number	) ;
			}
 			if( NO_EDIT( MtoSrc		) )  
				SET_NO_EDIT( Source		) ;
			 
 			if( NO_EDIT( CutOff		) )  
				SET_NO_EDIT( Cut_Off		) ;
			 
 			if( NO_EDIT( Offset		) )  
				SET_NO_EDIT( Offset		) ;
			 
 			if( NO_EDIT( Orientation	) )  
				SET_NO_EDIT( Orientation	) ;
			 
 			if( NO_EDIT( PartNum		) )  
				SET_NO_EDIT( Thickness		) ;
			 
 			if( NO_EDIT( MbrClass		) )  
				SET_NO_EDIT( Member_Class	) ;
			 
 			if( NO_EDIT( MbrType		) )  
				SET_NO_EDIT( Member_Type	) ;
			 
 			if( NO_EDIT( AppStat		) )  
				SET_NO_EDIT( Approval_Status	) ;
			 	
 			if( NO_EDIT( CstStat		) )  
				SET_NO_EDIT( Construction_Status) ;
			 	
 			if( NO_EDIT( FpThck		) )  
				SET_NO_EDIT( Fireproofing 	) ; 
			 
			if( NO_EDIT( ChgNum		) )
				SET_NO_EDIT( Change_Number	) ; 

			if( NO_EDIT( UsrAttr		) )  
				SET_NO_EDIT( Mcf_User_Attributes) ; 
			 
			/*
			 * We do not want the name to be changed from this form.
			 */
			if( me->number_of_plates != 1)
			SET_NO_EDIT( Name ) ;
		}
	}
	*msg = MSSUCC ;
	*list = VS_Ga_fmplat_labels ;

	wrapup :
#if vdsDEBUG
	printf("@@@ VSmdplatCmd.get_modifiable_gadgets\n");
#endif
		return OM_S_SUCCESS ;

#undef NO_EDIT
#undef SET_NO_EDIT

} /* method get_modifiable_gadgets */
/*----------------------------------------------------------------------------*/
method construct_plate( long *msg ) {

	long			sts ;
	VSpartAttr		part ;
	VSplateAttr		plate ;
	int			i,
				count,
				needRecompute ;
	struct GRobj_env	*plateList = NULL ;
	struct GRid		cachedPart ;

	/*
	 * Get parents.
	 */
#if vdsDEBUG
	printf(">>> VSmdplatCmd.construct_plate\n");
#endif
	plateList = _MALLOC( me->number_of_plates, struct GRobj_env ) ;
	if( !plateList ) {
		*msg = EMS_E_NoDynamicMemory ; sts = OM_W_ABORT ; goto wrapup ;
	}
	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
					msg, me->number_of_plates, plateList ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Change name of plate
	 */

	if( me->number_of_plates == 1 ) {
		if( me->nameModified ) {

		  // TR179800861
		  sts = vdobj$ChgName(msg = msg, objOE = &plateList[0], name = me->basename, keepDir = 1);
		  /*
		    om$send(msg = message GRgraphics.GRchgname( 
		    msg,
		    &plateList[0].mod_env,
		    me->basename),
		    targetid = plateList[0]._objid,
		    targetos = plateList[0]._osnum ) ;
				 */
                }
	}
		
	/*
	 * Will only set modified attributes if one plate is located else all
	 * attributes will set for each plates.
	 */

	if( me->number_of_plates == 1 ) part.Iwant = me->modAttr ;
	else				part.Iwant = VS_m_All ;
	
	if( part.Iwant == VS_m_All ) {
		me->modAttr = VS_m_PartNum ;
		me->flag   |= VS_K_change_usr_attr ;
	}
						     
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
				options		= part.Iwant,
				partFam		= me->actFam,
				matType		= me->actMat,
				matGrade	= me->actGrd,
				partNum		= me->actPrt,
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
				thickness	= me->actPar,
				usrAttrId	= &me->UAid,
				partAttr	= &part,
				plateAttr	= &plate ) ;

	/*
	 * Load plate from RDB if something changed.
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
					 | VS_m_CutOff
					 | VS_m_Offset
					 | VS_m_Orientation ) ;

	count = me->number_of_plates ;

	for( i = 0 ; i < count ; i++ ) {
		sts = om$send(	msg	= message GRvg.GRputattr( msg,
							(char *) &part ),
				targetid= plateList[i]._objid,
				targetos= plateList[i]._osnum ) ;

		if( !( sts & 1 & *msg ) ) {
			*msg = MSFAIL ; me->number_of_plates = 0 ; goto wrapup ;
		}

		if( needRecompute ) {
			/*
			 * Put plate to batch Q.
			 */
			sts = om$send( 
				msg	= message VSfeature.VSregenerate(),
				targetid= plateList[i]._objid,
				targetos= plateList[i]._osnum ) ;
		}
		/*
		 * Decrease plate count.
		 */
		me->number_of_plates-- ;
		FIfld_set_value( me->fm_ptr,
				 VS_K_pl_Number_Of_Plates,
				 0, 0, (double) me->number_of_plates, FALSE ) ;
	}
	
	if( count ) {
		int mode ;
		nd$mod_batch( request = ND_GET, p_ret_mode = &mode ) ;
		if( mode != ND_DEFER ) nd$exec_batch() ;
	}
	
	wrapup :
		me->number_of_plates = 0 ;
		me->modAttr = 0 ;
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

		om$send(msg	= message VSfmplatCmd.display_support_normal(
									 GRhe ),
			targetid= my_id ) ;

		_FREE( plateList ) ;

#if vdsDEBUG
	printf("@@@ VSmdplatCmd.construct_plate\n");
#endif
		return OM_S_SUCCESS ;

} /* method construct_plate */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		sts ;

#if vdsDEBUG
	printf(">>> VSmdplatCmd.form_notification, %d\n",gadget_label);
#endif

	switch( gadget_label ) {
	case VS_K_pl_Dismiss_Execute	:
	case VS_K_pl_Execute		:
	case VS_K_pl_Revert		: break ;
	default	:
		sts = om$send(	msg	= message VSplplatCmd.form_notification(
						form_label, gadget_label,
						value, form_ptr ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	if( ( gadget_label != VS_K_pl_Execute			) &&
	    ( gadget_label != VS_K_pl_Dismiss_Execute		) &&
	    ( gadget_label != VS_K_pl_Revert			) &&
	    ( gadget_label != VS_K_pl_Dismiss			) &&
	    ( gadget_label != VS_K_pl_Definition		) &&
	    ( gadget_label != VS_K_pl_Plate_Manipulation	) &&
	    ( gadget_label != VS_K_pl_User_Attributes		) &&
	    ( gadget_label != VS_K_pl_Material_Take_Off		) &&
	    ( gadget_label != VS_K_pl_Roll_Through		) )
				me->flag |= VS_K_modify_form ;

	switch( gadget_label ) {

	int	response ;
	long	msg ;

	case VS_K_pl_Dismiss_Execute	:
		/*
		 * Modify plate(s), then exit command.
		 */
		response = TERMINATE ;
		goto EXECUTE ;

	case VS_K_pl_Execute		:
		/*
		 * Construct plates, then go to state "start".
		 */
		response = EX_BACK_UP ;
	EXECUTE	:
		if( (me->flag & VS_K_modify_form) || (me->number_of_plates>1) ){
			om$send(msg	= message VSplplatCmd.construct_plate(
									&msg ),
				targetid= my_id ) ;

			ex$putque( msg = &msg, response = &response ) ;
		} else {
			om$send( msg = message VSplplatCmd.tellUser(
								VS_gI_PlNoMod ),
			 	targetid = my_id ) ;
			FIg_set_state_off( form_ptr, gadget_label ) ;
		}
		break ;

	case VS_K_pl_Revert		:
		response = EX_BACK_UP ;
		om$send( msg      = message VSqryRdbCmd.freeRDBdata(),
			 targetid = my_id ) ;
		ex$putque( msg = &msg, response = &response ) ;
		break ;

	case VS_K_pl_Roll_Through	:
		/*
		 * Erase support normal.
		 */
		om$send( msg   = message VSmdplatCmd.display_support_normal( 
									GRhe ), 
			 targetid = my_id ) ;
			 
		me->ActPlate++ ;
		if( me->ActPlate == me->number_of_plates ) me->ActPlate = 0 ;
		
		/*
		 * Load attributes from new active plate and fill the form.
		 */
		om$send( msg   = message VSmdplatCmd.load_attributes( &msg ),
			 targetid = my_id ) ;
		om$send( msg   = message VSmdplatCmd.fill_form( &msg ),
			 targetid = my_id ) ;
			 
		/*
		 * Display support normal.
		 */
		om$send( msg   = message VSmdplatCmd.display_support_normal( 
									GRhd ), 
			 targetid = my_id ) ;
		break ;

	case VS_K_pl_Material_Type	: me->modAttr |= VS_m_MatType	;
	case VS_K_pl_Material_Grade	: me->modAttr |= VS_m_MatGrade	;
	case VS_K_pl_Plate_Type		: me->modAttr |= VS_m_PartFam	;
	case VS_K_pl_Thickness		: me->modAttr |= VS_m_PartNum   ;
				  	  me->modAttr |= VS_m_Thickness ; break;
	case VS_K_pl_Cut_Off	: me->modAttr |= VS_m_CutOff		; break;
	case VS_K_pl_Offset	: me->modAttr |= VS_m_Offset		; break;
	case VS_K_pl_Orientation: me->modAttr |= VS_m_Orientation	; break;
	
	case VS_K_pl_Stock_Number	: me->modAttr |= VS_m_MtoStk	; break;
	case VS_K_pl_Source		: me->modAttr |= VS_m_MtoSrc	; break;

	case VS_K_pl_Member_Class	: me->modAttr |= VS_m_MbrClass	; break;
	case VS_K_pl_Member_Type	: me->modAttr |= VS_m_MbrType	; break;

	case VS_K_pl_Comments		: me->modAttr |= VS_m_Notes	; break;
	
	case VS_K_pl_Copy_Params	: me->modAttr = VS_m_All 	; break;
	
	case VS_K_pl_Approval_Status    : me->modAttr |= VS_m_AppStat	; break;
	case VS_K_pl_Construction_Status: me->modAttr |= VS_m_CstStat	; break;
	case VS_K_pl_Fireproofing	: me->modAttr |= VS_m_FpThck	; break;
	case VS_K_pl_Change_Number	: me->modAttr |= VS_m_ChgNum	; break;

	case VS_K_pl_Mcf_User_Attributes: me->modAttr |= VS_m_UsrAttr	; break;

	case VS_K_pl_Name		: me->nameModified = TRUE	; break;

	default				: break ;
	}

#if vdsDEBUG
	printf("@@@ VSmdplatCmd.form_notification, %d\n",gadget_label);
#endif
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method resetForm( int *sts ) {

	char	*form = me->fm_ptr ;	

#if vdsDEBUG
	printf(">>> VSmdplatCmd.resetForm\n");
#endif

	FIf_reset( form ) ;

	VSg_replace( form, VS_K_pl_Placement, VS_K_pl_Modification ) ;
	
	me->ActGrp = VS_K_pl_Grp_Default ;
	
	FIg_display( form, me->ActGrp ) ;

	om$send(msg	= message VSfmplatCmd.overrideForm(),
		targetid= my_id ) ;

#if vdsDEBUG
	printf("@@@ VSmdplatCmd.resetForm\n");
#endif
	return OM_S_SUCCESS ;

} /* method resetForm */
/*----------------------------------------------------------------------------*/
method ActivateDismissGadget( int *sts ) {
	
	 
	FIg_enable( me->fm_ptr, VS_K_pl_Dismiss ) ;
	return OM_S_SUCCESS ;

} /* ActivateDismissGadget */
/*----------------------------------------------------------------------------*/
method store_support( int *sts ) {

        struct GRlc_info        *toStore = me->event1.located_object ;

#if vdsDEBUG
	printf(">>> VSmdplatCmd.store_support\n");
#endif
	
        me->ret = om$send(
                        msg     = message VSlocateCmd.addLocObj(
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
                                 0, 0, (double) me->number_of_plates, FALSE ) ;

                me->flag &= ~VS_K_no_object_located ;


        }
	
        me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

#if vdsDEBUG
	if (me->ret != VS_K_ACT_SUCCESS) printf("    FAILED\n");
	printf("@@@ VSmdplatCmd.store_support\n");
#endif
        return OM_S_SUCCESS ;

} /* method store_support */
/*----------------------------------------------------------------------------*/

end implementation VSmdplatCmd ;






