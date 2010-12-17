#include "machine.h"
/************************************************************************/
/* FUNCTION:      getopt(argc, argv, opts)                              */
/* -----                                                                */
/* PROJECT:       Microsoft C - Standard Library                        */
/* -----                                                                */
/* PURPOSE:       Gets option letter from argument vector.              */
/* -----                                                                */
/* ARGUMENTS:                                                           */
/* -----          argc  - The number of arguments in the vector.        */
/* -----          argv  - The argument vector pointers.                 */
/* -----          opts  - A string of recognized options letters.       */
/* -----                                                                */
/* RETURNS:       The next option letter in argv. ('?' for errors)      */
/* -----                                                                */
/* COMMENTS:      This is the Standard UNIX getopt(S) function.         */
/* -----          (See System V documentation for additional details.)  */
/************************************************************************/
static char SCCSID[]   = "@(#)getopt  -K. Maser- MS-DOS ver 1.1 09/06/87";

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "CLIstruct.h"
#include "proto.h"
#include <memcheck.h>

/* Define the external variables */
char     *optarg;                      /* Points to start of option     */
short    opterr      = 1;              /* Flag to control errmsgs       */
short    optind      = 1;              /* The argv index of next arg    */
short    optopt;                       /* The argv index of option      */


char getopt(argc, argv, opts)
 short   argc;
 char    **argv;
 char    *opts;

  {
   register char  c;                   /* Temp character variable       */
   register char  *cp;                 /* Index into opts string        */
   static short   sp = 1;              /* Index into argv[optind]       */


   /* Initialize on first call */   
   if ( sp == 1 )
      /* Check for any errors */
      if (optind >= argc || argv[optind][0] != '-' || argv[optind][1] == '\0')
         return(EOF);

       /* Check for auxillary end of arguments indicator */
       else if ( strcmp(argv[optind], "--") == 0 ) {
         optind++;
         return(EOF);
         }

   /* Get first character of current argument */
   optopt = c = argv[optind][sp];

   /* Check for Illegal options */
   if ( c == ':' || (cp = strchr(opts, c)) == NULL ) {
      if ( opterr )
         fprintf(stderr, "%s: illegal option -- %c\n", argv[0], c);

      if ( argv[optind][++sp] == '\0' ) {
         optind++;
        sp = 1;
         }

      return('?');
      }

   /* Check if option requires an argument */
   if ( (*++cp == ':') ) {
      if ( argv[optind][sp+1] != '\0' )
         optarg = &argv[optind++][sp+1];        /* Get option, or ...   */
       /*   ... attempt to move to next argument */
       else if ( ++optind >= argc ) {
         if ( opterr )
            fprintf(stderr, "%s: requires an argument -- %c\n", argv[0], c);
      
        sp = 1;
         return('?');
         }
       else
         optarg = argv[optind++];               /* Get next option      */

      sp = 1;
      }
    /* A normal option */
    else {
      if ( argv[optind][++sp] == '\0' ) {
         sp = 1;
         optind++;
         }

      optarg = NULL;                         /* No option arg here..    */
      }

   return(c);                                /* Return option letter    */
  }  /* getopt() */

