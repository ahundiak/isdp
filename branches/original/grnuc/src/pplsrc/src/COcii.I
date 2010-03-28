/*
 * Command Object for Command Language
 * Etienne BEEKER	( FRANCE )
 * beginning: July 1986
 *
 * This command object just waits for a string which is
 * the command file to be executed
 * The file is parsed at entry "PARSE" and then executed
 * at entry "EXECUTE", which is also used after an interruption.
 *
 * The Command Language behaves as a Command Object
 * and so COcii is sometimes only a filter for messages.
 * 
 */
class implementation COci;

#define CIREADRTREE 1

#include <errno.h>
#include <ctype.h>
#include <string.h>
#include "cimsg.h"
#include "cisetup.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "msmacros.h"

#include "OMrtreeops.h"
extern char errmess[];

#define NUM_TOKENS 5
/*
 * define the states
 */
#define UNIC_STATE 0
#define NUM_STATES 1
/*
 * define the actions
 */
#define NIL		0
#define ERR		1
#define ASK_FOR_NAME	2
#define PARSE		3
#define EXECUTE		4

%safe
int ci_flash_messages = 1;	/* to say to the ci object if */
				/* it must output the messages */
%endsafe

from ci import cmd_info, setargs ;

/*----------------------------------------------------------------------------*/
/*		    		method COinit			 	      */
/*----------------------------------------------------------------------------*/

