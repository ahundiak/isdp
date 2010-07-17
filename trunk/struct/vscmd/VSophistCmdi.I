/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSophistCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSophistCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/07/07  08:58:26  pinnacle
# TR 179900612 - Jayadev/Vinit
#
# Revision 1.3  1999/05/19  20:43:50  pinnacle
# TR_179900571
#
# Revision 1.2  1998/07/16  18:07:28  pinnacle
# For TR#17980765
#
 *
 * History:
 *      MM/DD/YY AUTHOR	       DESCRIPTION
 *      unknown                creation 
 *      07/15/98 Manoj         TR17980765 Review Operation History 
 *			       was not hiliting subplates.
 *	05/19/99 ejm	       TR_179900571: Picking empty MCF gadget results in crash;
 *			       Return without processing if field is empty.
 *      07/07/99 Jayadev/vinit TR179900612
 ***************************************************************************/
class implementation VSophistCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "COBmacros.h"
#include "igewindef.h"
#include "nddef.h" // For ND_CHILD etc.
#include "vsattr.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsrvformdef.h"
#include "vs.h"
#include "vsdbgmacros.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes.
 */
#include "COm_navigi.h"
%safe
/* VX_FIproto.h uses OPP keywords ... */
#	include "VX_FIproto.h"
%endsafe
#include "vsioproto.h"
#include "vsophstproto.h"

#define VS_K_CmdNotStacked	0
#define VS_K_CmdIsStacked	1
#define VS_K_DelWhenStacked	2
#define	VS_K_LocStructElm	260

extern COB_FI_form_notification() ;


from NDnode	import	ASreturn_go ;
from NDnode	import	NDget_objects ; // TR179800765
from VSfeature	import	VSgetOperationHistory ;
extern OMuword OPP_VSsplPlate_class_id ; // TR179800765
/*----------------------------------------------------------------------------*/
%safe
static int	X_FORM_POS  = -1,
		Y_FORM_POS  = -1,
		FORM_SCREEN = -1 ;
