/*
 * OM macros for command files in CI
 * for event queue managing
 * E BEEKER sept '87
 *
 * File dependency: ciminimum.h
 */

#ifndef cievent_include
#define cievent_include

#ifndef ciminimum_include
#	omerror "ciminimum.h must be included prior to this file"
#endif
int M_response;
int M_status;
char *M_string;
double *M_p;
long M_msg;

extern struct EX_cmd_cntr *EX_cmdlist_ptr;
extern int EX_cmdsrch();

/******************************* ci$getevent ***********************************
 * general purpose getevent
 * ARGUMENTS:
 *  struct GRevent	*event	Pointer to the general event.
 *				"struct GRevent" is defined in grio.h.
 *  OR
 *  struct EXFI_data_st	*gadget Pointer to a form's gadget data.
 *				"struct EXFI_data_st" is defined in exfi.h
 *				The pointed-to variableis updated by the system,
 *				the allocation must be done by the user.
 *  int		*response	Address of the response to be returned.
 *				Allocation must be done by the user.
 *		*data		pointer to a point (EX_DATA) or a string
 *				([CMD_]STRING)
 *				This pointer is updated by the system :
 *				NO ALLOCATION to be done.
 *	int	stackable	0: no i.e. catches CMD_STRING, EX_RJT_MOVEON,
 *				etc., except TERMINATE.
 *				1: the calling file can be stacked
 *	GRobj   *window_id	Returns the window's object id.
 *	short   *window_osnum   Object space number of the window
 *	char	*prompt 	Prompt that will be output.
 *				If CI_NULL, the prompt is unchanged
 *				( the one output by function prompt() )
 *	int	msgnum		Alternative to "prompt", using the 
 *				message subsystem.
 *	int	mask		Internal use ( can be used by the user as in 
 *				co$getevent at her or his own risk )
 *
 * RETURN CODE
 *	0: failure
 *	1: success
 */

#omdef ci$getevent(	
		event		= CI_NULL,
		response	= CI_NULL,
		data		= CI_NULL, /* redundant with event, but handy */
		stackable	= 0,
		window_id	= CI_NULL,
		window_osnum 	= CI_NULL,
		mask		= 0,
		prompt		= CI_NULL,
		msgnum		= -1  )


#if om$specified( msgnum )
CIgetevent( ( event ), ( response ), (data), (stackable),
	    (window_id), (window_osnum), (msgnum), (mask) )
#else
CIgetevent( ( event ), ( response ), (data), (stackable),
	    (window_id), (window_osnum), (prompt), (mask) )
#endif
#endomdef

/********************************* ci$get **************************************
 *  more selective get
 *  one of the next types must be specified:
 *  int			*response	OUT to get only the response
 *  double		point[3]	OUT to get a point
 *  int/double		value		OUT to get a value
 *  char		*string		OUT to get a string
 *  char		*cmd		OUT to get a command string
 *  char		*form		IN  name of form to get data from
 *			                Must be specified along with `gadget'
 *  struct EXFI_data_st	*gadget		OUT gadget data collected from form.
 *  int			rc		OUT Return code (0:failed, 1:SUCCESS )
 *
 *  The other parameters are similar to those of ci$getevent.
 *
 * RETURN CODE
 *	0: failure (RESET)
 *	1: success
 *	or in "rc"
 * NOTE: `gadget' must have some of its field filled ( e.g. gadget label, etc. )
 *       before the call as before sending a FIform.get_by_value message.
 */

#omdef ci$get(		response ^ point ^ value ^ string ^ cmd ^ char ^ form,
		   	stackable	= 1,
		   	window_id	= CI_NULL,
		   	window_osnum	= CI_NULL,
		   	prompt		= CI_NULL,
		   	msgnum		= -1,
		   	gadget		= CI_NULL,
		   	rc		= M_status )

#if om$specified (string)
 {
#	if om$specified( msgnum )
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= (stackable),
		    			mask		= GRm_STRING,
		    			msgnum		= (msgnum) ) ;
#	else
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= (stackable),
		    			mask		= GRm_STRING,
		   			prompt		= (prompt) ) ;
#	endif
	if( M_response == STRING )
		strcpy( (string), M_string) ;
 }
#elif om$specified (char)
 {
#	if om$specified( msgnum )
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= (stackable),
		    			mask		= GRm_CHAR,
		    			msgnum		= (msgnum) );
#	else
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= (stackable),
		    			mask		= GRm_CHAR,
		    			prompt		= (prompt) ) ;
#	endif
	if( M_response == CHAR )
		(char) = M_string[0] ;
 }
