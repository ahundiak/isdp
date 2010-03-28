/*
 *	 Etienne Beeker
 *
 *	functions managing the event queue
 *	through omcpp macro calls
 */


#include <ctype.h>
#include <string.h>
#include "ci.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "expriv.h"
#include "exfi.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "comiscmac.h"
#include "grdpbmacros.h"
#include "codef.h"
#include "msdef.h"
#include "msmacros.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "cimsg.h"
#include "grmsg.h"
#include "cisetup.h"

extern char 	errmess[];
extern struct 	instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;

/*----------------------------------------------------------------------------*/
#argsused
int CIgetevent(func, getevdata, runparms, state )
struct ci_instruction	*func;
CIco_resp		*getevdata ;
CIruntime		*runparms  ;
short			*state	   ;

/*
 * general ci macro getevent
 */
{
	IGRlong		msg,
			msgnumb ;	/* Message number of prompt	*/
	int		mask;		/* Event filtering mask		*/
	struct GRevent	*event;		/* Pointer to user event buffer	*/
	static struct GRevent tmpevent;
	int		status;
	int		*resp,		/* Pointer to user response	*/
			tmpresp;
	int		stackable;	/* Flags if PPL file may be
					   interrupted			*/
	OM_S_OBJID	*window_id,	/* Object id of window		*/
			tmpwindow_id;
	short		*window_osnum,	/* Object Space of window	*/
			tmpwindow_osnum;
	char		*prmpt;		/* Event prompt			*/
	struct FI_X_data_st	*gadgetbuf ; /* Gadget data		*/
	char			*form_name ; /* Form to modify		*/
	register short	*pm	;

	enum CIgetevent_args	{
		GETEVRC		=  0, EVENT	=  1, RESPONSE	=  2,
		EVDATA		=  3, STACKABLE	=  4, WINDOWID	=  5,
		WINDOWOS	=  6, PROMPT	=  7, MASK	=  8
	} ;


	pm = func->paramlist ;
	mask = i_cival(pm[MASK]);
#ifdef DEBUG
 printf( "CIgetevent: mask %u\n", mask ) ; fflush( stdout ) ;
#endif

	if( mask & GRm_COMMAND ) {
#ifdef DEBUG
 printf( "CIgetevent: form data\n" ) ; fflush( stdout ) ;
#endif
/* --		GRm_COMMAND is not used by co$getevent: it is used here to flag
		that data are requested from a form.
   -- */
		form_name = st_cival( pm[EVDATA] ) ;
		gadgetbuf = (struct FI_X_data_st *)st_cival( pm[EVENT ] ) ;
#ifdef DEBUG
 printf( "CIgetevent: form name <%s>\n", form_name ) ; fflush( stdout ) ;
 printf( "CIgetevent: gadgetbuf <%u>\n", gadgetbuf ) ; fflush( stdout ) ;
#endif
		if( gadgetbuf == NULL ) return ISUCCESS ;
		else {
			i_cival(pm[GETEVRC]) = CIgetform( &status,
							  form_name,
							  gadgetbuf ) ;
			return ISUCCESS ;
		}
	}

	/* space for event must be given by the user */
	if( ( event = (struct GRevent *)p_cival( pm[EVENT] ) ) == NULL ) event = &tmpevent;

	if( ( resp = (int *)p_cival( pm[RESPONSE] ) ) == NULL ) resp = &tmpresp;

	stackable = i_cival(pm[STACKABLE]);

	if( ( window_id = (OM_S_OBJID *)p_cival( pm[WINDOWID] ) ) == NULL )
		 window_id = &tmpwindow_id;

	if( (window_osnum = (short *)p_cival( pm[WINDOWOS] ) ) == NULL )
		 window_osnum = &tmpwindow_osnum;

	if( isstring( pm[PROMPT] ) ) {
		msgnumb	= GRIO_NO_MSG ;
		prmpt	= st_cival( pm[PROMPT] ) ;
		if( prmpt == NULL ) {
			if( runparms->msgsys.clear_prompt ) {
					if( mask & GRm_DATA )
						msgnumb = GR_P_EntPt ;
				else	if( mask & GRm_STRING	)
						msgnumb = CI_P_dfKEYSTR ;
				else	if( mask & GRm_RESET	)
						msgnumb = CI_P_dfENTCMD ;
				else	if( mask & GRm_CHAR	)
						msgnumb = CI_P_dfKEYCHR ;
				else	prmpt = "Waiting for an event...";
			} else {
				prmpt = runparms->msgsys.Prompt ;
			}
		}
	} else {
		prmpt	= NULL ;
		msgnumb	= i_cival(pm[PROMPT]) ;
	}

	if( mask == 0 ){
		mask =  GRm_DATA |
			GRm_RESET |
			GRm_STRING |
			GRm_BACK_UP |
			GRm_MOVE_ON |
			GRm_SPECIFIED_OBJ |
			GRm_VALUE |
			GRm_FORM_FINISHED ;
	}

	do {
/* EB, Feb 22th, '89 */
                char str_to_cmd = 0;
                if ( (mask & GRm_DATA)
                 && !(mask & GRm_STRING)){
                        mask |= GRm_STRING;
                        str_to_cmd = 1;
                }
/* end of change */

		mask |= ( GRm_RESET | GRm_FORM_FINISHED );
#ifdef DEBUG
printf("ci$getevent: mask:%d\n", mask);
fflush(stdout);
#endif
		status = co$getevent (
			msg = &msg,
			event_mask = mask,
			prompt = prmpt,
			msgnum = msgnumb,
			response = getevdata->response,
			response_data = getevdata->response_data,
			mode = (mask & GRm_CHAR ) ? 
					EX_ALL_CHAR_MODE : EX_LINE_MODE,
			event = event );
#ifdef DEBUG
printf("response:%d event.response:%d\n",*getevdata->response, event->response);	
fflush(stdout);
#endif
		*resp = *getevdata->response;

		if(    *getevdata->response == STRING
		    && !strcmp(event->event.keyin, ""))
			/* good response anyway, EB, July 19th, 1988 */
			break;

/* EB, Feb 22th, '89 */
/* for trapping event generators such as xy=... */
                if( *getevdata->response == STRING  && str_to_cmd == 1 ){
                        *resp = *getevdata->response = event->response = CMD_STRING;
                        return ISTACK;
                }
/* */

/*
 * Carlos M. Diaz: fix for 119416299. A return code of GRw_no_value was
 * being flagged as error when it is not. 
 */
		if ( !status || (COERROR(msg) && msg != GRw_no_value)){
			erreur ("CIgetevent error");
			return ISUCCESS ;
		}

		/* CLEAR_STACK and TERMINATE cannot be trapped */
		if( *resp == CLEAR_STACK
		 || *resp == TERMINATE )
			return ISTACK;

		if( stackable ){
			if( !ci_can_be_stacked(ci_data, ci_data_info ) ) {
				erreur("getevent: cannot interrupt or stack this file");
				break;
			}
			switch (*resp) {
			case RESET: 
				return ISUCCESS;
			case D_COMMAND:
			case HELP:
			case CMD_STRING:
			case TOGGLE_COMMAND:
			case EX_POCKET:
			case EX_CMD_KEY:
			case EX_CMD_M_STR:  /* TR-90N0613  2/8/90  GLC */
			case EX_CMD_M_KEY:  /* TR-90N0613  2/8/90  GLC */
				return ISTACK;
			default:
				break;
			} 
		}
/*		if( *resp == EX_CMD_KEY )*/   /* TR#90N1859 */
/*			break;*/
/*
 * commented out the above to fix TR119221171, Carlos.
 */

	} while( event->response == GR_UNKNOWN_TYPE 
			&& *resp != CMD_STRING );

	*window_id = event->event.button.objid;
	*window_osnum = event->event.button.osnum;

	/* fills data according to the type of resp */
	switch (*resp) {
	case RESET:
	case D_RESET:
		/* to avoid noticed problems */
	case DATA:
		p_cival(pm[EVDATA]) = (char *)&event->event.button.x;
		/*
			dp = cival(pm[EVDATA]);
			dp[0] = event->event.button.x;
			dp[1] = event->event.button.y;
			dp[2] = event->event.button.z;
		*/
		break;
	case CMD_STRING:
	case EX_CMD_KEY:
		p_cival(pm[EVDATA]) = getevdata->response_data;
		if( mask & GRm_RESET ) 			/* TR#90N1859 */
			*getevdata->response = VALUE;
		break;
	case STRING:
	case CHAR:
#ifdef DEBUG
printf("cigetevent: res_data = <%s>, even,,keyin = <%s>\n",
	getevdata->response_data, event->event.keyin );
#endif
		p_cival(pm[EVDATA]) = event->event.keyin;
		break;
	}

	runparms->msgsys.clear_prompt = TRUE ;

	if( !( runparms->options & CI_NOMSG_MODE ) ) {
		COND_message( runparms->msgsys.Message ) ;
	}
	ex$message(	field = PROMPT_FIELD, in_buff = "" ) ;

	i_cival(pm[GETEVRC]) = 1;
	return ISUCCESS ;
}