method init (IGRint type; IGRchar *string_ptr)
/*
 * - save the symbology
 * - initialize the construction list
 * - save dynamics and put dynamics off
 * - allocate the buffer for readrtree
 * - look for the initial state of the state machine
 */
{
	static int	flag_rtree_alloc = 0;
	extern char	CIcci_path[]	;
	int		Quiet	;
	long		stat	;

#ifdef DEBUG
  printf( "COci.init : ENTER\n" ) ; fflush( stdout ) ;
#endif
#ifdef CIREADRTREE
	/* alloc the buffer to read in the rtree */
	if(!flag_rtree_alloc){
		som_rtree_ops_init(SZ_RTREE_FIFO);
		flag_rtree_alloc = 1;
	}
#endif

	if( !CIdynamics ) {
		IGRboolean	set_inq = 1, dyn_off ;

		/* save the current dyn */
	 	DPdynflags( &stat, &set_inq, &ME.COci->dyn_save, NULL) ;

		/* sets dynamics off */
		set_inq = 0;
		dyn_off = 0;
	 	DPdynflags( &stat, &set_inq, &dyn_off, NULL ) ;
	}

	Quiet = !CIgdisplay ;

	ex$disp_flag( mode = EX_INQ, flag = &ME.COci->dsp_save ) ;
	ex$disp_flag( mode = EX_SET, flag = &Quiet ) ;

	Quiet = (CImessages && ex$is_interactive ()) ? MS_ON : MS_OFF ;
	ms$onoff( msg = &stat, prevstate = &ME.COci->msg_save, type = Quiet ) ;


	ME.super_cmd->mytype = type;
	ME.COci->action = ASK_FOR_NAME;

	ME.super_cmd->state= UNIC_STATE;
	ME.COci->ci_objid = NULL_OBJID;
#ifdef DEBUG
  printf( "COci.init : my_type %d\n", ME.super_cmd->mytype ) ; fflush( stdout ) ;
#endif
/* -- Initialize CI options upon the first invocation.
   -- */
	if( *CIcci_path == '\0' ) CIiniopt() ;

#ifdef DEBUG
  printf( "COci.init : EXIT\n" ) ; fflush( stdout ) ;
#endif
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
/*		       		method COsleep				      */
/*----------------------------------------------------------------------------*/

method super_cmd.sleep (IGRint pos)
{
	if( CI_MSG ) {
			ex$message(	field	= PROMPT_FIELD	,
					in_buff	= ""		) ;
			ex$message(	field	= MESSAGE_FIELD	,
					in_buff	= ""		) ;
	}
	return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
/*		       		method COwakeup	 		 	      */
/*----------------------------------------------------------------------------*/

method wakeup (IGRint pos)
{
#ifdef DEBUG
  printf( "COci.wakeup : ENTER, pos = %d\n", pos ) ; fflush( stdout ) ;
#endif
	if( CI_FILE_KEYED_IN( ME.super_cmd->mytype ) ) {
		if( CI_MSG ) {
			ex$message(	field	= PROMPT_FIELD	,
					in_buff	= ""		) ;
			ex$message(	field	= ERROR_FIELD	,
					in_buff	= ""		) ;
			ex$message(	msgnumb = CM_M_ExCmdLg	) ;
		}
	}
#ifdef DEBUG
  printf( "COci.wakeup : EXIT\n" ) ; fflush( stdout ) ;
#endif
	return OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/
/*		       		method COexecute			      */
/*----------------------------------------------------------------------------*/

method execute ( IGRint  *response;
		 IGRchar *response_data;
		 IGRint   pos )
{

  struct GRevent	event;	 	/* Event from getevent		*/
  IGRlong		rc;	        /* Flags success 		*/
  IGRlong		size;	        /* Size of GRevent struct	*/
  IGRlong		mask;	        /* Mask for input		*/
  IGRint		token;	 	/* Token that was found		*/
  UNIXpath		PPLfile;	/* Name of PPL file to process	*/
  char			*arglist ;	/* List of args for PPL file	*/
  extern char 		CIprevious[],	/* Previous name given		*/
			CIprevargs[] ;	/* Previous arguments		*/
  
  IGRint		i;    /* hyperbolic sign of my social security number */
  IGRint		CIsts,		/* CI error code		*/
  			OMsts;		/* OM return code		*/

  static IGRint Tokens[]=
 		 {DATA, RESET, STRING, GR_UNKNOWN_TYPE, GR_UNWANTED_PT};

  static IGRchar Action[NUM_STATES][NUM_TOKENS]= {

   /* Tokens:	      DATA   RESET  STRING  GR_UNKNOWN_TYPE  GR_UNWANTED_PT
   Previous State */
   /* UNIC_STATE */  { ERR,  ERR,   PARSE,  ASK_FOR_NAME,    ERR  },
   };

#ifdef DEBUG
  printf( "COci.execute : ENTER\n" ) ; fflush( stdout ) ;
#endif
  mask = GRm_DATA | GRm_STRING | GRm_RESET;
  size = sizeof( struct GRevent );

  do {
	switch (ME.COci->action) {
	   case NIL:/* not used */
	      break;

	   case ERR:
	      rc = 0;
	      break;

	   case ASK_FOR_NAME:
	      rc = 1;
		if( CI_MSG ) {
			ex$message( msgnumb = CI_P_KeyInFi  ) ;
		}
	      break;

	   case PARSE:
	      /*
	       * If empty string is given, the last-called file is assumed 
	       */
	      if (event.event.keyin[0] == 0) {
			strcpy( event.event.keyin, CIprevious ) ;
			arglist = CIprevargs ;
	      } else {
		i = strlen( event.event.keyin ) ;
		arglist = strtok( event.event.keyin, " \t" ) ;

		if( i == strlen( arglist ) ) arglist = "" ;
		else arglist = arglist + strlen( arglist ) + 1 ;

		if( CI_FILE_KEYED_IN( ME.super_cmd->mytype ) ) {
			/* CI= ... command, not another command executing
			   a PPL file */
			strcpy( CIprevious, event.event.keyin	) ;
			strcpy( CIprevargs, arglist		) ;
		}
	      }

	      if( event.event.keyin[0] == 0 ){
		  rc = 0;
		  break;
	      } else
		  strcpy(PPLfile, event.event.keyin);

	      if( CI_MSG ) {
			ex$message(	field	= PROMPT_FIELD	,
					in_buff	= ""		) ;
	      }
#ifdef DEBUG
  printf( "COci.execute : before ci$load, file %s\n", PPLfile ) ; fflush(stdout);
#endif
	      /* 
	       * parse the file and construct the object
	       * Type 1 : LOAD_UNCOND, 0 (command) : DUP
	       */

	      rc = ci$load(
		        file_name  = PPLfile,
			load	   = CI_FILE_KEYED_IN( ME.super_cmd->mytype ) ?
							 LOAD_UNCOND : DUP ,
			file_id	   = &ME.COci->ci_objid,
			sender_id  = my_id,
			stat	   = &CIsts );
#ifdef DEBUG
  printf( "COci.execute: ci$load rc = %d\n", rc ) ; fflush(stdout);
			ci$report_error( status = CIsts,
					 output = CI_ERR_STDOUT ) ;
#endif
	      if( !rc ) {

		ME.COci->ci_objid = NULL_OBJID;
		if( CI_MSG ) {
			ci$report_error( status = CIsts,
					 output = CI_ERR_MSGSYS ) ;
		}
#ifdef DEBUG
  printf( "COci.execute: BAD rc from ci$load, exiting...\n" ) ; fflush(stdout);
#endif
		break ;
	      }

#ifdef DEBUG
  printf( "COci.execute: after ci$load, file_id %d\n", ME.COci->ci_objid ) ;
  fflush(stdout);
#endif
	    
	      /* initialize */
	      OMsts = om$send(msg = message ci.cmd_info(ME.super_cmd->cmd_name,
						   ME.super_cmd->cmd_key,
						   &(ME.super_cmd->mytype),
						   EX_SET ),
	           targetid = ME.COci->ci_objid,
        	   targetos = OM_Gw_TransOSnum_0);

	      if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts	= OMsts,
	      			text	= "COci.execute -> ci.cmd_info" ) ;
	      	rc = FALSE ;
	    	break;
	      }

	      OMsts = om$send(	mode = OM_e_wrt_object,
		  		msg = message super_cmd.init(0, "main"),
        	   		targetos = OM_Gw_TransOSnum_0,
	           		targetid = ME.COci->ci_objid);

	      if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts	= OMsts,
	      			text	= "COci.execute -> ci.init" ) ;
	      	rc = FALSE ;
	    	break;
	      }

#ifdef DEBUG
  printf( "COci.execute: after init\n" ); fflush(stdout);
#endif

/* ci.setargs message send moved here for TR-89N4300  1-6-90  GLC */

#ifdef DEBUG
   printf( "COci.execute : before ci.setargs\n"); fflush(stdout);
#endif

	      om$send( msg	= message ci.setargs( arglist ),
		       targetid = ME.COci->ci_objid ) ;


	   case EXECUTE:
#ifdef DEBUG
  printf( "COci.execute: before super_cmd.wakeup\n" ) ; fflush(stdout);
#endif
	      /* send wakeup */
	      OMsts = om$send(mode = OM_e_wrt_object,
				msg = message super_cmd.wakeup(1),
        	   		targetos = OM_Gw_TransOSnum_0,
			   	targetid = ME.COci->ci_objid );
	      if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts	= OMsts,
	      			text	= "COci.execute -> super_cmd.wakeup" ) ;
	      	rc = FALSE ;
	    	break;
	      }

