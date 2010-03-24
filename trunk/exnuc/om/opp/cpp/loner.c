#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <stdlib.h>
#include "cpp.h"

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define convert_filename(F)	F
#elif defined(NT)
#define stat _stat
extern char	*convert_filename(char *);
#else
#error Unknown OS
#endif

#define PITS(a) { char *c; c = a; while (*c) putc (*(c++),cpp_outfile); }
#define OUTPUT_LINEx ((omcpp_opts['l']==0)&&\
                     (omcpp_opts['L']==0)&&\
                     (omcpp_opts['P']==0))

#define OUTPUT_LINE 0

#if defined (IRIX5) || defined (SUNOS5)
static int not_in_stdc = 0;
#endif
float ff = 0.0;
static char *last_file = 0;
static int last_line,last_pol;
char omcpp_run_name[80];
char omcpp_opts[256];
char omcpp_inname[80];
char omcpp_outname[80];
FILE *cpp_outfile;

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

void cpp_end __((void));
void cpp_print_version __((void));

/* loner.c */
void OMcpp_dump_it __((void));
void OMcpp_file __((char **argv));

#if defined(__cplusplus)
}
#endif

void OMcpp_dump_it()
 {
  float ff = 0.0;
  int i;

#if defined (IRIX5) || defined (SUNOS5)
  static int in_extern=0;
  static int open_cnt=0;
  static int ok=1;
#endif

  if (last_file != active_stream->tok.filename)
   {
    if (OUTPUT_LINE)
     {
      PITS ("\n#line ");
      fprintf (cpp_outfile,"%d",active_stream->tok.line_no);
      PITS ("  \"");
      PITS (convert_filename(active_stream->tok.filename));
      PITS ("\"\n");
     }
    last_pol = 1;
    last_line = active_stream->tok.line_no;
    last_file = active_stream->tok.filename;
   }
  if (last_line != active_stream->tok.line_no)
   {
    i = active_stream->tok.line_no - last_line;
    if (i>10)
     {
      if (OUTPUT_LINE)
       {
        PITS ("\n#line ");
        fprintf (cpp_outfile,"%d",active_stream->tok.line_no);
        PITS ("  \"");
        PITS (convert_filename(active_stream->tok.filename));
        PITS ("\"\n");
       }
     }
    else
     {
      while ((i--) > 0) putc ('\n',cpp_outfile);
     }
    last_pol = 1;
    last_line = active_stream->tok.line_no;
   }
  i = active_stream->tok.pol - last_pol - 1;
  putc (' ',cpp_outfile);
  while (i-- > 0) putc (' ',cpp_outfile);

  /*=============================================================*/
  /*  This chunk-o-code is used to filter out full prototypical  */
  /*  extern statements so as not to upset PPL - the poor baby   */
  /*  is oooh so sensitive                                       */
  /*                                                             */
  /*  note that this won't handle :  extern int (*p_func2)();    */
  /*=============================================================*/

#if defined (IRIX5) || defined (SUNOS5)
  if (not_in_stdc)
  {
    if ((active_stream->yylen == 6 ) && 
        (!strcmp(active_stream->yytext,"extern"))) 
    {
      in_extern = 1;
    }
    else if ((in_extern) && (active_stream->yytext[0] == ')'))
    {
      --open_cnt;
      if (!open_cnt)
      {
        in_extern = 0;
        ok = 1;
      }
    }
  }

  if (ok)
  {
#endif

     PITS(active_stream->yytext);

#if defined (IRIX5) || defined (SUNOS5)
  }

  if (not_in_stdc)
  {
    if (in_extern) 
    {
      if (active_stream->yytext[0] == '(')
      {
        open_cnt++;
        ok = 0;
      }
      else if (active_stream->yytext[0] == ';')
      {
        in_extern = 0;
      }
    }
  }
#endif

  last_pol = active_stream->tok.pol + active_stream->yylen;
 }


static FILE *oppout;
char oppout_name[]="harry";

