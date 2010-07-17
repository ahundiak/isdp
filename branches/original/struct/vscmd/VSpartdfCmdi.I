/* $Id: VSpartdfCmdi.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSpartdfCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSpartdfCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.5  2000/03/29  20:36:30  pinnacle
# Replaced: vscmd/VSpartdfCmdi.I for:  by impd252 for struct
#
# Revision 1.4  1999/12/06  17:27:34  pinnacle
# tr179900782
#
# Revision 1.3  1999/11/12  19:42:46  pinnacle
# tr179900782
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/06  08:09:10  pinnacle
# Replaced: vscmd/VSpartdfCmdi.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 *      09/28/99        Jayadev         TR179900782
 *      10/13/99        bkeesara        TR179900646 face name crash avoided 
 *      12/06/99        ah              Fixed problem when 646 was merged with 782
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSpartdfCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "OMmacros.h"
#include "DImacros.h"
#include "igr.h"
#include "go.h"
#include "dpmacros.h"
#include "acrepdef.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsdpb.h"
#include "vspart.h"
#include "vs.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsbeam.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsoptdef.h"
#include "vsptformdef.h"
#include "vsgeommacros.h"
#include "vsmeasmacros.h"
#include "vsmiscmacros.h"
#include "vsbeammacros.h"
#include "vsplatmacros.h"
#include "vsformmacros.h"
#include "vsiomacros.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsfmcpypaste.h"
#include "vsgrenvproto.h"
#include "vsioproto.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"

from GRvg	import	GRgetattr,
			GRgetname ;
from GRowner	import	GRget_components ;
from NDmacro	import	ACreturn_foot ;
from ACncpx	import	ACget_NV_rep ;
from VSpart	import	VSgetUserEditableAttr ;
from VSfeature	import	VSgetUsrAttributes ;
from VSbeam	import	VSgetProfileDef,
			VSgetSectionParameter ;
from VSxscurve	import	VStransUsrNmToCmp ;
from GRcurve	import GRtotlength;
extern long VSgetBeamCentroidalAxis();

%safe
static struct VSdpb_form_pos plateForm_pos = { 0, 0, 0, 0, 0 } ;
static struct VSdpb_form_pos beamForm_pos  = { 0, 0, 0, 0, 0 } ;
%endsafe

#define VS_K_CmdNotStacked	0
#define VS_K_CmdIsStacked	1
#define VS_K_DelWhenStacked	2
#define	VS_K_LocStructElm	260
/*----------------------------------------------------------------------------*/
void VSfillUsrAttrForm( form, mcfLabel, partId )

char			*form ;
int			mcfLabel ;
const struct GRid	*partId ; {

	long		rc ;
	struct GRid	UAid ;
	char		**names,
			**values ;
	int		i,
			size ;

	names = values = NULL ;
 
	FIg_reset( form, mcfLabel ) ;

	UAid.objid = NULL_OBJID ;
	om$send(msg	= message VSfeature.VSgetUsrAttributes( &rc, &UAid ),
		senderid= partId->objid,
		targetid= partId->objid,
		targetos= partId->osnum ) ;

	if( IF_NULL_OBJID( UAid.objid ) ) return ;

	vs$getUsrAttrContent(	msg		= &rc,
				UAid		= &UAid,
				p_size		= &size,
				p_names		= &names,
				p_syntaxes	= &values ) ;
	if( !( rc & 1 ) ) goto wrapup ;

	if( size ) {
	  FIfld_set_num_rows( form, mcfLabel, size ) ;
	  for( i = 0 ; i < size ; i++ ) {
		FIfld_set_text( form, mcfLabel, i, 0, names [i], FALSE ) ;
		FIfld_set_text( form, mcfLabel, i, 1, values[i], FALSE ) ;
	  }
	}

	wrapup :
		VSfreeList( size, names  ) ;
		VSfreeList( size, values ) ;
		return ;
	
} /* VSfillUsrAttrForm */
/*----------------------------------------------------------------------------*/
void VScreateUsrAttrForm( masterForm, label, cmdId, partId, p_form )

