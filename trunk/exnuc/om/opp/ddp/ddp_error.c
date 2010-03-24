/*
------------------------------------------------------------------------------

	Name:			ddp_error.c
	Author:			Richard Eade
	Creation Date:		October 1987
	Abstract:
			Generic error reporting function

	Revision History:

------------------------------------------------------------------------------
*/
#include <stdio.h>
#ifndef __STDC__
#include <varargs.h>
#else
#include <stdarg.h>
#endif

#include "ddp_error.h"

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define SEPARATOR_C	'/'
#elif defined(NT)
#define SEPARATOR_C	'\\'
#else
#error Unknown OS
#endif

extern FILE *Gp_outfile;
extern char *Gp_outfilename;
extern char *Gp_imagename;

/*--------------------------------------------------------------------------
**   Error handling routine
*/
#ifndef __STDC__
void error(va_alist)
va_dcl
#else
void error(int type, char *format, ...)
#endif
{
   va_list args;    /* Variable argument list. */
#ifndef __STDC__
   int     type;    /* Type of error. */
   char    *format; /* Printing format. */
#endif
   char    *p_slash;/* Basename of the running image. */

#ifndef __STDC__
   va_start(args);  

   type = va_arg(args, int);  
   format = va_arg(args, char*);
#else
   va_start(args, format);  
#endif

   switch (type)
   {
      case INFO:
         vfprintf(stdout, format, args);
         break;
      case WARNING:
      case FATAL:
         if (p_slash = (char *) strrchr(Gp_imagename,SEPARATOR_C))
            fprintf(stderr,"%s: ",p_slash+1);
         else
            fprintf(stderr,"%s: ",Gp_imagename);

         vfprintf(stderr, format, args);

         if (FATAL == type)
         {
            if (Gp_outfile)
            {
               fclose(Gp_outfile);
               Gp_outfile = NULL;
               unlink(Gp_outfilename);
            }
            exit(-1);
         }

         break;
   }

}