%endsafe
/*----------------------------------------------------------------------------*/
method createForm() {

	long	sts ;

	me->history	= NULL ;
	me->flag	= VS_K_CmdNotStacked ;

	if( FIf_new(	1,
			VS_K_RVOPHST_FORM,
			COB_FI_form_notification, 
			&me->opHistForm ) == FI_SUCCESS ) {
		char *form = me->opHistForm ;

		FIf_set_cmd_oid_os( form, my_id, OM_Gw_current_OS ) ;
		if( -1 != X_FORM_POS ) {
		       FIf_set_location( form, X_FORM_POS, Y_FORM_POS ) ;
		       FIf_set_screen( form, FORM_SCREEN ) ;
   		}
		FIf_display( form ) ;

		sts = OM_S_SUCCESS ;
	} else {
		sts = OM_W_ABORT ;
	}

	return sts ;

} /* method createForm */
/*----------------------------------------------------------------------------*/
method setStackedStatus( int stacked ) {

  switch( me->flag ) {
    case VS_K_CmdNotStacked : if(  stacked ) me->flag = VS_K_CmdIsStacked ;
  			      break ;
    case VS_K_CmdIsStacked  : if( !stacked ) me->flag = VS_K_CmdNotStacked;
  			      break ;
    case VS_K_DelWhenStacked: if( !stacked ) {
   				int	rsp = TERMINATE ;
   				long	rc ;
				ex$putque( msg = &rc, response = &rsp ) ;
    			      }
    			      break ;
  }
  return OM_S_SUCCESS ;

} /* method setStackedStatus */
/*----------------------------------------------------------------------------*/
void VStoggleCommand( OM_S_OBJID cmdId, OMuword cmdOs ) {

   long			rc ;
   OMuint		cmdIndex = 0 ;
   OM_S_CHANSELECT	chan ;
   OM_S_OBJECT_LINKAGE	cmd_server ;
   OMuint		nb ;

   __DBGpr_com(" Entered VStoggleCommand");
   chan.type	   = OM_e_name ;
   chan.u_sel.name = "super_cmd.cmd" ;
   rc = om$get_channel_objects( objid        = cmdId,
   				osnum        = cmdOs,
                                p_chanselect = &chan,
                                list         = &cmd_server,
				size         = 1,
				count        = &nb ) ;
   if( rc & 1 ) {
     chan.u_sel.name = "cmdserver.cmdstack" ;
     rc = om$get_index( objid_c      = cmd_server.S_objid,
			osnum_c      = cmd_server.osnum,
                        p_chanselect = &chan,
			objid        = cmdId,
			osnum2       = cmdOs,
			indexaddr    = &cmdIndex ) ;
    }

    if( cmdIndex != 0 ) {
   	int	rsp = TOGGLE_COMMAND ;
	ex$putque( msg = &rc, response = &rsp ) ;
    }

} /* VStoggleCommand */
/*----------------------------------------------------------------------------*/
method toggleCommand() {
	VStoggleCommand( my_id, OM_Gw_current_OS ) ;
	return OM_S_SUCCESS ;
} /* toggleCommand */
/*----------------------------------------------------------------------------*/
method cleanUp() {

	if( me->history ) {
		VSfreeOpHistory( me->history ) ; me->history = NULL ;
	}
	if( me->opHistForm ) {
	      FIf_get_location( me->opHistForm, &X_FORM_POS, &Y_FORM_POS ) ;
	      FIf_get_screen( me->opHistForm, &FORM_SCREEN ) ;
	      FIf_erase( me->opHistForm ) ;
	      FIf_delete( me->opHistForm ) ; me->opHistForm = NULL ;
	}
	om$send( msg      = message VSlocateCmd.rmLastLocObjs( 0 ),
		 targetid = my_id ) ;

	return OM_S_SUCCESS ;

} /* method cleanUp() */
/*----------------------------------------------------------------------------*/
method displayOperators( long *msg ; enum GRdpmode mode ) {

  long		sts ;
  int		i, count ;
  int 	        parentCount;
  VSoperator	*list ;
  struct GRid     theGRid,   // argument to is_ancestry_valid 
    buffer[2];   // argument to NDget_objects 
	__DBGpr_com("Entered displayOperators");

	if( me->selected ) {
		count	= me->selected->opCount ;
		list	= me->selected->opList ;
	} else {
		count	= 0 ;
		list	= NULL ;
	}
/////the change made by Manoj : start 
	for ( i = 0; i < count ; i++ ){
	   __DBGpr_int(" list memb id",list[i].id );
	   __DBGpr_int("           os",list[i].os );
	}

	
	// Check added for TR179900612
	// If count is zero, then list is NULL, so goto wrapup.

  if(count){
    theGRid.objid = list[0].id;
    theGRid.osnum = list[0].os;
  }
  else
    goto wrapup;

  if ( vs$is_ancestry_valid( object  = &theGRid,
			     classid = OPP_VSsplPlate_class_id)){
    __DBGpr_com("It is a splPlate ");
    sts = om$send( msg = message NDnode.NDget_objects( ND_CHILDREN,
						       buffer, 2,
						       NULL,
						       0, OM_K_MAXINT,
						       &parentCount),
					
				   senderid = NULL_OBJID,
				   targetid = list[0].id,
				   targetos = list[0].os);
		__CheckRC( sts,1, "NDnode.NDget_objects", wrapup);

		__DBGpr_int("No of parents", parentCount);
		__DBGpr_obj("buffer[0] ", buffer[0]);

		for ( i = 0 ; i < 2 ; i++){
			vs$bulk_display(	grids	= &buffer[i],
						theEnv	= &list[i].env,
						dpmode	= mode ) ;
		}
		__DBGpr_com("going to wrapup");
		goto wrapup;
	}
/////the change made by Manoj : Ends:TR 179800765 

	for( i = 0 ; i < count ; i++ ) {
		IGRmatrix	mx ;
		short		mxType ;
		struct GRid	graphic ;

		/*
		 * Note : we have AS headers in list: get graphics.
		 */
		sts = om$send(	msg	= message NDnode.ASreturn_go(
							&graphic, &mxType, mx ),
				targetid= list[i].id,
				targetos= list[i].os ) ;
		__DBGpr_int("Object on list id:",list[i].id);
		__DBGpr_int("               os:",list[i].os);

		if( sts & 1 ) {
			vs$bulk_display(	grids	= &graphic,
						theEnv	= &list[i].env,
						dpmode	= mode ) ;
		}
	}
	me->ret = VS_K_ACT_SUCCESS ;

	wrapup:
	   return OM_S_SUCCESS ;

} /* method displayOperators */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts,		/* OM return code	*/
				num ;		/* Message number	*/
	struct GRobj_env	part ;
	VSopHistory		*h ;
	int			row,		/* Row index		*/
				opCount ;	/* Count of operators	*/
	VSoperator		*opList ;	/* List of operators	*/
	char			operation[MS_MAX_MSG_LENGTH],
				operator [MS_MAX_MSG_LENGTH],
