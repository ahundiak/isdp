/*
**	NAME:						cppmain.c
**	AUTHORS:					David Michal
**	CREATION DATE:					6/22/88
**	ABSTRACT:
**		The main function of the CPP preprocessor.
**	
**	REVISION HISTORY:
**
**	Modified to have new options like -acc, -gh etc..
**	and to have the ability to specify a list of include 
**	directory paths with -I option.
**											Prasad Chella 8/91	
**
**	Added a feature to get the appropriate 'ris.a' depending
**	on the target microprocessor. Also added an argument to
**	include '$RISDEVDIR/include' into the  search path.
**											Prasad 11/21/91	
**
**	Added support of exec'ing compiler for NT
**											Hitesh 04/19/93
**
**	Added support of language for NT
**											Hitesh 05/17/93
**
**	Added support of resource reading for NT (version info)
**											Hitesh 07/09/93
**
**	Added support for version 5.0
**                                          Sanju 02/02/94
**	Added support for i18n.  
**											Paula 01/95
**
**	Fixed problem with not mallocing enough space for the
**	wchar_t ** arrays.  
**											Paula 04/07/95
**
**	Removed linking with -lUMS, now that we have UMS
**	function calls archived into RIS archive ris.a.
**											Surjit 06/95
**
**	Also, added $RISDEVDIR/risutl/include to -I<search_path>
**	to specify path for rislduld.h file.
**											Surjit 06/95
**      Fix problem where -ext extension was passed through to the acc/cc compiler      Adell  07/29/95
**											Surjit 06/95
**      Put quotes around the include and lib paths for the default values WIN32 only,
**      if RISDP is loaded in a path that contains blanks. Added a static global
**      variable RISDP_has_blanks which should stay FALSE for all platforms except WIN32. Melania 03/06/96
*/
 
#define CPP_GLOBAL_DEFINE

/*
**	INCLUDES
*/
#include <stdio.h>
#include <string.h>
#include "riscom.h"
#include "risdebug.h"
#include "ris_err.h"
#include "ris_inf.h"
#include "rismem.h"
#include "risver.h"
#include "risprods.h"
#include "risums.h"
#include "commacro.h"
#include "cpp.h"
#if defined(__clipper__)
#include <sys/sysclip.h>
#endif
#if defined (WIN32)
#include <windows.h>
#include <process.h>
#include <locale.h>
#endif

/*
**	DEFINES
*/
#if defined(sun)
# define CPU_NAME	"sun"
#elif defined(__Sol2__)
# define CPU_NAME	"Sol2"
#elif defined(Soli)
# define CPU_NAME	"Soli"
#elif defined(__hpux__)
# define CPU_NAME	"hpux"
#elif defined(sco)
# define CPU_NAME	"sco"
#endif

#if defined(sco)
# define vfork	fork
#endif /* sco */

/*
**	VARIABLES
*/
include_dir_list_node *current_i_list=NULL, *temp_i_list;

/*  
**	It is easier to define these varibles rather than linking arcglobs.o and 
**	netglobs.o
*/
int ARC_debug = 0;
int NET_debug = 0;

/*
**	It is easier to extern them here rather than including risapp.h
*/
extern char RIS_app_version[12]; /* XX.XX.XX.XX\0 */
extern int  RIS_app_version_maj;
extern int  RIS_app_version_min;
extern int  RIS_app_version_rel;

static	char idirstr[RIS_MAX_PATH_SIZE];
static	int arg_count = 0;
static	char ** args;
static	int * eris_files;
static	int eris_file_count = 0;
static	int preprocess_only = 0;
static	int command_file_index = -1;
static	int command_file_argc = 0;
static	char **command_file_argv = NULL;
static	int	final_argc;
static	char **final_argv = NULL;
static	int gflag = 0;
static	int  extension_flag = 0;
static	char extension_str[4];
static	char filename[RIS_MAX_PATH_SIZE];
static	int len = 0;

#if defined(__clipper__)
static	int accflag = 0;
static	int ghflag = 0;
#endif
#if defined (sun)
static  int sunaccflag = 0;
static  int sungccflag = 0;
static  int sunccflag = 0;
#endif
#if defined (WIN32)
static	int cl386flag = 0;
static	int mclflag = 0;
static  BOOL    RISDP_has_blanks = FALSE ;  
#endif

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define cppmain_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtdir.prt"
#include "comuni.prt"
#if defined(WIN32)
#include "comstcmi.prt"
#include "comgtver.prt"
#endif
#include "comjmp.prt"
#include "comlang.prt"	
#include "commem.prt"
#include "comumsg.prt"
#include "cpperror.prt"
#include "cppmain.prt"
#if defined(WIN32) || defined(DOS)
#include "cppmisc.prt"
#endif
#include "cppproc.prt"
#include "comwrap.prt"
#include "sys.prt"

/******************************************************************************/

static void Usage()
{
	fprintf(STDERR,
#if defined(__clipper__)
		"Usage: riscpp [-r] [-g] [-l] [-I directory] [-ext extension]\n"
		"[-Atarg=c100|c200|c300|c400|c400r0|c400r1|c400safe|c400r4|native]\n"
		"[-gh|acc] [-V] filename.rc\n"
#elif defined(unix)
		"Usage: riscpp [-r] [-g] [-l] [-I directory] [-ext extension] "
#if defined(sun)
		"[-acc|gcc|cc] " /* three different compiler for sun */
#endif
		"[-V] filename.rc\n"
#endif
#if defined (WIN32)
		"riscpp:usage  riscpp [-r] [-l] [-I directory] [-ext extension] "
		"[@commandfile] [-V] filename.rc\n"
#elif defined (DOS)
		"riscpp:usage  riscpp [-r] [-l] [-I directory] "
		"[@commandfile] [-V] filename.rc\n"
#endif
	);
}

/******************************************************************************/

static void Version()
{
	/*
	** fprintf(stdout, RIScom_umsg(RIS_I_COPYRIGHT));
	** 1996.03.12:Alan Barksdale:TR439600483
	*/
	fprintf(stdout, RIScom_umsg(RIS_I_BEGIN_COPYRIGHT));
	fprintf(stdout, " ");
	fprintf(stdout, COPYRIGHTYEAR);
	fprintf(stdout, ", ");
	fprintf(stdout, RIScom_umsg(RIS_I_END_COPYRIGHT));
	fprintf(stdout, "\n");
	fprintf(stdout, RIScom_umsg(RIS_I_PREPROC_RELEASE), RIS_app_version);
	fprintf(stdout, "\n");
#if defined(WIN32) || defined(DOS)
	if( !RIS_development )
	{
		fprintf(stdout, RIScom_umsg(RIS_I_LICENSE_MSG));
		fprintf(stdout, "\n");
		fprintf(stdout, RIScom_umsg(RIS_I_LICENSE_USER), RIScpp_get_user());
		fprintf(stdout, "\n");
		fprintf(stdout, RIScom_umsg(RIS_I_LICENSE_COMPANY), RIScpp_get_company());
		fprintf(stdout, "\n");
	}
#endif
	exit(0);
}

/******************************************************************************/