/* ci.setargs message send removed from here for TR-89N4300  1-6-90  GLC */
		       
#ifdef DEBUG
   printf( "COci.execute : before super_cmd.execute resp = %d\n", *response);
   fflush(stdout);
#endif
	      /* send execute */
	      OMsts = om$send(	mode = OM_e_wrt_object,
                  		msg = message super_cmd.execute( response,
                  						 response_data,
                  						 pos ),
        	  		targetos = OM_Gw_TransOSnum_0,
                  		targetid = ME.COci->ci_objid );

	      if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts	= OMsts,
	      			text	= "COci.execute -> super_cmd.execute" );
	      	rc = FALSE ;
	    	break;
	      }
#ifdef DEBUG
   printf( "COci.execute : after super_cmd.execute resp = %d\n", *response);
   fflush(stdout);
#endif

	      /* send sleep */
	      OMsts = om$send(	mode	 = OM_e_wrt_object,
				msg	 = message super_cmd.sleep(1),
        	  		targetos = OM_Gw_TransOSnum_0,
				targetid = ME.COci->ci_objid );

	      if( !( OMsts & SUCC ) ) {
		ci$om_failed(	sts	= OMsts,
	      			text	= "COci.execute -> super_cmd.sleep" );
	      	rc = FALSE ;
	    	break;
	      }

	      if( *response == CMD_STRING ||
		  *response == D_COMMAND  ||
		  *response == EX_CMD_M_STR ||
		  *response == EX_CMD_M_KEY ||
/* DG July 06 */
		  *response == EX_POCKET  ||
		  *response == EX_CMD_KEY ||
		  *response == TOGGLE_COMMAND ){
			ME.COci->action = EXECUTE;
			goto WRAPUP ;
	      } 

	      if( *response != CLEAR_STACK )
		      *response = TERMINATE;
	      goto WRAPUP ;

	   default:
	      printf( "COci: unknown action requested\n");
	      rc = 0;
	      break;
	}

	if( !rc ) {
	    *response = TERMINATE;
	    goto WRAPUP ;
	} else {
	    /* get next event and set token */

	    token = GRget_token(&rc, Tokens, &mask, &event, &size, 
						    response, response_data);

	    ME.COci->action= Action[UNIC_STATE][token];
	}
  } while( Tokens[token] != GR_UNKNOWN_TYPE );

  WRAPUP :
#ifdef DEBUG
  printf( "COci.execute : EXIT\n" ) ; fflush( stdout ) ;
#endif
  return OM_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
method delete(int n)
/*----------------------------------------------------------------------------*/
/*
 * Deletes the ci object before deleting self
 * Restores dynamics, symbology
 */
{
	long  stat;
	short not_used;

        /* delete the object ci if not null*/
	if( !IF_EQ_OBJID(ME.COci->ci_objid , NULL_OBJID) ){
		stat = om$send(	mode	 = OM_e_wrt_object,
				msg	 = message Root.delete(0),
        	  		targetos = OM_Gw_TransOSnum_0,
				targetid = ME.COci->ci_objid );

		if( !( stat & SUCC ) ) {
			ci$om_failed( sts = stat,
	      			      text = "COci.delete -> Root.delete" );
		}
	}

	/* turn dynamic on last position */
	if( !CIdynamics ) {
		IGRboolean set_inq = 0;
	 	DPdynflags( &stat, &set_inq, &ME.COci->dyn_save, NULL ) ;
	}
	ex$disp_flag( mode = EX_SET, flag = &ME.COci->dsp_save ) ;
	ms$onoff( msg = &stat, prevstate = &not_used,
		  setstate = ME.COci->msg_save, type = MS_SET ) ;


        /* delete itself */
	stat = om$send(	mode	 = OM_e_wrt_message,
			msg	 = message Root.delete(n),
        	  	targetos = OM_Gw_TransOSnum_0,
			targetid = my_id );
	if( !( stat & SUCC ) ) {
		ci$om_failed( sts = stat,
			      text = "COci.delete -> Root.delete" );
		return OM_W_ABORT ;
	}

	return OM_S_SUCCESS ;
}

end implementation COci;