#elif om$specified (value)
 {
#	if om$specified( msgnum )
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= (stackable),
		    			mask		= GRm_STRING,
		    			msgnum		= (msgnum) ) ;
#	else
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= (stackable),
		    			mask		= GRm_STRING,
		    			prompt		= (prompt) ) ;
#	endif
	if( M_response == STRING )
		(value) = atof(M_string) ;
 }
#elif om$specified (point)
 {
#	if om$specified( msgnum )
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_p,
		    			stackable	= (stackable),
		    			window_id	= (window_id),
		    			window_osnum	= (window_osnum),
    		    			mask		= GRm_DATA,
		    			msgnum		= (msgnum) ) ;
#	else
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_p,
		    			stackable	= (stackable),
		    			window_id	= (window_id),
		    			window_osnum	= (window_osnum),
    		    			mask		= GRm_DATA,
		    			prompt		= (prompt) ) ;
#	endif
	if( M_response == DATA ){
		(point)[0] = M_p[0];
		(point)[1] = M_p[1];
		(point)[2] = M_p[2];
	}
  }
#elif om$specified (response)
#	if om$specified( msgnum )
		ci$getevent(	response	= (response),
		    		stackable	= (stackable),
		    		msgnum		= (msgnum) )
#	else
		ci$getevent(	response	= (response),
		    		stackable	= (stackable),
		    		prompt		= (prompt) )
#	endif
#elif om$specified (cmd)
 {
#	if om$specified( msgnum )
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= 0,
    		    			mask		= GRm_RESET,
		    			msgnum		= (msgnum) ) ;
#	else
		rc = ci$getevent(	response	= &M_response,
		    			data		= M_string,
		    			stackable	= 0,
    		    			mask		= GRm_RESET,
		    			prompt		= (prompt) ) ;
#	endif
	if( M_response == CMD_STRING )
		strcpy( (cmd), M_string) ;

	if( M_response == EX_CMD_KEY )
         {
		strcpy( (cmd), M_string );
		EX_cmdsrch ( &M_msg, EX_cmdlist_ptr, (cmd), &M_cmd, &M_response);
         }
 }
#elif om$specified( form )
#	if om$equal( gadget, CI_NULL )
#		omerror "`gadget' must be specified with `form'"
#	else
 {
 	rc = ci$getevent(	response 	= &M_response	,
 				data	 	= (form)	,
 				stackable 	= (stackable)	,
 				mask	 	= GRm_COMMAND	,
 				event		= (gadget)	) ;
 }
#	endif
#endif
#endomdef /* ci$get */

/******************************** ci$putevent *********************************/
/*
 * general putevent
 * not to be used by end user
 * is used in ci$put
 */
#omdef ci$putevent(	
		response,
		data		= CI_NULL,
		window_name	= CI_NULL
		^ window_id	= NULL_OBJID,	/* for ci$put( point = ... */
		osnum		= CI_NULL,	/* for ci$put( obj   = ... */
		data_point	= CI_NULL,	/* for ci$put( obj   = ... */
		gadget		= CI_NULL,	/* for ci$put( form  = ... */
		pos		= BACK )	/* BACK or FRONT	   */

#if om$specified (window_name)
    CIputevent( ( response ), (pos), (data),
    			 (osnum), (0), (window_name), (data_point), (gadget) )
#else
    CIputevent( ( response ), (pos), (data), 
    			(osnum), (1), (window_id), (data_point), (gadget) )
#endif

#endomdef

/****************************** ci$put ******************************/
/*
 * selective putevent
 * ARGUMENTS
 *	char	*cmd		: Command string
 *	char	*cmd_key	: Command key string
 *	char	*string		: String
 *	double	*point		: Co-ordinates of point
 *	char	*form		: Form name
 *	int	response	: Type of event, some responses do not need any
 *				  data to be specified :
 *					EX_RJT_MOVEON,
 *					EX_BACK_UP,
 *					MOVE_ON,
 *					 ...
 *	GRobj	obj		: Object Manager's object id.
 * NOTE: these arguments are exclusives.
 *  char		*window_name	: Active for ci$put( point = ... only,
 *					  optional
 *  GRobj		window_id	: For ci$put( point = ... only if
 *					  "window_name" not specified, optional
 *  short		*osnum		: Object space of the object or the
 *					  window
 *  double		*data_point	: For "obj" only
 *  struct EXFI_data_st	*gadget    	: For ci$put( form = ... only, 
 *                                        "struct EXFI_data_st" is defined
 *                                        in exfi.h
 *  int			pos		: BACK or FRONT defined in exdef.h
 *
 * RETURN CODE
 *	0: failure
 *	1: success
 *
 * EXAMPLES of CALLS
 *	ci$put(cmd="place point");
 *	ci$put(obj=LINE, osnum=&OM_Gw_current_OS);
 *	ci$put(point=p1, window_name="front");
 *	ci$put(response=MOVE_ON);
 */
 
