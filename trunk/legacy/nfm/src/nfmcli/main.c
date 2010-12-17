#include "machine.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
    int   fake_index=0;
    char  *fake_path={"\0"};
#else
    char  install_file[24];
    char  doscommand[32];
   
    FILE  *fopen();
    FILE  *file_check;
#endif 


    /* Print the copyright */
    _NFMprint_copyright (CLIexec);
    sleep(3);


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
mc_endcheck();
#endif
            exit(1);
    }
    else
    {

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
            strcpy (npath, "/usr/ip32/nfm");
#else
            _splitpath(npath, drive, dir, filename, ext);
            dir[strlen(dir) - strlen("\\BIN\\") ] = '\0';
            sprintf(npath,"%s%s",drive, dir);
#endif
    }


/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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
    while ((c = getopt(argc,argv,"do:s:e:u:p:c:i:r:a:t:v:f:b:")) != EOF)
    {
        switch(c)
        {
            case 'o':

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
              strcpy (CLImsg_ptr.debug_file, optarg);

              strncpy(_NFMdebug_st.NFMRdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NFMRdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy(_NFMdebug_st.NETCdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NETCdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy(_NFMdebug_st.NETSdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NETSdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy(_NFMdebug_st.NFMSdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NFMSdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy(_NFMdebug_st.NFMdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NFMdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy(_NFMdebug_st.SQLdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.SQLdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy(_NFMdebug_st.ERRdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.ERRdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';
/*
              strncpy(_NFMdebug_st.MEMdebug_file, optarg, NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.MEMdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';
*/
#else
                sprintf (CLImsg_ptr.debug_file,"%s\\temp\\%s", npath, optarg);
                CLImsg_ptr.debug_file[strlen(CLImsg_ptr.debug_file)] = '\0';
#endif
                break;

            case 'd':
                CLImsg_ptr.debug_on = 1;

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifdef OS_UNIX
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
                /* storage area */
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

            default :
                error_flag = 1;
                CLIprint (stderr,"Usage: %s [-d [-o output] [-s server] [-e environment] [-u username] [-p password] [-c catalog] [-i item] [-r revision] [-t set] [-v set revision] [-a storage area] [-f command file] [-b defaults file]\n", argv[0]);
         }
    }
    
    if( error_flag )
	{
		if (buffer)
		{
			free(buffer);
                        buffer = NULL;
		}

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
mc_endcheck();
#endif
        exit(1);
	}

    status = CLIread_default_data();
    
    if( status != CLI_S_SUCCESS )
    {
    fprintf( stderr, "CLI ERROR : error reading default data file.\n");

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
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

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
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

/* MSSP - 29 Dec 93. UNIX changed to OS_UNIX. */
#ifndef OS_UNIX
  CLIpcid[0] = 0 ;
  CLIhostsfile[0] = 0 ;
  CLIoverwrite = 0 ;   /* 0 - No overwrite */
#endif
  CLIreset_add_item_st () ;
}

