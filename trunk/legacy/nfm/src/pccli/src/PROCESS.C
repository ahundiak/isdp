#include <stdio.h>
#include <string.h>
#include <malloc.h>

# include "CLIstruct.h"
#ifdef UNIX
# include "CLI.h"
#else
# include <io.h>
# include "CLIerrordef.h"
# include "CLIextern.h"
# include "proto.h"
# include <memcheck.h>
#endif

#define  SERVER      0
#define  ENVIRONMENT 1
#define  USERNAME    2
#define  PASSWORD    3
#define  CATALOG     4
#define  ITEMNAME    5
#define  REVISION    6
#define  WORKINGAREA 7
#define  PCID        8
#define  HOSTSFILE   9
#define  OVERWRITE  10 
#define  CONNECT    100
#define  DISCONNECT 110
#define  LOGIN      120
#define  LOGOUT     130
#define  CHECKIN_ITEM   140
#define  CHECKOUT_ITEM  150
#define  COPY_ITEM_FILES 160
#define  CHECKIN_SET    170
#define  CHECKOUT_SET   180
#define  COPY_SET_FILES   190
#define  FLAG_ITEM_ARCHIVE  200
#define  FLAG_ITEM_BACKUP   210
#define  FLAG_ITEM_RESTORE  220
#define  CANCEL_ITEM_ARCHIVE    230
#define  CANCEL_ITEM_BACKUP 240
#define  CANCEL_ITEM_RESTORE    250
#define  FLAG_SET_ARCHIVE   260
#define  FLAG_SET_BACKUP    270
#define  FLAG_SET_RESTORE   280
#define  CANCEL_SET_ARCHIVE 290
#define  CANCEL_SET_BACKUP  300
#define  CANCEL_SET_RESTORE 310
#define  CANCEL_ITEM_CHECKOUT 320
#define  CANCEL_SET_CHECKOUT 330
#define  STOP 340
#define  EXIT 341
#define  QUIT 342
#define  SHOW 350
#define  HELP 360
#define  SAVE 370
#define  ADD_ITEM 380
#define  ADD_ITEM_FILE   390
#define  LIST_ITEMS 400
#define  LIST_ITEM_FILE  410
#define  SEARCH_NAME   420
#define  SORT_NAME     430
#define  DEFAULTS_FILE 440
/******* DM/L Export **********/
#define  ADD_CI_ITEM   445
#define  LIST_CATALOGS 450
#define  LIST_STORAGE_AREAS   460
#define  ADD_MEMBERS   465
#define  PARENT        470
#define  PARENT_REV    475

extern char npath[51];
extern short file_flag;
extern struct add_item_info ADD_ITEM_st ;

long  CLI_FATAL_ERROR  = 0;
long  CLI_CONNECT_FLAG = 0;
long  CLI_LOGIN_FLAG   = 0;
long  CLI_STOP         = 0;

#define  NUM_OF_KEYWORDS 79L
static struct entry commands[NUM_OF_KEYWORDS+1] = 
{   
    { "SERVER", SERVER },
    { "ENVIRONMENT", ENVIRONMENT },
    { "USERNAME", USERNAME },
    { "PASSWORD", PASSWORD },
    { "CATALOG", CATALOG },
    { "ITEMNAME", ITEMNAME },
    { "REVISION", REVISION },
    { "WORKINGAREA", WORKINGAREA },
    { "PCID", PCID },
    { "HOSTSFILE", HOSTSFILE },
    { "OVERWRITE", OVERWRITE },
    { "CONNECT", CONNECT },
    { "DISCONNECT", DISCONNECT },
    { "LOGIN", LOGIN },
    { "LOGOUT", LOGOUT },
    { "CHECKIN_ITEM", CHECKIN_ITEM },
    { "CII", CHECKIN_ITEM },
    { "CHECKOUT_ITEM", CHECKOUT_ITEM },
    { "COI", CHECKOUT_ITEM },
    { "COPY_ITEM", COPY_ITEM_FILES },
    { "COPY_ITEM_FILES", COPY_ITEM_FILES },
    { "CIF", COPY_ITEM_FILES },
    { "CHECKIN_SET", CHECKIN_SET },
    { "CIS", CHECKIN_SET },
    { "CHECKOUT_SET", CHECKOUT_SET },
    { "COS", CHECKOUT_SET },
    { "COPY_SET", COPY_SET_FILES },
    { "COPY_SET_FILES", COPY_SET_FILES },
    { "CSF", COPY_SET_FILES },
    { "FLAG_ITEM_ARCHIVE", FLAG_ITEM_ARCHIVE },
    { "FIA", FLAG_ITEM_ARCHIVE },
    { "FLAG_ITEM_BACKUP", FLAG_ITEM_BACKUP },
    { "FIB", FLAG_ITEM_BACKUP },
    { "FLAG_ITEM_RESTORE", FLAG_ITEM_RESTORE },
    { "FIR", FLAG_ITEM_RESTORE },
    { "CANCEL_ITEM_ARCHIVE", CANCEL_ITEM_ARCHIVE },
    { "CIA", CANCEL_ITEM_ARCHIVE },
    { "CANCEL_ITEM_BACKUP", CANCEL_ITEM_BACKUP },
    { "CIB", CANCEL_ITEM_BACKUP },
    { "CANCEL_ITEM_RESTORE", CANCEL_ITEM_RESTORE },
    { "CIR", CANCEL_ITEM_RESTORE },
    { "FLAG_SET_ARCHIVE", FLAG_SET_ARCHIVE },
    { "FSA", FLAG_SET_ARCHIVE },
    { "FLAG_SET_BACKUP", FLAG_SET_BACKUP },
    { "FSB", FLAG_SET_BACKUP },
    { "FLAG_SET_RESTORE", FLAG_SET_RESTORE },
    { "FSR", FLAG_SET_RESTORE },
    { "CANCEL_SET_ARCHIVE", CANCEL_SET_ARCHIVE },
    { "CSA", CANCEL_SET_ARCHIVE },
    { "CANCEL_SET_BACKUP", CANCEL_SET_BACKUP },
    { "CSB", CANCEL_SET_BACKUP },
    { "CANCEL_SET_RESTORE", CANCEL_SET_RESTORE },
    { "CSR", CANCEL_SET_RESTORE },
    { "CANCEL_ITEM_CHECKOUT", CANCEL_ITEM_CHECKOUT },
    { "CICO", CANCEL_ITEM_CHECKOUT },
    { "CANCEL_SET_CHECKOUT", CANCEL_SET_CHECKOUT },
    { "CSCO", CANCEL_SET_CHECKOUT },
    { "STOP", STOP },
    { "EXIT", EXIT },
    { "QUIT", QUIT },
    { "SHOW", SHOW },
    { "HELP", HELP },
    { "SAVE", SAVE },
    { "ADD_ITEM_FILE", ADD_ITEM_FILE },
    { "AIF", ADD_ITEM_FILE },
    { "ADD_ITEM", ADD_ITEM },
    { "LIST_ITEMS", LIST_ITEMS },
    { "LIST_ITEM_FILE", LIST_ITEM_FILE },
    { "LIF", LIST_ITEM_FILE },
    { "SEARCH_NAME", SEARCH_NAME },
    { "SORT_NAME", SORT_NAME },
    { "DEFAULTS_FILE", DEFAULTS_FILE },
    { "DF", DEFAULTS_FILE },
/***** EXPORT **********/
    { "ADD_CI_ITEM", ADD_CI_ITEM },
    { "LIST_CATALOGS", LIST_CATALOGS },
    { "LIST_STORAGE_AREAS", LIST_STORAGE_AREAS },
    { "ADD_MEMBERS", ADD_MEMBERS },
    { "PARENT", PARENT },
    { "PARENT_REV", PARENT_REV }
};