#argsused
int CIputevent(func, putevdata, runparms, state )
struct ci_instruction	*func;
CIco_resp		*putevdata ; /* Unused */
CIruntime		*runparms  ;
short			*state	   ;
/*
 * general ci macro putevent
 */
{
  int			size;		/* Size of event buffer		*/
  IGRlong		msg;
  struct GRevent	event;		/* Event buffer			*/
  int			status;
  int			pos;		/* Position on event queue	*/
  int			resp;		/* Event response		*/
  int			exmode ;	/* For ex$putque		*/
  char			*data;		/* Event data			*/
  double		*tmpp;
  OM_S_OBJID 		window_id;	/* Object id of event window	*/
  short			g_osnum;
  double		*data_point;
  struct EX_form_data_st fidata	;	/* Form data			*/
  struct EXFI_data_st	*figadget ;	/* Gadget data			*/
  register short	*pm ;		/* PPL's CIputevent arg list	*/
  enum CIputevent_args	{
		PUTEVRC	=  0, RESPONSE	=  1, POSITION	=  2,
		EVDATA	=  3, G_OSNUM	=  4, WINDFLAG	=  5,
		WINDOW	=  6, DATAPNT	=  7, FIGADGET	=  8
  } ;

	pm	= func->paramlist ;

	resp	= i_cival ( pm[RESPONSE] );
	pos	= i_cival ( pm[POSITION] );
	data	= st_cival( pm[EVDATA  ] );

	if (p_cival(pm[G_OSNUM]) == NULL ){
		struct GRid modGrid;
		GRfindmod( &modGrid );
		g_osnum = modGrid.osnum; /* POSSIBLE BUG HERE ! */
	} else
		g_osnum = *((short *)p_cival(pm[G_OSNUM]));

	/* fill data according to the type of resp */
	switch (resp) {
	case D_COMMAND:
	case TOGGLE_COMMAND:
	case CLEAR_STACK:
	case EX_FORM_FINISHED:
	case HELP:
	case EX_POCKET:
	case TERMINATE:
	case EX_BACK_UP:
	case EX_CMDSVR_RETURN:
	case STATUS_DISP:
	case EX_RESTART:
		data = "";
		size = 1;
		break;
/*
 * Modified 02/04/92 : rlw
 *
 * Changed to allow stuff in (x,y,z) coordinates for resets
 * if present.
 *
 */
	case EX_RJT_MOVEON: 
	case MOVE_ON:
		if (data == NULL) {
			data = "";
			size = 1;
			break;
		}
	case EX_OBJID:
	case EX_DATA:
	case ABS_DIG:
		/* build the event button */
		if ( i_cival( pm[WINDFLAG] ) == 0 ){
			/* we have a window name */
			char *s = st_cival( pm[WINDOW] ) ;
			if( s != NULL && s[0] != '\0' ) {
				/* get the window_id */
/* OLD
				if( !__ci_build_button(&event.event.button, s) ){
end OLD */
				if( !ci_build_button(	&msg,
							&event.event.button,
							s ) ) {
					sprintf(errmess,"ci$put: window \"%s\" not found, default window taken",s);
					erreur(errmess);
/* OLD
					__ci_build_button(&event.event.button,"*");
end OLD */
					ci_build_button( &msg,
							 &event.event.button,
							 NULL ) ;
				}
			} else
/* OLD
				__ci_build_button(&event.event.button, "*");
end OLD */
				ci_build_button(	&msg,
							&event.event.button,
							NULL ) ;
		} else {
			/* we have a window id */
			window_id = o_cival(pm[WINDOW]);
			if( !IF_EQ_OBJID( window_id, NULL_OBJID )){
				co$build_button( 
					msg = &msg,
					objid = window_id,
					osnum = g_osnum,
					button = &event.event.button );
			} else
/* OLD
				__ci_build_button(&event.event.button, "*");
end OLD */
				ci_build_button(	&msg,
							&event.event.button,
							NULL ) ;
		}

		if( resp == EX_OBJID ){
			IGRlong NumberOfBytes, BytesReceived;

			/* R Chawla, 03 May 88 */
/*			resp = EX_DATA;		*/
/* EB: 10 May does not work */
			/* get module info  */
			NumberOfBytes = sizeof( struct GRmd_env );
			gr$get_module_env( 
				msg	= &msg, 
				sizbuf	= &NumberOfBytes, 
			        buffer	= &event.located_object[0].module_info,
				nret	= &BytesReceived );

			/* rebuilding an kludgy event, according to R.Watson */
			event.response	= EX_DATA;

			/* data_point replaces special, no longer taken in account */
			data_point = (double *)st_cival( pm[DATAPNT] );
#ifdef DEBUG
printf("CIputevent, data_point:%d\n",data_point );
#endif
			if( data_point != NULL ){
				/* DATA point user */
				event.event.button.x = data_point[0];
				event.event.button.y = data_point[1];
				event.event.button.z = data_point[2];
			} else {
				event.event.button.x = 0.;
				event.event.button.y = 0.;
				event.event.button.z = 0.;
			}
			event.num_id	= 1;
			event.num_val	= 0;
			event.subtype	= GRst_LOCATE;
			event.located_object[0].located_obj.objid = 
						*((OM_S_OBJID *)data);
			event.located_object[0].located_obj.osnum = g_osnum;
			event.located_object[0].geom_parms.u = 0;
			event.located_object[0].geom_parms.v = 0;
			event.located_object[0].geom_parms.polygon_inx = 2;
			size = sizeof( struct GRevent ) - 2*sizeof( long );
			data = (char *)&(event.event.button);
			break;
		}

		if (data) { /* TR-89N4327  1/5/90  GLC */

			/* now resp = EX_DATA */
			tmpp = (double *)data;

#ifdef DEBUG
printf("put: tmpp=0x%.8x  <%lf, %lf, %lf>\n", tmpp, tmpp[0], tmpp[1], tmpp[2]);
fflush(stdout);
#endif
			event.event.button.x = tmpp[0];
			event.event.button.y = tmpp[1];
			event.event.button.z = tmpp[2];
		}

/* DG 07/06 */
		if( resp != EX_OBJID )
		{
			event.subtype = GRst_REGULAR;
			event.num_id = 0;
		}
		event.num_val = 0;

		data = (char *)&event.event.button;
		size = sizeof(struct GRevent);
		break;
	case CMD_STRING:
	case EX_STRING:
	case EX_CMD_KEY:
		if (!data) data = ""; /* TR-89N4327  1/5/90  GLC */
		size = strlen(data) + 1;
		break;
	case EX_CHAR:
		if (!data) data = ""; /* TR-89N4327  1/5/90  GLC */
		size = 1;
		break;
	case EX_FORM_DATA:
#ifdef DEBUG
  printf( "CIputevent: EX_FORM_DATA\n" )	; fflush( stdout ) ;
  printf( "CIputevent: form = <%s>\n", data )	; fflush( stdout ) ;
#endif

		size = sizeof( struct EX_form_data_st ) ;
		strncpy( fidata.form_name, data, CI_NAME_MAX )[CI_NAME_MAX] = '\0' ;
		figadget = (struct EXFI_data_st *)p_cival( pm[FIGADGET] ) ;
		fidata.data = *figadget ;
		data = (char *)&fidata ;
		break ;
	default:
		sprintf(errmess,"ci$putevent: event response not found: %d\n",resp);
		erreur(errmess);
		break;
	}

	switch( resp ) {
		case COMMAND	:
		case EX_CMD_KEY	:  /* TR-90N1659  2/10/91  GLC */
		/* case EX_STRING	: AF 13-JUN-89 causes troubles */
		case CMD_STRING	: exmode = runparms->EX_cmd_mode ; break ;
		default		: exmode = 0 ; break ;
	}
	status = ex$putque (
		msg =		&msg,
		pos =		pos ,
		response =	&resp,
		byte =		(IGRlong *)&size,
		mode =		exmode,
		buffer =	data );

	if (!status || COERROR(msg)){
		erreur("ciputevent->ex$putque error");
		return 0;
	}

	i_cival(pm[PUTEVRC]) = 1;
	return ISUCCESS ;
}