void OMcpp_file (argv)
char **argv;
{

#if defined (IRIX5)

  int my_argc, i, j;
  char **my_argv;

  /*=================================================================*/
  /*  here we have to cheat and throw -D_LANGUAGE_C and -DHUGE_VAL   */
  /*  for PPL on IRIX5 systems because their includes are ANSI only  */
  /*=================================================================*/

  for (my_argc=0; argv[my_argc]; ++my_argc);

  my_argv = (char **) malloc ( sizeof(char*) * (my_argc+3) );
  my_argv[0] = argv[0];
  for (i=1; argv[i] && argv[i][0]=='-'; ++i) my_argv[i] = argv[i];
  j = i;
  for (;i<=my_argc; ++i) my_argv[i+2] = argv[i];
  my_argv[j] = (char *)calloc(1,2+strlen("_LANGUAGE_C")+1);
  strcpy ( my_argv[j++], "-D_LANGUAGE_C" );

  my_argv[j] = (char *)calloc(1,2+strlen("HUGE_VAL")+1);
  strcpy ( my_argv[j++], "-DHUGE_VAL" );

#elif defined (SUNOS5)

  int my_argc, i, j;
  char **my_argv;

  /*==================================================================*/
  /*  here we have to cheat and throw -D_NO_LONGLONG                  */
  /*  for PPL on SUNOS5 systems because their includes are ANSI only  */
  /*==================================================================*/

  for (my_argc=0; argv[my_argc]; ++my_argc);

  my_argv = (char **) malloc ( sizeof(char*) * (my_argc+2) );
  my_argv[0] = argv[0];
  for (i=1; argv[i] && argv[i][0]=='-'; ++i) my_argv[i] = argv[i];
  j = i;
  for (;i<=my_argc; ++i) my_argv[i+1] = argv[i];
  my_argv[j] = (char *)calloc(1,2+strlen("_NO_LONGLONG")+1);
  strcpy ( my_argv[j++], "-D_NO_LONGLONG" );

#endif

  oppout=stdout;
  if (omcpp_outname[0])
   {
    cpp_outfile = fopen (omcpp_outname,"w");
    if (!cpp_outfile)
     {
      extern int errno;
      fprintf (stderr, "omcpp - failed to create file \"%s\".\n", cpp_outfile);
      exit (errno);
     }
   }
  else
   cpp_outfile = stdout;

#if defined (IRIX5) || defined (SUNOS5)
  cpp_init(my_argv,(omcpp_opts['d']?CPP_DUPE_INCL_FILTER:0) |
                   (omcpp_opts['i']?CPP_INFO_ON:0) |
                   CPP_WARN_ON,0);
#else
  cpp_init(argv,(omcpp_opts['d']?CPP_DUPE_INCL_FILTER:0) |
                (omcpp_opts['i']?CPP_INFO_ON:0) |
                CPP_WARN_ON,0);
#endif

  if (omcpp_inname[0]) cpp_open(omcpp_inname);
  else cpp_open ("stdin");
  cpp_get_tok();
  while (active_stream->tok.typ != TOK_EOF)
   {
    OMcpp_dump_it();
    cpp_get_tok();
   }
  fprintf (cpp_outfile,"\n");
  cpp_end();
 }


static void analyze_args (p_argc,argv)
int *p_argc;
char *argv[];
 {
  int i, c;
  
  extern int getopt();
  extern char *optarg;
  extern int optind, opterr;
  static char *error = "omcpp: bad command line";
  
  omcpp_outname[0]=0;
  omcpp_inname[0]=0;
  for (i=0; i<256; i++) omcpp_opts[i]=0;
  strcpy (omcpp_run_name,argv[0]);



  for (i = 1; EOF != (c = getopt(*p_argc, argv, "idlVD:U:I:")); ++i)
  {
     omcpp_opts[c] = 1;

     switch (c)
     {
	case 'i':
	   /* options |= CPP_INFO_ON; */
	   break;

	case 'd':
	   /* options |= CPP_DUPE_INCL_FILTER; */
	   break;

        case 'I':
        case 'D':
        case 'U':
           if ('I' != c && '-' == optarg[0])
           {
              fprintf(stderr, "%s: illegal define name %s\n", error, optarg);
              exit(1);
           }
           if (NULL == (argv[i] = (char *)calloc(1,2+strlen(optarg)+1)))
           {
              fprintf(stderr, "%s: could not calloc for argument %d\n", error, optind);
              exit(1);
           }
           argv[i][0] = '-';
           argv[i][1] = c;

#if defined (IRIX5) || defined (SUNOS5)
           if ((c=='U') && (!strcmp("__STDC__",optarg))) not_in_stdc = 1;
#endif

           strcat(argv[i], optarg);
           break;

        case 'l':
        case 'V':
           argv[i] = argv[optind-1];
           break;

        default:
           fprintf(stderr, "usage: omcpp [-i] [-d] [-V] [-l] [-Idir] [-Dmacro] [-Umacro] [infile [outfile]]\n\
\t-i\t\tPrint file names as they are opened.\n\
\t-d\t\tFilter duplicate include files.\n\
\t-V\t\tPrint omcpp version.\n\
\t-l\t\tDo not insert #line directives in the output.\n\
\t-Idir\tSearch for include files in dir.\n\
\t-Dmacro\tDefine macro.\n\
\t-Umacro\tUndefine macro.\n\
\tinfile\tInput file name [stdin].\n\
\toutfile\tOutput file name [stdout].\n");
           exit(1);
           break;
     }

  }/* for all command line args */

  if (optind < *p_argc)
  {
     /* input file name */

     struct stat buf;

     if (stat(argv[optind], &buf))
     {
        fprintf(stderr, "%s: %s: ", error, argv[optind]);
        perror(0);
        exit(1);
     }
     strcpy (omcpp_inname,argv[optind]);
     argv[i++] = argv[optind++];
  }  

  if (optind < *p_argc)
  {
     /* output file name */

    strcpy (omcpp_outname,argv[optind]);
    argv[i++] = argv[optind++];
  }

  argv[i] = 0;
  *p_argc = i;


}/* analyze args */

/* ARGSUSED */
static void cleanup(int notused)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
   if (omcpp_outname[0])
   if (!fork())
      execl("/bin/rm", "rm", omcpp_outname, 0);
#elif defined(NT)
	if (omcpp_outname[0])
	{
		char	cmd[4096];

		strcpy(cmd, "del/q ");
		strcat(cmd, omcpp_outname);
		system(cmd);
	}
#else
#error Unknown OS
#endif
   exit(1);
}

main (argc,argv,envr)
int argc;
char **argv,**envr;
 {

  signal(SIGINT, cleanup);	/* control-C */
  signal(SIGTERM, cleanup);	/* kill -15 */

  analyze_args (&argc,argv);
  if (omcpp_opts['V']) cpp_print_version();
  OMcpp_file(argv);
  if (cpp_error_count)
     cleanup(0);
  return (0);
 }