long CLIread_default_data( )
{
    long   key_number;
    long  status;
    long  no_words ;

    char  key[21];
    char  key_data[65];
    char  rec[81];
    char  defpath[100];
    char  *fname="CLIread_default_data";

    FILE  *fopen();
    FILE  *def_file;   
    long  cli_flag ;
 
    cli_flag = 0 ;
    if (strlen (CLIdefaults_file))
      {
	strcpy (defpath, CLIdefaults_file) ;
	cli_flag = 1 ;
      }
    else
      {
#ifdef UNIX
	sprintf(defpath,"./cli_defaults");
#else
	sprintf(defpath,"%s\\cfg\\defaults",npath);
#endif
      }

    _CLI_str("CLI DEFAULT FILE <%s>", defpath);
    def_file = fopen(defpath, "r");
        
    if( def_file == NULL )
      {
/* tr 249292768 - did not like this
	_CLI_str("%s : Could not open defaults file", fname);
	fprintf (stderr, "Could not open default file <%s>..",
		 defpath) ;
*/
	if (cli_flag)
	  {
	    /* try with default file */
#ifdef UNIX
	    sprintf(defpath,"./cli_defaults");
#else
	    sprintf(defpath,"%s\\cfg\\defaults",npath);
#endif
	    _CLI_str("Trying CLI DEFAULT FILE <%s>", defpath);
	    fprintf (stderr, "Defaulting to <%s>\n", defpath) ;
	    CLIdefaults_file[0] = 0 ;
	    _CLI_str("CLI DEFAULT FILE <%s>", defpath);
	    def_file = fopen(defpath, "r");
	    if (def_file == NULL)
	      {
		_CLI_str("%s : Could not open defaults file", fname);
		fprintf (stderr, "Could not open defaults file <%s>. No defaults values\n",
			 defpath) ;
		return( CLI_E_FAILURE);
	      }
	  }
	else
	  {
#ifdef UNIX
	    fprintf (stderr, "No defaults was specified\n") ;
	    _CLI_str ("%s: No defaults file specified", fname) ;
	    return (CLI_S_SUCCESS) ;
#else
	    fprintf (stderr, "CLI_E_PCID must be set in defaults file.");
	    _CLI_str("%s : PCID must be set in defaults file", fname);
	    return(CLI_E_FAILURE);
#endif
	  }
      }

    while( fgets( rec, 81, def_file ) != (char*)NULL )
    {
        status = CLIget_key_or_command( rec, key, key_data, &no_words ); 

        key_number = CLIlookup_keyword( commands, key, NUM_OF_KEYWORDS );
        switch( key_number )
        {
#ifndef UNIX
            case PCID:
                strcpy( CLIpcid, key_data );
                _CLI_str( "CLIpcid <%s>", CLIpcid );
                break;

            case HOSTSFILE:
                strcpy( CLIhostsfile, key_data );
                _CLI_str( "CLIhostsfile <%s>", CLIhostsfile );
                break;

            case OVERWRITE:
                if (key_data[0] == 'y' || key_data[0] == 'Y')
                {
                   _CLI_str( "CLIoverwrite <Y>");
                   CLIoverwrite = 1;
                }
                else 
                {
                   _CLI_str( "CLIoverwrite <N>");
                   CLIoverwrite = 0;
                }
                break;
#endif

            case SERVER :
	      if (! strlen (CLIserver)) strcpy( CLIserver, key_data );
                _CLI_str( "CLIserver <%s>", CLIserver );
                break;

            case ENVIRONMENT :
                if (! strlen (CLIenv)) strcpy( CLIenv, key_data );
                _CLI_str( "CLIenv <%s>", CLIenv );
                break;

            case USERNAME :
                if (! strlen (CLIuser)) strcpy( CLIuser, key_data );
                _CLI_str( "CLIuser <%s>", CLIuser );
                break;

            case PASSWORD :
                if (! strlen (CLIpasswd)) strcpy( CLIpasswd, key_data );
                _CLI_str( "CLIpasswd <%s>", CLIpasswd );
                break;

            case CATALOG :
                if (! strlen (CLIcatalog)) strcpy( CLIcatalog, key_data );
                _CLI_str( "CLIcatalog <%s>", CLIcatalog );
                break;

            case ITEMNAME :
                if (! strlen (CLIitem)) strcpy( CLIitem, key_data );
                _CLI_str( "CLIitem <%s>", CLIitem );
                break;

            case REVISION :
                if (! strlen (CLIrev)) strcpy( CLIrev, key_data );
                _CLI_str( "CLIrev <%s>", CLIrev );
                break;

	      case SEARCH_NAME:
                strcpy( CLIsearch, key_data );
                _CLI_str( "CLIsearch <%s>", CLIsearch );
                break;

	      case SORT_NAME :
                strcpy( CLIsort, key_data );
                _CLI_str( "CLIsort <%s>", CLIsort );
                break;

	      case LIST_ITEM_FILE:
                strcpy( CLIdisplay_file, key_data );
                _CLI_str( "CLIdisplay_file <%s>", CLIdisplay_file );
                break;

	      case ADD_ITEM_FILE :
                strcpy( CLIadd_item_file, key_data );
                _CLI_str( "CLIadd_item_files <%s>", CLIadd_item_file );
                break;

	      case DEFAULTS_FILE :
		if (! strlen(CLIdefaults_file)) 
		  strcpy( CLIdefaults_file, key_data );
                _CLI_str( "CLIdefaults_file <%s>", CLIdefaults_file );
                break;


#ifdef UNIX
            case WORKINGAREA :
                if (! strlen (CLIstorage)) strcpy( CLIstorage, key_data );
                _CLI_str( "CLIstorage <%s>", CLIstorage );
                break;
#endif

            case PARENT :
                if (! strlen (CLIparent)) strcpy( CLIparent, key_data );
                _CLI_str( "CLIparent <%s>", CLIparent );
                break;

            case PARENT_REV :
                if (! strlen (CLIparent_rev)) strcpy( CLIparent_rev, key_data );
                _CLI_str( "CLIparent_rev <%s>", CLIparent_rev );
                break;

            default :
                fprintf( stderr, "CLI_I_Illegal keyword <%s>.\n", key );
                break;
        }
    }

    fclose( def_file );

#ifndef UNIX
    if ( strlen (CLIpcid) == 0)
    {
        fprintf (stderr, "CLI_E_PCID must be set in defaults file.");
        _CLI_str("%s : PCID must be set in defaults file", fname);
        return(CLI_E_FAILURE);
    }
#endif
    return( CLI_S_SUCCESS );
}