static void preprocess_argv(
	int local_argc,
	char ** local_argv)
{
	int		i=0, j=0, p=0, q=0, c=0;
	char	*tokptr;
	char 	*strptr;
	int		name_chr=0;
	FILE	*fp;
	char	*name;
#ifdef WIN32
        char    TmpStr[RIS_MAX_PATH_SIZE+1] ;
#endif

#ifdef WIN32
      /*
      ** INTERNATIONALIZATION CHANGE. Need to convert to wide chars
      **  in order to evaluate command line args.
      */
       wchar_t **tmp_argv = NULL;
       int tmp_size;
       int mb_ext = 0;
		
       tmp_argv = (wchar_t **) SYS_MALLOC ( local_argc * sizeof( wchar_t **));
       for (i = 1; i < local_argc; i++)
       {
	   	  tmp_size = 0;
                  RIScom_multiwide(&tmp_argv[i],
                           &local_argv[i],
                           &tmp_size,
                           MULTITOWIDE,
                           0);
		CPP_DBG(("process_cpp_argv: tmp_argv[%d] = <%S>\n", i, tmp_argv[i]));
       }
#else
      char **tmp_argv = local_argv;
#endif

	/*
	**	Scan the command line arguments
	*/
	for (i = 1;i < local_argc;i++)
	{
		if ( tmp_argv[i][0] == WIDECHAR('-') )
		{
			if ( tmp_argv[i][1] == WIDECHAR('V') )
			{
				Version();
			}
			else if ( tmp_argv[i][1] == WIDECHAR('r') )
			{
				/*
				** preprocess only, donot compile or link
				*/
				preprocess_only = 1;
			}

#if defined(__clipper__)
			else if (tmp_argv[i][1] == 'g' && tmp_argv[i][2] == 'h')
			{
				ghflag = 1;
			}
			else if (tmp_argv[i][1]=='a' && tmp_argv[i][2] == 'p' && tmp_argv[i][3] == 'g')
			{
				accflag = 1;
			}
#endif /* clipper */

#if defined (sun)
            else if (tmp_argv[i][1]=='g' && tmp_argv[i][2] == 'c' && tmp_argv[i][3] == 'c')
            {
                sungccflag = 1;
            }
            else if (tmp_argv[i][1]=='a' && tmp_argv[i][2] == 'c' && tmp_argv[i][3] == 'c')
            {
                sunaccflag = 1;
            }
            else if (tmp_argv[i][1]=='c' && tmp_argv[i][2] == 'c')
            {
                sunccflag = 1;
            }
#endif /* sun */

#if defined (WIN32)
            else if (tmp_argv[i][1]== WIDECHAR('i') && tmp_argv[i][2] == WIDECHAR('3') && tmp_argv[i][3] == WIDECHAR('8')
					&& tmp_argv[i][4] == WIDECHAR('6') )
            {
                cl386flag = 1;
            }
            else if (tmp_argv[i][1]==WIDECHAR('m') && tmp_argv[i][2] == WIDECHAR('i') && tmp_argv[i][3] == WIDECHAR('p')
					&& tmp_argv[i][4] == WIDECHAR('s') )
            {
                mclflag = 1;
            }
#endif

			else if (tmp_argv[i][1] == WIDECHAR('g') )
			{
				gflag = 1;
				RIScpp_pound_lines = 0;
			}
			else if (tmp_argv[i][1] == WIDECHAR('l') && tmp_argv[i][2] == WIDECHAR('\0') )
			{
				/*
				** Donot output line directives
				*/
				RIScpp_pound_lines = 0;
			}
			else if (tmp_argv[i][1] == WIDECHAR('I') )
			{
				/*
				** Include files
				*/
				if(tmp_argv[i][2] == WIDECHAR('\0') )
				{   
					/* -I dir  */
					i++;

					/*
					** leave this one in mb form
					*/
					strcpy(idirstr,local_argv[i]);
				}
				else
				{
					 /* -Idir  */
					 p = strlen(local_argv[i]);
					 q = 0;
					 for(j = 2;j <= p; j++)
					 {
						idirstr[q] = local_argv[i][j];
						q++;
					 }
					idirstr[q] = '\0';
				}
                                temp_i_list = ALLOCTP(include_dir_list_node); 
				CPP_DBG(("CPPMAIN: idirstr=<%s>\n", idirstr));
#if defined (WIN32)
				if (DoesDirHasBlanks(idirstr)) {
				    free (local_argv[i]) ;
				    local_argv[i] = malloc (strlen (idirstr) + 3) ;
				    sprintf (local_argv[i], "-I\"%s\"", idirstr) ;
				    CPP_DBG (("CPPMAIN: local_argv[i] is <%s>\n", local_argv[i])) ;
				}
#endif
                                strcpy(temp_i_list->include_dir, idirstr);
				if (RIScpp_start_i_list)
				{
					current_i_list->next = temp_i_list;
				}
				else
				{
					RIScpp_start_i_list = temp_i_list;
				}
				current_i_list = temp_i_list;
			}
			else if(tmp_argv[i][1] == WIDECHAR('e') && tmp_argv[i][2] == WIDECHAR('x') && tmp_argv[i][3] == WIDECHAR('t') )
			{
				if (tmp_argv[i][4] == WIDECHAR('\0') )
				{
					/* -ext XXX  */
                    i++;
					/* Only 3 chars will be readed */
                	q = 0;
                	for(j = 0;j <= 2; j++)
                	{
                    	extension_str[q] = local_argv[i][j];
                    	q++;
                    	if (local_argv[i][j] == '\0') break;
                	}
				}
				else
				{
					/* -extXXX */
					/* Only 3 chars will be readed */
                	q = 0;
                	for(j = 4;j <= 6; j++)
                	{
                    	extension_str[q] = local_argv[i][j];
                    	q++;
                    	if (local_argv[i][j] == '\0') break;
                	}
				}
                        extension_str[q] = '\0';
				extension_flag = 1;
			}
		}
		else if ( tmp_argv[i][0] == WIDECHAR('@') )
		{
			command_file_index = i;
			/*
			** Additional @filename option
			** Leave this in multi-byte format.
			*/
			for(j = 1; local_argv[i][j] != '\0'; j++)
			{
				filename[name_chr++] = local_argv[i][j];	
			}
			filename[name_chr] = '\0';
			CPP_DBG(("CPPMAIN: @filename=<%s>\n", filename));
           	        if(filename[0])
			{
				if( (fp = RIScom_fopen(filename, "rt")) == NULL )
				{
					RIScpp_err_return(RIS_E_OPEN_INPUT_FILE_ERROR,0,0,
					 filename,0);
					exit(1);
				}
				j = 0;
				while((c = getc(fp)) != EOF)
				{
					len++;
				}
				name = (char *) ALLOCNP(char, len);
				fseek(fp, 0L, SEEK_SET);
				RIScom_fread(name, sizeof(char), len, fp);
				CPP_DBG(("CPPMAIN: name=<%s> len=%d\n", name, len));
				strptr = name;
				command_file_argc = 0;
				while ( (tokptr = strtok (strptr, " \n")) != NULL) /*itbokic 3/30 */
				{
					command_file_argv[command_file_argc++] = tokptr;
					strptr = NULL;
				}
			}
       		}
       		else
       		{
       		    CPP_DBG (("argument <%s> has no known switch\n", local_argv[i])) ;
#if defined (WIN32)
       		    if (DoesDirHasBlanks (local_argv[i])) {
       		        strcpy (TmpStr, local_argv[i]) ;
       		        free (local_argv[i]) ;
       		        local_argv[i] = malloc (strlen (TmpStr) + 3) ;
       		        sprintf (local_argv[i], "\"%s\"", TmpStr) ;
       		        CPP_DBG (("with quotes is <%s>\n", local_argv[i])) ;
       		    }
#endif
       		}
	}
}

