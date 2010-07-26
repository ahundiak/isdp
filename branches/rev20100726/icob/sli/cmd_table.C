/** sli/cmd_table.C --  JAJ:08-29-87  **/

/****	Makes a command_table entry (in some directory)		****/
/****   for the .sl file command_string and each synonym	****/

#include <sli.h>
#include "../sli/y.tab.h"


static insert_cmd_string();

make_cmd_table()
{

  symbol    * sp = 0;
  char	      cmd_string[256];		/** WITH quotes **/
  char	      cmd_table_name[256];	/** complete path/file name  **/
					/**   of cmd_table file	     **/
  char	      file_name[256];		/** file name only of cmd tbl**/
  char	    * tmp_cmd_table_name;	/** unique name for temporary */
					/**   cmd table name 	     **/


/********** Don't touch "cmd_tbl_list" file anymore -- JAJ:08/06/91 ***/
/*  char   cmd_tbl_list[132];      / ** path/filename of cmd_tbl_list**/
/*  char   found_cmd_tbl_list_entry;                                 **/
/*  char   cmd_tbl_list_entry[132];    / ** holds names read in from **/
/*				       / **  cmd_tbl_list file	     **/
/**********************************************************************/


  char	      temp_string[512];	  /**",cmd key, cmd class [, mytype]"**/
  char	    * ch;
  int	      status = 0;	/**  0   ==> some error occurred     **/
  				/**  1   ==> inserted all entries ok **/
  short	      jj;		/**  0   ==> entry for command string**/
  				/** > 0  ==> entry for synonyms	     **/
  extern char * strrchr();
  extern symbol * find_type (), * lookup ();
  extern char * tempnam();
  

	/**************************************************/
	/*** First, get a temporary filename for the 	***/
	/*** command_table file, that's guaranteed to	***/
	/*** be unique, so another user running slic	***/
	/*** and updating command tables on the same	***/
	/*** machine at the same time won't collide	***/

	/*** in the same temporary command_table file.	***/

	/*****************************  JAJ:08/06/91  *****/
/*
#ifdef NT
    status = GetTempFileName ("c:\temp","TMPCT",0,&tmp_cmd_table_name);
#else
  tmp_cmd_table_name = tempnam ( "/tmp", "TMPCT" );
#endif
*/
   tmp_cmd_table_name = tempnam ("/tmp","TMPCT");
/**********************************************************************/
/********** Don't touch "cmd_tbl_list" file anymore -- JAJ:08/06/91 ***/
/**********************************************************************

	/ *** figure out the pathname to the cmd_tbl_list  *** /
  make_file_name ( cmd_tbl_list, ".T" );

	/ ***-------------------------------------------------*** /
	/ *** FOR NOW, ASSUME THE cmd_tbl_list FILE IS ONE    *** /
	/ ***	DIRECTORY UP FROM THE ".T" FILE		      *** /
	/ ***-------------------------------------------------*** /
#ifndef NT
  ch = strrchr ( cmd_tbl_list, '/' );
#else
  ch = strrchr (cmd_tbl_list, '\\');
#endif
  if ( ch == NULL )
    {
      fprintf ( stderr,
		"\nSlic: Couldn't find cmd_tbl_list file.\n\n" );
      goto quit;
    }
  * ch = '\0';
#ifndef NT
  ch = strrchr ( cmd_tbl_list, '/' );
#else
  ch = strrchr (cmd_tbl_list, '\\');
#endif
  if ( ch == NULL )
    {
      fprintf ( stderr,
	"\nSlic: couldn't find cmd_tbl_list file.\n\n" );
      goto quit;
    }
  * ch = '\0';
#ifndef NT
  strcat ( cmd_tbl_list, "/cmd_tbl_list" );
#else
  strcat (cmd_tbl_list, "\\cmd_tbl_list");
#endif
**********************************************************************/


	/*** determine the file name of the command_table file ***/
  if ( command_table_sp )
    {
      strcpy ( file_name, expand_shell_vars ( strip_quotes
				    ( command_table_sp->name )));
    }
  else
    {
      strcpy ( file_name, "command_table" );
    }

  cmd_table_name[0]='\0';

  /*** if the command_table path wasn't hardcoded, figure out	***/
  /***   the path to the config directory			***/
#ifndef NT
  if ( file_name[0] != '/' )
#else
  if (file_name[0] != '\\')
#endif
    {
	/*** figure out the pathname to the command_table  ***/
      make_file_name ( cmd_table_name, ".T" );

	/***-------------------------------------------------***/
	/*** FOR NOW, ASSUME THE command_table IS ONE 	     ***/
	/***	DIRECTORY UP FROM THE ".T" FILE		     ***/
	/***-------------------------------------------------***/
#ifndef NT
      ch = strrchr ( cmd_table_name, '/' );
#else
      ch = strrchr (cmd_table_name,'\\');
#endif
      if ( ch == NULL )
        {	/*** error ***/
          fprintf ( stderr, "\nSlic: Couldn't find command_table.\n" );
          goto quit;
        }
      * ch = '\0';
#ifndef NT
      ch = strrchr ( cmd_table_name, '/' );
#else
      ch = strchr (cmd_table_name,'\\');
#endif
      if ( ch == NULL )
        {	/*** error ***/
          fprintf ( stderr, "\nSlic: couldn't find command_table.\n" );
          goto quit;
        }
      * (ch+1) = '\0';
    }

  strcat ( cmd_table_name, file_name );


	/**********************************************************/
	/*** Compose a command_table entry for the command 	***/
	/*** string and one for each synonym			***/
	/**********************************************************/

for ( jj = 0 ; ; jj++ )
  {
  if ( jj == 0 )
    {
      sp = find_type ( _cmd_string_word );
      if ( ! sp )
	{	/*** error ***/
	  fprintf ( stderr, "\nSlic: couldn't find command_string.\n" );
	  goto quit;
	}
    }
  else
    {
      if ( jj == 1 )
	{
	  sp = top_syms;
	  if ( sp == NULL )
	    {
		break;
	    }
	}
      else
	{
	  sp = sp->list.next;
	  if ( sp == top_syms )
	    {
		break;
	    }
	}

      if ( sp->type != _synonym_word )
	{
	  continue;
	}
    }

  strcpy ( cmd_string, sp->name ); /*** leave the quotes ON ***/

  /**** add on the command key **********************************/
  strcpy ( temp_string, "," );
  strcat ( temp_string, sp->strs->list.next->str );

  /**** add on the command class ****/
  strcat ( temp_string, "," );
  strcat ( temp_string, class_sp->name );

  /**** add on the command type (if any) ****/
  if ( sp->strs->str[0] )
    {
      strcat ( temp_string, "," );
      strcat ( temp_string, sp->strs->str ); /** command type **/
    }
  

  status = insert_cmd_string ( cmd_table_name, cmd_string, temp_string,
				tmp_cmd_table_name );
  if ( status != 1 )
    {
      goto quit;
    }

 } /** for loop **/


/**********************************************************************/
/********** Don't touch "cmd_tbl_list" file anymore -- JAJ:08/06/91 ***/
/**********************************************************************

	/ ********************************************************** /
	/ *** see if the command_table name specified is in	 *** /
	/ ***   the cmd_tbl_list file; if not, append it therein *** /
	/ ********************************************************** /

  if ( NULL == ( fp = fopen ( cmd_tbl_list, "r" ) ) )
    {
	 / *** the cmd_tbl_list file isn't there, make one and put *** /
	 / ***   the name of the command_table in it		   *** /
        append_to_cmd_tbl_list ( cmd_tbl_list, file_name );
    }
  else
    {
      if ( do_debug )
	{
          fprintf(stderr, "\nSearching %s for '%s' entry...\n",
					cmd_tbl_list, file_name );
	}
      for ( found_cmd_tbl_list_entry = 0 ; ; )
	{
	  if ( EOF == fscanf ( fp, "%s", cmd_tbl_list_entry )) 
	      break;
	  else if ( ! strcmp ( cmd_tbl_list_entry, file_name ) )
	    {
	      if ( do_debug )
		{
		  fprintf ( stderr,
			"  Found '%s' in cmd_tbl_list file.\n",
			file_name );
		}
	      found_cmd_tbl_list_entry = 1;
	      break;
	    }
	}
      fclose ( fp );
      if ( ! found_cmd_tbl_list_entry )
        append_to_cmd_tbl_list ( cmd_tbl_list, file_name );
    }
**********************************************************************/


quit:
  return ( status );

} /* make_cmd_table() */