void CLIwrite_default_data( )
{
    char  defpath[100];
    char  *fname="CLIwrite_default_data";

    FILE  *fopen();
    FILE  *def_file;   
 
/**** 08/27/92 - mms (per Linda)
    If Save is done and there is a defaults file defined, the settings
    will go to the defaults file. If there is no defaults file then it
    will go the the cli_defaults file
 *****/

    if (! strlen (CLIdefaults_file))
      {
#ifdef UNIX
	sprintf(defpath,"./cli_defaults");
#else
	sprintf(defpath,"%s\\cfg\\defaults",npath);
#endif
      }
    else
      {
	strcpy (defpath, CLIdefaults_file) ;
      }

    _CLI_str("CLI DEFAULT FILE <%s>", defpath);
    def_file = fopen(defpath, "w");
        
    if( def_file == NULL )
    {
       _CLI_str("%s : Could not open defaults file", fname);
       return;
    }

#ifndef UNIX
    if ( strlen (CLIpcid) == 0)
    {
        fprintf (stderr, "CLI_E_PCID must be set in defaults file.");
        _CLI_str("%s : PCID must be set in defaults file", fname);
        return(CLI_E_FAILURE);
    }
    else
      {
	fprintf (def_file, "PCID : %s\n", CLIpcid) ;
      }

     if (strlen(CLIhostsfile))
         fprintf(def_file, "HOSTSFILE : %s\n", CLIhostsfile);
     else
         fprintf(def_file, "HOSTSFILE : \n");
#endif
     if (strncmp (CLIserver, "nfms_", 5) != 0)
        fprintf (def_file, "SERVER      : %s\n", CLIserver);
     else
        fprintf (def_file, "SERVER      : %s\n", &CLIserver[5]);
     if (strncmp (CLIenv, "nfme_", 5) != 0)
        fprintf (def_file, "ENVIRONMENT : %s\n", CLIenv);
     else
        fprintf (def_file, "ENVIRONMENT : %s\n", &CLIenv[5]);
     fprintf (def_file, "USERNAME    : %s\n", CLIuser);
     if (strlen(CLIpasswd))
         fprintf(def_file, "PASSWORD    : %s\n", CLIpasswd);
     else
         fprintf(def_file, "PASSWORD    : \n");
     fprintf (def_file, "CATALOG     : %s\n", CLIcatalog);
     fprintf (def_file, "ITEMNAME    : %s\n", CLIitem);
     fprintf (def_file, "REVISION    : %s\n", CLIrev);
#ifdef UNIX
     fprintf (def_file, "WORKINGAREA : %s\n", CLIstorage);
#else
     if (CLIoverwrite)
        fprintf (def_file, "OVERWRITE   : Y\n");
     else 
        fprintf (def_file, "OVERWRITE   : N\n");
#endif
     fprintf (def_file, "SEARCH_NAME : %s\n", CLIsearch);
     fprintf (def_file, "SORT_NAME   : %s\n", CLIsort);
     fprintf (def_file, "LIST_ITEM_FILE : %s\n", CLIdisplay_file);
     fprintf (def_file, "ADD_ITEM_FILE : %s\n", CLIadd_item_file );
     fprintf (def_file, "DEFAULTS_FILE : %s\n", CLIdefaults_file ) ;
    

    fclose( def_file );
    return;
}



