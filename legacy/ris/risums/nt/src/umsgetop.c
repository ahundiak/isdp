/*******************************************************************************

	UMSgetopt()

	Function GETOPT gets the next option letter from the command line.
	GETOPT is an enhanced version of the C Library function, GETOPT(3).


	Invocation:

		option = UMSgetopt (argc, argv, optstring) ;

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

#include <stdio.h>
#include <stdlib.h>

/* sml:06-29-93     include this to get UMCWriteLogComments() function */
#include "pumc_all.h"




#define USE_INDEX 0				/* Set to 1 if your C       */
						/* Library uses "index"     */
						/* instead of "strchr".     */

/* compiler not seeing USE_INDEX 0 define */
//	#if USE_INDEX
//	#	include <strings.h>			** C Library string functions **
//	#	define strchr index
//	#else
#	include <string.h>			/* C Library string functions */
//	#endif
#include "UMSgetop.h"				/* GETOPT(3) definitions.     */

						/* Public variables.	      */

/***********************************************/
/* sml,jaj:NO TR                               */
/*  UMSoptarg must have some space allocated   */
/*  in order to work on the Pentium.           */
/*char  *UMSoptarg = NULL ;                    */
/***********************************************/

THREAD_DECL char  UMSoptarg [1000] ;
THREAD_DECL int  UMSopterr = -1 ;
THREAD_DECL int  UMSoptind = 0 ;
						/* Private variables.	      */
THREAD_DECL static  int  end_UMSoptind = 0 ;
THREAD_DECL static  int  last_UMSoptind = 0 ;
THREAD_DECL static  int  offset_in_group = 1 ;



int  UMSgetopt (argc, argv, optstring)

	int  argc ;
	char  **argv ;
	char  *optstring ;

{
/* Local variables */

	char  *group, option, *s ;


/* Did the caller restart or advance the scan by modifying OPTIND? */

	if (UMSoptind <= 0)
	{
		end_UMSoptind = 0 ;
		last_UMSoptind = 0 ;
		UMSoptind = 1 ;
	}
	if (UMSoptind != last_UMSoptind)
		offset_in_group = 1 ;

/********************************************************************

	Scan the command line and return the next option or, if none,
	the next non-option argument.  At the start of each loop
	iteration, OPTIND is the index of the command line argument
	currently under examination and OFFSET_IN_GROUP is the offset
	within the current ARGV string of the next option (i.e., to
	be examined in this iteration).

********************************************************************/

	for (option = ' ', UMSoptarg[0] = (char) NULL ;
		UMSoptind < argc ;
		UMSoptind++, offset_in_group = 1, option = ' ')
	{
		group = argv[UMSoptind] ;

/* Is this a non-option argument?  If it is and it's the same
   one GETOPT returned on the last call, then loop and try the 
   next command line argument to the calling routine               */

		if ((group[0] != '-') ||
			((end_UMSoptind > 0) && (UMSoptind > end_UMSoptind)))
		{
			if (UMSoptind == last_UMSoptind)
				continue ; 
			             /* Return NONOPT and argument */
			strcpy(UMSoptarg, group) ;
			break ;
		}

/* Are we at the end of the current options group?  If so, loop and
   try the next command line argument.				   */

		if ( (unsigned) offset_in_group >= strlen (group))
			continue ;

/* If the current option is the end-of-options indicator, remember
   its position and move on to the next command line argument.     */

		option = group[offset_in_group++] ;
		if (option == '-')
		{
			end_UMSoptind = UMSoptind ;
				  /* Mark end-of-options position. */
			continue ;
		}

/* If the current option is an illegal option, print an error 
   message and return '?' to the calling routine                   */

		s = strchr (optstring, option) ;
		if (s == NULL)
		{
			if (UMSopterr)
			{
                            /*sml:06-29-93 write to log file not stderr */
        		    char comment[256];
		    
				/*(void) fprintf (stderr, "%s: illegal option -- %c\n", argv[0], option) ;*/
				sprintf (comment, "%s: illegal option -- %c\n", argv[0], option) ;
				UMCWriteLogComments(comment);
			}   
			option = '?' ;
			strcpy(UMSoptarg, &group[offset_in_group-1]) ;
			break ;
		}

/* Does the option expect an argument?  If yes, return the option 
   and its argument to the calling routine.  The option's argument
   may be flush up against the option (i.e., the argument is the
   remainder of the current ARGV) or it may be separated from the
   option is the whole of the next ARGV).                          */

		if (*++s == ':')
		{
			if ((unsigned) offset_in_group < strlen (group))
			{
				strcpy(UMSoptarg, &group[offset_in_group]) ;
				offset_in_group = strlen (group) ;
			}
			else 
			{
				if ((++UMSoptind < argc) && (*argv[UMSoptind] != '-'))
				{
					strcpy(UMSoptarg, argv[UMSoptind]) ;
				}
				else
				{
					if (UMSopterr)
                			{
                                            /*sml:06-29-93 write to log file not stderr */
                			    char comment[256];
						/*(void) fprintf(stderr, "%s: option requires an argument -- %c\n", argv[0], option) ; */
						sprintf(comment, "%s: option requires an argument -- %c\n", argv[0], option) ;
                				UMCWriteLogComments(comment);
		                	}   
					option = '?' ; 
					strcpy(UMSoptarg, &group[offset_in_group-1]) ;
					offset_in_group = 1 ;
				}
			}
			break ;
		}

/* It must be a single-letter option without an argument.          */

		break ;

	}

/* Return the option and (optionally) its argument.                */

	last_UMSoptind = UMSoptind ;
	return ((option == ' ') ? NONOPT : (int) option) ;

}
/* End of File */