#define SIZE 500
				buf[SIZE],
				*ptr ;

	__DBGpr_com("entered operation");
	me->history = NULL ;

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
								msg, 1, &part ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Unhighlight part.
	 */
	vs$bulk_display( objenvs = &part, dpmode = GRhe ) ;
	
	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
					     msg, &part.mod_env, &me->history ),
			targetid= part._objid,
			targetos= part._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	for( row = 0, h = me->history ; h ; row++, h = h->next ) {

	   num = VSgetOperandTypeMsgKey( VS_OP_TYPE( h->resultType ) ) ;

	   if( h->resultType & VS_m_IN_DEFINITION ) {
	     operation[0] = '*' ;
	     ptr = operation + 1 ;
	   } else ptr = operation ;

	   ex$message( msgnumb = num, buff = ptr ) ;

	   if( h->resultType & VS_m_IN_ASSEMBLY ) {
	     ex$message( msgnumb = VS_gI_InAsbly, buff = buf ) ;
	   } else if( ( opCount = h->opCount ) && ( opList = h->opList ) ) {
	      int o, n = 0 ;

	      for( o = 0 ; o < opCount ; o++ ) {

	         num = VSgetOperatorTypeMsgKey( opList[o].type );

		 ex$message( msgnumb = num, buff = operator ) ;

		 if( n + strlen( operator ) + 2 > SIZE - 1 ) {
		   break ;
		 }
		 n += sprintf( buf + n, "%s ", operator ) ;
	      }
	   } else *buf = '\0' ;

	     FIfld_set_text( me->opHistForm, VS_K_rv_HistField,
				row, 0, operation, FALSE ) ;
	     FIfld_set_text( me->opHistForm, VS_K_rv_HistField,
				row, 1, buf, FALSE ) ;
	}

	me->selected = NULL ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			VSfreeOpHistory( me->history ) ;
			me->ret = VS_K_ABORT_CMD ;
		} else {
			me->ret = VS_K_ACT_SUCCESS ;
		}
		return OM_S_SUCCESS ;
#undef SIZE

} /* method operation */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {

	long		msg ;
	int		row,	/* Active row of field	*/
			col,	/* Active col of field	*/
			pos,
			rsp,
			i ;
	VSopHistory	*h ;
	char		buf[MS_MAX_MSG_LENGTH] ;


	switch( gadget_label ) {

	  case FI_CANCEL :
	    if( VS_K_CmdIsStacked == me->flag ) {
	      /*
 	       * Just cleanup the command when it is stacked:
 	       * the command will be deleted when the command stack is emptied.
	       * BEWARE: form_ptr is no longer valid now since form has been
	       * deleted in `cleanUp()'
 	       */
	      om$send( msg = message VSophistCmd.cleanUp(), targetid = my_id ) ;
	      me->flag = VS_K_DelWhenStacked ;

	    } else if( VS_K_CmdNotStacked == me->flag ) {
	      rsp = TERMINATE ;
	      ex$putque( msg = &msg, response = &rsp ) ;
	    }
	    break ;

	  case FI_RESET :
	    /* Ask the user to locate another element ...
	     * First free the history of the previous element, if any.
	     */
	    VSfreeOpHistory( me->history ) ; me->history = NULL ;
	    om$send( msg      = message VSlocateCmd.rmLastLocObjs( 0 ),
		     targetid = my_id ) ;

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

	  case VS_K_rv_PutQ	:
	    /*
	     * Put selected object onto queue if any.
	     */
	    if( me->selected ) {
	      VSputObjectToQueue(  &msg,
	  			   me->selected->resultId,
	  			   me->selected->resultOs,
		 		   &me->selected->resultEnv,
		 		   FRONT ) ;
	    }
	    break ;

	  case VS_K_rv_HistField :

	    FIfld_get_active_row( form_ptr, gadget_label, &row, &pos ) ;

	    h = me->history ; me->selected = NULL ;
	    for( i = 0, h = me->history ; h ; h = h->next, i++ ) {
		  if( i == row ) {
			__DBGpr_int(" row ", row );
			me->selected = h ; break ;
		  }
	    }
	    // TR_179900571: select FALSE - removes highlight of empty col pick 
	    if(me->selected == NULL ){
		FImcf_get_active_col( form_ptr, VS_K_rv_HistField, &col, &pos );
		FIfld_set_select( form_ptr, VS_K_rv_HistField, row, col, FALSE);
		return 1;  // Not fatal
	    }

	    /*
	     * Highlight both cols: operation and operators.
	     */
	    FImcf_get_active_col( form_ptr, VS_K_rv_HistField, &col, &pos ) ;
	    FIfld_set_select( form_ptr, VS_K_rv_HistField, row, col, TRUE ) ;
	    col = 1 - col ;
  	    FIfld_set_select( form_ptr, VS_K_rv_HistField, row, col, TRUE ) ;

	    ex$message( msgnumb = VS_gP_AccRow, buff = buf ) ;
	    FIg_set_text( form_ptr, FI_MSG_FIELD, buf ) ;
	    om$send( msg     = message VSophistCmd.displayOperators( &msg, GRhd ),
	    	     targetid=my_id);
	    break ;
	
	    default : break ;

	}
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/

end implementation VSophistCmd ;
