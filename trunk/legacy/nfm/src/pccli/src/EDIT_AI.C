/******************************************************************************
*   History								      *
*	Date	: 7/28/92						      *
*   	By  	: Melania M Seward					      *
*   	Comments: Add Item to nfmcli                                          *
******************************************************************************/

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

/* #define  CATALOG     4 */
#define  ITEMNAME    5
#define  REVISION    6
#define  DESCRIPTION 7
#define  VERSIONLIMIT     8
#define  ACL          9
#define  LOCALFILE   10
#define  FILETYPE    11
#define  STORAGEAREA 12
#define  INTERNALFILE 13
#define  EXIT        340
#define  QUIT        350
#define  HELP        360
#define  SHOW        370
#define  PROCESS     380

extern char npath[51];

struct add_item_info ADD_ITEM_st ;

static unsigned long curpos ;

#define  NO_ADD_KEYS 18L
static struct entry add_item_commands[NO_ADD_KEYS+1] = 
{   
/*    { "CATALOG", CATALOG }, */
    { "ITEMNAME", ITEMNAME },
    { "REVISION", REVISION },
    { "DESCRIPTION", DESCRIPTION },
    { "VERSIONLIMIT", VERSIONLIMIT },
    { "ACL", ACL },
    { "LOCALFILE", LOCALFILE },
    { "LFILE", LOCALFILE },
    { "FILETYPE", FILETYPE },
    { "TYPE", FILETYPE },
    { "STORAGEAREA", STORAGEAREA },
    { "SA", STORAGEAREA },
    { "INTERNALFILE", INTERNALFILE },
    { "IFILE", INTERNALFILE },
    { "EXIT", EXIT },
    { "QUIT", QUIT },
    { "HELP", HELP },
    { "SHOW", SHOW },
    { "PROCESS", PROCESS }
};