/*====================================================================*/
static insert_cmd_string ( cmd_table_name, cmd_string, temp_string,
			   tmp_cmd_table_name )
  char * cmd_table_name;
  char * cmd_string;
  char * temp_string;
  char * tmp_cmd_table_name;
{
  FILE	* fp;
  char	  system_cmd[512];
  short	  status = 1;


	/********************************************************/
	/*** Check to see if the command_table already exists ***/
	/********************************************************/

  if ( NULL != ( fp = fopen ( cmd_table_name, "a" ) ) )
    {
      if (fp != NULL) fclose ( fp );

	/******************************************/
	/*** Delete the existing entry (if any)	***/
	/*** in the command_table.		***/
	/******************************************/
#ifndef NT
      sprintf ( system_cmd, "sed -e '/^%s,/d' %s > %s ; mv %s %s ",
		cmd_string, cmd_table_name, tmp_cmd_table_name,
	tmp_cmd_table_name, cmd_table_name );
#else
sprintf ( system_cmd, "sed -e '/^%s,/d' %s > %s ; rename %s %s ",
		cmd_string, cmd_table_name, tmp_cmd_table_name,
	tmp_cmd_table_name, cmd_table_name );
#endif
      if ( do_debug )
	{
          printf("\n%s\n", system_cmd );
	}

      status = system ( system_cmd );
      if ( status )	/* system calls return 0 on success */
	{
          fprintf(stderr,
		"\nSlic:  Couldn't do system command '%s'.\n\n",
		system_cmd );
	  status = 0;
	  goto quit;
	}
      else
	{
	  status = 1;
	}
    }
  else
    {
      if ( NULL != ( fp = fopen ( cmd_table_name, "r" ) ) )
	{
	  /*** slic doesn't have write privs on the command_table ***/
	  fclose ( fp );
	  fprintf(stderr,
		"\nSlic:  Couldn't open '%s' for writing.\n\n",
		cmd_table_name );
	}
      else
	{
	  fprintf(stderr,
		"\nSlic:  Couldn't open '%s'.\n\n", cmd_table_name);
	}
      goto quit;
    }

  /***   append the new entry onto the end of the command_table	    ***/
  /***   (first, make a temporary file with the new lines (along    ***/
  /***    with any #defines (that's why you need to run cpp)))      ***/
  if ( NULL == ( fp = fopen ( tmp_cmd_table_name, "w" ) ) )
    {
      fprintf ( stderr,
	"\nSlic:  Couldn't open temporary file '%s'.\n\n",
	tmp_cmd_table_name );
      status = 0;
      goto quit;
    }

  if ( dot_t_sp )
    {
      copy_lines ( fp, dot_t_sp, STATE_TABLE );
    }

  if ( do_debug )
    {
      printf ( "\nAppending '%s%s' to '%s'\n",
		cmd_string, temp_string, cmd_table_name );
    }

  fprintf ( fp, "XxXxXx\nCOB_CMD_TABLE_STARTS_HERE\n",
					cmd_string, temp_string );
  fprintf ( fp, "%s%s\n", cmd_string, temp_string );
  fclose ( fp );

  /*** run cpp and then run sed to get rid of the @#$%!!! blank ***/
  /***	lines that cpp inserts at the beginning of the file 	***/
  /***  strcpy ( system_cmd,
    "/lib/cpp -P -I$PWD $COBCPPOPT /tmp/command_table | sed -n '/^[a-zA-Z0-9_\"]/p' >> ");
  **************  use omcpp instead -- JAJ:03-21-88 *******************/
  /****** Modified to use EXTARG rather thant EXNUC -- scw 06-04-97 ***/
#ifndef NT
  sprintf ( system_cmd,
	"$EXTARG/bin/omcpp -l -I$PWD $COBCPPOPT < %s | sed '1,/COB_CMD_TABLE_STARTS_HERE/d' | sed 's/^[ 	]*//g' | sed 's/[ 	]*,/,/g' | sed 's/,[ 	]*/,/g' >> %s",
	tmp_cmd_table_name, cmd_table_name );
#else
sprintf ( system_cmd,
	"$EXTARG\\bin\\omcpp -l -I$PWD $COBCPPOPT < %s | sed '1,/COB_CMD_TABLE_STARTS_HERE/d' | sed 's/^[ 	]*//g' | sed 's/[ 	]*,/,/g' | sed 's/,[ 	]*/,/g' >> %s",
	tmp_cmd_table_name, cmd_table_name );
#endif
  if ( do_debug )
    {
      printf ( "\n%s\n", system_cmd );
    }

  status = system ( system_cmd );
  if ( status )	/* system calls return 0 on success */
    {
      fprintf ( stderr,"\nSlic:  Couldn't do system command '%s'.\n\n",
	system_cmd );
      status = 0;
      /* goto quit;  DON'T need this here */
    }
  else
    {
      status = 1;	/* everything is fine */
    }

quit:
  return status;

} /** insert_cmd_string () **/



/**********************************************************************/
/********** Don't touch "cmd_tbl_list" file anymore -- JAJ:08/06/91 ***/
/**********************************************************************
static append_to_cmd_tbl_list ( cmd_tbl_list, command_table_name )
  char * cmd_tbl_list;
  char * command_table_name;
{
  char system_cmd[300];
  int  status;

  sprintf ( system_cmd, "echo \"%s\" >> %s",
			command_table_name, cmd_tbl_list );

  if ( do_debug )
    printf("\n%s\n", system_cmd);
  status = system ( system_cmd );
  if ( status != 0 )	/ * system calls return 0 on success * /
    {
      fprintf(stderr,"\nSlic:  Couldn't do system command '%s'.\n\n",
	system_cmd );
    }
}
**********************************************************************/