long CLIprocess_command_file( command_file )
char *command_file;
{
    long  cmd_number;
    long  status;
    long  no_words ;

    char  command[21];
    char  data[65];
    char  rec[81];
    char  *output_file;
#ifndef UNIX
    char  *ext_ptr;
#endif

    FILE  *fopen();
    FILE  *cmd_file=NULL;   

    output_file = (char*)malloc( strlen( command_file ) + 11 );
    if (output_file == NULL)
    {
        fprintf(stderr, "CLI_E_Could not allocate memory for output file\n");
        return (CLI_E_FAILURE);
    }
    if (file_flag)
    {
#ifdef UNIX
       sprintf( output_file, "%s%s", command_file, ".out" );
#else
       strcpy (output_file, command_file);
       if ((ext_ptr = strchr (output_file, '.')) != NULL)
          *ext_ptr = '\0';
       strcat (output_file, ".out");
#endif
#ifndef EXPORT
       CLIout_file = fopen( output_file, "w" );
       if( CLIout_file == NULL )
       {
           fprintf( stderr, "CLI_E_Could Not Open Output File <%s>.\n", 
								output_file );
           free(output_file);
           return( CLI_E_FAILURE);
       }
#endif
       cmd_file = fopen( command_file, "r" );
       if( cmd_file == NULL )
       {
           fprintf( stderr, "CLI_E_Could Not Open Command File <%s>\n",
								command_file );
           free(output_file);
           return( CLI_E_FAILURE);
       }
       fprintf(stderr, "CLI> Executing Command File <%s>\n\n", command_file);
#ifndef EXPORT
       fprintf(CLIout_file, "CLI> Executing Command File <%s>\n\n", command_file);
#endif
    }
    else
    {
       cmd_file = stdin;

       sprintf( output_file, "%s", "Nfmcli.out" );
#ifndef EXPORT
       CLIout_file = fopen( output_file, "w" );
       if( CLIout_file == NULL )
       {
           fprintf( stderr, "CLI_E_Could Not Open Output File <%s>.\n", 
								output_file );
           free(output_file);
           return( CLI_E_FAILURE);
       }
#endif
    }
    if (!file_flag)
       fprintf (stderr,"CLI> ");
    while( fgets( rec, 81, cmd_file ) != (char*)NULL )
    {
        strcpy( command, "" );
        strcpy( data, "" );
        status = CLIget_key_or_command( rec, command, data, &no_words ); 
        cmd_number = CLIlookup_keyword( commands, command, NUM_OF_KEYWORDS );
        switch( cmd_number )
        {
            case SERVER :
                strcpy (CLIserver, data);
                fprintf(stderr, "SERVER: %s\n", CLIserver); 
#ifndef EXPORT
                fprintf(CLIout_file, "SERVER: %s\n", CLIserver); 
#endif
                _CLI_str( "CLIserver <%s>", CLIserver );
                break;

            case ENVIRONMENT :
                strcpy( CLIenv, data );
                fprintf(stderr, "ENVIRONMENT: %s\n", CLIenv); 
#ifndef EXPORT
                fprintf(CLIout_file, "ENVIRONMENT: %s\n", CLIenv); 
#endif
                _CLI_str( "CLIenv <%s>", CLIenv );
                break;

            case USERNAME :
        	strcpy( CLIuser, data );
                fprintf(stderr, "USERNAME: %s\n", CLIuser); 
#ifndef EXPORT
                fprintf(CLIout_file, "USERNAME: %s\n", CLIuser); 
#endif
        	_CLI_str( "CLIuser <%s>", CLIuser );
        	break;

            case PASSWORD :
        	strcpy( CLIpasswd, data );
                fprintf(stderr, "PASSWORD: Not Printed\n"); 
#ifndef EXPORT
                fprintf(CLIout_file, "PASSWORD: Not Printed\n"); 
#endif
        	_CLI_str( "CLIpasswd <%s>", CLIpasswd );
        	break;

            case CATALOG :
        	strcpy( CLIcatalog, data );
                fprintf(stderr, "CATALOG: %s\n", CLIcatalog); 
#ifndef EXPORT
                fprintf(CLIout_file, "CATALOG: %s\n", CLIcatalog); 
#endif
        	_CLI_str( "CLIcatalog <%s>", CLIcatalog );
        	break;

            case ITEMNAME :
        	strcpy( CLIitem, data );
                fprintf(stderr, "ITEMNAME: %s\n", CLIitem); 
#ifndef EXPORT
                fprintf(CLIout_file, "ITEMNAME: %s\n", CLIitem); 
#endif
        	_CLI_str( "CLIitem <%s>", CLIitem );
        	break;

       	    case REVISION :
        	strcpy( CLIrev, data );
                fprintf(stderr, "REVISION: %s\n", CLIrev); 
#ifndef EXPORT
                fprintf(CLIout_file, "REVISION: %s\n", CLIrev); 
#endif
        	_CLI_str( "CLIrev <%s>", CLIrev );
        	break;

#ifdef UNIX
            case WORKINGAREA :
        	strcpy( CLIstorage, data );
                fprintf(stderr, "WORKINGAREA: %s\n", CLIstorage); 
#ifndef EXPORT
                fprintf(CLIout_file, "WORKINGAREA: %s\n", CLIstorage); 
#endif
        	_CLI_str( "CLIstorage <%s>", CLIstorage );
        	break;
#else
            case OVERWRITE:
                if (data[0] == 'y' || data[0] == 'Y')
                {
                   _CLI_str( "CLIoverwrite <Y>");
                   fprintf(stderr, "OVERWRITE: Y\n");
#ifndef EXPORT
                   fprintf(CLIout_file, "OVERWRITE: Y\n");
#endif
                   CLIoverwrite = 1;
                }
                else 
                {
                   _CLI_str( "CLIoverwrite <N>");
                   fprintf(stderr, "OVERWRITE: N\n");
#ifndef EXPORT
                   fprintf(CLIout_file, "OVERWRITE: N\n");
#endif
                   CLIoverwrite = 0;
                }
                break;
#endif 

	      case SEARCH_NAME :
        	strcpy( CLIsearch, data );
                fprintf(stderr, "SEARCH_NAME: %s\n", CLIsearch); 
#ifndef EXPORT
                fprintf(CLIout_file, "SEARCH_NAME: %s\n", CLIsearch); 
#endif
        	_CLI_str( "CLIsearch <%s>", CLIsearch );
        	break;

	      case SORT_NAME :
        	strcpy( CLIsort, data );
                fprintf(stderr, "SORT_NAME: %s\n", CLIsort); 
#ifndef EXPORT
                fprintf(CLIout_file, "SORT_NAME: %s\n", CLIsort); 
#endif
        	_CLI_str( "CLIsort <%s>", CLIsort );
        	break;

	      case LIST_ITEM_FILE :
        	strcpy( CLIdisplay_file, data );
                fprintf(stderr, "LIST_ITEM_FILE: %s\n", CLIdisplay_file); 
#ifndef EXPORT
                fprintf(CLIout_file, "LIST_ITEM_FILE: %s\n", CLIdisplay_file); 
#endif
        	_CLI_str( "CLIdisplay_file <%s>", CLIdisplay_file );
        	break;

	      case ADD_ITEM_FILE :
        	strcpy( CLIadd_item_file, data );
                fprintf(stderr, "ADD_ITEM_FILE: %s\n", CLIadd_item_file ) ;
#ifndef EXPORT
                fprintf(CLIout_file, "ADD_ITEM_FILE: %s\n",CLIadd_item_file);
#endif
        	_CLI_str( "CLIadd_item_file <%s>", CLIadd_item_file);
        	break;

	      case DEFAULTS_FILE :
        	strcpy( CLIdefaults_file, data );
                fprintf(stderr, "DEFAULTS_FILE : %s\n", CLIdefaults_file );
#ifndef EXPORT
                fprintf(CLIout_file, "DEFAULTS_FILE : %s\n", CLIdefaults_file);
#endif
        	_CLI_str( "DEFAULTS_FILE <%s>", CLIdefaults_file);
        	break;


            case CONNECT : 
                if (CLI_CONNECT_FLAG)
                {
                    if (strncmp(CLIserver, "nfms_", 5) != 0)
                    {
                        CLIprint (stderr, "CLI_I_Invalid CONNECT command. Connection is currently established to server <%s>.", CLIserver);
#ifndef EXPORT
                        CLIprint (CLIout_file, "CLI_I_Invalid CONNECT command. Connection is currently established to server <%s>.", CLIserver);
#endif
                    }
                    else
                    {
                        CLIprint (stderr, "CLI_I_Invalid CONNECT command. Connection is currently established to server <%s>.", &CLIserver[5]);
#ifndef EXPORT
                        CLIprint (CLIout_file, "CLI_I_Invalid CONNECT command. Connection is currently established to server <%s>.", &CLIserver[5]);
#endif
                    }

                }
                else
                {
        	   status = CLIconnect();
         	   if( status != CLI_S_SUCCESS )
                   {
                      if (file_flag)
            	         CLI_FATAL_ERROR = 1;
                   }
                   else
                      CLI_CONNECT_FLAG = 1;
                }
                break;

            case DISCONNECT :
                if ( CLI_CONNECT_FLAG )
                {
        	   status = CLIdisconnect();
        	   if( status != CLI_S_SUCCESS )
                   {
                      if (file_flag)
                         CLI_FATAL_ERROR = 1;
                   }
        	   else
                   {
                      CLI_LOGIN_FLAG = 0;
            	      CLI_CONNECT_FLAG = 0;
                   }
                }
                else
                {
                    CLIprint (stderr, "CLI_I_Invalid DISCONNECT command. No connection is currently established.");
#ifndef EXPORT
                    CLIprint (CLIout_file, "CLI_I_Invalid DISCONNECT command. No connection is currently established.");
#endif
                }
         	break;

            case LOGIN :
                if (CLI_CONNECT_FLAG)
                {
                   if (CLI_LOGIN_FLAG)
                   {
                      CLIprint (stderr, "CLI_I_Invalid LOGIN command. Currently logged in to environment <%s>.", &CLIenv[5]);
#ifndef EXPORT
                      CLIprint (CLIout_file, "CLI_I_Invalid LOGIN command. Currently logged in to environment <%s>.", &CLIenv[5]);
#endif
                   }
                   else
                   {
                      status = CLIlogin();
                      if (status != CLI_S_SUCCESS)
                      {
                         if (file_flag)
                            CLI_FATAL_ERROR = 1;
                      }
                      else
                         CLI_LOGIN_FLAG = 1; 
                   }
                }
                else
                   CLIcheck_connect_and_login();
                break;

            case LOGOUT :
                if (CLI_LOGIN_FLAG)
                {
                   status = CLIlogout();
                   if( status != CLI_S_SUCCESS )
                   {
                       if (file_flag)
                          CLI_FATAL_ERROR = 1;
                   }
                   else
                       CLI_LOGIN_FLAG = 0;
                }
                else if ( CLI_CONNECT_FLAG )
                {
                    CLIprint (stderr, "CLI_I_Invalid LOGOUT command. Not currently logged in.");
#ifndef EXPORT
                    CLIprint (CLIout_file, "CLI_I_Invalid LOGOUT command. Not currently logged in.");
#endif
                    fprintf (stderr, "CLI>  Disconnecting.\n");
#ifndef EXPORT
                    fprintf (CLIout_file, "CLI>  Disconnecting.\n");
#endif
        	    status = CLIdisconnect();
        	    if( status != CLI_S_SUCCESS )
                    {
                       if (file_flag)
                          CLI_FATAL_ERROR = 1;
                    }
        	    else
            	       CLI_CONNECT_FLAG = 0;
                }
                else
                {
                    CLIprint (stderr, "CLI_I_Invalid LOGOUT command. Not currently logged in.");
#ifndef EXPORT
                    CLIprint (CLIout_file, "CLI_I_Invalid LOGOUT command. Not currently logged in.");
#endif
                }
                break;

            case CHECKIN_ITEM :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                   status = CLIcheckin_item();
                }
                break;

#ifndef EXPORT
            case CHECKOUT_ITEM :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcheckout_item();
                }
                break;

            case COPY_ITEM_FILES:
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcopy_item();
                }
                break;

            case CHECKIN_SET :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcheckin_set();
                }
                break;

            case CHECKOUT_SET :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcheckout_set();
                }
                break;

            case COPY_SET_FILES :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcopy_set();
                }
                break;

            case FLAG_ITEM_ARCHIVE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIflag_item_archive();
                }
                break;

            case FLAG_ITEM_BACKUP :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIflag_item_backup();
                }
                break;

            case FLAG_ITEM_RESTORE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIflag_item_restore();
                }
                break;

            case CANCEL_ITEM_ARCHIVE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_item_archive();
                }
                break;

            case CANCEL_ITEM_BACKUP :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_item_backup();
                }
                break;

            case CANCEL_ITEM_RESTORE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_item_restore();
                }
                break;

            case FLAG_SET_ARCHIVE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIflag_set_archive();
                }
                break;

            case FLAG_SET_BACKUP :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIflag_set_backup();
                }
            break;

            case FLAG_SET_RESTORE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIflag_set_restore();
                }
            break;

            case CANCEL_SET_ARCHIVE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_set_archive();
                }
            break;

            case CANCEL_SET_BACKUP :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_set_backup();
                }
            break;

            case CANCEL_SET_RESTORE :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_set_restore();
                }
            break;

	    case CANCEL_ITEM_CHECKOUT :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_item_checkout();
                }
            break;

	    case CANCEL_SET_CHECKOUT :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
                    status = CLIcancel_set_checkout();
                }
	    break;