char		*masterForm ;
int		label ;
OM_S_OBJID	cmdId ;
struct GRid	*partId ;
char		**p_form ; {

	int		screen,
			xpos,
			ypos,
			width,
			height ;
	char		*form ;

	*p_form = NULL ;

	om$send(msg	= message VSlocateCmd.formCreationByPtr(
					     label, VS_K_USRATTR_FORM, &form ),
		senderid= cmdId,
		targetid= cmdId,
		targetos= OM_Gw_TransOSnum_0 ) ;

	if( !form ) goto wrapup ;

	VSf_get_layout( masterForm, &screen, &xpos, &ypos, &width, &height ) ;

	xpos = xpos + width  / 2 ;
	ypos = ypos + height / 2 ;

	FIf_set_screen( form, screen ) ;
	FIf_set_location( form, xpos, ypos ) ;
	FIf_set_orig_location( form, xpos, ypos ) ;
	FIf_set_collapse_location( form, xpos, ypos ) ;

	VSfillUsrAttrForm( form, VS_K_UATTR_FLD, partId ) ;

	FIf_display( form ) ;

	wrapup :
		*p_form = form ;

} /* VScreateUsrAttrForm */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	om$send( msg	= message VSlocateCmd.wakeup( pos ),
		 mode	= OM_e_wrt_message,
		 targetid= my_id ) ;

	if( VS_K_DelWhenStacked == me->flag ) {
	  int	rsp = TERMINATE ;
   	  long	rc ;
	  ex$putque( msg = &rc, response = &rsp ) ;
	} else {
	  /*
	   * If part was deleted, don't display form. ( Don't test for first
	   * wakeup after init ).
	   */
	  if( om$is_objid_valid( objid = me->partObj._objid,
				 osnum = me->partObj._osnum ) != OM_S_SUCCESS ){
	    me->face.objid = NULL_OBJID ;
	  }
	  if( VS_K_CmdIsStacked == me->flag ) me->flag = VS_K_CmdNotStacked ;
	}

	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	 om$send(	msg	= message VSlocateCmd.sleep( pos ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	if( VS_K_CmdNotStacked == me->flag ) me->flag = VS_K_CmdIsStacked ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method toggleCommand() {
	VStoggleCommand( my_id, OM_Gw_current_OS ) ;
	return OM_S_SUCCESS ;
} /* toggleCommand */
/*----------------------------------------------------------------------------*/
method cleanUp() {
  
	/*
	 * Delete forms.
	 */
	if( me->plateForm ) {
	   VSf_resetCopyPasteInfo( me->plateForm ) ;
	   FIf_delete( me->plateForm   ) ;
	   me->plateForm = NULL ;
	}		      

	if( me->beamForm )  {
	   VSf_resetCopyPasteInfo( me->beamForm ) ;
	   FIf_delete( me->beamForm ) ;
	   me->beamForm = NULL ;
	}

	if( me->usrAttrForm ) {
	   VSf_resetCopyPasteInfo( me->usrAttrForm ) ;
	   FIf_delete( me->usrAttrForm ) ;
	   me->usrAttrForm = NULL ;
	}
	return OM_S_SUCCESS ;

} /* method cleanUp */
/*----------------------------------------------------------------------------*/
method initCmd() {

	me->beamForm  = me->plateForm = me->usrAttrForm = NULL ;
	me->face.objid= NULL_OBJID ;
	me->flag      = VS_K_CmdNotStacked ;

	return OM_S_SUCCESS ;

} /* method initCmd */
/*----------------------------------------------------------------------------*/
method store_part( long *msg ) {

	long		sts ;
	unsigned long	attrMask ;
	struct GRmd_env	env ;
	struct GRid	id ;

	me->face.objid = NULL_OBJID ;
	me->partObj.obj_id  = me->event1.located_object[0].located_obj ;
	me->partObj.mod_env = me->event1.located_object[0].module_info ;

	/*
	 * Note: located element may be an image of an original element, we must
	 * get the transformation matrix orignal -> image and do the
	 * multiplication
	 *        mx returned by locate x mx( matrix original -> image )
	 */
	sts = VSgetVirtualInfo( msg, &me->partObj._grid, &env, &id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	VSmulmx( me->partObj._matrix, env._MATRIX,
		 me->partObj._matrix, &me->partObj._matrix_type ) ;

	sts  = om$send( msg	= message VSpart.VSgetUserEditableAttr(
					msg, &me->partType, &attrMask ),
			targetid= me->partObj._objid,
			targetos= me->partObj._osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	wrapup :
		*msg = ( *msg & 1 & sts ) ? VS_K_ACT_SUCCESS
					  : VS_K_RESTART_CMD ;

	return OM_S_SUCCESS ;

} /* method store_part */
/*----------------------------------------------------------------------------*/
method display_work_form( long *msg ) {

	int	is_created = TRUE,
		is_displayed ;

	/*
	 * See if work form is created.
	 */
	if( me->partType == VS_m_SRC_PLATE ) {

		if( !me->plateForm ) {

			is_created = FALSE ;

			om$send(msg	= message VSpartdfCmd.create_form(
						msg, VS_K_PLDEF_MASTER_FORM ),
				targetid= my_id ) ;
			__CheckRC( 1, *msg, "VSpartdfCmd.create_form", wrapup );
		}
	} else {
		if( !me->beamForm ) {

			is_created = FALSE ;

			om$send(msg	= message VSpartdfCmd.create_form(
						msg, VS_K_BMDEF_MASTER_FORM ),
				targetid= my_id ) ;
			__CheckRC( 1, *msg, "VSpartdfCmd.create_form", wrapup );
		}
	}

	/*
	 * Change gadget text if part is a beam or a stiffener.
	 * In case of stiffener, the two gadgets 'rotation' and
	 * 'Y offset' are not available.
	 */
	 switch( me->partType ) {
		case VS_m_SRC_BEAM :
			     VSg_replace( me->beamForm,
					  VS_K_pt_bm_Grp_Txt_Stiffener,
					  VS_K_pt_bm_Grp_Txt_Beam ) ;

			     vs$g_display_gadgets( form = me->beamForm,
						   list = `VS_K_pt_bm_Rotation,
							   VS_K_pt_bm_Y_Offset,
							   -1` ) ;
			     break ;

		case VS_m_STF_BEAM :
			     VSg_replace( me->beamForm,
					  VS_K_pt_bm_Grp_Txt_Beam,
					  VS_K_pt_bm_Grp_Txt_Stiffener ) ;

			     vs$g_erase_gadgets(   form = me->beamForm,
						   list = `VS_K_pt_bm_Rotation,
							   VS_K_pt_bm_Y_Offset,
							   -1` ) ;
			     break ;

		default 	   :
			     break ;
	}

	/*
	 * Display form, if not yet displayed.
	 */
	if( me->partType == VS_m_SRC_PLATE ) {

		if( is_created )
			FIf_is_displayed( me->plateForm, &is_displayed ) ;
		else is_displayed = FALSE ;

		/*
		 * if 'plate form' always displayed, reset form. Else erase
		 * 'beam form' and display 'plate form'.
		 */
		if( !is_displayed ) {
			if( me->beamForm ) FIf_erase( me->beamForm ) ;

			VSf_display( me->plateForm ) ;
		}
	} else {

		if( is_created )
			FIf_is_displayed( me->beamForm, &is_displayed ) ;
		else is_displayed = FALSE ;

		/*
		 * if 'beam form' always displayed, reset form. Else erase
		 * 'plate form' and display 'beam form'.
		 */
		if( is_displayed ) {

			/*
			 * Erase profile drawn on form.
			 */
			vs$repaint_gadget( form 	= me->beamForm,
					   gadget	= VS_K_pt_bm_Area ) ;

		} else {
			if( me->plateForm ) FIf_erase( me->plateForm ) ;

			VSf_display( me->beamForm ) ;
		}
	}

	*msg = MSSUCC ;

	wrapup :
		me->ret = ( *msg & 1 ) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;

} /* method display_work_form */
/*----------------------------------------------------------------------------*/
method create_form( long *msg; char *form_name ) {

	char	*form ;

	*msg = MSSUCC ;

	if( *form_name ) {
		extern int COB_FI_initial_form_notification(),
			   COB_FI_form_notification() ;

		me->ret = FIf_new( VS_K_MASTER_LABEL, form_name,
				   COB_FI_form_notification, &form ) ;

		if( FI_SUCCESS != me->ret ) { *msg = MSFAIL ; goto wrapup ; }

		FIf_set_cmd_oid_os( form, my_id, OM_Gw_current_OS ) ;
		FIf_set_initial_notification_routine( form,
						      COB_FI_initial_form_notification ) ; 
		om$send(msg	= message VSlocateCmd.formOpByPtr(
						form, VS_FIf_WNEVENT_ON ),
			targetid= my_id ) ;

		/*
		 * Set location and size.
		 */
		if( me->partType == VS_m_SRC_PLATE ) {

			me->plateForm = form ;

			if( 0 != plateForm_pos.width ) {

			        VSf_set_layout( me->plateForm,
						plateForm_pos.screen,
						plateForm_pos.x,
						plateForm_pos.y,
						plateForm_pos.width,
						plateForm_pos.height ) ;
			}
		} else {
			me->beamForm  = form ;

			if( 0 != beamForm_pos.width ) {

				VSf_set_layout( me->beamForm,
						beamForm_pos.screen,
						beamForm_pos.x,
						beamForm_pos.y,
						beamForm_pos.width,
						beamForm_pos.height ) ;
			}
		}

	} else *msg = MSFAIL ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method create_form */
/*----------------------------------------------------------------------------*/
method fill_form( long *msg ) {

	long		sts ;
	char		*form ;
	GRname		pathName,
			partName ;
	VSpartAttr	attr ;
	VSplateAttr	plate_info ;
	VSbeamAttr	beam_info ;
	int		i,
			count,
			group = FALSE,
			textLength,
			maxVisChar ;
	char		**faceNames ;
	long		*faceDescrs ;

#define SCROLL_GADGET( label ) {\
	FIfld_get_text_length( form, (label), 0, 0, &textLength ) ;\
	FIfld_get_num_vis_chars( form, (label), 0, &maxVisChar ) ;\
	if( textLength -1 > maxVisChar ) {\
		if( !group ) {\
			FIgrp_delete( form, VS_K_pt_Grp_to_Scroll ) ;\
			FIg_new( form, FI_GROUP, VS_K_pt_Grp_to_Scroll ) ;\
			group = TRUE ;\
		}\
		FIg_add_to_group( form, (label), VS_K_pt_Grp_to_Scroll ) ;\
	}\
	}
#define FILL_ASCII_FIELD( label, text ) \
	FIfld_set_active_char( form, (label), 0, 0, 0 ) ;\
	FIfld_set_text( form, (label), 0, 0, (text), FALSE ) ;\
	SCROLL_GADGET( (label) )
#define SET_GADGET( mask ) \
	if( attr.Iwant & VS_m_##mask )

	/*
	 * Init variable 'form'.
	 */
	form = me->partType == VS_m_SRC_PLATE	? me->plateForm
						: me->beamForm ;
	/*
	 * Init wanted attributes.
	 */
	attr.Iwant = VS_m_MatGrade | VS_m_MatType | VS_m_PartFam | VS_m_PartNum;

	if( me->partType == VS_m_SRC_PLATE ) {

		attr.Iwant |= ( VS_m_Thickness	|
				VS_m_CutOff	|
				VS_m_Offset	|
				VS_m_Orientation) ;

		attr.specific = (void *) &plate_info ;
	} else {
		attr.Iwant |= ( VS_m_cardPnt	|
				VS_m_Symmetry	|
				VS_m_xOffset	) ;

		if( me->partType == VS_m_SRC_BEAM )
			attr.Iwant |= ( VS_m_RotAngle	|
					VS_m_yOffset	) ;

		attr.specific = (void *) &beam_info ;
	}

	/*
	 * Retrieve attributes of part.
	 */
	sts = om$send( msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
		       targetos = me->partObj._osnum,
		       targetid = me->partObj._objid ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	strcpy( me->mat, attr.info.material	) ;
	strcpy( me->fam, attr.info.family	) ;
	strcpy( me->num, attr.info.partNum	) ;

	/*
	 * Retrieve name of part.
	 */
	sts = om$send( msg	= message GRvg.GRgetname( msg, pathName ),
		       targetos = me->partObj._osnum,
		       targetid = me->partObj._objid ) ;
	if( !( sts & 1 & *msg ) ) *pathName = '\0' ;

	if( *pathName ) {
		di$split( pathname = pathName, name = partName ) ;
	} else {
		*partName = '\0' ;
	}
	strcpy( me->mat, attr.info.material	) ;
	strcpy( me->fam, attr.info.family	) ;
	strcpy( me->num, attr.info.partNum	) ;

	/*
	 * Fill form.
	 */
	FILL_ASCII_FIELD( VS_K_pt_Part_Name	, partName		) ;
	FILL_ASCII_FIELD( VS_K_pt_Material_Type , me->mat		) ;
	FILL_ASCII_FIELD( VS_K_pt_Material_Grade, attr.info.grade	) ;
	FILL_ASCII_FIELD( VS_K_pt_Part_Type	, me->fam		) ;
	FILL_ASCII_FIELD( VS_K_pt_Part_Number	, me->num		) ;

	SCROLL_GADGET( VS_K_pt_Part_Name ) ;

	if( me->partType == VS_m_SRC_PLATE ) {
	  /*
	   * Cut-off thickness.
	   */
	  SET_GADGET( CutOff ) {
	    vs$fillUnitField(	msg	= msg,
				form	= form,
				field	= VS_K_pt_pl_Cut_Off,
				osnum	= me->cstEnv._MD_OS,
				type	= GRIO_DISTANCE,
				value	= plate_info.cut_off ) ;
	  }

	  /*
	   * Plate offset.
	   */
	  SET_GADGET( Offset  ) {
	    vs$fillUnitField(	msg	= msg,
			 	form	= form,
				field	= VS_K_pt_pl_Plate_Offset,
				osnum	= me->cstEnv._MD_OS,
				type	= GRIO_DISTANCE,
				value	= plate_info.offset ) ;
	  }

	  /*
	   * Orientation.
	   */
	  SET_GADGET( Orientation ) {
	    if( plate_info.orientation == VS_K_USE_REV_NORM ) {
	      VSg_replace( form,
		           VS_K_pt_pl_Natural_Normal,
			   VS_K_pt_pl_Reverse_Normal ) ;
	    } else {
	      VSg_replace( form,
			   VS_K_pt_pl_Reverse_Normal,
			   VS_K_pt_pl_Natural_Normal ) ;
	    }
	  }

	  /*
	   * Faces.
	   */
	  sts = vs$listPlateFaces(	msg	= msg,
					plate	= &me->partObj._grid,
					count	= &count,
					names	= &faceNames,
					descrs	= &faceDescrs ) ;
	  if( sts & 1 & *msg ) {
	    FIfld_set_num_rows( form, VS_K_pt_Faces, count ) ;
	    for( i = 0 ; i < count ; i++ ) {
	      FIfld_set_text( form, VS_K_pt_Faces, i, 0, faceNames[i], FALSE ) ;
	      FIfld_set_text( form, VS_K_pt_Faces, i, 1,
				VSmsgkey2string( faceDescrs[i] ), FALSE ) ;
	    }
	    _FREE( faceDescrs ) ;
	    VSfreeList( count, faceNames ) ;
	  }
	} else {
	  /*
	   * Profile parameters.
	   */
	  om$send( msg	   = message VSpartdfCmd.fill_section_parameters( msg ),
		   targetid= my_id ) ;
	  __CheckRC( 1, *msg, "VSpartdfCmd.fill_section_parameters", wrapup ) ;

	  /*
	   * Profile length and area.
	   */
	  om$send( msg	    = message VSpartdfCmd.fill_section_area_and_length(),
		   targetid = my_id ) ;

	  SCROLL_GADGET( VS_K_pt_bm_Section_Length ) ;
	  SCROLL_GADGET( VS_K_pt_bm_Section_Area	 ) ;

	  /*
	   * Draw profile on form.
	   */
	  om$send( msg      = message VSpartdfCmd.draw_section(),
		   targetid = my_id ) ;

	  /*
	   * Reference Point.
	   */
	  SET_GADGET( cardPnt ) {
	    int		lbl ;

	    switch( beam_info.card ) {
	      case VS_e_UPP_LEFT : lbl = VS_K_pt_bm_Top_Left	  ; break;
	      case VS_e_LFT_MIDD : lbl = VS_K_pt_bm_Center_Left	  ; break;
	      case VS_e_BOT_LEFT : lbl = VS_K_pt_bm_Bot_Left	  ; break;
	      case VS_e_TOP_MIDD : lbl = VS_K_pt_bm_Top_Middle	  ; break;
	      case VS_e_BOT_MIDD : lbl = VS_K_pt_bm_Bot_Mid	  ; break;
	      case VS_e_UPP_RGHT : lbl = VS_K_pt_bm_Top_Right	  ; break;
	      case VS_e_GEO_CENT : lbl = VS_K_pt_bm_Center_Middle ; break;
	      case VS_e_RGH_MIDD : lbl = VS_K_pt_bm_Center_Right  ; break;
	      case VS_e_BOT_RGHT : lbl = VS_K_pt_bm_Bot_Right	  ; break;
	      default 	         : lbl = 0 ; break ;
	    }
	    if( lbl ) VSg_replace( form, VS_K_pt_bm_Grp_Ref_Point, lbl ) ;
	  }

	  /*
	   * Symmetry.
	   */
	  SET_GADGET( Symmetry ) {
	    int	label ;

	    switch( beam_info.sym ) {
	      case VS_e_No_Symm : label = VS_K_pt_bm_No_Sym ; break ;
	      case VS_e_X_Symm  : label = VS_K_pt_bm_X_Sym  ; break ;
	      case VS_e_Y_Symm  : label = VS_K_pt_bm_Y_Sym  ; break ;
	      case VS_e_XY_Symm : label = VS_K_pt_bm_XY_Sym ; break ;
	      default 	        : label = 0 ; break ;
	    }
	    if( label ) VSg_replace( form, VS_K_pt_bm_Grp_Sym, label ) ;
	  }

	  /*
	   * Rotation Angle.
	   */
	  SET_GADGET( RotAngle ) {
	    vs$fillUnitField(	msg	= msg,
			 	form	= form,
				field	= VS_K_pt_bm_Rotation,
				osnum	= me->cstEnv._MD_OS,
				type	= GRIO_ANGLE,
				value	= beam_info.rotat ) ;
	  }

	  /*
	   * X Offset.
	   */
	  SET_GADGET( xOffset ) {
	    vs$fillUnitField(	msg	= msg,
			 	form	= form,
				field	= VS_K_pt_bm_X_Offset,
				osnum	= me->cstEnv._MD_OS,
				type	= GRIO_DISTANCE,
				value	= beam_info.xoff ) ;
	  }

	  /*
	   * Y Offset.
	   */
	  SET_GADGET( yOffset ) {
	    vs$fillUnitField(	msg	= msg,
			 	form	= form,
				field	= VS_K_pt_bm_Y_Offset,
				osnum	= me->cstEnv._MD_OS,
				type	= GRIO_DISTANCE,
				value	= beam_info.yoff ) ;
	  }
		
	  /*
	   * Faces.
	   */
	  sts = vs$listBeamFaces(	msg	= msg,
					beam	= &me->partObj._grid,
					count	= &count,
					names	= &faceNames,
					descrs	= &faceDescrs ) ;
	  if( sts & 1 & *msg ) {
	    FIfld_set_num_rows( form, VS_K_pt_Faces, count ) ;
	    for( i = 0 ; i < count ; i++ ) {
	      FIfld_set_text( form, VS_K_pt_Faces, i, 0, faceNames[i], FALSE ) ;
	      FIfld_set_text( form, VS_K_pt_Faces, i, 1,
				VSmsgkey2string( faceDescrs[i] ), FALSE ) ;
	    }
	    _FREE( faceDescrs ) ;
	    VSfreeList( count, faceNames ) ;
	  }
	}

	/*
	 * If no gadgets to be scrolled, erase scroll bar.
	 */
	if( !group ) FIg_erase	( form, VS_K_pt_Scroll_Bar ) ;
	else	     FIg_display( form, VS_K_pt_Scroll_Bar ) ;

	if( me->usrAttrForm ) {
	  /*
	   * Sub-form of user-attributes is present: fill it.
	   */
	  VSfillUsrAttrForm( me->usrAttrForm, VS_K_UATTR_FLD,
	  			&me->partObj._grid ) ;
	}
	wrapup :
		*msg = ( *msg & 1 & sts ) ? VS_K_ACT_SUCCESS
					  : VS_K_RESTART_CMD ;

		/*
		 * If error encountered, erase form.
		 */
		if( VS_K_RESTART_CMD == *msg ) {
		  om$send( msg      = message VSpartdfCmd.cleanUp(),
		           targetid = my_id ) ;
		}
		
		/* Added by Sundar during Fix TR # 179600098 */
 
                FIg_set_text(form,VS_K_pt_Path,"");
                FIg_enable(form,VS_K_pt_UsrAttr);


#undef SCROLL_GADGET
#undef SET_GADGET
#undef FILL_ASCII_FIELD

	return OM_S_SUCCESS ;

} /* method fill_form */
/*----------------------------------------------------------------------------*/
method fill_section_parameters( long *msg ) {

	/*
	 * Retrieve profile parameters from RDB or database cache and
	 * fill gadget 'Section Parameters'.
	 */
#define	PMCOUNT	5
	long	sts ;			/* OM return code	*/
	char	*pmNames[PMCOUNT] ;	/* Names of parameters	*/
	double	pmValue ;		/* Value of one parm.	*/
	GRname	text ;			/* Text to set		*/
	int	i,
		l,
		lmax ;

	FIfld_set_num_rows( me->beamForm, 
	                    VS_K_pt_bm_Section_Parameters, 
	                    PMCOUNT ) ;

	pmNames[0] = VS_K_bmHeightAttr ;
	pmNames[1] = VS_K_bmWidthAttr  ;
	pmNames[2] = VS_K_bmFlgThkAttr ;
	pmNames[3] = VS_K_bmWebThkAttr ;
	pmNames[4] = VS_K_bmFltRadAttr ;

	for( lmax = -1, i = 0 ; i < PMCOUNT ; i++ ) {
		if( ( l = strlen( pmNames[i] ) ) > lmax ) lmax = l ;
	}
	/*
	 * Fill gadget.
	 */
	for( i = 0; i < PMCOUNT; i++ ) {
		sts = om$send(	msg	= message VSbeam.VSgetSectionParameter(
							msg,
							pmNames[i],
							&me->partObj.mod_env,
							&pmValue ),
				targetid= me->partObj._objid,
				targetos= me->partObj._osnum ) ;
		if( !( sts & 1 & *msg ) ) pmValue = 0 ;

		sprintf( text, "%-*s = %g", lmax, pmNames[i], pmValue ) ;

		FIfld_set_text( me->beamForm,
				VS_K_pt_bm_Section_Parameters,
				i,
				0,		/* Names column		*/
				pmNames[i],
				FALSE ) ;
		sprintf( text, "%g", pmValue ) ;

		FIfld_set_text( me->beamForm,
				VS_K_pt_bm_Section_Parameters,
				i,
				1,		/* Values column	*/
				text,
				FALSE ) ;
	}

	/*
	 * Display gadget.
	 */
	FIg_display( me->beamForm, VS_K_pt_bm_Grp_Sect_Param ) ;

	*msg = MSSUCC ;

	return OM_S_SUCCESS ;

#undef PMCOUNT

} /* method fill_section_parameters */
/*----------------------------------------------------------------------------*/
method fill_section_area_and_length() {
 
	long			msg,
				sts ;
	char			*form = me->beamForm ;
	struct	GRobj_env	section ;
	struct	GRid		sectionDef ;
	double			sectionLength,
				sectionArea ;
	struct GRid		cntAxis;
	double			len1;	

#define FILL_ASCII_FIELD( label, text ) \
	FIfld_set_text( form, (label), 0, 0, (text), FALSE ) ;

	/*
	 * Retrieve profile definition.
	 */
	sts = om$send( msg	= message VSbeam.VSgetProfileDef( &msg,
								  &sectionDef ),
		       targetos = me->partObj._osnum,
		       targetid = me->partObj._objid ) ;
	__CheckRC( sts, msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	/*
	 * Retrieve the graphic cross-section with 3D representation.
	 */
	vs$get_graphic_section( msg		= &msg,
				sectDef 	= &sectionDef,
				representation	= AC_3D_REP,
				section 	= &section ) ;
	__CheckRC( 1, msg, "vs$get_graphic_section", wrapup ) ;

	/*
	 * Get profile area and length.
	 */
	vs$lengthAndAreaOfClPlCv( msg		= &msg,
				  curveId	= &section.obj_id,
				  curveEnv	= &section.mod_env,
				  length	= &sectionLength,
				  area		= &sectionArea ) ;

	__CheckRC( 1, msg, "vs$lengthAndAreaOfClPlCv", wrapup ) ;

	sts = VSgetBeamCentroidalAxis ( &msg,
					me->partObj._grid,
					&me->partObj.mod_env,
					&me->partObj.mod_env,
					&cntAxis );
	__CheckRC(sts,  msg, "vs$lengthAndAreaOfClPlCv", wrapup ) ;

	sts = om$send( msg = message GRcurve.GRtotlength (
						&msg,
						&me->partObj.mod_env.md_env.matrix_type,
						me->partObj.mod_env.md_env.matrix,
						&len1),
			targetid = cntAxis.objid,
			targetos = cntAxis.osnum );
	__CheckRC( sts, msg,"GRcurve.GRtotlength",wrapup ) ;

	sts = vs$bulk_delete ( 	grids = &cntAxis,
				theEnv = &me->partObj.mod_env,
				count = 1 );
	sectionLength = len1;
	/*
	 * Fill gadgets.
	 */
	vs$fillUnitField(	msg	= &msg,
			 	form	= form,
				field	= VS_K_pt_bm_Section_Length,
				osnum	= section._osnum,
				type	= GRIO_DISTANCE,
				value	= sectionLength ) ;

	vs$fillUnitField(	msg	= &msg,
			 	form	= form,
				field	= VS_K_pt_bm_Section_Area,
				osnum	= section._osnum,
				type	= GRIO_AREA,
				value	= sectionArea ) ;

	ex$message(	field		= ERROR_FIELD,
			justification	= CENTER_JUS,
			in_buff 	= "" ) ;

	wrapup :
		return OM_S_SUCCESS ;

#undef FILL_ASCII_FIELD		

} /* method fill_section_area_and_length */
/*----------------------------------------------------------------------------*/
method draw_section() {

	long			msg,
				sts ;
	char			*form = me->beamForm ;
	struct GRid		sectionDef ;
	VSdspRep		rep ;

#define weight 1

	/*
	 * Get the profile definition.
	 */
	sts = om$send( msg	= message VSbeam.VSgetProfileDef( &msg,
								  &sectionDef ),
		       targetos = me->partObj._osnum,
		       targetid = me->partObj._objid ) ;
	__CheckRC( sts, msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	/*
	 * Retrieve the representation of the beam.
	 */
	om$send(msg	= message ACncpx.ACget_NV_rep( &rep ),
		targetid= me->partObj._objid,
		targetos= me->partObj._osnum ) ;

	/*
	 * Draw the profile on the form.
	 */
	vs$draw_section_on_form( msg		= &msg,
				 form		= form,
				 gadget 	= VS_K_pt_bm_Area,
				 representation = rep,
				 weight 	= weight,
				 mod_env	= &me->cstEnv,
				 sectDef	= &sectionDef ) ;

	/*
	 * Display profile on the form.
	 */
	FIg_display( form, VS_K_pt_bm_Area ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method draw_section */
/*----------------------------------------------------------------------------*/
method hiliteBeamFace(	struct GRobj_env	*beam ;
			char			*faceName ;
			enum GRdpmode		mode ) {

	long			sts,
				msg ;
	VSdspRep		bmRep ;
	struct GRid		profileDef,
				displayedProfile,
				face ;
	struct GRobj_env	cachedSection ;
	int			faceIndex,
				count ;
	GRname			dspProfPath ;
	char			*cmpName ;
	extern char		DIR_G_car_dir ;

	/*
	 * Retrieve the representation of the beam.
	 */
	om$send( msg	  = message ACncpx.ACget_NV_rep( &bmRep ),
		 targetid = beam->_objid,
		 targetos = beam->_osnum ) ;

	if( bmRep & AC_ENV_REP ) goto wrapup ;

	if( !( bmRep & AC_2D_REP ) ) {
		struct GRmd_env	env ;
		
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
									&msg, faceName, &face,
									&env._MATRIX_TYPE,
									env._MATRIX ),
				targetid= beam->_objid,
				targetos= beam->_osnum ) ;
		
		if( sts & 1 & msg ) {
		  
		  env.md_id = me->partObj.mod_env.md_id ;
		  face.osnum = beam->_osnum;
		  vs$bulk_display(	grids	= &face,
					theEnv	= &env,
					dpmode	= mode ) ;
		  me->face = face ;
		}
		goto wrapup ;
	}
	sts = om$send(	msg	= message VSbeam.VSgetProfileDef(
							&msg, &profileDef ),
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;

	/*
	 * Use 3D rep since 2D rep profiles have no named faces.
	 */
	sts = VSextractCachedSection( &msg, &profileDef, AC_3D_REP,
					&cachedSection ) ;


	// TR179900646 face name may be invalid
	// cmpName = strrchr( faceName, DIR_G_car_dir ) + 1 ;
         cmpName = strrchr( faceName, DIR_G_car_dir );
	 if (cmpName) {
	   cmpName++;
	 
	   sts = om$send(msg = message VSxscurve.
			 VStransUsrNmToCmp(&msg, cmpName, &faceIndex, NULL ),
			 targetid= cachedSection._objid,
			 targetos= cachedSection._osnum ) ;
	   __CheckRC( sts, msg, "VSxscurve.VStransUsrNmToCmp", wrapup ) ;
	 }
	 
	sprintf( dspProfPath, "%s:%s", VS_K_bmGrCmpName, "xsec" ) ;

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						&msg, dspProfPath,
						&displayedProfile, NULL, NULL ),
			targetid= beam->_objid,
			targetos= beam->_osnum ) ;
	__CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = om$send(	msg	= message GRowner.GRget_components(
						&msg, &beam->mod_env,
						&face, 1, &count,
						faceIndex, faceIndex ),
			targetid= displayedProfile.objid,
			targetos= displayedProfile.osnum ) ;
	__CheckRC( sts, msg, "GRowner.GRget_components", wrapup ) ;

	vs$bulk_display(	grids	= &face,
				theEnv	= &beam->mod_env,
				dpmode	= mode ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method hiliteBeamFace */	
/*----------------------------------------------------------------------------*/
method window_notification( int form_label, event ; char *form ) {

	 struct	VSdpb_form_pos	*fmPos ;

	/*
	 * Draw profile if beam form is displayed.
	 */
	if( me->partType != VS_m_SRC_PLATE && event == FI_REFRESH )
		om$send( msg	= message VSpartdfCmd.draw_section(),
			 targetid = my_id ) ;

	/*
	 * Save location and size if changed.
	 */
	if( event == FI_CHANGED_SIZE || event == FI_CHANGED_LOCATION ) {
		int	screen,
			x,
			y,
			width,
			height ;

		VSf_get_layout( form, &screen, &x, &y, &width, &height ) ;

		fmPos = me->partType == VS_m_SRC_PLATE	? &plateForm_pos
							: &beamForm_pos ;

		fmPos->screen	= screen ;
		fmPos->x	= x ;
		fmPos->y	= y ;
		fmPos->width	= width ;
		fmPos->height	= height ;	
	}

	return OM_S_SUCCESS ;

} /* method window_notification */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		sts,
			msg ;
	struct GRid	face ;
	char		name[DI_PATH_MAX] ;
	char		basename[DI_PATH_MAX],
			fullname[DI_PATH_MAX] ;
	int		sel,
			pos,
			rsp ;

	*basename = '\0' ;

	if( form_label == VS_K_UATTR_LABEL ) {
	  char *masterForm ;
	  char attrname[DI_PATH_MAX] ;

	  /*
	   * Sub-form of user attributes.
	   */
	  masterForm = me->partType == VS_m_SRC_PLATE ? me->plateForm :
							me->beamForm ;

	  switch( gadget_label ) {
	    case FI_CANCEL	:
	      VSf_resetCopyPasteInfo( form_ptr ) ;
	      FIf_delete( form_ptr ) ;
	      me->usrAttrForm = NULL ;
	      break ;

	    case VS_K_UATTR_FLD	:
	      FIfld_get_text( form_ptr, gadget_label, (int) value, 0,
	      		      DI_PATH_MAX, (unsigned char *) attrname, &sel,
			      &pos ) ;
	      DIstmcpy( basename, VS_K_prUsrAttr, attrname, NULL ) ;
	      form_ptr = masterForm ;			
	      break ;
	  }

	} /* Else this is for the master form. */

	if( form_label == VS_K_MASTER_LABEL ) switch( gadget_label ) {

	  case FI_CANCEL :
	    if( VS_K_CmdIsStacked == me->flag ) {
	      /*
 	       * Just cleanup the command when it is stacked:
 	       * the command will be deleted when the command stack is emptied.
	       * BEWARE: form_ptr is no longer valid now since form has been
	       * deleted in `cleanUp()'
 	       */
	      om$send( msg = message VSpartdfCmd.cleanUp(), targetid = my_id ) ;
	      me->flag = VS_K_DelWhenStacked ;

	    } else if( VS_K_CmdNotStacked == me->flag ) {

		rsp = TERMINATE ;
		ex$putque( msg = &msg, response = &rsp ) ;
	    }
	    break ;

	  case FI_RESET :
		/* Commented Sundar during Fix TR # 179600098
	    om$send( msg = message VSpartdfCmd.cleanUp(), targetid = my_id ) ;
		*/

		/* Added Sundar during Fix TR # 179600098 */
                { char *fm ;
                        fm = me->partType == VS_m_SRC_PLATE   ? me->plateForm
				 : me->beamForm ;
                        FIg_disable(fm,VS_K_pt_UsrAttr);
                }
 
                /* Added Sundar during Fix TR # 179600098 */
                if( me->usrAttrForm ) {
                        VSf_resetCopyPasteInfo( me->usrAttrForm ) ;
                        FIf_delete( me->usrAttrForm ) ;
                        me->usrAttrForm = NULL ;
                }
 

	    /*
	     * Force command into the locate state.
	     */

	    rsp = VS_K_LocStructElm ;
	    ex$putque( msg = &msg, response = &rsp ) ;
	    if( VS_K_CmdIsStacked == me->flag ) {
	      /* The command is stacked: make it active again by putting in on
	       * top of the command stack.
               */
	       COm_make_command_active( my_id, OM_Gw_current_OS ) ;
	    }
	    break ;

	  case VS_K_pt_Scroll_Bar 	:
	   FIgrp_callback( form_ptr, VS_K_pt_Grp_to_Scroll,
				VSscroll_field, (int) value ) ;
	   break ;

	  case VS_K_pt_CopyBtn		:
	    VSf_CopyFromForm( form_ptr ) ;
	    break ;

	case VS_K_pt_PutQueue		:
	  if( !IF_NULL_OBJID( me->face.objid ) ) {

	    VSputObjectToQueue(	&msg, me->face.objid, me->face.osnum,
				&me->partObj.mod_env, BACK ) ;
          }
          FIg_set_state_off( form_ptr, gadget_label ) ;

	  break ;
		
	  case VS_K_pt_Faces		:
	   /*
	    * Highlight selected face.
	    */
	   FIfld_get_text( form_ptr, gadget_label, (int) value, 0, DI_PATH_MAX,
			   (unsigned char *) name, &sel, &pos ) ;

	   dp$erase_hilite( msg = &msg ) ;

	   if( me->partType == VS_m_SRC_PLATE ) {

	     struct GRmd_env	env ;
	     sts = om$send( msg    = message NDmacro.ACreturn_foot(
					&msg, name, &face,
					&env._MATRIX_TYPE, env._MATRIX ),
			    targetid= me->partObj._objid,
			    targetos= me->partObj._osnum ) ;
/*
 printf("name: [%s]\n", name);
 printf("me->partObj:[%d,%d]\n", me->partObj._objid, me->partObj._osnum);
 printf("face: [%d,%d]\n", face.objid, face.osnum);
 printf("sts = %d, msg = %d\n", sts, msg);
*/
	      if( sts & 1 & msg ) {
		env.md_id = me->partObj.mod_env.md_id ;
		vs$bulk_display( grids = &face, theEnv = &env, dpmode = GRhd ) ;
		me->face = face ;
	      }
	    } else {
	      om$send( msg	= message VSpartdfCmd.hiliteBeamFace(
						    &me->partObj, name, GRhd ),
		       targetid = my_id ) ;
	    }
	    break ;

	  case VS_K_pt_UsrAttr	:
	    if( !me->usrAttrForm ) {
	      VScreateUsrAttrForm( form_ptr, VS_K_UATTR_LABEL, my_id,
				   &me->partObj._grid, &me->usrAttrForm ) ;
							
	    }
	    FIg_set_state_off( form_ptr, VS_K_pt_UsrAttr ) ;
	    break ;

	  default : break ;

	}
	if( form_label == VS_K_MASTER_LABEL && me->partType == VS_m_SRC_BEAM ) {

		switch( gadget_label ) {
			case VS_K_pt_bm_Section_Parameters	:

				FIfld_get_text(	form_ptr,
						gadget_label,
						(int) value,
						0,
						DI_PATH_MAX,
						(unsigned char *) basename,
						&sel,
						&pos ) ;
				break ;
		}
	}
	if( form_label == VS_K_MASTER_LABEL ) switch( gadget_label ) {

	case VS_K_pt_Faces		:
		/*
		 * For beams, check that face is available, ie. if
		 * beam is in linear rep., faces are *NOT* here.
		 */
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						&msg, name, &face, NULL, NULL ),
				targetid= me->partObj._objid,
				targetos= me->partObj._osnum ) ;
/*
 printf("---------------------------------\n");
 printf("name: [%s]\n", name);
 printf("me->partObj:[%d,%d]\n", me->partObj._objid, me->partObj._osnum);
 printf("face: [%d,%d]\n", face.objid, face.osnum);
 printf("sts = %d, msg = %d\n", sts, msg);
*/
		if( sts & 1 & msg ) {
			FIfld_get_text(	form_ptr,
					gadget_label,
					(int) value,
					0,
					DI_PATH_MAX,
					(unsigned char *) basename,
					&sel,
					&pos ) ;
		} else {
			*basename = '\0' ;
		}
		break ;
		
	case VS_K_pt_Material_Type	:
		strcpy( basename, VS_K_prMatTypAttr ) ; break ;

	case VS_K_pt_Material_Grade	:
		strcpy( basename, VS_K_prMatGrdAttr ) ; break ;

	case VS_K_pt_Part_Type		:
		strcpy( basename, VS_K_prPrtFamAttr ) ; break ;

	case VS_K_pt_Part_Number	:
		strcpy( basename, VS_K_prPrtNumAttr ) ; break ;

	}

	if( *basename ) {
		*fullname = '\0' ;
		om$send(msg	= message GRvg.GRgetname( &msg, fullname ),
			targetid= me->partObj._objid,
			targetos= me->partObj._osnum ) ;
		if( *fullname ) {
			di$strcat(	to	= fullname,
					from	= basename ) ;
		} else {
			strcpy(	fullname, 
				VSmsgkey2string( VS_gI_UnnamedObject ) ) ;
		}
		
		FIfld_set_text(	form_ptr,
				VS_K_pt_Path,
				0, 0,
				fullname,
				FALSE ) ;
		VS_Wait_timer( 10 ) ;
		FIfld_set_select( form_ptr, gadget_label, (int) value, 0, FALSE ) ;
	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method initial_form_notification(
  int	 form_label;		/* label of form which received user  input */
  int	 gadget_label;		/* gadget label  which received user  input */
  double value;			/* value of gadget ( or field row # )	    */
  char * form_ptr ) {		/* ptr to I/Forms form which received input */


	VSf_storeCopyPasteInfo( form_ptr, gadget_label ) ;

	return OM_S_SUCCESS ;

} /* method initial_form_notification */
end implementation VSpartdfCmd;