__ci_build_button(pbutton, wind_name) /* OLD */
struct EX_button *pbutton;
char *wind_name;
/*
 * to fill button the first time
 */
{
	IGRlong		msg;
	struct GRid	WinGRd[33];	/* 32 = default value */
	struct GRid     modGrid;
	int 		nb;
#ifdef DEBUG
printf("entering ci_build_button, name = %s\n",wind_name);fflush ( stdout ) ;
#endif
	/* get a window id */
	GRfindmod( &modGrid );
	dp$get_gragad_id (
		msg = &msg,
		array_size = 32,
		mod_GRid = &modGrid,
		name = wind_name,
		numberofids = &nb,
		found_GRids = WinGRd );
#ifdef DEBUG
printf("after dp$get_gragad_id, found_GRids[0]:(%d,%d), numberofids :%d, msg:%d\n",
			(int)WinGRd[0].objid,(int)WinGRd[0].osnum, nb, msg );
fflush ( stdout ) ;
#endif
	if( nb == 0 || COERROR(msg) )	return 0;

	/* build the button, always successfull */		
	co$build_button( 
		msg = &msg,
		objid = WinGRd[0].objid,
		osnum = WinGRd[0].osnum,
		button = pbutton );

	return ISUCCESS ;
}

/*----------------------------------------------------------------------------*/
int ci_build_button( rc, pbutton, wind_name ) /* NEW when gr$get_last_point works */

