#ifndef msmacros_include

#define msmacros_include
#include "igrtypedef.h"
#include "exms.h"
#include "msdef.h"
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern void MS_format_message __((struct MS_sd_msg *MS_msg));

extern int MS_init __((struct MS_sd_msg *MS_msg,IGRlong msgnumb,
                       IGRchar *msgname,IGRchar *in_buff,
                       IGRint field, IGRint justification));
extern int MSget_message __((long msgnumber,char **buffer,int *nbytes));
extern int EX_create_prompt __((int message_number, int left_prompt_number,
		int right_prompt_number, char *string, int *response,
		char *response_data));
extern void MS_file_init __((IGRchar *message_file, IGRchar *msg_file));
extern void MS_fix_type __((struct MS_sd_msg *MS_msg, IGRchar *type));
extern void MS_function __((IGRint status, IGRint (*function )()));
extern int MS_onoff __((IGRlong *msg, IGRshort *previous_state,
		IGRshort new_state, IGRint type));
extern int MS_out_msg __((struct MS_sd_msg *MS_msg, IGRchar *buff,
		IGRint field, IGRint justification, IGRint delay_time,
		IGRint seconds,IGRint buffer_size));
extern int MSmessage __((IGRint field, IGRlong msgnumb, IGRchar *msgname,
		IGRint justification, IGRchar *buff, IGRchar *type,
		IGRchar *var, IGRchar *in_buff, IGRint delay_time,
		IGRint seconds,IGRint buffer_size));

extern int MS_return_sizeof_message __((IGRlong msgnumb, IGRchar *msgname,
		IGRint *nbytes));


/* MSretmsg.c */
extern int MS_retrieve_msg __((struct MS_sd_msg *MS_msg));

/* MSdismsg.C */
extern int MS_display_message __((IGRint field, IGRint justification, IGRchar *string, struct MS_sd_msg *MS_msg, IGRint delay_time, int seconds));
extern int MSgetfont __((void));
extern int MS_update_msg_strip __((int field_no, int just, char *string));
extern int MSerrbox __((IGRint field, IGRint justification,
                          IGRchar *string, struct MS_sd_msg *MS_msg));
extern int EX_error_box __((int screen_no, char *msg, char *title));
extern int MS_paint_area __((void));
		
#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/
/*
	This macro is the interface into the message subsystem.  It will
	not display anything on the screen if message display is off.
	The arguments are as follows:
	
	IGRint		field
			   This specifies where to display the message.
			   This field will override the default built 
			   into the message.
			 
	IGRlong		msgnumb
			   This is the key by which the message table is
			   accessed.
			   
        IGRchar         *msgname
        		   This is an ascii key by which the message table
        		   may be accessed.
        		   
	IGRint		justification
			    How the text should be justified in the field
			    when displayed.
			    
	IGRchar		*buff
			    If specified, the message will not be displayed
			    but will be returned in the address specified by
			    buff.

    IGRint     buffer_size
               If specified, sizeof the buffer 'buff' above in which to
               output your text. If the message is longer than
               the buffer 'buff', the message will be truncated.

	IGRchar		*type		    
			   Indicates the type of arguments that are specified
			   in the variable. An example is  type = "%d%lf",


			var
			   The variables that are to be inserted into the 
			   message.  These must be surrounded by the 
			   character `.  An example is var = `ii, jj`,

	The macro will allow the specification of msgnumb, msgname, and
	in_buff at the same time.  The order of precedence is:

		in_buff
		msgnumb
		msgname
*/

#omdef  ex$message (field=0, msgnumb = MS_NO_MSG, msgname = NULL, 
                justification=-1, buff=NULL, type=NULL, 
                var=NULL, in_buff=NULL, time = MS_IMMEDIATE, 
                seconds = MS_IMMEDIATE, ret_status = NULL,
                buffer_size = 0 )