#endif
           
            case SHOW :
                CLIshow_active_data();
                break;
      
            case STOP :
	    case EXIT :
            case QUIT :
                CLI_STOP = 1;     
                break;
 
            case HELP :
                CLIhelp ();
                break;
               
            case SAVE :
                CLIwrite_default_data ();
                break;

            case ADD_ITEM :
	      if (! strlen (CLIcatalog)) 
		{
		  fprintf (stderr, "Please enter Catalog Name\n");
		  break ;
		}
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
		  CLIadd_item () ;
                }
                break ;

#ifndef EXPORT

            case LIST_ITEMS :
	        if (strlen(CLIdisplay_file) &&
		    strlen (CLIcatalog))
		  {
		    CLIcheck_connect_and_login();
		    if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
		      {
			status = CLIdisplay_items () ;
		      }
		  }
		else
		  {
		    if (! strlen(CLIdisplay_file))
		      fprintf (stderr, "Please specify a value for LIST_ITEM_FILE\n") ;
		    if (! strlen(CLIcatalog))
		      fprintf (stderr, "Please specify a Catalog\n") ;
		  }
		break ;
#endif
#ifdef UNIX
            case ADD_CI_ITEM :
	      if (! strlen (CLIcatalog)) 
		{
		  fprintf (stderr, "Please enter Catalog Name\n");
		  break ;
		}
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
		  CLIadd_ci_item () ;
                }
                break ;


            case LIST_CATALOGS :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
		  CLIlist_catalogs();
                }
                break ;

	      case LIST_STORAGE_AREAS :
		if (! strlen (CLIcatalog)) 
		  {
		    fprintf (stderr, "Please enter Catalog Name\n");
		    break ;
		  }
		
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
		  {
		    CLIlist_storage_areas () ;
		  }
                break ;

	      case ADD_MEMBERS :
                CLIcheck_connect_and_login();
                if( CLI_CONNECT_FLAG && CLI_LOGIN_FLAG )
                {
		  CLIadd_members_to_set () ;
                }
                break ;