long	*rc ;			/* OUT: Completion code		*/
struct	EX_button *pbutton ;	/* OUT: Button structure	*/
char	*wind_name ;		/* IN : Window name		*/
/*
 * to fill button the first time
 */
{
	IGRlong		msg;
	struct GRid	WinGRd[33];	/* 32 = default value */
	struct GRid     modGrid;
	int 		nb, size ;

#ifdef DEBUG
if( wind_name ) printf( "ci_build_button, ENTER name = %s\n", wind_name ) ;
else            printf( "ci_build_button, ENTER name = NULL\n" ) ;
#endif

	*rc = CI_S_SUCCESS ;

	if( wind_name == NULL ) {
		size = sizeof *pbutton ;
/* --		NOTE: gr$get_last_point seems to always return TRUE and
		msg = MSSUCC ...
   -- */
		gr$get_last_point(	msg	= &msg		,
					sizbuf	= &size		,
					buffer	= pbutton	,
					nret	= &nb		) ;

#ifdef DEBUG
 printf( "ci_build_button: gr$get_last_point msg == MSSUCC ? %d\n",
		msg == MSSUCC ) ;
 printf( "ci_build_button: window = ( %d, %d )\n", pbutton->osnum, pbutton->objid);
#endif
		if( IF_EQ_OBJID( pbutton->objid, NULL_OBJID ) ) {
/* --			No window at all !
   -- */
			*rc = CI_E_NOWINFOUND ;
			goto WRAPUP ;
		}
	} else {
		
		/* get a window id */
		GRfindmod( &modGrid );
		dp$get_gragad_id (
				msg = &msg,
				array_size = 32,
				mod_GRid = &modGrid,
				name = wind_name,
				numberofids = &nb,
				found_GRids = WinGRd );
#ifdef DEBUG
printf("after dp$get_gragad_id, found_GRids[0]:(%d,%d), numberofids :%d, msg:%d\n",
			(int)WinGRd[0].objid,(int)WinGRd[0].osnum, nb, msg );
fflush ( stdout ) ;
#endif
		if( nb == 0 || COERROR(msg) ) {
			*rc = CI_W_WNNOTFOUND ;
			goto WRAPUP ;
		}
		/* Build the button, always successfull */		
		co$build_button( 
			msg = &msg,
			objid = WinGRd[0].objid,
			osnum = WinGRd[0].osnum,
			button = pbutton );
	}

	WRAPUP :
#ifdef DEBUG
 printf( "ci_build_button: EXIT with " ) ;
 ci$report_error( status = *rc, output = CI_ERR_STDOUT ) ;
fflush ( stdout ) ;
#endif
	return *rc == CI_S_SUCCESS ;
}
/*----------------------------------------------------------------------------*/
#argsused
int cidocmd( type, func, cmdevdata, runparms, state )

