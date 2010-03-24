/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* opp.c - main function for opp					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* October 1985								*/
/*									*/
/* Global Functions :							*/
/*	main     - called when program execution begins			*/
/*	exit_opp - terminates opp and discards output if errors		*/
/*									*/
/* Command Line Flags :							*/
/*	-p	output goes to standard output				*/
/*	-i	all "import" operations are logged on stderr		*/
/*	-v	verbose, same as -i					*/
/*	-d	yacc debug log mode (stdout)				*/
/*	-l	"#line" directives are omitted from output		*/
/*	-k	keep output file even if errors				*/
/*	-V	report version number					*/
/*	-I	specifies include, import and inherit paths		*/
/*	-D	predefine a macro					*/
/*	-U	undefine a predefined macro				*/
/*									*/
/* All other flags are passed to cpp.					*/
/* Any filename found on command line is used as input.			*/
/* Output defaults to input file with extension changed to ".c".	*/
/* If no filename found in command line, input is from stdin and	*/
/* output goes to stdout.						*/
/*									*/
/* Modifications :							*/
/*  March 14, 1986 - changed to use getopt				*/
/*		     This fixed source deletion problem (3.0.4)		*/
/*									*/
/*  Sept. 19, 1986 - added -D and -U switches				*/
/*									*/
/*  November 10, 1986 - modified for multiple input files		*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/

/*------------------------------------------------------------------------
 * HF: 09/07/2001 - KLUDGE for the Solaris5.8 __FILE problem:
 *
 * compile fails if line: "typedef struct __FILE __FILE;" is missing
 *
 * added function:
 * void post_proc_opp(char * file_name);
 *
 *----------------------------------------------------------------------*/

#ifdef INTEL
#include <sys/stat.h>
#endif
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include "opp.h"
#include "identifier.h"
#include "lex3.h"
#include "lexinput.h"
#include "cpp.h"
#include "class.h"
#include "oppface.h"
#include "dumpmessage.h"

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define SEPARATOR_C	'/'
#define SEPARATOR_S	"/"
#elif defined(NT)
#include <direct.h>
#define SEPARATOR_C	'\\'
#define SEPARATOR_S	"\\"
#define fileno _fileno
#define getcwd _getcwd
#else
#error Unknown OS
#endif

extern void cpp_print_version(void);
extern char *getenv();
/* Externs for getopt */
extern int getopt();
extern char *optarg;
extern int optind, opterr;
extern int yydebug;

int different_files(f1, f2)
 FILE *f1, *f2;
 /* returns true if f1 and f2 refer to different files */
{
#include <stdio.h>
#include <sys/types.h>
#ifndef  INTEL
#include <sys/stat.h>
#endif
  int i;

#if defined(CLIX)
  struct statl st1, st2;
#elif defined(SUNOS) || defined(IRIX)
  struct stat st1, st2;
#elif defined(NT)
  struct _stat st1, st2;
#else
#error Unknown OS
#endif

#ifdef CLIX
  i = fstatl (fileno(f1), &st1);
#elif defined(SUNOS) || defined(IRIX)
  i = fstat (fileno(f1), &st1);
#elif defined(NT)
  i = _fstat (fileno(f1), &st1);
#else
#error Unknown OS
#endif
  if (i) return 1;

#ifdef CLIX
  i = fstatl (fileno(f2), &st2);
#elif defined(SUNOS) || defined(IRIX)
  i = fstat (fileno(f2), &st2);
#elif defined(NT)
  i = _fstat (fileno(f2), &st2);
#else
#error Unknown OS
#endif
  if (i) return 1;

  return st1.st_ino != st2.st_ino;
} /* different_files */

static void DUI (opt, count, flags)
 int opt;       /* 'D' 'U' or 'I' */
 int *count;    /* number of slots used in flags */
 char *flags[]; /* array of options for cpp */
{
  if (*count >= MAX_INCLUDE_PATHS)
  {
    fprintf (stderr,"opp command line error - too many -D, -U and -I flags\n");
    exit (1);
  }
  flags[*count] = malloc (strlen(optarg) + 4);
  sprintf (flags[(*count)++],"-%c%s", opt, optarg);
#ifdef DEBUG
  printf ("DUI - %d, %c, %s : %s\n",*count, opt, optarg, flags[*count -1]);
#endif
} /* DUI */

/* ARGSUSED */
static void doExit(int notused)
/*
**	cntrl-C and SIGTERM signal handler.
*/
{
  signal(SIGINT, SIG_IGN);	/* disable interrupt */
  signal(SIGTERM, SIG_IGN);	/* disable interrupt */
  ++opp_error_count;		/* ensure error condition */
  exit_opp();			/* exit with error(s) */
}

void post_proc_opp(char * file_name);

