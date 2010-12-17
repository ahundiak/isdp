#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef UNIX
# include "CLI.h"
#else
# include "CLIerrordef.h"
# include "CLIstruct.h"
# include "CLIextern.h"
# include "NFMerrordef.h"
# include "getopt.h"
# include "proto.h"
# include "pc.h"
# include <memcheck.h>
#endif
#ifdef EXPORT
#include "NFMRstruct.h"
struct NFMRglobal_st NFMRglobal ;
#endif

extern char *optarg;
char npath[51];
char drive[3];
char dir[50];
char filename[8];
char ext[3];
char *buffer;

short   file_flag = 0;
void main(argc,argv)
short argc;
char **argv;
{

    short   error_flag = 0;

    long  status=NFM_S_SUCCESS;

    char  c;
    char  *CLIexec="Command Line Interface";

#ifdef UNIX
    int   fake_index=0;
    char  *fake_path={"\0"};
#else
    char  install_file[24];
    char  doscommand[32];
   
    FILE  *fopen();
    FILE  *file_check;
#endif 


    /* Print the copyright */
#ifndef EXPORT
    _NFMprint_copyright (CLIexec);
#ifdef PCTCP
    sleep(3);
#endif
#endif

#ifdef UNIX
    /* Initialize error message subsystem. UNIX ONLY.*/

    setbuf(stderr, 0);

    status = ERRinit_messages (fake_path, fake_index);
    if (status != ERR_S_SUCCESS)
    {
       fprintf (stderr, "ERROR : Non-fatal.\n");
       fprintf (stderr, "ERROR : Could not initialize message subsystem.\n");
       fprintf (stderr, "ERROR : Check product configuration.\n");
    }
    
#else
mc_startcheck(NULL);
 
    /* Remove the installation executable is it exists. */
    strcpy (install_file, "C:\\ninstall.exe"); 
    file_check = fopen ( install_file, "r");
    if( file_check != NULL )
    {
       fclose (file_check);
       sprintf( doscommand, "erase %s", install_file );
       if (system (doscommand) == -1)
       {
          _CLI_str ("%s", "Error removing installation program");
       }
    }
#endif


    /* find where NFM is loaded */
    strcpy(npath, argv[0]);
    if (npath[0] == '\0')
    {
            printf ("File not found : NFMPC.EXE.\n");
#ifndef UNIX
mc_endcheck();
#endif
            exit(1);
    }
    else
    {
#ifdef UNIX
            strcpy (npath, "/usr/ip32/nfm");
#else
            _splitpath(npath, drive, dir, filename, ext);
            dir[strlen(dir) - strlen("\\BIN\\") ] = '\0';
            sprintf(npath,"%s%s",drive, dir);
#endif
    }

#ifdef UNIX
    buffer = (char *) malloc (2000) ;
    if (buffer == NULL)
    {
            printf ("Insufficient Memory to Execute NFMCLI \n");
            exit (1) ;
    }
#else
    buffer = (char *) malloc (PC_ALLOCATION_SIZE) ;
    if (buffer == NULL)
    {
            printf ("Insufficient Memory to Execute NFMPC \n");

mc_endcheck();
            exit (1) ;
    }
#endif


    CLIinit_all_globals () ;
    while ((c = getopt(argc,argv,"do:s:e:u:p:c:i:r:a:t:v:f:b:x:y:")) != EOF)
    {
        switch(c)
        {
            case 'o':
#ifdef UNIX
                strcpy (CLImsg_ptr.debug_file, optarg);
                strcpy (_NFMdebug_st.NFMRdebug_file, optarg);
                strcpy (_NFMdebug_st.NETCdebug_file, optarg); 
                strcpy (_NFMdebug_st.NETSdebug_file, optarg);
                strcpy (_NFMdebug_st.NFMSdebug_file, optarg);
                strcpy (_NFMdebug_st.NFMdebug_file, optarg);
                strcpy (_NFMdebug_st.SQLdebug_file, optarg);
                strcpy (_NFMdebug_st.ERRdebug_file, optarg);
/*
                strcpy (_NFMdebug_st.MEMdebug_file, optarg);
*/
#else
                sprintf (CLImsg_ptr.debug_file,"%s\\temp\\%s", npath, optarg);
                CLImsg_ptr.debug_file[strlen(CLImsg_ptr.debug_file)] = '\0';
#endif
                break;

            case 'd':
                CLImsg_ptr.debug_on = 1;
#ifdef UNIX
                _NFMdebug_st.NFMRdebug_on  = TRUE;
                _NFMdebug_st.NETCdebug_on  = TRUE;
                _NFMdebug_st.NETSdebug_on  = TRUE;
                _NFMdebug_st.NFMSdebug_on  = TRUE;
                _NFMdebug_st.NFMdebug_on   = TRUE;
                _NFMdebug_st.SQLdebug_on   = TRUE;
                _NFMdebug_st.ERRdebug_on   = TRUE;
/*
                _NFMdebug_st.MEMdebug_on   = TRUE;
*/
#endif

                break;

            case 's':
                /* server name */
                strncpy ( CLIserver, optarg, sizeof(CLIserver));
                break;

            case 'e':
                /* environment name */
                strncpy ( CLIenv, optarg, sizeof(CLIenv));
                break;

            case 'u':
                /* username */
                strncpy( CLIuser, optarg, sizeof(CLIuser));
                break;

            case 'p':
                /* password */
                strncpy( CLIpasswd, optarg, sizeof(CLIpasswd));
                break;

            case 'c':
                /* catalog */
                strncpy( CLIcatalog, optarg, sizeof(CLIcatalog));
                break;

            case 'i':
                /* item */
                strncpy( CLIitem, optarg, sizeof(CLIitem));
                break;

            case 'r':
                /* revision */
                strncpy( CLIrev, optarg, sizeof(CLIrev));
                break;

            case 'a':
                /* working area */
                strncpy( CLIstorage, optarg, sizeof(CLIstorage));
                break;

            case 't':
                /* set, same as item */
                strncpy( CLIitem, optarg, sizeof(CLIitem));
                break;

            case 'v':
                /* set revision, same as item revision */
                strncpy( CLIrev, optarg, sizeof(CLIrev));
                break;

            case 'f':
                /* command file */
                strncpy( CLIcmd_file, optarg, sizeof(CLIcmd_file));
                file_flag = 1;
                break;

            case 'b':
                /* defaults file */
                strncpy( CLIdefaults_file, optarg, sizeof(CLIdefaults_file));
                break;

            case 'x':
                /* storage area name */
                strncpy( CLIcisaname, optarg, sizeof(CLIcisaname));
                break;

#ifdef UNIX
            case 'y':
                /* where output of list sa and catalog is sa will be located */
                strncpy( CLIlistpath, optarg, sizeof(CLIlistpath));
                break;
#endif

            default :
                error_flag = 1;
#ifdef UNIX
                CLIprint (stderr,"Usage: %s [-d [-o output] [-s server] [-e environment] [-u username] [-p password] [-c catalog] [-i item] [-r revision] [-t set] [-v set revision] [-a working area] [-f command file] [-b defaults file] [-x storage area name] [-y list_path]\n", argv[0]);
#else
                CLIprint (stderr,"Usage: %s [-d [-o output] [-s server] [-e environment] [-u username] [-p password] [-c catalog] [-i item] [-r revision] [-t set] [-v set revision] [-a working area] [-f command file] [-b defaults file] [-x storage area name]\n", argv[0]);
#endif
         }
    }
    
    if( error_flag )
	{
		if (buffer)
		{
			free(buffer);
                        buffer = NULL;
		}
#ifndef UNIX
mc_endcheck();
#endif
        exit(1);
	}

    status = CLIread_default_data();
    
    if( status != CLI_S_SUCCESS )
    {
    fprintf( stderr, "CLI ERROR : error reading default data file.\n");
#ifndef UNIX
    exit(1);
#endif
    }

    status = CLIprocess_command_file( CLIcmd_file );
    if (file_flag)
    {
       if( status != CLI_S_SUCCESS )
          CLIprint( stderr, "\nError(s) processing command file <%s>.",
								CLIcmd_file );
       else
          CLIprint(stderr,"\nCLI> Successful completion of command file <%s>.",
								CLIcmd_file );
    }

    if (buffer)
    {
       free(buffer);
    }
#ifndef UNIX
    mc_endcheck();
#endif
    exit(0);
}


void CLIinit_all_globals ()
{
  CLIdefaults_file [0] = 0 ;
  CLIstorage [0] = 0 ;
  CLIserver [0] = 0 ;
  CLIenv [0] = 0 ;
  CLIuser[0] = 0 ;
  CLIpasswd[0] = 0 ;
  CLIcatalog[0] = 0 ;
  CLIitem[0] = 0 ;
  CLIrev[0] = 0 ;
  CLIsearch [0] = 0 ;
  CLIsort[0] = 0 ;
  CLIdisplay_file [0] = 0 ;
  CLIadd_item_file[0] = 0 ;
  CLIdefaults_file [0] = 0 ;
  CLIcisaname[0] = 0 ;
  CLIlistpath[0] = 0 ;
#ifndef UNIX
  CLIpcid[0] = 0 ;
  CLIhostsfile[0] = 0 ;
  CLIoverwrite = 0 ;   /* 0 - No overwrite */
#endif
  CLIreset_add_item_st () ;
}