#omdef ci$put(	  cmd
		^ cmd_key
		^ string
		^ point
		^ response
		^ obj
		^ value
		^ char
		^ form,
		window_name	= CI_NULL,	/* for ci$put( point = ... */
		window_id	= NULL_OBJID,	/* for ci$put( point = ... */
		osnum		= CI_NULL,	/* for ci$put( obj   = ... */
		data_point	= CI_NULL,	/* for ci$put( obj   = ... */
		gadget		= CI_NULL,	/* for ci$put( form  = ... */
		pos		= BACK )	/* BACK or FRONT	   */

#if om$specified (string)
	ci$putevent(	response	= EX_STRING,
		   	data		= (string),
		   	window_id	= NULL_OBJID, 
		   	pos		= (pos) )
#elif om$specified (char)
	ci$putevent(	response	= EX_CHAR,
		   	data		= &(char),
		   	window_id	= NULL_OBJID, 
		   	pos		= (pos) )
#elif om$specified (value)
 	ci$putevent(	response	= EX_STRING,
 		   	data		= ntoa(value),
		   	window_id	= NULL_OBJID, 
		   	pos		= (pos) )
#elif om$specified (point)
#	if om$equal(window_name, CI_NULL)
		ci$putevent(	response	= EX_DATA,
		   		data		= (point),
		   		window_id	= (window_id),
		   		osnum		= (osnum),
		   		pos		= (pos) )
#	else
		ci$putevent(	response	= EX_DATA,
		   		data		= (point),
		   		window_name	= (window_name),
		   		osnum		= (osnum),
		  		pos		= (pos) )
#	endif
#elif om$specified (response)
	ci$putevent(	response	= (response),
		   	window_id	= NULL_OBJID, 
		   	pos		= (pos) )
#elif om$specified (cmd)
	ci$putevent(	response	= CMD_STRING,
		   	data		= (cmd),
		   	window_id	= NULL_OBJID, 
		   	pos		= (pos) )
#elif om$specified (cmd_key)
	ci$putevent(	response	= EX_CMD_KEY,
		   	data		= (cmd_key),
		   	window_id	= NULL_OBJID, 
		   	pos		= (pos) )
#elif om$specified( form )
#	if om$equal( gadget, CI_NULL )
#		omerror "`gadget' must be specified with `form'"
#	else
	ci$putevent(	response	= EX_FORM_DATA	,
			data		= (form)	,
			window_id	= NULL_OBJID	, 
			gadget		= (gadget)	)
#	endif
#elif om$specified (obj)
#	if om$equal(window_name, CI_NULL)
		ci$putevent(	response	= EX_OBJID, 
			   	data		= &(obj),
			   	osnum		= (osnum),
			   	window_id	= (window_id),
			   	data_point	= (data_point), 
			   	pos		= (pos) )
#	else
		ci$putevent(	response	= EX_OBJID, 
			   	data		= &(obj),
			   	osnum		= (osnum),
			   	window_name	= (window_name),
			   	data_point	= (data_point), 
			   	pos		= (pos) )
#	endif
#endif
#endomdef


/****************************** ci$d_reset ******************************/
#omdef ci$d_reset( )

ci$put(response = TERMINATE )

#endomdef

/********************************** ci$reset **********************************/
#omdef ci$reset( )

ci$put(response = EX_RJT_MOVEON )

#endomdef

/******************************** ci$move_on **********************************/
#omdef ci$move_on( )

ci$put(response = MOVE_ON )

#endomdef

/********************************** ci$quiet **********************************/
/*
 * Set the quiet mode for the running CI object only.
 * Affect the standard CO called from that CI object through the macro:
 *  	ci$put(cmd = "XXX");
 * or the sequence:
 *	begincmd("XXX");
 *	  ...
 *	endcmd();
 * 0: default behaviour, quiet mode OFF.
 * 1: the corresponding quiet mode is ON.
 */
#omdef ci$quiet(hlp = 0,	// help quiet
		msg = 0,	// message quiet
		dsp = 0)	// display quiet

CIquiet((hlp), (msg), (dsp))
#endomdef

/********************************* OLDIES ******************************/
/* 
 * IGE response functions
 */
#define reset()		ci$reset()
#define d_reset()	ci$d_reset()
#define move_on()	ci$move_on()

#endif