/******************************************************************************/

static void process_argv(
	int argc,
	char ** argv)
{
	int i;
#ifdef WIN32
	/*
	** INTERNATIONALIZATION CHANGE. Need to convert to wide chars
	**  in order to evaluate command line args.
	*/
	wchar_t **tmp_argv = NULL;
	wchar_t *dot_ptr;
	int tmp_size;
#else
	char **tmp_argv;
	char *dot_ptr;
#endif
	int ext_bypass_flag = -1;	/* arw - bypass -ext command line arg */

	/* pre-process command line arguments */

	preprocess_argv(argc, argv);

	if (command_file_index != -1)
	{
		/* pre-process command file arguments */
		preprocess_argv(command_file_argc, command_file_argv);
	}

	/* allocate memory for all agruments */
	final_argc = argc;
	if (command_file_index != -1)
	{
		/* @filename detected */
		/* Donot include command file */
		final_argc--;
		final_argc += command_file_argc;
	}

	/* passed on command line and those in command file */
	final_argv = ALLOCNP(char *, final_argc);

	/* arw - don't pass -ext extension to c compiler */
	for (i = 0; i < argc; i++)
	{
		/* arw - get position in the arg list */
		if ((argv[i][0] == WIDECHAR('-')) &&
			(argv[i][1] == WIDECHAR('e') || argv[i][1] == WIDECHAR('E')) && 
			(argv[i][2] == WIDECHAR('x') || argv[i][2] == WIDECHAR('X')) && 
			(argv[i][3] == WIDECHAR('t') || argv[i][3] == WIDECHAR('T')) )
		{
			ext_bypass_flag = i;       /* arw - Got all we need */
			break;
		}
	}

	for (i = 0, final_argc = 0; i < argc; i++)
	{
		if (i != command_file_index)
		{
			if (i == ext_bypass_flag)
				i++ ;  /* arw - skip -ext and the next arg */
			else
				final_argv[final_argc++] = argv[i];
		}
	}

	for (i = 0; i < command_file_argc; i++)
	{
		final_argv[final_argc++] = command_file_argv[i];
	}

	CPP_DBG(("CPPMAIN: final_argc = %d\n", final_argc));
	for (i = 0; i < final_argc; i++)
	{
		CPP_DBG(("CPPMAIN: final_argv[%d] = <%s>\n", i, final_argv[i]));
	}

#ifdef WIN32
	/*
	** INTERNATIONALIZATION CHANGE. Need to convert to wide chars
	**  in order to evaluate command line args.
	*/
	tmp_argv = (wchar_t **) SYS_MALLOC (final_argc * sizeof(wchar_t **));
	for (i = 0; i < final_argc; i++)
	{
		tmp_size = 0;
		RIScom_multiwide(&tmp_argv[i],
						&final_argv[i],
						&tmp_size,
						MULTITOWIDE,
						0);
		CPP_DBG(("process_argv: tmp_argv[%d] = <%S>\n", i, tmp_argv[i]));
	}
#else
	tmp_argv = final_argv;
#endif

	for (i = 0; i < final_argc; i++)
	{
		/*
		** look for *.rc
		*/

#if defined(WIN32) || defined(DOS)
		if (((dot_ptr = wcsrchr(tmp_argv[i],WIDECHAR('.'))) != 0) 
			&& (dot_ptr[1] == WIDECHAR('r') || dot_ptr[1] == WIDECHAR('R'))
			&& (dot_ptr[2] == WIDECHAR('c') || dot_ptr[2] == WIDECHAR('C'))
			&& dot_ptr[3] == WIDECHAR('\0'))
#else
		if (((dot_ptr = RIScom_strrchr(tmp_argv[i],'.')) != 0) 
			&& dot_ptr[1] == 'r' 
			&& dot_ptr[2] == 'c' 
			&& dot_ptr[3] == '\0')
#endif
		{
			/*
			** *.rc files
			*/
			eris_files[eris_file_count++] = i;
		}
#ifdef WIN32
		else if ((dot_ptr = wcsrchr(tmp_argv[i], WIDECHAR('.'))) != 0)
#else
		else if ((dot_ptr = RIScom_strrchr(tmp_argv[i],'.')) != 0)
#endif
		{
#ifdef WIN32			
			/* At this point the extention is in unicode.
			** Convert to multibyte to do the string comparison.
			** Need to increment the pointer passed the (.).
			** When finished with the conversion, move the
			** dot_ptr back to point to the (.).  Paula 12/94
			*/
			dot_ptr++;
			RIScom_multiwide(&dot_ptr,&RISmulti_ptr,&RISmulti_size,WIDETOMULTI, 0);
            dot_ptr--;			
#endif		
			if (extension_flag)
			{
#ifdef WIN32
				if ( !RIScom_strcmp_ic(RISmulti_ptr, extension_str) )
#else
				if ( !strcmp(dot_ptr+1, extension_str) )
#endif
				{
					eris_files[eris_file_count++] = i;
				}
			}
			/*
			** So that even if extension flag is ON *.rc still valid
			*/
#ifdef WIN32
			if ( !RIScom_strcmp_ic(RISmulti_ptr, "rc") )
#else
			if (dot_ptr[1] == WIDECHAR('r') && dot_ptr[2] == WIDECHAR('c') && 
				dot_ptr[3] == WIDECHAR('\0'))
#endif
			{
				eris_files[eris_file_count++] = i;
			}
		}
	}

	CPP_DBG(("CPPMAIN: All embedded RIS files are: "));
	for (i = 0; i < eris_file_count; i++)
	{
		CPP_DBG(("<%s> ", final_argv[eris_files[i]]));
	}
	CPP_DBG(("\n"));
}

#if defined (WIN32)
static BOOL DoesDirHasBlanks (char *Dir)
{
    int i, len ;

    len = strlen (Dir) ;
    for (i=0; i<len; i++) {
        if (Dir[i] == ' ') {
            CPP_DBG (("Directory <%s> has blanks\n", Dir)) ;
            return TRUE ;
        }
    }
    CPP_DBG (("Directory <%s> has NO blanks\n", Dir)) ;
    return FALSE ;
}
#endif

/******************************************************************************/

