#ifndef getopt_h_DEFINED
#define getopt_h_DEFINED


/*******************************************************************************
	This INCLUDE file contains the external definitions for the GETOPT(3)
	function and its global variables.
*******************************************************************************/


extern  int UMSgetopt () ;		/* Function to get command line options       */

THREAD_DECL extern  char  UMSoptarg [];		/* Set by GETOPT for options expecting        */
				/* arguments.				      */

THREAD_DECL extern  int  UMSoptind ;		/* Set by GETOPT: index of next ARGV to be    */
				/* processed. 				      */

THREAD_DECL extern  int  UMSopterr ;		/* Disable (== 0) or enable (!=0) error       */
				/* messages written to standard error.	      */

#define  NONOPT  (-1)		/* Non-Option - returned by GETOPT when it    */
				/* encounters a non-option argument.          */

#endif getopt_h_DEFINED

/* End of File */

