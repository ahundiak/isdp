/*******************************************************************************

	BAGgetopt()

	Function GETOPT gets the next option letter from the command line.
	GETOPT is an enhanced version of the C Library function, GETOPT(3).


	Invocation:

		option = BAGgetopt (argc, argv, optstring) ;

	where:

		<argc>
			is the number of arguments in the argument value array.
		<argv>
			is the argument value array, i.e., an array of pointers
			to the "words" extracted from the command line.
		<optstring>
			is the set of recognized options.  Each character in
			the string is a legal option; any other character
			encountered as an option in the command line is an 
			illegal option and an error message is displayed.  If a
			character is followed by a colon in OPTSTRING, the
			option expects an argument.
		<option>
			returns the next option letter from the command line.
			If the option expects an argument, OPTARG is set to 
			point to the argument.  '?' is returned in the cases of
			an illegal option letter or a missing option argument.
			Constant NONOPT is returned if a non-option argument is
			encountered or the command line scan is completed (also
			see OPTARG below for both cases).

	Public Variables:

		OPTARG - returns the text of an option's argument or of a non-
			option argument.  NULL is returned if an option has no
			argument or if the command line scan is complete.  For
			illegal options or missing options arguments, OPTARG 
			returns a pointer to the trailing portion of the 
			defective ARGV.

		OPTERR - controls whether or not GETOPT prints out an error
			message upon detecting an illegal option or a missing
			option argument.  A non-zero value enables error 
			messages; zero disables them.

		OPTIND - is the index in ARGV of the command line argument
			that GETOPT will examine next.  GETOPT recognizes 
			changes to this variable.  Arguments can be skipped by
			incrementing OPTIND outside of GETOPT and the command
			line scan can be restarted by resetting OPTIND to 
			either 0 or 1.

*******************************************************************************/

#include <stdio.h>				/* Standard I/O definitions */
#include <string.h>			/* C Library string functions */

#include "BAGgetopt.h"				/* GETOPT(3) definitions.     */

#include "XFIproto_pub.h"
/* #include "XFIproto_pri.h" */
#include "XFUproto_pri.h"

						/* Public variables.	      */
char  *BAGoptarg = NULL ;
int  BAGopterr = -1 ;
int  BAGoptind = 0 ;
						/* Private variables.	      */
static  int  end_optind = 0 ;
static  int  last_optind = 0 ;
static  int  offset_in_group = 1 ;



int  BAGgetopt (argc, argv, optstring)

	int  argc ;
	char  **argv ;
	char  *optstring ;

{
/* Local variables */

	char  *group, option, *s ;


/* Did the caller restart or advance the scan by modifying OPTIND? */

	if (BAGoptind <= 0)
	{
		end_optind = 0 ;
		last_optind = 0 ;
		BAGoptind = 1 ;
	}
	if (BAGoptind != last_optind)
		offset_in_group = 1 ;

/********************************************************************

	Scan the command line and return the next option or, if none,
	the next non-option argument.  At the start of each loop
	iteration, OPTIND is the index of the command line argument
	currently under examination and OFFSET_IN_GROUP is the offset
	within the current ARGV string of the next option (i.e., to
	be examined in this iteration).

********************************************************************/

	for (option = ' ', BAGoptarg = NULL ;
		BAGoptind < argc ;
		BAGoptind++, offset_in_group = 1, option = ' ')
	{
		group = argv[BAGoptind] ;

/* Is this a non-option argument?  If it is and it's the same
   one GETOPT returned on the last call, then loop and try the 
   next command line argument to the calling routine               */

		if ((group[0] != '-') ||
			((end_optind > 0) && (BAGoptind > end_optind)))
		{
			if (BAGoptind == last_optind)
				continue ; 
			             /* Return NONOPT and argument */
			BAGoptarg = group ;
			break ;
		}

/* Are we at the end of the current options group?  If so, loop and
   try the next command line argument.				   */

		if (offset_in_group >= (int) strlen (group))
			continue ;

/* If the current option is the end-of-options indicator, remember
   its position and move on to the next command line argument.     */

		option = group[offset_in_group++] ;
		if (option == '-')
		{
			end_optind = BAGoptind ;
				  /* Mark end-of-options position. */
			continue ;
		}

/* If the current option is an illegal option, print an error 
   message and return '?' to the calling routine                   */

		s = strchr (optstring, option) ;
		if (s == NULL)
		{
			if (BAGopterr)
				(void) fprintf (stderr, "%s: illegal option -- %c\n", argv[0], option) ;
			option = '?' ;
			BAGoptarg = &group[offset_in_group-1] ;
			break ;
		}

/* Does the option expect an argument?  If yes, return the option 
   and its argument to the calling routine.  The option's argument
   may be flush up against the option (i.e., the argument is the
   remainder of the current ARGV) or it may be separated from the
   option is the whole of the next ARGV).                          */

		if (*++s == ':')
		{
			if (offset_in_group < (int) strlen (group))
			{
				BAGoptarg = &group[offset_in_group] ;
				offset_in_group = strlen (group) ;
			}
			else 
			{
				if ((++BAGoptind < argc) && (*argv[BAGoptind] != '-'))
				{
					BAGoptarg = argv[BAGoptind] ;
				}
				else
				{
					if (BAGopterr)
						(void) fprintf(stderr, "%s: option requires an argument -- %c\n", argv[0], option) ;
					option = '?' ; 
					BAGoptarg = &group[offset_in_group-1] ;
					offset_in_group = 1 ;
				}
			}
			break ;
		}

/* It must be a single-letter option without an argument.          */

		break ;

	}

/* Return the option and (optionally) its argument.                */

	last_optind = BAGoptind ;
	return ((option == ' ') ? NONOPT : (int) option) ;

}
/* End of File */