main ( argc, argv )
 int   argc;
 char *argv[];
{
  float ff = 0.0;
  int   cpp_flag_cnt = 0;
  char *cpp_flags[MAX_INCLUDE_PATHS];
  char  opppwd [256];
  char  file_name[SYMBOL_LENGTH];
  int   c; /* Current Option flag */
  int   i;
  int   multi_opp; /* true if more than one input file */
  int   not_same;  /* true if stderr and stdout are different files */

#ifdef ALLOC_PROFILE
  setSample(30);	/* sample every n secs. */
#endif

  for (i = 0; i < MAX_INCLUDE_PATHS; cpp_flags[i++] = 0); /* clear */

  opping_for_discos = 0;

  if (!getcwd (opppwd, 80))
  {
    fprintf (stderr, "opp Failed to read current working directory string.\n");
    exit (1);
  }
  strcat (opppwd, SEPARATOR_S);

  while ((c = getopt(argc, argv, "mVdvD:U:ilpkI:f:")) != EOF)
   switch (c)
   {
     case 'f' :
     {
       char buf[100];
       FILE *fptr;

       if (NULL == (fptr = (FILE *) fopen(optarg, "r")))
       {
         fprintf(stderr, "opp command line error - could not open '%s' for input.\n",optarg);
         exit(1);
       }

       while (EOF != fscanf(fptr, "%s", buf))
       {
         if (cpp_flag_cnt >= MAX_INCLUDE_PATHS)
         {
           fprintf (stderr,"opp command line error - too many -D, -U and -I flags\n");
           exit (1);
         }
         cpp_flags[cpp_flag_cnt] = malloc(strlen(buf) + 1);
         strcpy(cpp_flags[cpp_flag_cnt++], buf);

       }/* while more flags in the file */
     }/* end of case */
     break;

     case 'I' :
     case 'U' :
     case 'D' :
       DUI (c, &cpp_flag_cnt, cpp_flags);
       break;
     case 'V' : /* report version number */
       fprintf (stderr, "opp Version %d.%d.%d using ",
                opp_version >>16, (opp_version>>8) & 0xff, opp_version & 0xff);
       cpp_print_version();
       break;
     case 'd' :
       yydebug = 1;
       break;
     case 'i' :
       filter_duplicate_includes = 1;
       break;
     case 'v' :
       include_report = 1;
       break;
     case 'l' :
       emit_lines = 0;
       break;
     case 'k' :
       keep_mode = 1;
       break;
    case '?' :
      fprintf (stderr, " usage : opp [-VvdlkiIDU] infile\n");
      fprintf (stderr, "         -v	   verbose\n");
      fprintf (stderr, "         -V         report opp version\n");
      fprintf (stderr, "         -l         suppress #line directives\n");
      fprintf (stderr, "         -i         omit duplicate include files\n");
      fprintf (stderr, "         -k         keep output on error\n");
      fprintf (stderr, "         -d         debug mode, not recommended\n");
      fprintf (stderr, "         -I path    path for include and spec files\n");
      fprintf (stderr, "         -D sym     macro definition \n");
      fprintf (stderr, "         -U sym     macro undefinition \n");
      exit (1);
   } /* while switch */

  init_opp (cpp_flags);

  if (optind >= argc) /* more arguments ? */
  {
    fprintf (stderr, " input file must be specified\n");
    exit (1);
  }

  signal(SIGINT, doExit);	/* trap cntrl-C */
  signal(SIGTERM, doExit);	/* trap kill -15 */

  not_same = different_files (stderr, stdout);
  multi_opp = (argc - optind) > 1;
  while (optind < argc)
  {
    struct opp_class_def *pclass;
    char *ext, *short_file_name;

    strcpy (file_name, argv[optind++]);
    if (multi_opp)
    {
      fprintf (stderr, "%s:\n", file_name);
      if (not_same) printf ("%s:\n", file_name);
    }

    if (!(short_file_name = strrchr (file_name, SEPARATOR_C)))
      short_file_name = file_name;

    if ((ext = strrchr (short_file_name, '.')) && *++ext == 'S')
    {
      *--ext = 0;
      unmark_all_written_symbols();
      if (opp_get_class (file_name, 1, &pclass))
      {
        break;
      }
      else
      {
#if defined(SUNOS) || defined(__i386__)
        *ext = '.';
        post_proc_opp(file_name);
#endif
      }
    }
    else
    {
      unmark_all_written_symbols();
      if (opp_process_impl_file (file_name, &pclass))
      {
        break;
      }
      else
      {
#if defined(SUNOS) || defined(__i386__)
        post_proc_opp(file_name);
#endif
      }
    }
  }

  exit_opp();
  return 0;
} /* main */

/* This interface is provided for opp w/o discos */

int discos_get_class (class, outgen, p_class)
 char *class;
 int outgen;
struct opp_class_def **p_class;
{
  return opp_get_class (class, outgen, p_class);
} /* discos_get_class */

/*-----------------------------------------------------------------------------
 * HF: 09/07/2001 - KLUDGE for the Solaris5.8 __FILE problem:
 *
 * compile fails if line: "typedef struct __FILE __FILE;" is missing
 *
 *-----------------------------------------------------------------------------*/

