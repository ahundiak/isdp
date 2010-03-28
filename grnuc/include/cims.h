#ifndef cims
#define cims

#include "ciminimum.h"

/* following definitions are taken from include files
   ../exec/include/msdef.h
   ../exec/include/ms.h
 */
#define CENTER_JUS 1
#define RIGHT_JUS  2
#define LEFT_JUS   3

#define MESSAGE_FIELD 1
#define ERROR_FIELD   2
#define PROMPT_FIELD  3
#define KEYIN_FIELD   4

struct {
    int		no_args;
    int		no_msg;
    char	u_type[81];
    char	for_type[81];
    char 	in_msg[256];
    char 	variables[256];
    char	out_msg[256];
} MS_msg;


/*
	This macro is the interface into the message subsystem.  It will
	not display anything on the screen if message display is off.
	The arguments are as follows:
	
	int		field
			   This specifies where to display the message.
			   This field will override the default built 
			   into the message.
			 
	int		msgnumb
			   This is the key by which the message table is
			   accessed.
			   
	int		justification
			    How the text should be justified in the field
			    when displayed.
			    
	char		*buff
			    If specified, the message will not be displayed
			    but will be returned in the address specified by
			    buff.

	char		*type		    
			   Indicates the type of arguments that are specified
			   in the variable. An example is  type = "%d%lf",
			   
			var
			   The variables that are to be inserted into the 
			   message.  These must be surrounded by the 
			   character `.  An example is var = `ii, jj`,
*/

#omdef ci$message ( 
		field = (short)MESSAGE_FIELD, 
		msgnumb,
		justification = CENTER_JUS,
    		buff = NULL,
    		type = NULL,
    		var = NULL)

        if (MS_init ( (&MS_msg), (msgnumb) ) )
	{
#           if om$specified (type)
                MS_fix_type( (&MS_msg), (type) );
   	        sprintf( (MS_msg.variables), (MS_msg.for_type), var );
#           endif
	    MS_out_msg ( (&MS_msg), (buff), (field), (justification) );
        }

#endomdef

#endif

extern MS_init(), MS_fix_type(),  MS_out_msg(), sprintf();