long CLIread_add_item_data( )
{
    long   key_number;
    long  status;
    long  no_words ;

    char  key[21];
    char  key_data[65];
    char  rec[81];
    char  defpath[100];
    char  *fname="CLIread_add_item_data";

    FILE  *fopen();
    FILE  *def_file;   
 
#ifdef UNIX
    strcpy (defpath,"./ai_defaults");
#else
    sprintf(defpath,"%s\\cfg\\ai_def",npath);
#endif

    _CLI_str("CLI DEFAULT FILE <%s>", defpath);
    def_file = fopen(defpath, "r");
        
    if( def_file == NULL )
    {
       _CLI_str("%s : Could not open defaults file", fname);
       return( CLI_E_FAILURE);
    }

    while( fgets( rec, 81, def_file ) != (char*)NULL )
    {
        status = CLIget_key_or_command( rec, key, key_data, &no_words ); 
/* if no data do not overwrite structure except filetype*/

        key_number = CLIlookup_keyword( add_item_commands, key, NO_ADD_KEYS );

	if (! strlen (key_data)) 
	  {
	    if (key_number != FILETYPE)  
	      continue ;
	    else
	      {
		_CLI_str ("this field is allowed to have a null%s", "");
	      }
	  }

        switch( key_number )
        {
/*	    case CATALOG :
	      strcpy( ADD_ITEM_st.catalog, key_data );
	      _CLI_str( "ADD_ITEM_st.catalog <%s>", ADD_ITEM_st.catalog );
	      break;
*/

            case ITEMNAME :
                strcpy( ADD_ITEM_st.item, key_data );
                _CLI_str( "ADD_ITEM_st.item <%s>", ADD_ITEM_st.item );
                break;

            case REVISION :
                strcpy( ADD_ITEM_st.rev, key_data );
                _CLI_str( "ADD_ITEM_st.rev <%s>", ADD_ITEM_st.rev );
                break;

	      case DESCRIPTION :
                strcpy( ADD_ITEM_st.description, key_data );
                _CLI_str( "ADD_ITEM_st.description <%s>", ADD_ITEM_st.description );
                break;

	      case VERSIONLIMIT :
                strcpy( ADD_ITEM_st.version, key_data );
                _CLI_str( "ADD_ITEM_st.version <%s>", ADD_ITEM_st.version );
                break;

	      case ACL :
                strcpy( ADD_ITEM_st.aclname, key_data );
                _CLI_str( "ADD_ITEM_st.aclname <%s>", ADD_ITEM_st.aclname );
                break;

            case LOCALFILE :
                strcpy( ADD_ITEM_st.localfile, key_data );
                _CLI_str( "ADD_ITEM_st.localfile <%s>", ADD_ITEM_st.localfile );
                break;

            case FILETYPE :
                strcpy( ADD_ITEM_st.filetype, key_data );
                _CLI_str( "ADD_ITEM_st.filetype <%s>", ADD_ITEM_st.filetype );
                break;

            case STORAGEAREA :
                strcpy( ADD_ITEM_st.cisaname, key_data );
                _CLI_str( "ADD_ITEM_st.cisaname <%s>", ADD_ITEM_st.cisaname );
                break;

            case INTERNALFILE :
                strcpy( ADD_ITEM_st.cifile, key_data );
                _CLI_str( "ADD_ITEM_st.cifile <%s>", ADD_ITEM_st.cifile );
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


void CLIwrite_add_item_data(filename )
     char *filename ;
{
    char  *fname="CLIwrite_add_item_data";

    FILE  *fopen();
    FILE  *def_file;   
 
    _CLI_str("CLI DEFAULT FILE <%s>", CLIadd_item_file) ;
    if (strlen (filename))
      {
#ifdef UNIX
	sprintf (filename, "./%s", CLIadd_item_file);
#else
	sprintf (filename, "%s\\cfg\\%s", CLIadd_item_file) ;
#endif
	def_file = fopen(filename, "w");
      }
    else
      {
#ifdef UNIX
	def_file = fopen ("./ai_defaults", "w") ;
#else
	def_file = fopen ("%s\\cfg\\ai_def", "w") ;
#endif
      }
        
    if( def_file == NULL )
    {
       _CLI_str("%s : Could not open defaults file", fname);
       return;
    }

/*     fprintf (def_file, "CATALOG     : %s\n", ADD_ITEM_st.catalog); */
     fprintf (def_file, "ITEMNAME    : %s\n", ADD_ITEM_st.item);
     fprintf (def_file, "REVISION    : %s\n", ADD_ITEM_st.rev);
     fprintf (def_file, "DESCRIPTION : %s\n", ADD_ITEM_st.description);
     fprintf (def_file, "VERSIONLIMIT: %s\n", ADD_ITEM_st.version);
     fprintf (def_file, "ACL         : %s\n", ADD_ITEM_st.aclname);
     fprintf (def_file, "LOCALFILE   : %s\n", ADD_ITEM_st.localfile);
     fprintf (def_file, "FILETYPE    : %s\n", ADD_ITEM_st.filetype);
     fprintf (def_file, "STORAGEAREA : %s\n", ADD_ITEM_st.cisaname) ;
     fprintf (def_file, "INTERNALFILE: %s\n", ADD_ITEM_st.cifile) ;

    fclose( def_file );
    return;
}


long CLIedit_add_item( interactive, process )
     long *interactive ; /*  1 - if interactive (not ADD_ITEM_FILE) */
     long *process ;      /* 1 - if PROCESS (not EXIT) */
{
  char *fname = "CLIedit_add_item" ;
  long  cmd_number;
  long  status;
  long  no_words ;
  char  rec[81];
  char  command[65];
  char  data[65];
#ifndef UNIX
  char  *ext_ptr;
#endif
  
  FILE  *fopen();
  FILE  *cmd_file=NULL;   
  long  file_flag, no_add_keys ;
  void CLIshow_add_item_data( ) ;
  void CLIadd_item_help () ;

  _CLI_str ("%s : ENTER", fname) ;
  *interactive = 1 ;
  *process = 0 ;
  file_flag = 0 ;
  if (strlen (CLIadd_item_file))
    {
      cmd_file = fopen( CLIadd_item_file, "r" );
      if( cmd_file == NULL )
	{
	  fprintf( stderr, "CLI_E_Could Not Open Command File <%s>\n",
		  CLIadd_item_file) ;
	  return( CLI_E_FAILURE); 
	}
      else
	{
	  file_flag = 1 ;
	  *interactive = 0 ;
	  fprintf(stderr, "CLI> Executing Command File <%s>\n\n", 
		  CLIadd_item_file);
#ifndef EXPORT
	  fprintf(CLIout_file, "CLI> Executing Command File <%s>\n\n", 
		  CLIadd_item_file) ;
#endif
	  if (curpos > 0)
	    {
	      fseek ( cmd_file, curpos, 0 ) ;
	    }
	}
    }


  if (! file_flag)
    {
      cmd_file = stdin;
    }
  
  fprintf (stderr,"ENTER EDIT MODE FOR ADD ITEM\nADD ITEM> ");
  _CLI_str ("Enter edit mode %s", "") ;
  while( fgets( rec, 81, cmd_file ) != (char*)NULL )
    {
      curpos = curpos + (unsigned long) strlen ( rec ) ;
      strcpy( command, "" );
      strcpy( data, "" );
      status = CLIget_key_or_command( rec, command, data, &no_words ); 
      /* only overwrite existing values */
/*
      no_add_keys = NO_ADD_KEYS ;
      _CLI_num ("no add keys <%ld>", no_add_keys) ;
      _CLI_num ("constant <%ld>", NO_ADD_KEYS) ;
*/
      cmd_number = CLIlookup_keyword( add_item_commands, command, 
				     NO_ADD_KEYS );
      switch( cmd_number )
	{
/*	case CATALOG :
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.catalog, data );
	  fprintf(stderr, "CATALOG: %s\n", ADD_ITEM_st.catalog);  
#ifndef EXPORT
	  fprintf(CLIout_file, "CATALOG: %s\n", ADD_ITEM_st.catalog); 
#endif
	  _CLI_str( "ADD_ITEM_st.catalog <%s>", ADD_ITEM_st.catalog );
	  break;
*/
	  
	case ITEMNAME :
	  if (strlen (data)) 
	    strcpy( ADD_ITEM_st.item, data );
/*	  fprintf(stderr, "ITEMNAME: %s\n", ADD_ITEM_st.item);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "ITEMNAME: %s\n", ADD_ITEM_st.item); 
#endif
	  _CLI_str( "ADD_ITEM_st.item <%s>", ADD_ITEM_st.item );
	  break;
	  
	case REVISION :
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.rev, data );
/*	  fprintf(stderr, "REVISION: %s\n", ADD_ITEM_st.rev);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "REVISION: %s\n", ADD_ITEM_st.rev); 
#endif
	  _CLI_str( "ADD_ITEM_st.rev <%s>", ADD_ITEM_st.rev );
	  break;
	  
	case DESCRIPTION :
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.description, data );
/*	  fprintf(stderr, "DESCRIPTION: %s\n", ADD_ITEM_st.description); */
#ifndef EXPORT
	  fprintf(CLIout_file, "DESCRIPTION: %s\n", ADD_ITEM_st.description);
#endif
	  _CLI_str( "ADD_ITEM_st.description <%s>", ADD_ITEM_st.description );
	  break;
	  
	case VERSIONLIMIT :
	  if (strlen (data)) 
	    strcpy( ADD_ITEM_st.version, data );
/*	  fprintf(stderr, "VERSIONLIMIT: %s\n", ADD_ITEM_st.version);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "VERSIONLIMIT: %s\n", ADD_ITEM_st.version); 
#endif
	  _CLI_str( "ADD_ITEM_st.version <%s>", ADD_ITEM_st.version );
	  break;
	  
	case ACL :
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.aclname, data );
/*	  fprintf(stderr, "ACL: %s\n", ADD_ITEM_st.aclname);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "ACL: %s\n", ADD_ITEM_st.aclname); 
#endif
	  _CLI_str( "ADD_ITEM_st.aclname <%s>", ADD_ITEM_st.aclname );
	  break;
	  
	case LOCALFILE:
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.localfile, data );
/*	  fprintf(stderr, "LOCALFILE: %s\n", ADD_ITEM_st.localfile); */
#ifndef EXPORT
	  fprintf(CLIout_file, "LOCALFILE: %s\n", ADD_ITEM_st.localfile) ;
#endif
	  _CLI_str( "ADD_ITEM_st.localfile <%s>", ADD_ITEM_st.localfile) ;
	  break;
	  
	case FILETYPE :
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.filetype, data );
/*	  fprintf(stderr, "FILETYPE: %s\n", ADD_ITEM_st.filetype);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "FILETYPE: %s\n", ADD_ITEM_st.filetype); 
#endif
	  _CLI_str( "ADD_ITEM_st.filetype <%s>", ADD_ITEM_st.filetype );
	  break;
	  
	case STORAGEAREA :
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.cisaname, data );
/*	  fprintf(stderr, "STORAGEAREA: %s\n", ADD_ITEM_st.cisaname);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "STORAGEAREA: %s\n", ADD_ITEM_st.cisaname); 
#endif
	  _CLI_str( "ADD_ITEM_st.cisaname <%s>", ADD_ITEM_st.cisaname) ;
	  break;
	  
	case INTERNALFILE:
	  if (strlen (data))
	    strcpy( ADD_ITEM_st.cifile, data );
/*	  fprintf(stderr, "INTERNALFILE: %s\n", ADD_ITEM_st.cifile);  */
#ifndef EXPORT
	  fprintf(CLIout_file, "INTERNALFILE: %s\n", ADD_ITEM_st.cifile); 
#endif
	      _CLI_str( "ADD_ITEM_st.cifile <%s>", ADD_ITEM_st.cifile );
	  break;
	  
	case SHOW :
	  CLIshow_add_item_data(); 
	  break;
	  
	case PROCESS :
/*
	  if (file_flag) 
	    {
	      break ; / * ignore in file mode * /
		
	    }
*/
	  *process = 1 ;
/**** ???????
	  if (strlen (CLIadd_item_file))
	    {
	      CLIwrite_add_item_data (CLIadd_item_file) ;
	    }
*****************/
	  if (file_flag) fclose (cmd_file) ;
	  return (CLI_S_SUCCESS) ;
	  
	case HELP :
	  CLIadd_item_help ();
	  break;
	  
	case EXIT :
	  if (file_flag) fclose (  cmd_file ) ;
/**** ???????
	  if (strlen (CLIadd_item_file))
	    {
	      CLIwrite_add_item_data (CLIadd_item_file) ;
	    }
*****************/
	  curpos = 0 ;
	  *process = 0 ;
	  return (CLI_S_SUCCESS);
	  
	case QUIT :
	  if (file_flag) fclose (cmd_file) ;
	  curpos = 0 ;
	  *process = 0 ;
	  return (CLI_E_FAILURE) ;
	  
	  default :
	    fprintf( stderr, "CLI_I_Illegal keyword <%s>.\n", command );
	  curpos = 0 ;
	  break;
	}
      if (! file_flag) fprintf (stderr,"ADD ITEM> ");
    }
  if (file_flag) fclose (  cmd_file ) ;
  return( CLI_S_SUCCESS );
}


void CLIshow_add_item_data( )
{
/*     fprintf (stderr, "CATALOG     : <%s>\n", ADD_ITEM_st.catalog); */
     fprintf (stderr, "ITEMNAME    : <%s>\n", ADD_ITEM_st.item);
     fprintf (stderr, "REVISION    : <%s>\n", ADD_ITEM_st.rev);
     fprintf (stderr, "DESCRIPTION : <%s>\n", ADD_ITEM_st.description);
     fprintf (stderr, "VERSIONLIMIT: <%s>\n", ADD_ITEM_st.version);
     fprintf (stderr, "ACL         : <%s>\n", ADD_ITEM_st.aclname) ;
     fprintf (stderr, "LOCALFILE   : <%s>\n", ADD_ITEM_st.localfile) ;
     fprintf (stderr, "FILETYPE    : <%s>\n", ADD_ITEM_st.filetype) ;
     fprintf (stderr, "STORAGEAREA : <%s>\n", ADD_ITEM_st.cisaname) ;
     fprintf (stderr, "INTERNALFILE: <%s>\n", ADD_ITEM_st.cifile) ;
}

void CLIadd_item_help()
{
     fprintf (stderr, "NFM Add Item Line Interface Keywords\n");
     fprintf (stderr, "      Information : \n");
/*     fprintf (stderr, "            CATALOG              \n") ; */
     fprintf (stderr, "            ITEMNAME             REVISION\n");
     fprintf (stderr, "            DESCRIPTION          VERSIONLIMIT\n");
     fprintf (stderr, "            ACL                  \n");
     fprintf (stderr, "            LOCALFILE(lfile)      FILETYPE(type)\n");
     fprintf (stderr, "            STORAGEAREA(sa)       INTERNALFILE(ifile)\n");

     fprintf (stderr, "       Other : \n");
     fprintf (stderr, "            SHOW                 EXIT\n");
     fprintf (stderr, "            QUIT                 PROCESS\n");
}


long CLIreset_add_item_st ()
{
  char *fname = "CLIreset_add_item_st" ;

  _CLI_str ("%s : ENTER\n", fname) ;
/* use memset */
/*  ADD_ITEM_st.catalog [0] = 0 ; */
  ADD_ITEM_st.item [0] = 0 ;
  ADD_ITEM_st.rev [0] = 0 ;
  ADD_ITEM_st.description [0] = 0 ;
  ADD_ITEM_st.version [0] = 0 ;
  ADD_ITEM_st.aclname [0] = 0 ;
  ADD_ITEM_st.localfile [0] = 0 ;
  ADD_ITEM_st.filetype [0] = 0 ;
  ADD_ITEM_st.cisaname [0] = 0 ;
  ADD_ITEM_st.cifile [0] = 0 ;

  _CLI_str ("%s : SUCCESSFUL\n", fname) ;
  return (CLI_S_SUCCESS) ;
}

long CLIedit_ai_mode ( interactive, process, process_mode )
     long *interactive;     /* 1 - if data was not from ADD_ITEM_FILE */
     long *process ;        /* 1 - (if while interactive) process keyword */
     long process_mode ;   /* 1 - currently in continuous mode */
{
  char *fname = "CLIedit_ai_mode" ;
  long status ;

/*** if not in process mode ***/
  if (! process_mode)
    {
      curpos = 0 ;
      /* get ai_defaults if they exist */
      _CLI_str ("Get ai_defaults if file exist..%s", "") ;
      CLIread_add_item_data( ) ;
    }      
  
  _CLI_str ("Get Data from Add_Item_File or interactive %s", "") ;
  status = CLIedit_add_item( interactive, process ) ;
  /* if Add_item_file was specified -> do not allow interaction */
  if (status != CLI_S_SUCCESS)
    {
      /* quit */
      return (CLI_E_FAILURE) ;
    }

  return (CLI_S_SUCCESS) ;
}


