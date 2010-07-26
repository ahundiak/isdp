/*
------------------------------------------------------------------------------

	Name:			ddp.c      
	Author:			R. Eade
	Creation Date:		December, 1987
	Abstract:
			The main driver for the data dictionary processor.

	Revision History:
		rme 10/16/1992	2.0.0
			First NT mods.

		rme 04/15/1992	1.2.5
			Change long float to double.

		rme 08/12/1991	1.2.4
			Modify source code to be ansi-clean.

		rme 11/09/1988	1.2.3
			Add major and minor version numbers to the
			REJECTED_INSTANCE record.
			
		rme 10/24/1988	1.2.2
			Add support for rejected instance data.
			
		rme 09/06/1988	1.2.1
			Fixed bug with zero sized structures.
			
		rme 03/23/1988	1.2.0
			Added the -r flag which will cause class information
			to be replaced even if the same version already
			exists in the dictionary directory.

		rme 03/22/1988	1.1.1
			Fixed bug in dump.c.  Needed to save all globals
			before calling lookup_class.  This routine could
			cause recursion thus stepping on all globals.

		rme 03/22/1988	1.1.0
			Removed the idea of a dummy class from the
			channel class list.  If a class name is specified,
			the class must be processed.

                ems 05/06/1993  
                        Added support for -D flags

------------------------------------------------------------------------------
*/

#include <stdio.h>
#include <malloc.h>
#include <identifier.h>
#include <class.h>

#include "ddp_error.h"
#include "ddp_defns.h"

extern unsigned int 	opp_version;
extern unsigned int 	cpp_version;
static unsigned int 	ddp_version = {0x020000};	/* 2.0.0 */

char Gp_dirname[MAX_PATH_LEN];
int  Gf_verbose;
int  Gf_replace;
char *Gp_imagename;

static void compile (fname)
char *fname;		/* path of the file to be processed */
{
   int len;
   len = strlen(fname);

   if (fname[len-1] == 'S')
   {
      /* form the base filename */

      struct opp_class_def *p_classdef;
      char *classname;

      classname = (char *) malloc(len+1);
      strcpy (classname, fname);
      classname[len-2] = 0;

      /* let opp parse the file then create the dictionary class file(s) */

      opp_get_class (classname, 0, &p_classdef);
      DDP_create_class_info (p_classdef);
      free(classname);
   }
   else
   {
      error(INFO,"File '%s' not a class specification file\n",fname);
   }

   return;
}/* compile */


main (argc, argv, env)
int argc;
char *argv[];
char *env[];
{
   int optflag, ii, version=0;
   int cpp_flag_cnt = 0;
   char *cpp_flags[MAX_INCLUDE_PATHS];
   extern int include_report;

   void init_opp();
   
   extern int getopt(), optind, opterr;
   extern char	*optarg;

   Gp_dirname[0] = '\0';
   Gp_imagename = argv[0];
   include_report = 0;
   Gf_verbose = 0;
   Gf_replace = 0;

   for (ii=0; ii < MAX_INCLUDE_PATHS; cpp_flags[ii++] = 0);
   cpp_flags[cpp_flag_cnt++] = "-D__DDP__";

   while ((optflag = getopt(argc, argv, "Hztd:D:I:Vr")) != EOF)
      switch (optflag)
      {
         case 'r':
            Gf_replace = 1;
            break;

         case 'z':
            include_report = 1;
            break;

         case 'H':
            Gf_verbose = 1;
            break;

         case 'd':
            if ('\0' != Gp_dirname[0])
               error(FATAL,"only allowed one '-d' flag\n");

            if (MAX_PATH_LEN < (strlen(optarg)+1))
               error(FATAL,"max directory name length (%d) exceeded\n",
                             MAX_PATH_LEN-1);

            strcpy(Gp_dirname,optarg);
            break;

         case 't':
            if (! Gp_dirname[0])
               DDP_list_classes(".");
            else
               DDP_list_classes(Gp_dirname);

            version = 1;
            break;

         case 'I' :
            if (cpp_flag_cnt >= MAX_INCLUDE_PATHS)
               error(FATAL,"max num (%d) of '-I' flags exceeded\n",
                            MAX_INCLUDE_PATHS);

            cpp_flags[cpp_flag_cnt] = (char *)malloc(strlen(optarg) +4);
            sprintf (cpp_flags[cpp_flag_cnt++], "-I%s", optarg);
            break;

         case 'D' :
            if (cpp_flag_cnt >= MAX_INCLUDE_PATHS)
               error(FATAL,"max num (%d) of '-I' or '-D' flags exceeded\n",
                            MAX_INCLUDE_PATHS);

            cpp_flags[cpp_flag_cnt] = (char *)malloc(strlen(optarg) +4);
            sprintf (cpp_flags[cpp_flag_cnt++], "-D%s", optarg);
            break;

         case 'V' : 
            error(INFO,"\tOPP %d.%d.%d    CPP %d.%d.%d    DDP %d.%d.%d\n",
                     opp_version>>16, (opp_version>>8)&0xFF, opp_version&0xFF,
                     cpp_version>>16, (cpp_version>>8)&0xFF, cpp_version&0xFF,
                     ddp_version>>16, (ddp_version>>8)&0xFF, ddp_version&0xFF);
            version = 1;
            break;

         case '?' :
            PRINT_USAGE();

            exit (1);
            break;

      }/* switch on options */


   /* Use current working directory as the dictionary directory if none
      specified on the command line. */

   if ('\0' == Gp_dirname[0])
   {
      Gp_dirname[0] = '.';
      Gp_dirname[1] = '\0';
   }
   /* initialize OPP */

   init_opp (cpp_flags);

   if (optind < argc)
      for (; optind < argc; optind++)
      {
         compile (argv[optind]);
      }
   else
      if (! version)
         PRINT_USAGE();
     
   exit(0);
}

long discos_get_class (cl_name, genout, p_classdef)
char *cl_name;
int genout;
struct opp_class_def **p_classdef;
{
   /* OPP needs information about this class - extract it from the dictionary.
      For the time being invoke OPP to process the file and send the 
      information back. Also, store the information returned by OPP into 
      the dictionary. */

#ifdef  DEBUG
    printf ("in discos_get_class with class '%s'\n", cl_name);
#endif

    opp_get_class (cl_name, 0, p_classdef);
    DDP_create_class_info (*p_classdef);
    genout = 0;

    return (1);
}