int			type;
struct ci_instruction	*func;
CIco_resp		*cmdevdata;
CIruntime		*runparms ;
short			*state	  ;

/*
 * type = CI_DOCMD_STR	: begincmd
 * type = CI_DOCMD_KEY	: begincmd_key	add sept 12th, 1988
 * type = CI_DOCMD_END	: endcmd
 * type = CI_DOCMD_RESET: reset ( beginning of file )
 */

{
	static int			fcicmdstring = 0;
	struct EX_cmd_mode_resp_data	*EX_resp	;

#ifdef DEBUG
  printf( "cidocmd: ENTER type %d cmdtype %d\n", type, cmdevdata->cmd.type ) ;
  printf( "cidocmd: cmd <%u>\n",& cmdevdata->cmd ) ;
#endif

  if( type == CI_DOCMD_KEY || type == CI_DOCMD_STR || type == CI_DOCMD_END ) {
	if( !ci_can_be_stacked(ci_data, ci_data_info) ){
		erreur("begincmd/endcmd: cannot interrupt or stack this file");
		return IFAILED;
	}
  }

  switch( type ) {
	case CI_DOCMD_STR	:	/* begincmd */
	case CI_DOCMD_KEY	:	/* begincmd_key */
#ifdef DEBUG
  printf( "cidocmd: type %d val <%s>\n", type, st_cival(func->paramlist[1]) ) ;
#endif
		if( fcicmdstring == 1 ) {
		    linerreur("begincmd[_key]: nested begincmd/endcmd sequence",
					 func->paramlist[func->nbparam]);
		    fcicmdstring = 0;
		    return IFAILED;
		}
		fcicmdstring = 1;

/***************************************************/
/***** VALIDATE COMMAND:  added 3/14/91 by GLC *****/

		if (type == CI_DOCMD_STR)
		{
			if( !ex$get_cmd_info( 
				string = st_cival(func->paramlist[1]),
				mode = EX_STRING,
				cmdstr = &cmdevdata->cmd ) )
			{
				sprintf(errmess,
					"begincmd: CMD %s does not exist",
					st_cival(func->paramlist[1]) );
			 	linerreur( errmess, func->paramlist[func->nbparam]);
				fcicmdstring = 0;
				return IFAILED;
			}
			cmdevdata->cmd.command_name_ptr = st_cival(func->paramlist[1]);
			cmdevdata->cmd.type = EX_STRING;
		}
		else
		{
			if( !ex$get_cmd_info( 
				string = st_cival(func->paramlist[1]),
				mode = EX_CMD_KEY,
				cmdstr = &cmdevdata->cmd ) )
			{
				sprintf(errmess,
					"begincmd_key: CMD_KEY %s does not exist",
					st_cival(func->paramlist[1]) );
			 	linerreur( errmess, func->paramlist[func->nbparam]);
				fcicmdstring = 0;
				return IFAILED;
			}
			cmdevdata->cmd.type = EX_CMD_KEY;
		}


#ifdef DEBUG
  printf( "cidocmd: EXIT type %d cmdtype %d\n", type, cmdevdata->cmd.type ) ;
#endif
		return ISUCCESS;
	case CI_DOCMD_END	:	/* endcmd */
#ifdef DEBUG
  printf( "cidocmd: (endcmd) EX_cmd_mode %u\n", runparms->EX_cmd_mode ) ;
  fflush( stdout ) ;
#endif
		if( fcicmdstring == 0 )	{
			linerreur("endcmd:  nested begincmd/endcmd sequence",
					 func->paramlist[func->nbparam]);
			return ISUCCESS;
		}
/* --
   Following H. TSAI's advice, this is what is done to enable the quiet
   mode to be taken into account by the begincmd-endcmd sequence.
   1/ *cmdevdata->response is set to EX_CMD_M_STR or EX_CMD_M_KEY
   2/ cmdevdata->response_data is considered a pointer to the structure
	struct {
	    int	 mode;
	    char string[128];
	} EX_cmd_mode_resp_data; ( defined in expriv.h )

   -- */
		EX_resp = (struct EX_cmd_mode_resp_data *)cmdevdata->response_data ;
		EX_resp->mode = runparms->EX_cmd_mode ;
		switch( cmdevdata->cmd.type ) {
			case EX_STRING	:
					  strcpy(	EX_resp->string,
							cmdevdata->cmd.command_name_ptr ) ;
					  *cmdevdata->response = EX_CMD_M_STR;
					  break ;
			case EX_CMD_KEY	: 
					  strcpy(	EX_resp->string,
							cmdevdata->cmd.command_key ) ;
					  *cmdevdata->response = EX_CMD_M_KEY;
					  break ;
			default		:
				printf( "cidocmd: unknown command type %d\n",
					cmdevdata->cmd.type ) ;
		}
		fcicmdstring = 0;
		return IFLUSH;
	case CI_DOCMD_RESET	: /* reset of fcicmdstring */
		fcicmdstring = 0;
		return ISUCCESS;
	default:/* soft error: type unknown */
		return IFAILED;
	}
}


