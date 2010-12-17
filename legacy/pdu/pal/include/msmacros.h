#ifndef msmacros_include

#define msmacros_include

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

#omdef
    ex$message (field=0, msgnumb = MS_NO_MSG, msgname = NULL, 
                justification=0, buff=NULL, type=NULL, 
                var=NULL, in_buff=NULL, time = MS_IMMEDIATE, 
                seconds = MS_IMMEDIATE)
#   if om$specified (type)

    {
/*    struct MS_sd_msg MS_msg; */

        if (MS_init ( (&MS_msg), (msgnumb), (msgname), (in_buff), (field), 
                      (justification) ) )
	{
            MS_fix_type( (&MS_msg), (type) );
            sprintf( (MS_msg.variables), (MS_msg.for_type), var );
	    MS_out_msg ( (&MS_msg), (buff), (field), (justification),
	                  (time), (seconds) );
        }
    }
#else
    MSmessage ( (field), (msgnumb), (msgname), (justification), (buff),
                (type), (var), (in_buff), (time), (seconds) );
#endif    

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

/*
 *  This macro will take in a message key, and return the pointer to the
 *  associated string that is stored in the message tables.  Note that the
 *  pointer returned is stored internally in the message structures.  If 
 *  the contents of the pointer are changed the message tables may be
 *  corrupted.
 *
 *  Arguments:          Type        I/O    What is it?
 *
 *      msgname        IGRchar *     I      A pointer to an ascii key into the
 *                                            message system.
 *
 *      msgnumber      IGRlong       I      A numeric key into the message 
 *                                            system.
 *      
 *      buffer         IGRchar **    I/O    The pointer that will be modified
 *                                            to point to the message string
 *                                            stored in the message tables.
 */
 
#omdef ms$get_message (msgname = NULL ^ msgnumber = MS_NO_MSG,
                       buffer)
                       
    MSget_message ( (msgnumber), (msgname), (buffer) )
    
#endomdef
   
#endif
