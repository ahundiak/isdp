/*
	I/STRUCT
*/
class implementation VSlocateCmd ;

#include <stdio.h>
#include <string.h>
%safe
#include <stdlib.h>
%endsafe
#include <FI.h>
#include "OMmacros.h"
#include "madef.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "griomacros.h" 
#include "expmacros.h"
#include "vsgraphicenv.h"
#include "vscmddef.h"
#include "vscmd.h"
#include "vsformdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsnamemacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "maidmx.h"
#include "LCptlocact.h"
#include "ASget_par.h"
#include "vsacthrproto.h"
#include "vsformproto.h"
#include "vsgrenvproto.h"

%safe
static struct GRobj_env *VSlocObjs = NULL;
static IGRint            locCount  = 0;
%endsafe

extern int	COB_FI_form_notification() ;
extern int	COB_FI_initial_form_notification() ;
/*----------------------------------------------------------------------------*/
method init( int type ; char *string ) {

	long			sts,
				numberOfBytes,
				BytesReceived ;
        _FREE(VSlocObjs);
	me->constructedObject.objid	= NULL_OBJID ;
	me->expression.objid		= NULL_OBJID ;
	me->suppressHilite		= FALSE ;
	me->PFAH			= NULL ;
	me->LCAHarg.rejectSts		= MS_NO_MSG ;

	om$send(	msg	= message CEO_LOCATE.init( type, string ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	di$pwd( dirname = me->Cwd ) ;

	numberOfBytes = sizeof me->cstEnv ;
	gr$get_module_env(	msg	= &sts,
				sizbuf	= &numberOfBytes,
				buffer	= &me->cstEnv,
				nret	= &BytesReceived ) ;
				
	/*
	 * When locating elements by fence, all elements will not be hilighted
	 * by filter locate with this mode for 'unhilight_mode'.
	 */
	me->UnhilightMode	= GRheo ; 
	me->previousNotification= NULL ;

	me->action_args		= NULL ;
	me->action_handler	= NULL ;

	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method wakeup( int pos ) {

	long		msg ;
	int		size,		/* Of a vla			*/
			i,		/* Loop-on-loc'd-objects index	*/
			objectLost ;	/* Did we lose an object ?	*/

	objectLost = FALSE ;

	om$send(msg	= message CEO_LOCATE.wakeup( pos ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	size = om$dimension_of( varray = me->locObjs ) ;

	for( i = 0 ; i < size ; i++ ) {
		if( !( om$is_objid_valid(
				objid	= me->locObjs[i]._objid,
				osnum	= me->locObjs[i]._osnum ) & 1 ) ) {
			me->stskey = VS_gE_PreLocObjLost ;
			objectLost = TRUE ;
			break ;
		}
	}
	if( objectLost ) {
		/*
		 * Some of the located objects have disappeared when
		 * command was stacked: bad, abort command.
		 */
		om$send(msg	= message VSlocateCmd.abortCmd( &msg ),
			targetid= my_id ) ;
	} else {
		/*
		 * Re-obtain directory where we sit since it may have changed.
		 */
		di$pwd( dirname = me->Cwd ) ;
		/*
		 * Get representation.
		 */
		vd$symbology(	msg	= &msg,
				symb_id	= &me->ModuleInfo.md_id,
				symb	= &me->ActiveRep ) ;

		if( !me->suppressHilite ) {
			om$send(msg	= message VSlocateCmd.dpLocObjs(
							       &msg, 0, GRhd ),
				targetid= my_id ) ;
		}
	}

	me->execFlags &= ~VS_m_CmdStacked ;

	me->ret = objectLost ? VS_K_RESTART_CMD : VS_K_ACT_SUCCESS ;

	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method sleep( int pos ) {

	long		msg ;

	om$send(msg	= message CEO_LOCATE.sleep( pos ),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	if( !me->suppressHilite ) {
		om$send(msg	= message VSlocateCmd.dpLocObjs( &msg, 0, GRhe),
			targetid= my_id ) ;
	}
	me->execFlags |= VS_m_CmdStacked ;

	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int dummy ) {

	om$send(msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
		targetid= my_id ) ;

	return om$send(	msg	= message CEO_LOCATE.delete( dummy ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

} /* method delete */
/*----------------------------------------------------------------------------*/
method addLocObj(	struct GRid	*objToAdd ;
			struct GRmd_env	*envToAdd ;
			int		index ) {

	long			sts ;
	int			size,
				i ;

	size = om$dimension_of( varray = me->locObjs ) ;

	/*
	 * Is object already stored ?.
	 */
	for( i = 0 ; i < size ; i++ ) {
		if( IF_EQ_GRID( *objToAdd, me->locObjs[i]._grid ) ) {

			sts = VS_K_OBJONCHEXIST ; goto wrapup ;
		}
	}

	if( index >= size ) {
		/*
		 * Add.
		 */
		if( index == OM_K_MAXINT ) {
			/*
			 * Add at the end.
			 */
			index = size ;
		}
		sts = om$vla_set_dimension(	varray	= me->locObjs,
						size	= index + 1 ) ;
		__CheckRC( sts, 1, "om$vla_set_dimension", wrapup ) ;
	} /* Else : replace */

	me->locObjs[index]._grid = *objToAdd ;

	if( envToAdd ) {
		me->locObjs[index].mod_env	= *envToAdd ;
	} else {
		ex$get_modid(	mod_osnum	= objToAdd->osnum,
				mod_id		= &me->locObjs[index]._md_id ) ;

		me->locObjs[index]._md_os	= objToAdd->osnum ;
		me->locObjs[index]._matrix_type = MAIDMX ;
		MAidmx( &sts, me->locObjs[index]._matrix ) ;
	}
				      
	sts = OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* method addLocObj */
/*----------------------------------------------------------------------------*/
method rmLastLocObjs( int from_index  ) {

	long		msg ;
	int		size ;

	size = om$dimension_of( varray = me->locObjs ) ;

	if( from_index >= size ) { goto wrapup ; }

	if( !me->suppressHilite ) {
	  om$send( msg     = message VSlocateCmd.dpLocObjs(
							&msg, from_index, GRhe),
		   targetid= my_id ) ;
	}
	om$vla_set_dimension( varray = me->locObjs, size = from_index ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method rmLastLocObjs */
/*----------------------------------------------------------------------------*/
method dpLocObjs( long *sts ; int from_index ; enum GRdpmode dpmode ) {

	int			count ;

	count = om$dimension_of( varray = me->locObjs ) ;

	if( !count ) { *sts = OM_I_CHAN_EMPTY ; goto wrapup ; }
	if( from_index >= count ) { *sts = OM_E_INVINDEX ; goto wrapup ; }

	vs$bulk_display(	objenvs	= me->locObjs + from_index,
				count	= count - from_index,
				dpmode	= dpmode ) ;
	*sts = OM_S_SUCCESS ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method dpLocObjs */
/*----------------------------------------------------------------------------*/
method getLocObjs( long *msg ; int size ; struct GRobj_env *list ) {

	long			sts ;
	int			count,
				i ;
	*msg = MSSUCC ;

	count = om$dimension_of( varray = me->locObjs ) ;

	if( !count ) { sts = OM_I_CHAN_EMPTY ; goto wrapup ; }

	if( size < count ) count = size ;

	for( i = 0 ; i < count ; i++ ) {
		list[i] = me->locObjs[i] ;
	}
	sts = OM_S_SUCCESS ;

	wrapup :
		return sts ;
	
} /* method getLocObjs */
/*----------------------------------------------------------------------------*/
method getLocObjAtIndex( long *msg ; int index ; struct GRobj_env *locObj ) {

	long			sts ;
	int			size ;

	size = om$dimension_of( varray = me->locObjs ) ;

	if( index >= size ) {
		*msg = MSINARG ; sts = OM_E_INVINDEX ; goto wrapup ;
	}
	*locObj = me->locObjs[index] ;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		return sts ;

} /* method getLocObjAtIndex */
/*----------------------------------------------------------------------------*/
method abortCmd( long *sts ) {

	ex$message(	msgnumb		= me->stskey,
			justification	= CENTER_JUS,
			field		= ERROR_FIELD,
			time		= 2 ) ;

	om$send(msg	= message VSlocateCmd.rmLastLocObjs( 0 ),
		targetid= my_id ) ;
	/*
	 * Force command to terminate.
	 */
	me->state = me->next_state = _terminate ;

	om$send(msg	= message CEO_LOCATE.action(	_go_next_state,
							NULL,
							(int *) &sts ),
		targetid= my_id ) ;

	return OM_S_SUCCESS ;

} /* method abortCmd */
/*- LOCATE GET-EVENT ETC. FOR COB --------------------------------------------*/
method filter( int filter, *response ; char *response_data ) {

	/*
	 * Implements filteer to locate/create an expression.
	 */
	long		sts ;
	long		msg ;
	struct GRid	expId ;
	double		expVal ;
	int		size = sizeof me->event1 ;
	int		tokenList[4],
			token ;

#define LOC_PARAM 22

	switch( filter ) {

	case VSget_exp :
	
	  /*
	   * This filter locates/creates an expression.
	   *
	   * The filter returns ERROR if the expression isn't created.
	   */
	 
	  tokenList[0] = EX_RJT_MOVEON ;
	  tokenList[1] = EX_STRING ;
	  tokenList[2] = GR_UNKNOWN_TYPE ;
	  tokenList[3] = LOC_PARAM ;

	  token = ASget_param(
			&msg,
			tokenList,
			&me->event1,
			&me->event2,		/* RELATED COB KEYWORDS	*/
			&me->event_mask1,	/* locate_mask		*/
			&me->event_mask2,	/* accept_mask		*/
			&size,
			&me->display_flag,	/* locate_display	*/
			response,
			response_data,
			me->prompt,		/* prompt_key		*/
			me->acc_prompt,		/* accept_key		*/
			me->reloc_prompt,	/* relocate_key		*/
			&me->attributes,	/* owner, props., etc.	*/
			&me->stack,		/* locate_stack		*/
			&expId,
			&expVal ) ;

	  /*
	   * Must do the following else CEO will ignore response.
	   */
	  me->event1.response = *response ;
		
	  switch( tokenList[token] ) {
			
	    case LOC_PARAM :
	      me->expression = expId ;
	      me->event1.located_object[0].located_obj = expId ;
	      break ;
			
	    case EX_STRING :
	      if( IF_NULL_OBJID( expId.objid ) ) {
	        /*
		 * The expression isn't created.
		 */
		me->ret = ERRO ;
	      }
	      break ;
				
	    case GR_UNKNOWN_TYPE :
	      if( *response == EX_STRING ) {
		/*
		 * the expression is a directory,
		 * the name of an element... but not
		 * an expression.
		 */
	        ex$message( msgnumb		= VS_gE_NotAnExp,
			    justification	= CENTER_JUS ) ;
		me->ret = ERRO ;
	      }
	      break ;
			
	    default :
	      break ;			
			
	  }
	
	  sts = OM_S_SUCCESS ;
	  break ;

	default :
	  /*
	   * Invoke regular COB filter.
	   */
	  sts = om$send( msg	 = message CEO_LOCATE.filter(
					      filter, response, response_data ),
			 mode	 = OM_e_wrt_message,
			 targetid= my_id ) ;
	  break ;

	case VSget_event_with_dynamics :
	  sts = om$send( msg	 = message VSlocateCmd.get_event_with_dynamics(
						      response, response_data ),
			 targetid= my_id ) ;
		break ;

	case VSlocateGadget		:
	  sts = om$send( msg	 = message VSlocateCmd.locateGadget(
						      response, response_data ),
			 targetid= my_id ) ;
	  break ;
					
	}

	return sts ;
#undef LOC_PARAM

} /* method filter */
/*----------------------------------------------------------------------------*/
#define NO_GADGET  (-1)
#define ACC_GADGET (-2)

method locateGadget(	int	*response ;
			char	*response_data ) {

	long		sts		= OM_S_SUCCESS,
			rc ;
	int		goOn		= FALSE,
			proposeNext	= FALSE,
			x, y,
			located ;
	char		savePrompt[_max_key] ;

	while( TRUE ) {

		if( goOn ) goOn = FALSE ;

		if( proposeNext ) {
			*response = VS_K_GADGET_LOCATED ;
		} else {
			om$send(msg	= message CEO.filter(
							_get_event,
							response,
							response_data ),
				targetid= my_id ) ;
		}

		switch( *response ) {

		case EX_RJT_MOVEON	 : goOn = FALSE ; break ;

		case VS_K_GADGET_LOCATED :

			FIg_hilite( me->locatedForm, me->locatedGadget ) ;

			if( !proposeNext ) {
				strcpy( savePrompt, me->prompt ) ;
				strcpy( me->prompt, me->acc_prompt ) ;
			} else	proposeNext = FALSE ;

			/*
			 * Set `me->locatedGadget' to -2 to tell
			 * processLocate we're in accept mode.
			 */
			located		  = me->locatedGadget ;
			me->locatedGadget = ACC_GADGET ;

			om$send(msg	= message CEO.filter(	_get_event,
								response,
								response_data ),
				targetid= my_id ) ;

			FIg_unhilite( me->locatedForm, located ) ;

			switch( *response ) {

			case VS_K_GADGET_LOCATED:
			case EX_DATA		:
				*response = VS_K_GADGET_LOCATED ;
				me->locatedGadget = located ;
				break ;

			case VS_K_FORM_MOVEON	:
			case EX_RJT_MOVEON	:
				/*
				 * This gadget rejected, propose next if any.
				 */
				rc = VSf_locate( me->locatedForm,
						 me->locGadgetArea,
						 &x,
						 &y,
						 &me->locatedGadget,
						 1 ) ;

				if(    rc == FI_SUCCESS
				    && me->locatedGadget != NO_GADGET ) {

					if( located != me->locatedGadget ) {
						goOn = proposeNext = TRUE ;

						break ;
					}
				}

				/*
				 * No other gadget to propose.
				 */
				strcpy( me->prompt, savePrompt ) ;

				ex$message(	
					msgnumb		= VS_gW_NoObjLoc,
					field		= ERROR_FIELD,
					justification	= CENTER_JUS ) ;

				goOn = TRUE ;

				break ;
		
			default			:
					break ;
			}
			break ;

			default			: break ;
		}
		if( !goOn ) break ;
	}

	return sts ;

} /* method locateGadget */
/*----------------------------------------------------------------------------*/
method processLocate( char *form ; int gadget ) {

	long	msg ;
	int	rc,
		x,
		y,
		acceptMode ;

	me->locGadgetArea = gadget ;

	switch( me->locatedGadget ) {

	case ACC_GADGET	: acceptMode = TRUE ; break ;

	default		:
		me->locatedForm = form ;
		rc = VSf_locate( form, gadget, &x, &y, &me->locatedGadget, 0 ) ;
		acceptMode = FALSE ;
		break ;
	}

	if( acceptMode ) {
		rc = VS_K_GADGET_LOCATED ;
		ex$putque( msg = &msg, response = &rc ) ;
	} else {
		if( rc == FI_SUCCESS && me->locatedGadget != NO_GADGET ) {

			rc = VS_K_GADGET_LOCATED ;
			ex$putque( msg = &msg, response = &rc ) ;

		} else {
			ex$message(	msgnumb		= VS_gW_NoObjLoc,
					field		= ERROR_FIELD,
					justification	= CENTER_JUS ) ;

		}
	}
	return OM_S_SUCCESS ;

#undef NO_GADGET
#undef ACC_GADGET

} /* method processLocate */
/*----------------------------------------------------------------------------*/
method get_event_with_dynamics( int	*response ;
				char	*response_data ) {

	long		sts,
			msg ;
	VSgrEnvEvent	events ;
	int		resp,
			wflag,
			isCollapsed,
			i,
			x,
			y,
			ox = -1,
			oy = -1 ;

	ex$message(	in_buff		= me->prompt,
			justification	= RIGHT_JUS ) ;
#if defined(ENV5)
	while( TRUE ) {
		if( VS_InqEvents( &events ) ) {
			if( VS_isBtnOrWnEvent( &events ) ) {
				if( !VS_FI_process_event( &events ) ) {
					if( VS_isWnEvent( &events ) ) {
						VS_DPhandle_event( &events ) ;
					} else break ;
				}
			} else if( VS_isKeyBoardEvent( &events ) ) {
				break ;
			}
		} else if( ex$peek_event_queue( resp = &resp ) ) {
			break ;
		}
		for( i = 0 ; i < VS_K_MAX_DYN_FORMS ; i++ ) {

			if( !me->dynFrm[i] ) continue ;
			sts = FIf_is_collapsed( me->dynFrm[i],
						&isCollapsed ) ;

			if( sts != FI_SUCCESS || isCollapsed ) continue ;

			if( VS_Mouseposition(	&me->dynWno[i],
						&x,
						&y,
						&wflag ) != 0 ) goto ENDLOOP ;

			if( wflag && ( ox != x || oy != y ) ) {

				ox = x ; oy = y ;

				sts = om$send(
					msg	= message VSlocateCmd.mouse(
							&msg, me->dynFrm[i],
							x, y ),
					targetid= my_id ) ;
				__CheckRC( sts, msg, "VSlocateCmd.mouse", ENDLOOP ) ;
				break ;
			}
		}
	}
	ENDLOOP :

	sts = om$send(	msg	= message CEO_LOCATE.filter(	_get_event,
								response,
								response_data ),
			targetid= my_id ) ;
#elif defined(X11)

        sts = om$send(  msg     = message CEO_LOCATE.filter(    _get_event,
                                                                response,
                                                                response_data ),
                        targetid= my_id ) ;

#else
#       omerror "Windowing system switches must be set!"
#endif
 
	return sts ;

} /* method get_event_with_dynamics */
/*----------------------------------------------------------------------------*/
method set_dynamics_in_form( long *msg ; char *form ) {

	long		sts ;
	VSgrEnvWindow	wno ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;
	me->ret	= VS_K_ACT_SUCCESS ;

	if( form && VS_FIf_get_window( form, &wno ) == FI_SUCCESS ) {
		int	i,
			slot = -1 ;

		for( i = 0 ; i < VS_K_MAX_DYN_FORMS ; i++ ) {
			if( me->dynFrm[i] == form ) {
				/*
				 * Already listed !.
				 */
				goto wrapup ;
			}
		}
		for( i = 0 ; i < VS_K_MAX_DYN_FORMS ; i++ ) {
			if( !me->dynFrm[i] ) { slot = i ; break ; }
		}
		if( slot != -1 ) {
			me->dynFrm[slot] = form ;
			me->dynWno[slot] = wno ;
		} else {
			/*
			 * No more room.
			 */
			*msg	= MSFAIL ;
			me->ret	= VS_K_ABORT_CMD ;
		}
	}
	wrapup :
		return sts ;

} /* method set_dynamics_in_form */
/*----------------------------------------------------------------------------*/
method stop_dynamics_in_form( long *msg ; char *form ; ) {

	long	sts ;
	int	i ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSFAIL ;
	me->ret	= VS_K_ABORT_CMD ;

	for( i = 0 ; i < VS_K_MAX_DYN_FORMS ; i++ ) {
		if( me->dynFrm[i] == form ) {
			me->dynFrm[i] = NULL ;
			*msg	= MSSUCC ;
			me->ret	= VS_K_ACT_SUCCESS ;
			break ;
		}
	}
	return sts ;

} /* method stop_dynamics_in_form */
/*----------------------------------------------------------------------------*/
method mouse( long *msg ; char *form ; int x, y ) {
	*msg = MSSUCC ; return OM_S_SUCCESS ;
} /* method mouse */
/*----------------------------------------------------------------------------*/
int VSlocateCmd_initial_notification( form_label, gadget, value, form )

int	form_label,
	gadget ;
double	value ;
char	*form ; {

	OM_S_OBJID	cmdId ;
	OMuword		cmdOs ;

	FIf_get_cmd_oid_os(	form,
				(unsigned int   *) &cmdId,
				(unsigned short *) &cmdOs ) ;

	om$send(msg	= message VSlocateCmd.initial_notification(
					form_label, gadget, value, form ),
		senderid= cmdId,
		targetid= cmdId,
		targetos= cmdOs ) ;

	return FI_SUCCESS ;

} /* VSlocateCmd_initial_notification */
/*----------------------------------------------------------------------------*/
method initial_notification(	int	form_label,
					gadget ;
				 double value ;
				 char	*form ) {
	return OM_S_SUCCESS ;

} /* method initial_notification */
/*----------------------------------------------------------------------------*/
int VSlocateCmd_window_event( form_label, event, form )

int	form_label,
	event ;
char	*form ; {

	OM_S_OBJID	cmdId ;
	OMuword		cmdOs ;

	FIf_get_cmd_oid_os(	form,
				(unsigned int   *) &cmdId,
				(unsigned short *) &cmdOs ) ;

	om$send(msg	= message VSlocateCmd.window_notification(
						form_label, event, form ),
		senderid= cmdId,
		targetid= cmdId,
		targetos= cmdOs ) ;

	return FI_SUCCESS ;

} /* VSlocateCmd_window_notification */
/*----------------------------------------------------------------------------*/
method window_notification(	int	form_label,
					event ;
				char	*form ) {
	return OM_S_SUCCESS ;

} /* method window_notification */
/*----------------------------------------------------------------------------*/
int VSlocateCmd_button_event(	form_label,
				xpos,
				ypos,
				button_number,
				transition,
				time_tag,
				form )

int	form_label,
	xpos,
	ypos,
	button_number,
	transition,
	time_tag ;
char	*form ; {

	OM_S_OBJID	cmdId ;
	OMuword		cmdOs ;
	int		rc ;

	FIf_get_cmd_oid_os(	form,
				(unsigned int   *) &cmdId,
				(unsigned short *) &cmdOs ) ;

	om$send(msg	= message VSlocateCmd.button_notification(
								form_label,
								xpos,
								ypos,
								button_number,
								transition,
								time_tag,
								form,
								&rc ),
		senderid= cmdId,
		targetid= cmdId,
		targetos= cmdOs ) ;

	return rc ;

} /* VSlocateCmd_button_event */
/*----------------------------------------------------------------------------*/
method button_notification(	int	form_label,
					xpos,
					ypos,
					button_number,
					transition,
					time_tag ;
				char	*form ;
				int	*rc ) {
	return OM_S_SUCCESS ;

} /* method button_notification */
/*----------------------------------------------------------------------------*/
method formCreationByPtr( int label ; char *file, **form ) {

	int	rc ;

	rc = FIf_new(	label,
			file,
			COB_FI_form_notification,
			form ) ;

	if( rc == FI_SUCCESS ) {
		FIf_set_cmd_oid_os( *form, my_id, OM_Gw_current_OS ) ;
		me->ret = VS_K_ACT_SUCCESS ;
	} else {
		*form = NULL ;
		me->ret = VS_K_ABORT_CMD ;
	}
	return OM_S_SUCCESS ;

} /* method formCreationByPtr */
/*----------------------------------------------------------------------------*/
method formOpByPtr( char *form ; int opCode ) {

	if( form ) switch( opCode ) {

	case VS_FIf_DISPLAY	: VSf_display	( form ) ; break ;

	case VS_FIf_ERASE	: FIf_erase	( form ) ; break ;

	case VS_FIf_RESET	: FIf_reset	( form ) ; break ;

	case VS_FIf_DELETE	: FIf_delete	( form ) ; break ;

	case VS_FIf_WNEVENT_ON	: FIf_set_window_event_routine(
						form, VSlocateCmd_window_event);
				  break ;

	case VS_FIf_BTEVENT_ON	: FIf_set_button_event_routine(
						form, VSlocateCmd_button_event);
				  break ;

	case VS_FIf_INITNTFY_ON	: FIf_set_initial_notification_routine(
					form, COB_FI_initial_form_notification);
				  break ;

	case VS_FIf_WNEVENT_OFF	: FIf_set_window_event_routine( form, NULL ) ;
				  break ;

	case VS_FIf_BTEVENT_OFF	: FIf_set_button_event_routine( form, NULL ) ;
				  break ;

	case VS_FIf_INITNTFY_OFF: FIf_set_initial_notification_routine(
								form, NULL ) ;
				  break ;

	default			: break ;

	}
	me->ret = VS_K_ACT_SUCCESS ;

	return OM_S_SUCCESS ;

} /* method formOpByPtr */
/*----------------------------------------------------------------------------*/
method formOpByIndex( int index ; int opCode ) {

	if( index < om$dimension_of( varray = me->forms ) && index >= 0 ) {

		 om$send(msg	= message VSlocateCmd.formOpByPtr(
						me->forms[index].form_ptr,
						opCode ),
			targetid= my_id ) ;
		me->ret = VS_K_ACT_SUCCESS ;
	} else {
		me->ret = VS_K_ABORT_CMD ;
	}

	return OM_S_SUCCESS ;

} /* method formOpByIndex */
/*----------------------------------------------------------------------------*/
method waitTimer( int time ) {

	VS_Wait_timer( time * 10 ) ;
	me->ret = VS_K_ACT_SUCCESS ;
	return OM_S_SUCCESS ;

} /* method waitTimer */
/*----------------------------------------------------------------------------*/
method checkPWD() {

	int	inModel,
		writable ;
	char	warning[MS_MAX_MSG_LENGTH] ;

	di$pwd( dirname = me->Cwd ) ;

	vs$isDirUsable(	dirname	= me->Cwd,
			inModel	= &inModel,
			writable= &writable ) ;

	if( !inModel ) {
		ex$message(	msgnumb		= VS_gW_CwdNtInMod,
				buff		= warning ) ;
		ex$message(	msgnumb		= VS_gW_WARNING,
				type		= "%s",
				var		= `warning`,
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;
	} else if( !writable ) {
		ex$message(	msgnumb		= VS_gW_CwdNotWritable,
				buff		= warning ) ;
		ex$message(	msgnumb		= VS_gW_WARNING,
				type		= "%s",
				var		= `warning`,
				field		= ERROR_FIELD,
				justification	= CENTER_JUS ) ;
	}
	return OM_S_SUCCESS ;

} /* method checkPWD */
/*----------------------------------------------------------------------------*/
static int VSactionHandlerInCmd_PFAH( object, PFAHargs )

struct GRobj_env	*object ;
VSfenceArgs		*PFAHargs ; {

	int			keepIt ;
	struct GRlc_info	entry ;
	OM_S_OBJID		cmdObjid ;

	cmdObjid = PFAHargs->value ;

	entry.located_obj	= object->_grid ;
	entry.module_info	= object->mod_env ;
	om$send(msg      = message VSlocateCmd.locate_action_handler( 
								&keepIt,
								NULL,
								&entry,
								NULL ),
		senderid = cmdObjid,
		targetid = cmdObjid,
		targetos = OM_Gw_TransOSnum_0 ) ;

	return keepIt ;

} /* VSactionHandlerInCmd_PFAH */
/*----------------------------------------------------------------------------*/
static int VSactionHandlerInCmd_LCAH( LCAHargs, entry, args, action )

VSlocateArgs		*LCAHargs ;
enum GRlocate_action	*action ;
struct GRlc_info	*entry ;
struct LC_action_args	*args ; {
	
	int		keepIt ;
	int		sts ;
	OM_S_OBJID	cmdObjid ;

	if( *action == start_transition || *action == end_transition ) {
		sts = LCptlocact( (char *) LCAHargs->stack, entry, args, action );
		goto wrapup ;
	}

	cmdObjid = LCAHargs->value ;
	sts = om$send(	msg      = message VSlocateCmd.locate_action_handler( 
								&keepIt,
							        action,
							        entry,
							        args ),
			senderid = cmdObjid,
			targetid = cmdObjid,
		 	targetos = OM_Gw_TransOSnum_0 ) ;
	if( !( sts & 1 ) ) keepIt = FALSE ;

	sts = (keepIt & 1)  ? LCptlocact( (char *) LCAHargs->stack, entry,
					  args, action )
			    : LC_RELOCATE ;

	wrapup :
		return sts ;
	
} /* VSactionHandlerInCmd_LCAH */
/*----------------------------------------------------------------------------*/
method locate_action_handler( int 			*keepIt; 
  		              enum GRlocate_action	*action ;
		              struct GRlc_info		*entry ;
		              struct LC_action_args	*args ) {

	*keepIt = FALSE ;
	return OM_S_SUCCESS ;
	
} /* method locate_action_handler */
/*----------------------------------------------------------------------------*/
method setupActionHandler( long *msg ; int LCAHcode ; long arg ) {

	/*
	 * Arg is either an int mask, flag, etc. or a pointer to a character
	 * string (eg. a classname).
	 */
	int	(*LCAH) __((	VSlocateArgs*,
				struct GRlc_info*,
				struct LC_action_args*,
				enum GRlocate_action* )),
		(*PFAH) __((	struct GRobj_env*,
				VSfenceArgs* )), i, size;

	*msg = VS_K_ACT_SUCCESS ;

	/*
	 * Reset reject info displayed by some locate action handlers.
	 */
	me->LCAHarg.rejectSts = MS_NO_MSG ;

	switch(  LCAHcode ) {
		default					:
		case VS_K_RESET_LCAH			:
			LCAH = NULL ;
			PFAH = NULL ;
			break ;
		case VS_K_isSupportOfBeam_LCAH		:
			LCAH = VSisSupportOfBeam_LCAH ;
			PFAH = VSisSupportOfBeam_PFAH ;
			break ;
		case VS_K_isAnEditableFeature_LCAH	:
			LCAH = VSisAnEditableFeature_LCAH ;
			PFAH = VSisAnEditableFeature_PFAH ;
			break ;
		case VS_K_isSupportOfStiffener_LCAH	:
			LCAH = VSisSupportOfStiffener_LCAH ;
			PFAH = VSisSupportOfStiffener_PFAH ;
			break ;
		case VS_K_notSupportOfPlate_LCAH	:
			PFAH = VSnotSupportOfPlate_PFAH ;	
			LCAH = VSnotSupportOfPlate_LCAH ;
			break ;
		case VS_K_actionHandlerInCmd_LCAH	:
			LCAH = VSactionHandlerInCmd_LCAH ;
			PFAH = VSactionHandlerInCmd_PFAH ;
			break ;
		case VS_K_filterFeature_LCAH		:
			LCAH = VSfilterFeature_LCAH ;
			PFAH = VSfilterFeature_PFAH ;
			break ;
		case VS_K_filterFeatureNeg_LCAH		:
			LCAH = VSfilterFeatureNeg_LCAH ;
			PFAH = VSfilterFeatureNeg_PFAH ;
			break ;
		case VS_K_rejectSubClass_LCAH		:
                  _FREE(VSlocObjs);
                  size = om$dimension_of( varray = me->locObjs );
                  if(size > 0) 
                  {
                    locCount  = size;
                    VSlocObjs = _MALLOC(size, struct GRobj_env);
                    for(i=0; i<size; i++) VSlocObjs[i] = me->locObjs[i];
                  } 
			LCAH = VSrejectSubClass_LCAH ;
			PFAH = VSrejectSubClass_PFAH ;
			break ;
		case VS_K_noFrozenFeature_LCAH		:
			LCAH = VSnoFrozenFeature_LCAH ;
			PFAH = VSnoFrozenFeature_PFAH ;
			break ;
		case VS_K_isAnExtOrOrgStiffener_LCAH	:
			LCAH = VSisAnExtOrOrgStiffener_LCAH ;
			PFAH = VSisAnExtOrOrgStiffener_PFAH ;
			break ;
		case VS_K_isAClosedPlanarCurve_LCAH	:
                  _FREE(VSlocObjs);
                  size = om$dimension_of( varray = me->locObjs );
                  if(size > 0) 
                  {
                    locCount  = size;
                    VSlocObjs = _MALLOC(size, struct GRobj_env);
                    for(i=0; i<size; i++) VSlocObjs[i] = me->locObjs[i];
                  } 
			LCAH = VSisAClosedPlanarCurve_LCAH ;
			PFAH = VSisAClosedPlanarCurve_PFAH ;
			break ;
	}

	/*
	 * Stupid COB defined the action handler as returning a "char *" whereas
	 * it is an integer (LC_* code or TRUE/FALSE).
	 */
	me->action_handler	= (char (*)()) LCAH ;
	me->action_args		= (char *) &me->LCAHarg ;
	me->LCAHarg.value	= arg ;
	me->LCAHarg.stack	= &me->stack ;
	me->PFAH		= PFAH ;
	me->PFAHarg.value	= arg ;

	me->ret = VS_K_ACT_SUCCESS ;

	return OM_S_SUCCESS ;

} /* method setupActionHandler */
/*----------------------------------------------------------------------------*/
method setupAHrejectSts( long msgKey ) {

	me->LCAHarg.rejectSts = msgKey ;

	return OM_S_SUCCESS ;

} /* method setupAHrejectSts */
/*----------------------------------------------------------------------------*/
method keyin_key( long msgnumb ) {

	ex$message(	msgnumb		= msgnumb,
			field		= KEYIN_FIELD,
			justification	= CENTER_JUS ) ;

	return OM_S_SUCCESS ;

} /* method keyin_key */
/*----------------------------------------------------------------------------*/
method setMatchKey( char *matchKey ) {

	strcpy( me->matchKey, matchKey ) ;

	return OM_S_SUCCESS ;

} /* method setMatckKey */
/*----------------------------------------------------------------------------*/
void VDgetLocatedObjs(
                       struct GRobj_env **objs,
                       IGRint           *count
                     )
{
  *objs  = VSlocObjs;
  *count = locCount;
} 

end implementation VSlocateCmd ;
