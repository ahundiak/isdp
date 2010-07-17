/*
	I/STRUCT
*/
class implementation VSmdstelCmd ;

#include <stdio.h>
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "COBmacros.h"
#include "comiscmac.h"
#include "lcdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "EMSmsgdef.h"
#include "vsdef.h"
#include "vsglobalmsg.h"
#include "vsmdformdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "vscmddef.h"
#include "vsdpb.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsformproto.h"
#include "vsgrenvproto.h"

%safe
     static struct   VSdpb_form_pos	form_pos = { 0, 0, 0, 0, 0 } ;
%endsafe


from VSpart	import	VSgetUserEditableAttr ;
from GRgrset	import	GSobject_add,
			GSremove_member ;

#define PL	0
#define BM	1
#define SF	2

#define VS_K_message_set	0x01
#define VS_K_command_stacked	0x02

/*----------------------------------------------------------------------------*/
method init( int type ; char *str_ptr ) {

	/*
	 * Initialize instance data.
	 */
	me->GSelement[PL].objid  = NULL_OBJID ;
	me->GSelement[BM].objid  = NULL_OBJID ;
	me->GSelement[SF].objid  = NULL_OBJID ;
	me->nb_of_elements[PL]	 = 0 ;
	me->nb_of_elements[BM]	 = 0 ;
	me->nb_of_elements[SF]	 = 0 ;
	me->element_type	 = -1 ;
	me->flag		 = 0 ;

	me->ret = om$send( msg	= message VSlocateCmd.init( type, str_ptr ),
			   mode = OM_e_wrt_message,
			   targetid= my_id ) ;

	/*
	 * Put last location and size to the form.
	 */
	if( form_pos.x		||
	    form_pos.y		||
	    form_pos.width	||
	    form_pos.height	||
	    form_pos.screen	) {

		VSf_set_layout( me->forms[0].form_ptr,
				form_pos.screen,
				form_pos.x,
				form_pos.y,
				form_pos.width,
				form_pos.height ) ;
	}

	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	om$send( msg	  = message VSlocateCmd.sleep( pos ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	me->flag |= VS_K_command_stacked ;

	/*
	 * If one modification was selected, unhighlight corresponding
	 * graphic set.
	 */
	if( me->element_type != -1 )
		vs$bulk_display( count	= 1,
				 dpmode = GRhe,
				 grids	= &me->GSelement[me->element_type],
				 theEnv = &me->cstEnv ) ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	long	msg = MSSUCC ;
	int	i,
		number,
		update_form = FALSE ;

	om$send( msg	  = message VSlocateCmd.wakeup( pos ),
		 mode	  = OM_e_wrt_message,
		 targetid = my_id ) ;

	/*
	 * If command stacked, see if located elements still exist.
	 */
	if( me->flag & VS_K_command_stacked ) {
		for( i=0; i<3; i++ ) {
			if( IF_NULL_OBJID( me->GSelement[i].objid ) ) continue ;

			gr$gsinqcount(	msg		= &msg,
					count		= &number,
					object_id	= &me->GSelement[i] ) ;
			__CheckRC( 1, msg, "gr$gsinqcount", wrapup ) ;

			if( number != me->nb_of_elements[i] ) {
				me->nb_of_elements[i] = number ;
				update_form = TRUE ;
			}
		}

		/*
		 * Update form, if one element was lost.
		 */
		if( update_form )
			om$send(msg	= message VSmdstelCmd.update_form(
								 (int *) &msg ),
				targetid= my_id ) ;
	}

	/*
	 * Highlight corresponding graphic set if one modification was selected.
	 */
	if( me->element_type != -1 )
		vs$bulk_display( count	= 1,
				 dpmode = GRhd,
				 grids	= &me->GSelement[me->element_type],
				 theEnv = &me->cstEnv ) ;

	me->flag &= ~VS_K_command_stacked ;

	wrapup :
		if( !(msg & 1) ) {
			me->stskey = VS_gE_ErrEncCmdTrm ;
			om$send( msg	  = message VSlocateCmd.abortCmd( &msg),
				 targetid = my_id ) ;

			VS_Wait_timer( 40 ) ;
		}
		return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ) {

	int	i,
		notUsed = 0 ;
	long	msg ;

	/*
	 * Dissolve created graphic sets.
	 */
	for( i=0; i<3; i++ ) {
		if( IF_NULL_OBJID( me->GSelement[i].objid ) ) continue ;

		gr$gsdissolve( msg = &msg, object_id= &me->GSelement[i] ) ;
	}

	/*
	 * Save last location and size of form.
	 */
	VSget_form_pos( me->forms[0].form_ptr, &form_pos ) ;

	om$send(msg	= message VSlocateCmd.delete( notUsed ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method store_element( long *msg ) {

	int			sts,
				properties = LC_DP_ONLY | LC_LC_ONLY | LC_RW ;
	unsigned long		type,
				attr ;
	struct GRid		gs ;
	struct GRlc_info	*element = me->event1.located_object ;

	/*
	 * See what object is.
	 */
	sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attr ),
		       targetid = me->event1.located_object[0].located_obj.objid,
		       targetos = me->event1.located_object[0].located_obj.osnum ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	me->nb_of_elements[PL] = type == VS_m_SRC_PLATE ? 1 : 0 ;
	me->nb_of_elements[BM] = type == VS_m_SRC_BEAM	? 1 : 0 ;
	me->nb_of_elements[SF] = type == VS_m_STF_BEAM	? 1 : 0 ;

	me->element_type       = -1 ;

	/*
	 * Create graphic set.
	 */
	sts = gr$gsinit( msg	      = msg,
			 flag	      = 2,
			 p_objid      = &gs.objid,
			 osnum	      = me->ModuleInfo.md_id.osnum ) ;
	__CheckRC( sts, *msg, "gr$gsinit", wrapup ) ;

	gs.osnum = me->ModuleInfo.md_id.osnum ;

	/*
	 * Add element to graphic set.
	 */
	sts = om$send( msg	= message GRgrset.GSobject_add(
							msg,
							&element->located_obj,
							&element->module_info,
							&properties,
							NULL,
							NULL ),
		       targetid = gs.objid,
		       targetos = gs.osnum ) ;
	__CheckRC( sts, *msg, "GRgrset.GSobject_add", wrapup ) ;

	me->GSelement[PL].objid = type == VS_m_SRC_PLATE ? gs.objid : NULL_OBJID ;
	me->GSelement[BM].objid = type == VS_m_SRC_BEAM  ? gs.objid : NULL_OBJID ;
	me->GSelement[SF].objid = type == VS_m_STF_BEAM  ? gs.objid : NULL_OBJID ;

	me->GSelement[PL].osnum = gs.osnum ;
	me->GSelement[BM].osnum = gs.osnum ;
	me->GSelement[SF].osnum = gs.osnum ;

	wrapup :
		*msg = (*msg & sts & 1) ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method store_element */
/*----------------------------------------------------------------------------*/
method process_fence( long *msg ) {

	int			sts = OM_S_SUCCESS,
				nbElement,
				i,
				index,
				properties = LC_DP_ONLY | LC_LC_ONLY | LC_RW,
				GScreated[3] ;
	unsigned long		type,
				attr ;
	struct GRobj_env	fence,
				*element ;

	/*
	 * Retrieve elements of fence.
	 */
	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				p_count 	= &nbElement,
				p_content	= &element,
				response	= me->response,
				response_data	= me->response_data ) ;
	if( *me->response != EX_DATA || !nbElement ) {
		*msg = VS_K_NO_FENCE ; return OM_S_SUCCESS ;
	}
	if( !(*msg & 1) ) { *msg = VS_K_RESTART_CMD ; return OM_S_SUCCESS ; }

	/*
	 * Store element.
	 */
	GScreated[PL] = GScreated[BM] = GScreated[SF] = FALSE ;

	me->nb_of_elements[PL] = 0 ;
	me->nb_of_elements[BM] = 0 ;
	me->nb_of_elements[SF] = 0 ;

	for( i=0; i<nbElement; i++ ) {

		/*
		 * Retrieve type of element.
		 */
		sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attr ),
			       targetid = element[i]._objid,
			       targetos = element[i]._osnum ) ;
		__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

		switch( type ) {
			case VS_m_SRC_PLATE	: index = PL ; break ;
			case VS_m_SRC_BEAM	: index = BM ; break ;
			case VS_m_STF_BEAM	: index = SF ; break ;
			default 		: index = -1 ; break ;
		}

		/*
		 * Add element to corresponding graphic set.
		 */
		if( index != -1 ) {
			/*
			 * If corresponding graphic set was not created,
			 * create it.
			 */
			if( !GScreated[index] ) {

				sts = gr$gsinit( msg	 = msg,
						 flag	 = 2,
						 p_objid = &me->GSelement[index].objid,
						 osnum	 = me->ModuleInfo.md_id.osnum ) ;
				__CheckRC( sts, *msg, "gr$gsinit", wrapup ) ;

				me->GSelement[index].osnum =
						    me->ModuleInfo.md_id.osnum ;

				GScreated[index] = TRUE ;
			}

			/*
			 * Add element to graphic set.
			 */
			sts = om$send( msg	= message GRgrset.GSobject_add(
							msg,
							&element[i]._grid,
							&element[i].mod_env,
							&properties,
							NULL,
							NULL ),
				       targetid = me->GSelement[index].objid,
				       targetos = me->GSelement[index].osnum ) ;
			__CheckRC( sts, *msg, "GRgrset.GSobject_add", wrapup ) ;

			me->nb_of_elements[index]++ ;
		}

	}

	me->element_type	 = -1 ;

	for( i=0; i<3; i++ )
		if( !GScreated[i] ) {
			me->GSelement[i].objid = NULL_OBJID ;
			me->GSelement[i].osnum = me->ModuleInfo.md_id.osnum ;
		}

	/*
	 * Unhighlight fence.
	 */
	vs$bulk_display( count	= 1, dpmode = GRhe, objenvs = &fence ) ;

	wrapup :
		_FREE( element ) ;
		*msg = (*msg & sts & 1) ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method reset_form( int * sts ) {

	char	*fm_ptr = me->forms[0].form_ptr ;

	FIg_enable( fm_ptr, VS_K_md_btn_plate	  ) ;
	FIg_set_state_off( fm_ptr, VS_K_md_btn_plate	 ) ;

	FIg_enable( fm_ptr, VS_K_md_btn_beam	  ) ;
	FIg_set_state_off( fm_ptr, VS_K_md_btn_beam	 ) ;

	FIg_enable( fm_ptr, VS_K_md_btn_stiffener ) ;
	FIg_set_state_off( fm_ptr, VS_K_md_btn_stiffener ) ;

	FIg_enable( fm_ptr, VS_K_md_btn_drop  ) ;
	FIg_set_state_off( fm_ptr, VS_K_md_btn_drop	 ) ;

	return OM_S_SUCCESS ;

} /* method reset_form */
/*----------------------------------------------------------------------------*/
method unhilight_gs( int *sts ) {

	if( me->element_type != -1 )
		vs$bulk_display( count	= 1,
				 dpmode = GRhe,
				 grids	= &me->GSelement[me->element_type],
				 theEnv = &me->cstEnv ) ;

	return OM_S_SUCCESS ;

} /* method unhilight_gs */
/*----------------------------------------------------------------------------*/
method hilight_gs( int *sts ) {

	if( me->element_type != -1 )
		vs$bulk_display( count	= 1,
				 dpmode = GRhd,
				 grids	= &me->GSelement[me->element_type],
				 theEnv = &me->cstEnv ) ;

	return OM_S_SUCCESS ;

} /* method hilight_gs */
/*----------------------------------------------------------------------------*/
method update_form( int *sts ) {

	char	*fm_ptr = me->forms[0].form_ptr ;

	/*
	 * Display number of located elements.
	 */
	FIfld_set_value( fm_ptr, VS_K_md_fld_plate,	0, 0,
			 (double) me->nb_of_elements[PL], FALSE ) ;

	FIfld_set_value( fm_ptr, VS_K_md_fld_beam,	0, 0,
			 (double) me->nb_of_elements[BM], FALSE ) ;

	FIfld_set_value( fm_ptr, VS_K_md_fld_stiffener, 0, 0,
			 (double) me->nb_of_elements[SF], FALSE ) ;

	if( !me->nb_of_elements[PL] ) {
		FIg_disable( fm_ptr, VS_K_md_btn_plate	   ) ;
		if( me->element_type == PL ) {
			/*
			 * In this case, that means there were elements inside
			 * graphic set of plates and the modification of plates
			 * was selected, so change the value of
			 * 'me->element_type' and set button back off.
			 */
			me->element_type = -1 ;
			FIg_set_state_off( fm_ptr, VS_K_md_btn_plate ) ;
		}
	}

	if( !me->nb_of_elements[BM] ) {
		FIg_disable( fm_ptr, VS_K_md_btn_beam	   ) ;
		if( me->element_type == BM ) {
			/*
			 * In this case, that means there were elements inside
			 * graphic set of beams and the modification of beams
			 * was selected, so change the value of
			 * 'me->element_type' and set button back off.
			 */
			me->element_type = -1 ;
			FIg_set_state_off( fm_ptr, VS_K_md_btn_beam ) ;
		}
	}

	if( !me->nb_of_elements[SF] ) {
		FIg_disable( fm_ptr, VS_K_md_btn_stiffener ) ;
		if( me->element_type == SF ) {
			/*
			 * In this case, that means there were elements inside
			 * graphic set of stiffeners and the modification of
			 * stiffeners was selected, so change the value of
			 * 'me->element_type' and set button back off.
			 */
			me->element_type = -1 ;
			FIg_set_state_off( fm_ptr, VS_K_md_btn_stiffener ) ;
		}
	}

	/*
	 * See if there already are elements to modify. Because located
	 * elements may have been lost if use of commands like 'delete' or
	 * 'drop' was made.
	 */
	if( !me->nb_of_elements[PL] &
	    !me->nb_of_elements[BM] &
	    !me->nb_of_elements[SF] ) {

		long	msg ;
		int	response ;

		ex$message( msgnumb = VS_gE_PreLocObjLost ) ;
		FIg_disable( fm_ptr, VS_K_md_btn_drop ) ;
		FIg_set_state_off( fm_ptr, VS_K_md_btn_drop ) ;

		VS_Wait_timer( 50 ) ;

		response = EX_BACK_UP ;
		ex$putque( msg = &msg, response = &response ) ;
	}

	return OM_S_SUCCESS ;

} /* method update_form */
/*----------------------------------------------------------------------------*/
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		msg ;
	int		rsp ;

	if( me->flag & VS_K_message_set ) {
		FIg_set_text( form_ptr, VS_K_md_fld_message, "" ) ;
		me->flag &= ~VS_K_message_set ;
	}

	switch( gadget_label ) {

		case VS_K_md_Dismiss		:
			rsp = TERMINATE ;
			ex$putque( msg = &msg, response = &rsp ) ;
			break ;

		case VS_K_md_Execute		:
			 if( me->element_type == -1 ) {
				char	text[MS_MAX_MSG_LENGTH] ;
				ex$message( msgnumb = VS_gE_NoModifSelect,
					    buff    = text ) ;
				FIg_set_text( form_ptr, VS_K_md_fld_message,
					      text ) ;
				me->flag |= VS_K_message_set ;
				break ;
			 }
			 om$send( msg	   = message
					   VSmdstelCmd.execute_command( &msg ),
				  targetid = my_id ) ;
			 if( !(msg & 1) )
				ex$message( msgnumb = VS_gE_CannotExecCmd ) ;
			 break ;

		case VS_K_md_btn_plate		:
			if( me->element_type == PL ) break ;

			/*
			 * Unhighlight old GS.
			 */
			if( me->element_type != -1 )
				vs$bulk_display( count	= 1,
						 dpmode = GRhe,
						 grids	= &me->GSelement[me->element_type],
						 theEnv = &me->cstEnv ) ;
			/*
			 * Highlight GS.
			 */
			me->element_type = PL ;

			vs$bulk_display( count	= 1,
					 dpmode = GRhd,
					 grids	= &me->GSelement[PL],
					 theEnv = &me->cstEnv ) ;
			break ;

		case VS_K_md_btn_beam		:
			if( me->element_type == BM ) break ;

			/*
			 * Unhighlight old GS.
			 */
			if( me->element_type != -1 )
				vs$bulk_display( count	= 1,
						 dpmode = GRhe,
						 grids	= &me->GSelement[me->element_type],
						 theEnv = &me->cstEnv ) ;
			/*
			 * Highlight GS.
			 */
			me->element_type = BM ;

			vs$bulk_display( count	= 1,
					 dpmode = GRhd,
					 grids	= &me->GSelement[BM],
					 theEnv = &me->cstEnv ) ;
			break ;

		case VS_K_md_btn_stiffener	:
			if( me->element_type == SF ) break ;

			/*
			 * Unhighlight old GS.
			 */
			if( me->element_type != -1 )
				vs$bulk_display( count	= 1,
						 dpmode = GRhe,
						 grids	= &me->GSelement[me->element_type],
						 theEnv = &me->cstEnv ) ;
			/*
			 * Highlight GS.
			 */
			me->element_type = SF ;

			vs$bulk_display( count	= 1,
					 dpmode = GRhd,
					 grids	= &me->GSelement[SF],
					 theEnv = &me->cstEnv ) ;
			break ;

		case VS_K_md_btn_drop		:
			rsp = VS_K_DROP_ELEM ;
			ex$putque( msg = &msg, response = &rsp ) ;
			break ;
	}
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/
method execute_command( long *msg ) {

	long		sts,
			size ;
	int		response ;
	char		cmd[20] ;
	struct GRevent	event ;

	/*
	 * Put accept point onto software queue because the element passed
	 * through to the command is a graphic set and the 'Modify ...'
	 * command sees the graphic set as a fence.
	 */

	response = EX_DATA ;

	sts = ex$putque( msg		= msg,
			 pos		= BACK,
			 response	= &response ) ;
	__CheckRC( sts, *msg, "ex$putque", wrapup ) ;

	/*
	 * Put graphic set onto software queue.
	 */
	co$build_button( msg	  = msg,
			 objid	  = me->event1.event.button.objid,
			 osnum	  = me->event1.event.button.osnum,
			 button   = &event.event.button ) ;

	event.num_id = 1 ;
	event.located_object[0].located_obj = me->GSelement[me->element_type] ;
	event.located_object[0].module_info = me->ModuleInfo ;

	response = EX_OBJID ;

	size = sizeof( struct GRevent ) - 2*sizeof( long ) ;

	sts = ex$putque( msg		= msg,
			 pos		= FRONT,
			 response	= &response,
			 byte		= &size,
			 buffer 	= (char *) &event.event.button ) ;
	__CheckRC( sts, *msg, "ex$putque", wrapup ) ;

	/*
	 * Put 'Modify ...' command onto software queue.
	 */
	switch( me->element_type ) {
		case PL : strcpy( cmd, "VSMdPl" ) ; break ;
		case BM : strcpy( cmd, "VSMdBm" ) ; break ;
		case SF : strcpy( cmd, "VSMdSt" ) ; break ;
	}

	response = EX_CMD_KEY ;

	size = 1 + strlen( cmd ) ;

	sts = ex$putque( msg		= msg,
			 pos		= FRONT,
			 response	= &response,
			 byte		= &size,
			 buffer 	= cmd ) ;
	__CheckRC( sts, *msg, "ex$putque", wrapup ) ;

	wrapup :
		if( !(sts & 1 & *msg) ) {
			/*
			 * Clear software queue.
			 */
			 ex$clear_event_queue() ;
			 *msg = MSFAIL ;
		} else *msg = MSSUCC ;

	return OM_S_SUCCESS ;

} /* method execute_command */
/*----------------------------------------------------------------------------*/
method dissolve_gs( long *msg ) {

	int	i ;

	*msg = MSSUCC ;

	/*
	 * Dissolve created graphic sets.
	 */
	for( i=0; i<3; i++ ) {
		if( IF_NULL_OBJID( me->GSelement[i].objid ) ) continue ;

		gr$gsdissolve( msg	= msg,
			       object_id= &me->GSelement[i] ) ;
		__CheckRC( 1, *msg, "gr$gsdissolve", wrapup ) ;

		me->GSelement[i].objid = NULL_OBJID ;

		me->nb_of_elements[i] = 0 ;
	}

	me->element_type = -1 ;
	me->flag	 = 0 ;

	wrapup :
		*msg = *msg & 1 ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
	return OM_S_SUCCESS ;

} /* method dissolve_gs */
/*----------------------------------------------------------------------------*/
method drop_element( long *msg ) {

	long			sts ;
	unsigned long		type,
				attr ;
	int			element_type, i, nbElement ;
	struct GRobj_env	fence,
				*element ;
	/*
	 * Retrieve elements of fence.
	 */
	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= msg,
				fence		= &fence,
				classList	= me->locate_eligible,
				p_count 	= &nbElement,
				p_content	= &element,
				response	= me->response,
				response_data	= me->response_data ) ;
	if( *me->response != EX_DATA || !nbElement ) {
		*msg = VS_K_NO_FENCE ; return OM_S_SUCCESS ;
	}
	if( !(*msg & 1) ) { *msg = VS_K_RESTART_CMD ; return OM_S_SUCCESS ; }

	for( i=0; i<nbElement; i++ ) {

		/*
		 * See what object is.
		 */
		sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							msg, &type, &attr ),
				targetid = element[i]._objid ,
				targetos = element[i]._osnum );
		__CheckRC( sts, *msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

		/*
		 * Retrieve corresponding graphic set.
		 */
		switch( type ) {
			case VS_m_SRC_PLATE	: element_type = PL ;  break ;
			case VS_m_SRC_BEAM	: element_type = BM ;  break ;
			case VS_m_STF_BEAM	: element_type = SF ;  break ;
			default			: vs$inv_arg() ;
		}

		/*
		 * Remove located object from graphic set.
		 */
		sts = om$send( msg	= message GRgrset.GSremove_member(
					    msg,
					    &element[i].obj_id),
			       targetid = me->GSelement[element_type].objid,
			       targetos = me->GSelement[element_type].osnum ) ;
		__CheckRC( sts, *msg, "GRgrset.GSremove_member", wrapup ) ;

		/*
		 * Update count.
		 */
		switch( element_type ) {
			case PL : me->nb_of_elements[PL]-- ; break ;
			case BM : me->nb_of_elements[BM]-- ; break ;
			case SF : me->nb_of_elements[SF]-- ; break ;
		}
	}
	wrapup :
		*msg = (*msg & sts & 1) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
	return OM_S_SUCCESS ;

} /* method drop_element */
/*----------------------------------------------------------------------------*/
method locate_action_handler(	int			*keepIt ;
				enum GRlocate_action	*action ;
				struct GRlc_info	*entry ;
				struct LC_action_args	*args ) {

	long			msg,
				sts ;
	unsigned long		type,
				attr ;
	int			i,
				element_type,
				number ;
	struct GRobj_env	*element = NULL ;

	/*
	 * This method is executed by the filter locate through the action
	 * handler. Keep object which is inside one of the three graphic sets.
	 */

	sts = om$send( msg	= message VSpart.VSgetUserEditableAttr(
							&msg, &type, &attr ),
		       targetid = entry->located_obj.objid,
		       targetos = entry->located_obj.osnum ) ;
	__CheckRC( sts, msg, "VSpart.VSgetUserEditableAttr", wrapup ) ;

	switch( type ) {
		case VS_m_SRC_PLATE	: element_type = PL ; break ;
		case VS_m_SRC_BEAM	: element_type = BM ; break ;
		case VS_m_STF_BEAM	: element_type = SF ; break ;
		default			: vs$inv_arg( msg = &msg ) ;
	}

	/*
	 * See if corresponding graphic set exists.
	 */
	if( IF_NULL_OBJID( me->GSelement[element_type].objid ) ) {
		*keepIt = FALSE ; goto wrapup ;
	}

	/*
	 * Retrieve all elements from corresponding graphics of located
	 * object.
	 */
	gr$gsinqcount(	msg		= &msg,
			count		= &number,
			object_id	= &me->GSelement[element_type] ) ;
	__CheckRC( 1, msg, "gr$gsinqcount", wrapup ) ;

	element = _MALLOC( number, struct GRobj_env ) ;
	if( !element ) {
		msg = MSFAIL ;
		goto wrapup ;
	}

	gr$gsget_objects( msg		= &msg,
			  array 	= element,
			  size		= number * sizeof *element,
			  count 	= &number,
			  from_obj	= 0,
			  to_obj	= number - 1,
			  object_id	= &me->GSelement[element_type] ) ;
	__CheckRC( 1, msg, "gr$gsget_objects", wrapup ) ;

	/*
	 * See if object is inside list 'element'.
	 */
	for( i=0; i<number; i++ ) {
		if( element[i]._objid == entry->located_obj.objid &&
		    element[i]._osnum == entry->located_obj.osnum )
			break ;
	}

	*keepIt = i < number ;

	wrapup :
		_FREE( element ) ;
		if( !( msg & sts & 1 ) ) keepIt = FALSE ;

	return OM_S_SUCCESS ;

} /* method locate_action_handler */
/*----------------------------------------------------------------------------*/

end implementation VSmdstelCmd ;