void post_proc_opp(char * file_name)
{
  FILE *fp0;
  char  filnm1[SYMBOL_LENGTH], filnm2[SYMBOL_LENGTH];
  char *ext = NULL, strng[256];
  int   sts0 = 0, sts1 = 0, dbg = 0, i0 = 0, nmr[2] = {0};

  memset(filnm1, 0 ,SYMBOL_LENGTH);
  strcpy(filnm1, file_name);

  dbg = 0;

  if ( ext = strrchr (filnm1, '.') )
  {
    *++ext = 'c';
    strcpy(filnm2, filnm1);
    strcat(filnm2, "_");

    if ( fp0 = fopen(filnm1, "r") )
    {
      sprintf(strng, "grep -n \"^ struct __FILE\" %s > /dev/null", filnm1);

      /*
       * Look for string: "struct __FILE"
       */
      sts0 = system(strng);
      if (dbg) printf("sts0 = %3d == <%s>\n", sts0, strng);
      /*
       * If      (sts0 ==   0) string: "struct __FILE" is present -->> proceed
       * Else if (sts0 == 256) string: "struct __FILE" is absent  -->> goto wrapup
       */
      if (sts0) goto wrapup;

      sprintf(strng, "grep -n \"^ struct __FILE\" %s | awk -F\\: '{print $1}' > /tmp/HFHFHF", filnm1);

      /*
       * Look for string: "^ struct __FILE", and, if found, write line# to file /tmp/HFHFHF
       *
       * Regardless of string "^ struct __FILE" being found or not -->> ALWAYS (sts1 == 0)
       */
      sts1 = system(strng);
      if (dbg) printf("sts1 = %3d == <%s>\n", sts1, strng);

      fclose(fp0);

      if (sts0 == 0)
      {
        sprintf(strng, "grep -n \"typedef struct __FILE __FILE\" %s > /dev/null", filnm1);

        /*
         * Look for string: "typedef struct __FILE __FILE"
         */
        sts0 = system(strng);
        if (dbg) printf("sts0 = %3d == <%s>\n", sts0, strng);
        /*
         * If      (sts0 ==   0) string: "typedef struct __FILE __FILE" is present,
         *                                check its line# (should be BEFORE line "^ struct __FILE")
         * Else if (sts0 == 256) string: "typedef struct __FILE __FILE" is absent, so needs to be inserted
         */

        sprintf(strng, "grep -n \"typedef struct __FILE __FILE\" %s | awk -F\\: '{print $1}' >> /tmp/HFHFHF", filnm1);

        /*
         * Look for string: "typedef struct __FILE __FILE", and, if found, append line# to file /tmp/HFHFHF
         */
        sts1 = system(strng);
        if (dbg) printf("sts1 = %3d == <%s>\n", sts1, strng);

        if (sts0 == 0)
        {
          /*
           * "typedef struct __FILE __FILE" line is NOT missing, but possibly AFTER "^ struct __FILE"
           */
          if ( fp0 = fopen("/tmp/HFHFHF", "r") )
          {
            i0 = 0;
            while (fscanf(fp0, "%d", &nmr[i0]) != EOF)
            {
              if (dbg) printf("nmr[%d] = %d\n", i0, nmr[i0]);
              i0++;
            }
          }

          fclose(fp0);
          if(! dbg) unlink("/tmp/HFHFHF");

          if ( i0 > 1 && nmr[0] < nmr[1] )
          {
            /*
             * Incorrect order (line is AFTER); delete "typedef struct __FILE __FILE" line
             */
            sprintf(strng, "cp %s %s", filnm1, filnm2);

            /* Copy file: filnm1 to temporary file: filnm2 */
            sts0 = system(strng);
            if (dbg) printf("sts0 = %3d == <%s>\n", sts0, strng);

            if (sts0 == 0)
            {
              sprintf(strng,
                      "sed -e %dd -e \"s/struct __FILE/typedef struct __FILE __FILE; struct __FILE/\" %s > %s",
                      nmr[1], filnm2, filnm1);
              /*
               * First delete and then insert the missing line: "typedef struct __FILE __FILE;" into the file
               */
              sts0 = system(strng);
              if (dbg) printf("sts0 = %3d == <%s>\n", sts0, strng);

              unlink(filnm2);
            }
          }
        }
        else
        {
          /*
           * "typedef struct __FILE __FILE" line is missing, so insert it
           */
          sprintf(strng, "cp %s %s", filnm1, filnm2);

          /* Copy file: filnm1 to temporary file: filnm2 */
          sts0 = system(strng);
          if (dbg) printf("sts0 = %3d == <%s>\n", sts0, strng);

          if (sts0 == 0)
          {
            sprintf(strng,
                    "sed -e \"s/struct __FILE/typedef struct __FILE __FILE; struct __FILE/\" %s > %s",
                    filnm2, filnm1);

            /*
             * Insert the missing line: "typedef struct __FILE __FILE;" into the file
             */
            sts0 = system(strng);
            if (dbg) printf("sts0 = %3d == <%s>\n", sts0, strng);

            sprintf(strng, "rm %s", filnm2);
            sts0 = system(strng);
          }
        }
      }
    }
  }
wrapup:
  return;
}