#endif
            case PARENT :
                if (! strlen (CLIparent)) strcpy( CLIparent, data );
                _CLI_str( "CLIparent <%s>", CLIparent );
                break;

            case PARENT_REV :
                if (! strlen (CLIparent_rev)) strcpy( CLIparent_rev, data );
                _CLI_str( "CLIparent_rev <%s>", CLIparent_rev );
                break;


            default :
                fprintf( stderr, "CLI_I_Illegal keyword <%s>.\n", command );
                break;
       }
       if( CLI_FATAL_ERROR || CLI_STOP)
           break;
       if (!file_flag)
         fprintf (stderr,"CLI> ");
       
    }

    if( CLI_LOGIN_FLAG )
    {
    status = CLIlogout();
    }
    if( CLI_CONNECT_FLAG )
    {
    status = CLIdisconnect();
    }

    if (file_flag)
       fclose( cmd_file );
#ifndef EXPORT
    fclose( CLIout_file );
#endif
    free (output_file);
    return( CLI_S_SUCCESS );
}

long CLIlookup_keyword( keywords, search, no_keywords )
struct entry *keywords;
char     *search;
long     no_keywords ;
{
    long i, no_match, type ;
  
    no_match = 0 ;
    type = -1 ;
    for( i=0; i<no_keywords; ++i )
      {
	if( CLIequal_strings( search, keywords[i].word )==0 )
	  {
	    if (strlen (search) == strlen (keywords[i].word))
	      {
		return( keywords[i].type );
	      }
	    else
	      {
		type = keywords[i].type ;
		++no_match ;
	      }
	  }
      }
    if (no_match == 1)
      {
	return (type) ;
      }
    else if (no_match > 1)
      {
	CLIprint (stderr, "Keyword <%s> is not Unique\n", search);
	return (-1) ;
      }

    return( -1 );
}