#   if om$specified (type)

    {
    struct MS_sd_msg MS_msg;

        if (MS_init ( (&MS_msg), (msgnumb), (msgname), (in_buff), (field), 
                      (justification) ) )
	{
     int stat;
            MS_fix_type( (&MS_msg), (type) );
            sprintf( (MS_msg.variables), (MS_msg.for_type), var );
	    stat =MS_out_msg ( (&MS_msg), (buff), (field), (justification),
	                  (time), (seconds),(buffer_size) );
#if om$specified( ret_status ) 
         *(ret_status)=stat;
#endif
        }
    }
#else
     MSmessage ( (field), (msgnumb), (msgname), (justification), (buff),
                (type), (var), (in_buff), (time), (seconds),(buffer_size) );
#endif    

#endomdef

/*----------------------------------------------------------------------------*/
/*
	This macro returns the number of bytes in the message, including
    an extra byte necessary for a NULL should you wish to null terminate
    the string.

	The arguments are as follows:
	
	IGRlong    msgnumb
			   This is the key by which the message table is
			   accessed.
			   
    IGRchar     *msgname
        		This is an ascii key by which the message table
        		   may be accessed.
        		   
	IGRint		*nbytes
			    The number of bytes in the message string, including
                an extra byte for a NULL should you wish to null terminate
*/

#omdef
    ex$sizeof_message (msgnumb = MS_NO_MSG, msgname = NULL, 
                nbytes=NULL)

    MS_return_sizeof_message ( msgnumb, msgname,nbytes)

#endomdef

#omdef ex$create_prompt ( message_no, left_prompt, right_prompt,
                           string = NULL, response,response_data)
  EX_create_prompt((message_no),(left_prompt),(right_prompt),(string),
                   (response),(response_data))
#endomdef



/*
	This macro is to control the display of messages to the 
	screen.  The arguments are as follows:
	
	IGRlong		*msg 
			    return code (MSSUCC or MSFAIL)
			    
	IGRshort	*prevstate
			    state of message display previous to call
			    (this allows for nesting)
			    
	IGRshort	setstate
			    what to set the message display state to 	
			    this is only valid when type is equal to 
			    MS_SET

	IGRint		type
			    type of action to take (on/off/set)
	
*/
#omdef ms$onoff ( msg, prevstate, setstate = MS_NO_STATE, type = MS_ON )

    MS_onoff ( (msg), (prevstate), (setstate), (type) )
    
#endomdef   

/*
	This macro will initialize the message system.  The two arguments
	are as follows:
	
	IGRchar		*message_file
	
			If the default is taken the file called message_file
			located in the current mod_type_x will be used to
			initialize the message system.  This file will contain
			a list of .msg files that the message system will open
			and read into memory.
			
			If a file is specified the explicit path name is 
			assumed to be included.  
			
	IGRchar		*msg_file
			If the default is taken no action occurs.
			
			If a file is specified the full path name must
			be specified.  The file specified will be opened
			and the contents read into memory.
			
*/

#omdef ms$init (message_file = NULL, msg_file = NULL)

    MS_file_init ( (message_file), (msg_file) )

#endomdef   

/*
	This macro provides a way to intercept messages that are going
	to be displayed on the screen.
	
	The arguments are:
	
	status      use #define's specified in msdef.h
		    This argument will tell which  type of messages
		    should call the specified function.

		    If this is not specified the message system
		    will be set to default system status.  That is 
		    messages will be displayed in the message fields.

	function    IGRint (*function)()
		    This is a pointer to a function that will be called
		    for type type of message specified.

		    If this is not specified then the function is assumed
		    to be the system default.

	Example calls:
	
		ms$function();	   -- return to default system status 
		
		
		ms$function (status = MS_I_STATUS, function = my_fun)
		
				   set all messages of information status
				   to call the function pointed to by my_fun
				   
*/
#omdef ms$function (status = MS_SYSTEM_STATUS, function = NULL)

   MS_function  ( (status), (function) )
   
#endomdef

   
#endif