#argsused
ci_can_be_stacked(xdata, xdata_info)
struct 	instance_ci *xdata;
char	*xdata_info;
/*
 * checks if the ci file can be interrupted, i.e. if its sender_id
 * is a ci or COci object and if option is good
 */
{
	extern GRclassid	CI_ci_classid, CI_COci_classid ;

/* AF causes many troubles to the dimensioning ...
#ifdef DEBUG
  printf( "ci_can_be_stacked : xdata->options & 0x02 ? %d\n", xdata->options & 0x02 ) ;
#endif
	if( xdata->options & CI_NOMSG_MODE )
		return 0;
*/
	return TRUE ;

/* sender_os to be taken into account as soon as possible
	om$get_classid(	osnum		= OM_Gw_TransOSnum_0,
			objid		= ((ci_IGE *)xdata_info)->sender_id,
			p_classid	= &sender_class_id );

	if ( om$is_ancestry_valid(
			subclassid	= sender_class_id,
			superclassid	= CI_ci_classid   ) == OM_S_SUCCESS
	  || om$is_ancestry_valid(
			subclassid	= sender_class_id,
			superclassid	= CI_COci_classid ) == OM_S_SUCCESS )
		return 1;


	return 0;  */
}


#argsused
int CIquiet( func, evdata, runparms, state )
struct ci_instruction	*func		;
CIco_resp		*evdata		;
CIruntime		*runparms 	;
short			*state		;
/*
 * Set the quiet mode for the running CI object.
 * Function called from CI code.
 * Referenced in the macro: ci$quiet
 */
{
     runparms->EX_cmd_mode =
	(i_cival(func->paramlist[1]) == 0? 0: EX_HELP_QUIET) |
	(i_cival(func->paramlist[2]) == 0? 0: EX_MSG_QUIET) |
	(i_cival(func->paramlist[3]) == 0? 0: EX_DISP_QUIET);
    i_cival(func->paramlist[0]) = 1;

    return ISUCCESS;
}