short CLIequal_strings( search, word )
char *search;  /* user input */
char *word;    /* keyword */
{
    short  len;
    char   tmp_str [200] ;
   
/*    len = strlen( word ); */
    len = strlen (search) ;

    strcpy (tmp_str, word) ;
    tmp_str [len] = 0 ;

/* does not work on pc 
    return( strncmp( search, word, len ) );
*/
    return (strcmp (search, tmp_str)) ;
}

 
void _CLI_num (str, var)
char  *str;  /* i - input string */
long  var;   /* i - long variable for input string */

{
    FILE   *CLIdbg_ptr, *fopen ();

    if (CLImsg_ptr.debug_on)
    {
        CLIdbg_ptr = fopen (CLImsg_ptr.debug_file, "a");
        if (CLIdbg_ptr)
        {
            fprintf (CLIdbg_ptr, "CLI : ");
            fprintf (CLIdbg_ptr, str, var);
            fprintf (CLIdbg_ptr, "\n");
            fclose  (CLIdbg_ptr);
        }
    }
}
 
void _CLI_str (str, var)
char  *str;  /* i - input string */
char  *var;  /* i - string variable for input string */
{
    FILE   *CLIdbg_ptr, *fopen ();

    if (CLImsg_ptr.debug_on)
    {
        CLIdbg_ptr = fopen (CLImsg_ptr.debug_file, "a");
        if (CLIdbg_ptr)
        {
            fprintf (CLIdbg_ptr, "CLI : ");
            fprintf (CLIdbg_ptr, str, var);
            fprintf (CLIdbg_ptr, "\n");
            fclose  (CLIdbg_ptr);
        }
    }
}


long CLIget_key_or_command( record, key, data, no_words )
char *record;     /* input string */
char *key;        /* output : left side of colon */
char *data;       /* output : right side of colon */
long *no_words;  /* output : no_data_words */
{
    long  i;
    long  len;
    long  start_flag ;

    *no_words = *no_words ;
    len = strlen( record )-1;
    *(record+len) = '\0';
    for( i=0; i<len; ++record, ++i )
    {
        if( *record == ' ' )
        {
            *key = '\0';
            continue;
        }
        else if( *record == ':' )
        {
            *key = '\0';
            ++record;
	    start_flag = 1 ;
            for( ; i<len; ++record, ++i )
            {
	      if (start_flag && *record == ' ') continue ;
	      start_flag = 0 ;
	      *data = *record;
	      ++data;
            }
            *data = '\0';
            break;
        }
        else if( (i+1) == len )
        {
            *key = (char) toupper((int)*record);
            *(++key) = '\0';
            break;
        }
        else
        {
            *key = (char) toupper((int)*record);
            ++key;
        }
    }
    
    return( CLI_S_SUCCESS );
    
}