main(
	int argc,
	char ** argv,
	char ** envp)
{
	int i;
	char ** new_argv;
	int status;
	int sts;
	char	*tokptr;
	char * obj_file = 0;
	char * inc_file = 0;
	char * inc_file2 = 0;
	char * inc_file3 = 0;
	char * language_name;
	int static_arg_count = 0;
	char version[12];
#if defined(__clipper__)
	extern char *getenv();
	extern getcpuid();
	int cpid = -1;
	int xns_flag=0;
	int dnp_flag=0;
	int tcp_flag=0;
	LDFILE * ldptr;
	ARCHDR  arhead;
#endif
#if defined(sco)
	int tcp_flag=0;
	LDFILE * ldptr;
	ARCHDR  arhead;
#endif
#if defined(unix)
	int pid;
	int start;
	int size;
	char * cp;
	char cpuid[10];
#endif
#if defined (WIN32)
	int cl386flag = 0;
	int mclflag = 0;
	char *cmdline;
	int sizeofcmdline = 0;
	PROCESS_INFORMATION	pi;
	STARTUPINFO			sui;
	DWORD	wStatus;
	BOOL	cStatus;
	char *buffer;
	char filepath[RIS_MAX_PATH_SIZE];
        char **mod_argv ;
#endif
        
	if(argc < 2)
	{
		Usage();
		exit(1);
	}

	/*
	** This is to indicate parser that we're in preprocessor mode
	** so that only preprocessor valid syntax will be checked.
	*/
	SET_PREPROCESSOR;

	RIScpp_found_error = 0;
	RIScpp_pound_lines = 1;
	strcpy(idirstr,"\0");
	strcpy(extension_str,"\0");

	status = SETJMP();
	if (status)
	{
		RIScpp_err_return(status,0,0,0,0);
		exit(1);
	}
	RIScom_initialize_debug();
#ifdef WIN32
	if ( !setlocale(LC_ALL, ""))
	{
		CPP_DBG(("Cannot set Locale for server machine\n"));
		LONGJMP(RIS_E_ERROR_FROM_LOCALE);
	}
#endif

	CPP_DBG(("CPPMAIN: argc = <%d> argv = <0x%x>\n",argc,argv));

	/*
	**	Get RISDP version information
	*/
#if defined(unix) || defined(DOS)
	/*
	** Use the define ( itbokic 3/30 )
	*/
	strncpy(RIS_app_version, RIS_VERSION_STR, sizeof(RIS_app_version));
#elif defined(WIN32)
	/*
	** Use resource file of current dll in this
	** application's address space
	*/
	strcpy(filename,"riscpp.exe");
	if( !RIScom_get_filepath(filename, filepath, sizeof(filepath)) )
	{
		CPP_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	CPP_DBG(("CPPMAIN: filepath:%s\n", filepath));
	if( !(buffer = RIScom_get_version_info(filepath, "040904E4", 
		"FileVersion")) )
	{
		CPP_DBG(("GetFileVersionInfoSize returned:%d\n", GetLastError()));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	strncpy(RIS_app_version,buffer,sizeof(RIS_app_version)); /*itbokic 3/30 */
#endif

	strncpy(version, RIS_app_version, sizeof(version));
	if ((tokptr = strtok(version, ".")) != (char *) NULL)
	{
		RIS_app_version_maj = atoi(tokptr);
	}
	if ((tokptr = strtok(NULL, ".")) != (char *) NULL)
	{
		RIS_app_version_min = atoi(tokptr);
	}
	if ((tokptr = strtok(NULL, ".")) != (char *) NULL)
	{
		RIS_app_version_rel = atoi(tokptr);
	}

	CPP_DBG(("CPPMAIN: RIS_app_version=<%s> (maj=%d min=%d rel=%d)\n",
			RIS_app_version, RIS_app_version_maj,
			RIS_app_version_min, RIS_app_version_rel));

	/*
	** For version 5 -- Sanju Kapoor
	** Parser needs to differentiate between V4 and V5 sub-systems using
	** parser. RIS_app_cli_version is global variable used by parser for
	** this purpose.
	*/
	RIS_app_cli_version = RIS_app_version_maj;

	/*
	** Check whether we're in development or product mode --
	** RISCLI_dir is required for runtime and ums.lib
	** RISDP_dir is required for ris.h, ris library etc
	** For development, RISCLI_dir and RISDP_dir should be the same.
	*/
	sts = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, RIS_app_version_maj, 
		    RIS_app_version_min, RIS_app_version_rel, MATCH_COMPATIBLE, 
		    0, RISCONFIG_FILE, RISCLI_dir, &RIS_development, 0);
	if( sts )
	{
		LONGJMP(sts);
	}
	
	sts = RIScom_get_risdir(RIS_DEVELOPMENT_PRODUCT, RIS_app_version_maj, 
		    RIS_app_version_min, RIS_app_version_rel, MATCH_MAJOR_MINOR_RELEASE,
		    0, RISCONFIG_FILE, RISDP_dir, 0, 0);
	if( sts )
	{
		LONGJMP(sts);
	}
	
	/*
	**  Initialize Memory Management
	*/
	RIScom_get_mem();

	/*
	**  Initialize language_name
	*/
#if defined(unix) || defined(DOS)
	if((language_name = getenv("RIS_LANGUAGE")) == NULL)
	{
		language_name = RIS_DEFAULT_LANGUAGE;
	}
#endif
#if defined(WIN32)
	language_name = RIS_DEFAULT_LANGUAGE;
#endif

	/*
	**  Initialize language config file and ums file
	*/
	RIScom_init_ums_msg(RIS_UMS_FILE, RISCLI_dir, RIS_development,
						   language_name);
	language_name = RIScom_ris_lang_name(RIS_language_code);
	CPP_DBG(("CPPMAIN: language_name=<%s>\n", language_name));

	/*
	** Branding stuff only for WIN32 and DOS
	*/
#if defined(WIN32) || defined(DOS)
	RIScpp_verify_license();
#endif

	RIS_current_stmt_id = 0;
	RIScpp_query_buf_size = RIScpp_QUERY_CHUNK_SIZE;
	RIScpp_query_buf = ALLOCBP(RIScpp_query_buf_size);

	command_file_argv = ALLOCNP(char *, 128);
	eris_files = ALLOCNP(int, 128);

#if defined(DOS)
	/*
	** For DOS, only preprocess the *.rc file and DONOT compile or link 
	*/
	preprocess_only = 1;
#endif

#if defined (WIN32)
        /*
        ** Set global indicating if the path where RISDP is located has blanks
        */
        
        RISDP_has_blanks = DoesDirHasBlanks (RISDP_dir) ;

        /*
        ** convert to an array of malloced strings  - Melania Stewart 3/96
        */

        mod_argv = (char **) calloc (argc, sizeof(char *)) ;
        for (i=0; i<argc; i++)
        {
            mod_argv[i] = (char *) malloc (strlen (argv[i]) + 1) ;
            strcpy (mod_argv[i], argv[i]) ;
        }
	/*
	** process argv
	*/

	process_argv(argc, mod_argv);
#else
	/*
	** process argv
	*/
	process_argv(argc, argv);
#endif
	/*
	** From henceforth use final_argv and final_argc ONLY -hitesh 1/94
	*/

	/*
	** preprocess all *.rc files
	*/
	for (i = 0; i < eris_file_count; i++)
	{
		RIScpp_found_error_in_file = 0;
		RIScpp_out_name = "";
		*RIScpp_temp_name = '\0';
		RIScpp_in_file = 0;
		RIScpp_out_file = 0;
		RIScpp_temp_file = 0;

		RIScpp_process_file(final_argv[eris_files[i]]);

		if (RIScpp_found_error_in_file)
		{
			hdestroy();
			if (RIScpp_in_file) RIScom_fclose(RIScpp_in_file);
			/* fix for TR 439503095 -kmreddy 09/13/95 */
			if (RIScpp_out_file)
			{
				RIScom_fclose(RIScpp_out_file);
				RIScom_remove(RIScpp_out_name);
			}
			if (RIScpp_temp_file)
			{
				RIScom_fclose(RIScpp_temp_file);
				RIScom_remove(RIScpp_temp_name);
			}
		}
		final_argv[eris_files[i]] = RIScpp_out_name;
	}

	CPP_DBG(("CPPMAIN: final_argc = <%d>\n", final_argc));
	for (i = 0; i < final_argc; i++)
	{
		CPP_DBG(("CPPMAIN: final_argv[%d] = <%s>\n", i, final_argv[i]));
	}

	CPP_DBG(("CPPMAIN: Done preprocessing all files.\n"));
	CPP_DBG(("CPPMAIN: Preprocess only ? <%s>\n",
				preprocess_only ? "YES" : "NO"));
	CPP_DBG(("CPPMAIN: Preprocessor error ? <%s>\n",
				RIScpp_found_error ? "YES" : "NO"));

#if defined(unix)
	/*
	** Call appropriate compiler and linker
	** if not to be preprocessoed only and no error
	*/

	if (!preprocess_only && !RIScpp_found_error)
	{
		if ((pid=vfork()) > 0)
		{
			if (wait(&status) == -1 || status)
			{
				RIScpp_err_return(RIS_E_WAIT_FOR_CC_ERROR,0,0,0,0);
				exit(1);
			}
			if (!gflag && eris_file_count == 1)
			{
				if (remove(RIScpp_out_name))
				{
					RIScpp_err_return(RIS_E_UNLINK_OUTPUT_FILE_ERROR,0,0,
									  RIScpp_out_name,0);
					exit(1);
				}
			}
		}

		else if (pid == 0)
		{
			/*
			** Call the compiler with all arguments except listed below
			*/

			arg_count = 0;
			args = ALLOCNP(char *, final_argc);

			for (i = 0;i < final_argc;i++)
			{
#if defined(__clipper__)
				if (strcmp(final_argv[i],"-l") && 
				    strcmp(final_argv[i],"-gh") &&
				    strcmp(final_argv[i],"-acc") 
				)
#elif defined (sun)
				if (strcmp(final_argv[i],"-l") &&
				    strcmp(final_argv[i],"-acc") &&
				    strcmp(final_argv[i],"-gcc") &&
				    strcmp(final_argv[i],"-cc")
				)
#elif defined(unix)
				if (strcmp(final_argv[i],"-l")) 
#endif /* all unix */
				{
					args[arg_count++] = final_argv[i];
				}
			}

#if defined(__clipper__)
			if (accflag)	
			{
				args[0] = "acc"; 
			}
			else if(ghflag)
			{
				args[0] = "cc"; 
			}
			else
			{
				args[0] = "acc"; 
			}
/* endif clipper */

#elif defined (sun)
			if (sunaccflag)
			{
				args[0] = "acc";
			}
			else if (sungccflag)
			{
				args[0] = "gcc";
			}
			else if (sunccflag)
			{
				args[0] = "cc";
			}
			else
			{
				args[0] = "acc";
			}
/* endif sun4 */

#elif defined(unix)
			/*
			** Only one compiler supported for sco, Solaris or HP
			*/
			args[0] = "cc";
/* endif rest of the unix */

#endif /* all unix */

			/*
			** To store include path and library names
			*/

#if defined(__clipper__)
/*
**	One for "-Dunix" symbol  ( 02/08/95  Surjit)
**	One for ris include path (three in case of development mode)
**	One for ris library
**	Two for inc and nsl_s if xns
**	One for bsd if tcp or dnp
**	One for NULL
*/
			if (RIS_development)
				static_arg_count = 9;
			else
				static_arg_count = 7;
/* endif clipper */

#elif defined (sun)
/*
**	One for ris include path (three in case of development mode)
**	One for ris library
**	One for /usr/lib/libc library
**	One for /usr/5lib/libc library
**	One for NULL
*/
			if (RIS_development)
				static_arg_count = 7;
			else
				static_arg_count = 5;
/* endif sun4 */

#elif defined (__Sol2__) || defined(Soli)
/*
**	One for "-D__Sol2__" or "-DSoli" symbol
**	One for ris include path (three in case of development mode)
**	One for ris library
**	One for /usr/lib/libc library
**	One for /usr/lib/libsocket library (if required)
**	One for NULL
*/
			if (RIS_development)
				static_arg_count = 15;
			else
				static_arg_count = 13;
/* endif solaris */

#elif defined (__hpux__)
/*
**	One for "-D__hpux__" symbol
**	One for ris include path (three in case of development mode)
**	One for ris library
**	One for /usr/lib/libc library
**	One for /usr/lib/libsocket library (if required)
**	One for NULL
*/
			if (RIS_development)
				static_arg_count = 16;
			else
				static_arg_count = 14;
/* endif hpux */

#elif defined (sco)
/*
**	One for "-Dsco" symbol
**	One for ris include path (three in case of development mode)
**	One for ris library
**	One for /usr/lib/libc library
**	One for /usr/lib/libsocket library (if required)
**	One for NULL
*/
			if (RIS_development)
				static_arg_count = 8;
			else
				static_arg_count = 6;
/* endif sco */

#endif /* all unix */

			new_argv = ALLOCNP(char *, arg_count + static_arg_count);
			memcpy((char *)new_argv, (char *)args, arg_count*sizeof(char **));
			memcpy((char *)new_argv, (char *)args, arg_count*sizeof(char **));
			len = strlen(RISDP_dir);
			/*
			** This is for the include path for ris.h etc.
			** Same for all UNIX platforms
			*/
			if (RIS_development)
			{
				/*
				** Whenever a new include path need to be added
				** it should be done as a seperate argument and
				** not appended to the inc_file with "-I.."
				*/

				inc_file = ALLOCBP(2+len+sizeof("/riscom/include"));
				sprintf(inc_file, "-I%s%s", RISDP_dir,  
						"/riscom/include");

				inc_file2 = ALLOCBP(2+len+sizeof("/risapp/include"));
				sprintf(inc_file2, "-I%s%s", RISDP_dir, 
						"/risapp/include");

				inc_file3 = ALLOCBP(2+len+sizeof("/risutl/include"));
				sprintf(inc_file3, "-I%s%s", RISDP_dir,
						"/risutl/include");
			}
			else
			{
				inc_file = ALLOCBP(2+len+sizeof("/include"));
				memcpy(inc_file ,"-I",2 );
				memcpy(inc_file+2 ,RISDP_dir,len );
				memcpy(inc_file+len+2,"/include",sizeof("/include"));
			}

			/*
			** To make sure that we use the right
			** "ris.a" depending on the target cpuid.
			** For clipper: c100, c300, c400 etc
			** For sun    : future (sunos,solaris)
			*/
			cpuid[0] = '\0';
			for(start = 0; new_argv[start]; start++)
			{
				/*
				** Get targ options if any
				*/
				if (!strncmp(new_argv[start],"targ", 4) || 
				!strncmp(new_argv[start],"-Atarg", 6)) /*itbokic*/
				{
					cp = new_argv[start]; 
					while(*cp != '=') 
					{
						cp++;
					}
					for(size = 0,cp++; *cp; cp++)
					{
						cpuid[size++] = *cp;
					}	
				}
			}

			/*
			** Determine what was specified in targ option
			*/

#if defined(__clipper__)
			if (!strcmp(cpuid, "c100") ||
			    !strcmp(cpuid, "c200") ||
			    !strcmp(cpuid, "c300"))
			{
				cpid = 0;
			}
			else if (!strcmp(cpuid, "c400") ||
				 !strcmp(cpuid, "c400safe") ||
				 !strcmp(cpuid, "c400r0") ||
				 !strcmp(cpuid, "c400r1") ||
				 !strcmp(cpuid, "c400r4"))
			{
				cpid = 4;
			}
			/*
			** If targ=native option is specified, then
			** we get the cpuid from the system 'getcpuid' call.
			** This call returns 0 for c100, 1 for c200,
			** 2 for c300 and 4 from c400.
			*/
			else if(!strcmp(cpuid, "native"))
			{
				if( (sts = getcpuid(&cpid)) != 0)
				{
					RIScpp_err_return(RIS_E_GET_CPUID_FAILED,0,0,0,0);
				}
			}
			else
			{
				/* 
				** In development mode, it targ is not specified get the
				** cpu-id. This can be done for non-development too.
				** -Hitesh 12/93
				*/
				if( (sts = getcpuid(&cpid)) != 0)
				{
					RIScpp_err_return(RIS_E_GET_CPUID_FAILED,0,0,0,0);
				}
			}
			/*
			**	Set obj_file to cpuid/ris.a
			*/
			switch (cpid)
			{
				case 0:
				case 1:
				case 2:
					if (RIS_development)
					{
						obj_file = ALLOCBP(len+sizeof("/risapp/lib/c100/ris.a"));
						memcpy(obj_file ,RISDP_dir,len);
						memcpy(obj_file+len ,"/risapp/lib/c100/ris.a\0", 
								sizeof("/risapp/lib/c100/ris.a"));
					}
					else
					{
						obj_file = ALLOCBP(len+sizeof("/lib/c100/ris.a"));
						memcpy(obj_file ,RISDP_dir,len);
						memcpy(obj_file+len ,"/lib/c100/ris.a\0", 
								sizeof("/lib/c100/ris.a"));
					}
					break;
				case 4:
					if (RIS_development)
					{
						obj_file = ALLOCBP(len+sizeof("/risapp/lib/c400/ris.a"));
						memcpy(obj_file ,RISDP_dir,len );
						memcpy(obj_file+len,"/risapp/lib/c400/ris.a",
							sizeof("/risapp/lib/c400/ris.a"));
					}
					else
					{
						obj_file = ALLOCBP(len+sizeof("/lib/c400/ris.a"));
						memcpy(obj_file ,RISDP_dir,len );
						memcpy(obj_file+len,"/lib/c400/ris.a",
							sizeof("/lib/c400/ris.a"));
					}
					break;
				default:
					break;
			}
/* endif clipper */

#elif defined(unix)
			{
				int len0 = strlen("/risapp");
				int len1 = strlen("/lib/");
				int len2 = strlen(CPU_NAME);
				int len3 = strlen("/ris.a");

				if (!RIS_development)
					len0 = len2 = 0; /* reset to 0 for product mode */
				obj_file = ALLOCBP(len+len0+len1+len2+len3+1);

				memcpy(obj_file, RISDP_dir, len);
				if (RIS_development)
					memcpy(obj_file+len, "/risapp", len0);
				memcpy(obj_file+len+len0, "/lib/", len1);
				if (RIS_development)
					memcpy(obj_file+len+len0+len1, CPU_NAME, len2);
				memcpy(obj_file+len+len0+len1+len2, "/ris.a", len3+1);
			}
/* endif rest of the unix */

#endif /* all unix */

			/*
			** linking the right library depending upon the network protocol.
			*/

#if defined(__clipper__) || defined(sco)
			ldptr = NULL;
			do
			{
				if ((ldptr = ldopen(obj_file, ldptr)) != NULL)
				{
					if (ldahread(ldptr,&arhead) == SUCCESS)
					{

#if defined(__clipper__)
						if(!strcmp(arhead.ar_name, "netxns.o"))
						{
							CPP_DBG(("CPPMAIN: detected netxns.o\n"));
							xns_flag = 1;
						}
						if(!strcmp(arhead.ar_name, "netdnp.o"))
						{
							CPP_DBG(("CPPMAIN: detected netdnp.o\n"));
							dnp_flag = 1;
						}
#endif /* clipper */

						if(!strcmp(arhead.ar_name, "nettcp.o"))
						{
							CPP_DBG(("CPPMAIN: detected nettcp.o\n"));
							tcp_flag = 1;
						}
					}
					else
					{
						RIScpp_err_return(RIS_E_CANNOT_READ_OBJ,0,0,0,0);
					}
				}
				else
				{
					RIScpp_err_return(RIS_E_CANNOT_OPEN_OBJ,0,0,0,0);
				}
			} while (ldclose(ldptr) == FAILURE);
#endif /* only clipper or sco */

			/*
			** It should be always Post-increment of arg_count -Hitesh
			*/

#if defined(__clipper__)
			new_argv[arg_count++] = "-Dunix";
			new_argv[arg_count++] = inc_file;
			/*
			** Two more in case of RIS_development 
			*/
			if (RIS_development)
			{
				new_argv[arg_count++] = inc_file2;
				new_argv[arg_count++] = inc_file3;
			}
			new_argv[arg_count++] = obj_file;
			if(xns_flag)
			{
				new_argv[arg_count++] = "-linc";
				new_argv[arg_count++] = "-lnsl_s";
			}
			if(tcp_flag || dnp_flag)
			{
				new_argv[arg_count++] = "-lbsd";
			}
/* endif clipper */

#elif defined (sun)
			new_argv[arg_count++] = inc_file;
			/*
			** Two more in case of RIS_development 
			*/
			if (RIS_development)
			{
				new_argv[arg_count++] = inc_file2;
				new_argv[arg_count++] = inc_file3;
			}
			new_argv[arg_count++] = obj_file;
			new_argv[arg_count++] = "/usr/5lib/libc.a";
			new_argv[arg_count++] = "/usr/lib/libc.a";
/* endif sun4 */

#elif defined(__Sol2__) || defined(Soli)
			new_argv[arg_count++] = inc_file;
			/*
			** Two more in case of RIS_development 
			*/
			if (RIS_development)
			{   
				new_argv[arg_count++] = inc_file2;
				new_argv[arg_count++] = inc_file3;
			}
			new_argv[arg_count++] = obj_file;
			new_argv[arg_count++] = "/usr/lib/libc.a";
			new_argv[arg_count++] = "/usr/lib/libw.a";
			new_argv[arg_count++] = "/usr/lib/libsocket.a";
			new_argv[arg_count++] = "/usr/lib/libnsl.a";
			new_argv[arg_count++] = "/usr/lib/libdl.so";
			new_argv[arg_count++] = "/usr/lib/libintl.a";
/* endif solaris */

#elif defined (__hpux__)
			new_argv[arg_count++] = "-D__hpux__";
			new_argv[arg_count++] = "-Dunix";
			new_argv[arg_count++] = "-Ae";
			new_argv[arg_count++] = inc_file;
			/*
			** Two more in case of RIS_development 
			*/
			if (RIS_development)
			{
				new_argv[arg_count++] = inc_file2;
				new_argv[arg_count++] = inc_file3;
			}
			new_argv[arg_count++] = obj_file;
			new_argv[arg_count++] = "/lib/libp/libc.a";
			new_argv[arg_count++] = "/lib/libc.a";
			new_argv[arg_count++] = "/usr/lib/libV3.a";
			new_argv[arg_count++] = "/usr/lib/libbsdipc.a";
			new_argv[arg_count++] = "/usr/lib/libBSD.a";
			new_argv[arg_count++] = "/usr/lib/libC.a";
/* endif hpux */

#elif defined (sco)
			/*
			** FUNNY KLUDGE 
			** -Ipath and -Dsco as to appear before *.c on commandline
			*/
			for( i = arg_count; i >= 2; i-- )
			{
				new_argv[i+1] = new_argv[i-1];
			}
			new_argv[1] = "-Dsco";	 /* SO THAT -Dsco comes before *.c */
			new_argv[2] = inc_file;  /* SO THAT -Ipath comes before *.c */
			/*
			** Two more in case of RIS_development 
			*/
			if (RIS_development)
			{
				new_argv[3] = inc_file2;
				new_argv[4] = inc_file3;
				arg_count += 2;
			}
			/* 
			** Now as the above arguments were inserted, following lines
			** are required so that RIS required arguments (libs) start at
			** correct location. -Hitesh 1/94 
			*/
			arg_count += 2;
			new_argv[arg_count++] = obj_file;
			new_argv[arg_count++] = "/lib/libc.a";
			if (tcp_flag)
			{
				new_argv[arg_count++] = "-lsocket";
			}
/* endif sco */

#endif /* all unix */

			/* now, arg_count should not change */
			new_argv[arg_count] = 0;
			for (i = 0; i < arg_count; i++)
			{
				CPP_DBG(("CPPMAIN: new_argv[%d] = <%s>\n",
							i, STRING(new_argv[i])));
			}

			CPP_DBG(("CPPMAIN: CHILD process will now exec \"cc\"\n"));

#if defined(__clipper__)
			if (accflag)	
			{
				RIScom_execve("/bin/acc",new_argv,envp); 
			}
			else if(ghflag)
			{
				RIScom_execve("/bin/cc",new_argv,envp);  
			}
			else
			{
				RIScom_execve("/bin/acc",new_argv,envp); 
			}
/* endif clipper */

#elif defined (sun)
			if (sunaccflag)
			{
				if (!access("/usr/sunc/lang/acc", F_OK))
				{
					RIScom_execve("/usr/sunc/lang/acc",new_argv,envp);
				}
				else if (!access("/usr/lang/acc", F_OK))
				{
					RIScom_execve("/usr/lang/acc",new_argv,envp);
				}
				else
				{
					RIScom_execvp("acc",new_argv);
				}
			}
			else if (sungccflag)
			{
				RIScom_execve("/usr/bin/gcc",new_argv,envp);
			}
			else if (sunccflag)
			{
				RIScom_execve("/usr/5bin/cc",new_argv,envp);
			}
			else
			{
				if (!access("/usr/sunc/lang/acc", F_OK))
				{
					RIScom_execve("/usr/sunc/lang/acc",new_argv,envp);
				}
				else if (!access("/usr/lang/acc", F_OK))
				{
					RIScom_execve("/usr/lang/acc",new_argv,envp);
				}
				else
				{
					RIScom_execvp("acc",new_argv);
				}
			}
/* endif sun4 */

#elif defined (__Sol2__) || defined(Soli)
			if (!access("/opt/SUNWspro/bin/cc", F_OK))
			{
				RIScom_execve("/opt/SUNWspro/bin/cc",new_argv,envp);
			}
			else
			{
				RIScom_execvp("cc",new_argv);
			}
/* endif solaris */

#elif defined(__hpux__)
			RIScom_execve("/bin/cc",new_argv,envp);  
/* endif hpux */

#elif defined(sco)
			RIScom_execve("/bin/cc",new_argv,envp);  
/* endif sco */

#endif /* all unix */

			RIScpp_err_return(RIS_E_EXEC_CC_ERROR,0,0,0,0);
			_exit(1);
		}

		else
		{
			RIScpp_err_return(RIS_E_FORK_ERROR,0,0,0,0);
			exit(1);
		}
	}
#endif /* ifdef unix */

#if defined(WIN32)
	if (!preprocess_only && !RIScpp_found_error)
	{
	    int TotalLen =0  ;
		/*
		** This is for the include path for ris.h and other include files
		** Same for WINDOWS platforms
		*/
		len = strlen(RISDP_dir);
		TotalLen = len ;
		if (RISDP_has_blanks) TotalLen += 2 ;
		if (RIS_development)
		{
			inc_file = ALLOCBP(2*(2+TotalLen+sizeof("\\riscom\\include")+2));
			if (RISDP_has_blanks) {  /* mms - Only TRUE with WIN32 */
			sprintf(inc_file,"-I\"%s%s\" -I\"%s%s\"", RISDP_dir,
					"\\riscom\\include", RISDP_dir, "\\risapp\\include");
			}
			else {
			sprintf(inc_file,"-I%s%s -I%s%s", RISDP_dir,
					"\\riscom\\include", RISDP_dir, "\\risapp\\include");
			}
		}
		else
		{
			inc_file = ALLOCBP(2+TotalLen+sizeof("\\include"));
			if (RISDP_has_blanks ) {  /* mms - Only TRUE with WIN32 */
			memcpy(inc_file ,"-I\"",3 );
			memcpy(inc_file+3 ,RISDP_dir,len );
			memcpy(inc_file+len+3,"\\include\"",sizeof("\\include\""));
			}
			else {
			memcpy(inc_file ,"-I",2 );
			memcpy(inc_file+2 ,RISDP_dir,len );
			memcpy(inc_file+len+2,"\\include",sizeof("\\include"));
                        }			    
		}

		if (RIS_development)
		{
			obj_file = ALLOCBP(TotalLen+sizeof("\\risapp\\lib\\nt\\ris.lib"));
			if (RISDP_has_blanks ) {  /* mms - Only TRUE with WIN32 */
			memcpy(obj_file, "\"", 1) ;
			memcpy(obj_file+1,RISDP_dir,len);
			memcpy(obj_file+len+1,"\\risapp\\lib\\nt\\ris.lib\"",
				sizeof("\\risapp\\lib\\nt\\ris.lib\""));
			}
			else {
			memcpy(obj_file,RISDP_dir,len);
			memcpy(obj_file+len,"\\risapp\\lib\\nt\\ris.lib",
				sizeof("\\risapp\\lib\\nt\\ris.lib"));
			}
		}
		else
		{
			obj_file = ALLOCBP(TotalLen+sizeof("\\lib\\ris.lib"));
			if (RISDP_has_blanks ) {  /* mms - Only TRUE with WIN32 */
			memcpy(obj_file, "\"", 1) ;
			memcpy(obj_file+1,RISDP_dir,len);
			memcpy(obj_file+len+1,"\\lib\\ris.lib\"",
				sizeof("\\lib\\ris.lib\""));
			}
			else {
			memcpy(obj_file,RISDP_dir,len);
			memcpy(obj_file+len,"\\lib\\ris.lib",
				sizeof("\\lib\\ris.lib"));
			}
		}

		arg_count = 0;
		args = ALLOCNP(char *, final_argc);
		for (i = 0; i < final_argc; i++)
		{
			if (strcmp(final_argv[i],"-l") &&
			    strcmp(final_argv[i],"-cl386"))
			{
				args[arg_count++] = final_argv[i];
			}
		}
		if (cl386flag)
		{
		    args[0] = "cl";
		}
		else if(mclflag)
		{
		    args[0] = "mcl";
		}
		else 
		{
		    args[0] = "cl";
		}

		/*
		**	To store ris include path, ris and nt library names
		**	One for "-DWIN32" macro
		**	One for ris include path
		**	One for ris library
		** 	One for crtdll.lib library
		** 	One for kernel32.lib library
		** 	One for advapi32.lib library
		** 	One for user32.lib library
		*/
		static_arg_count = 7;
		new_argv = ALLOCNP(char *, arg_count + static_arg_count);

		/*
		**	Copy all user passed arguments
		*/
		memcpy((char *)new_argv ,(char *)args,arg_count*sizeof(char **));

		/*
		**	Copy all libraries
		*/
		/* It should be always Post-increment of arg_count -Hitesh */
		new_argv[arg_count++] = "-DWIN32";
		new_argv[arg_count++] = inc_file;
		new_argv[arg_count++] = obj_file;
		/*
		** changed msvcrt.lib to /MD which is the same as saying
		** /D_MT /D_DLL msvcrt.lib because of TR 439502559 DDF 6/23/95
		*/
		new_argv[arg_count++] = "/MD"; /* was: msvcrt.lib TR 439502559 */
		new_argv[arg_count++] = "kernel32.lib";
		new_argv[arg_count++] = "advapi32.lib";
		new_argv[arg_count++] = "user32.lib";
		new_argv[arg_count] = 0;

		for (i = 0; i < arg_count; i++)
		{
			sizeofcmdline += strlen(new_argv[i]) + 1;
			CPP_DBG(("new_argv[%d] = <%s>\n", i, STRING(new_argv[i])));
		}
	
		/*
		**	Copy all arguments into a char buffer
		**	cmdline to be passed to CreateProcess
		*/
		cmdline = ALLOCNP(char, sizeofcmdline + 20);
		cmdline[0] = '\0';
		for (i = 0; i < arg_count; i++)
		{
			strcat(cmdline, new_argv[i]);
			strcat(cmdline, " ");
		}

		CPP_DBG(("cmdline = <%s>\n", cmdline));

		memset(&sui, 0, sizeof(STARTUPINFO));
		sui.cb = sizeof(STARTUPINFO);

		/*
		** Call the compiler with all arguments listed above
		*/
		cStatus = CreateProcess(NULL, cmdline, NULL, NULL, TRUE,
				 0, NULL, NULL, &sui, &pi );
		if (cStatus == FALSE)
		{
			CPP_DBG(("CPPMAIN: CreateProcess failed; error:%d\n",
					GetLastError()));
			RIScpp_err_return(RIS_E_EXEC_CC_ERROR,0,0,0,0);
			_exit(1);
		}
		CPP_DBG(("CPPMAIN: CreateProcess was successful\n"));

		wStatus = WaitForSingleObject((LPVOID)pi.hProcess, INFINITE);
		if (wStatus == 0)
		{
			CPP_DBG(("CPPMAIN: normal termination of compiler process.\n"));
		}
		else
		{
			CPP_DBG(("CPPMAIN: WaitForSingleObject wStatus: %d\n",
				GetLastError()));
		}

		if (!gflag && eris_file_count == 1)
		{
			if (remove(RIScpp_out_name))
			{
				RIScpp_err_return(RIS_E_UNLINK_OUTPUT_FILE_ERROR,0,0,
				 RIScpp_out_name,0);
				exit(1);
			}
		}
	}

	/*
	** turn off licensing 
	*/
	RIScpp_serialaudit_end();

#endif /* ifdef WIN32 */

#if defined(DOS)
    if (!preprocess_only && !RIScpp_found_error)
    {
        arg_count = 0;
		args = ALLOCNP(char *, final_argc);
        for (i=0;i < final_argc;i++)
        {
            if (strcmp(final_argv[i],"-l"))
            {
            	args[arg_count++] = final_argv[i];
            }
        }
	/*
	**	To store ris include path, ris and ums library names
	**	One for ris include path
	**	One for ris library
	** 	One for ums library
	**	One for NULL
	*/
        static_arg_count = 4;

        new_argv = ALLOCN(char *, arg_count + static_arg_count);
        memcpy((char *)new_argv,(char *)args,arg_count*sizeof(char **));
        len = strlen(RISDP_dir);
        obj_file = ALLOCB(len+sizeof("\\risapp\\lib\\dos\\ris.lib"));
        if (!obj_file)
        {
                    RIScpp_err_return(RIS_E_TARGET_PROCESSOR_ERROR,0,0,0,0);
        }
        memcpy(obj_file,RISDP_dir,len); 
        memcpy(obj_file+len,"\\risapp\\lib\\dos\\ris.lib",
		sizeof("\\risapp\\lib\\dos\\ris.lib"));
        inc_file = ALLOCB(2+len+sizeof("\\riscom\\include"));
        memcpy(inc_file,"-I",2);
        memcpy(inc_file+2,RISDP_dir,len); 
        memcpy(inc_file+len+2,"\\riscom\\include",sizeof("\\riscom\\include"));
        new_argv[arg_count] = obj_file;
        new_argv[arg_count+1] = inc_file;
		new_argv[arg_count+2] = "-lUMS";
        new_argv[arg_count+3] = 0;
        if (RIScpp_debug)
        {
            int i;
            for (i = 0; i < arg_count + static_arg_count; i++)
                CPP_DBG(("new_argv[%d] = <%s>\n", i,
                      new_argv[i]));
        }
    }
	RIScpp_serialaudit_end();
#endif /* ifdef DOS */

	
	CPP_DBG(("CPPMAIN: Exiting with status %d.\n", RIScpp_found_error));
	return(RIScpp_found_error);
}

/******************************************************************************/