void CLIcheck_connect_and_login( )
{
    long  status;

    if( !CLI_CONNECT_FLAG )
    {
        if( (status = CLIconnect() ) != CLI_S_SUCCESS )
        {
            if (file_flag)
               CLI_FATAL_ERROR = 1;
        }
        else
            CLI_CONNECT_FLAG = 1;
    }

    if( CLI_CONNECT_FLAG && !CLI_LOGIN_FLAG )
    {
        if( (status = CLIlogin()) != CLI_S_SUCCESS )
        {
            if (file_flag)
               CLI_FATAL_ERROR = 1;
        }
        else 
            CLI_LOGIN_FLAG = 1;
    }
    
}

void CLIshow_active_data( )
{
     if (strncmp (CLIserver, "nfms_", 5) != 0)
        fprintf (stderr, "SERVER      : <%s>\n", CLIserver);
     else
        fprintf (stderr, "SERVER      : <%s>\n", &CLIserver[5]);
     if (strncmp (CLIenv, "nfme_", 5) != 0)
        fprintf (stderr, "ENVIRONMENT : <%s>\n", CLIenv);
     else
        fprintf (stderr, "ENVIRONMENT : <%s>\n", &CLIenv[5]);
     fprintf (stderr, "USERNAME    : <%s>\n", CLIuser);
     if (strlen(CLIpasswd))
         fprintf(stderr, "PASSWORD    : <Not Printed>\n");
     else
         fprintf(stderr, "PASSWORD    : <>\n");
     fprintf (stderr, "CATALOG     : <%s>\n", CLIcatalog);
     fprintf (stderr, "ITEMNAME    : <%s>\n", CLIitem);
     fprintf (stderr, "REVISION    : <%s>\n", CLIrev);
#ifdef UNIX
     fprintf (stderr, "WORKINGAREA : <%s>\n", CLIstorage);
#else
     if (CLIoverwrite)
        fprintf (stderr, "OVERWRITE   : Y\n");
     else 
        fprintf (stderr, "OVERWRITE   : N\n");
#endif
     fprintf (stderr, "SEARCH_NAME : <%s>\n", CLIsearch);
     fprintf (stderr, "SORT_NAME   : <%s>\n", CLIsort);
     fprintf (stderr, "LIST_ITEM_FILE : <%s>\n", CLIdisplay_file);
     fprintf (stderr, "ADD_ITEM_FILE     : <%s>\n", CLIadd_item_file) ;
     fprintf (stderr, "DEFAULTS_FILE     : <%s>\n", CLIdefaults_file) ;
}

void CLIhelp()
{
	int c;
     fprintf (stderr, "NFM Command Line Interface Keywords\n");
     fprintf (stderr, "      Information : \n");
     fprintf (stderr, "            SERVER               ENVIRONMENT\n");
     fprintf (stderr, "            USERNAME             PASSWORD\n");
     fprintf (stderr, "            ITEMNAME             REVISION\n");
     fprintf (stderr, "            SEARCH_NAME          SORT_NAME\n");
#ifdef UNIX
     fprintf (stderr, "            CATALOG              WORKINGAREA\n");
#else
     fprintf (stderr, "            CATALOG              OVERWRITE\n");
#endif
     fprintf (stderr, "            LIST_ITEM_FILE(lif)  ADD_ITEM_FILE(aif)\n");
     fprintf (stderr, "            DEFAULTS_FILE(df)\n");
     fprintf (stderr, "\n\n Press ENTER/RETURN for more  ...");
     c=getc(stdin);
     fprintf(stderr,"\n\n");
     if ( c=='x' || c== 'X')  return;
     fprintf (stderr, "\n      NFM Commands : \n");
     fprintf (stderr, "            CONNECT              FLAG_ITEM_ARCHIVE(fia)\n");
     fprintf (stderr, "            DISCONNECT           FLAG_ITEM_BACKUP(fib)\n");
     fprintf (stderr, "            LOGIN                FLAG_ITEM_RESTORE(fir)\n");
     fprintf (stderr, "            LOGOUT               FLAG_SET_ARCHIVE(fsa)\n"); 
     fprintf (stderr, "            ADD_ITEM             ADD_CI_ITEM\n");
     fprintf (stderr, "            LIST_ITEMS           LIST_CATALOGS\n");
     fprintf (stderr, "            LIST_STORAGE_AREAS\n");
     fprintf (stderr, "            CHECKIN_ITEM(cii)    FLAG_SET_BACKUP(fsb)\n");
     fprintf (stderr, "            CHECKIN_SET(cis)     FLAG_SET_RESTORE(fsr)\n");
     fprintf (stderr, "            CHECKOUT_ITEM(coi)   CANCEL_ITEM_ARCHIVE(cia)\n");
     fprintf (stderr, "            CHECKOUT_SET(cos)    CANCEL_ITEM_BACKUP(cib)\n");
     fprintf (stderr, "            COPY_ITEM_FILES(cif) CANCEL_ITEM_RESTORE\n");
     fprintf (stderr, "            COPY_SET_FILES(csf)  CANCEL_SET_ARCHIVE\n");
     fprintf (stderr, "            CANCEL_ITEM_CHECKOUT(cico) CANCEL_SET_BACKUP(csb)\n");
     fprintf (stderr, "            CANCEL_SET_CHECKOUT(csco)  CANCEL_SET_RESTORE(csr)\n");
     fprintf (stderr, "       Other : \n");
     fprintf (stderr, "            SHOW                 STOP(QUIT or EXIT)\n");
     fprintf (stderr, "            SAVE\n") ;
     fprintf (stderr, "\n\n Press Enter/Return to Continue ...");
     c=getc(stdin);
     fprintf(stderr,"\n\n");
}









