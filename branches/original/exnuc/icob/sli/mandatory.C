/* --------------------   mandatory   (JAJ:09-04-87) -----------------*/
/**   This file checks to make sure that all parameters in the .sl  **/
/**  file that are mandatory for producing the .S,.I, and .T files  **/
/**  and the command_table are present.  It also defaults parameters */
/**  that are optional in the .sl file but which slic needs to run  **/
/**  with.							    **/
/**								    **/
/**	Notice that errors is the global counter to indicate if any **/
/**  errors occurred, so that all the error messages are output	    **/
/**  instead of just returning after the first one encountered.	    **/
/**								    **/
/**  return codes:	>0 -	failure of some kind, so terminate  **/
/**  			0 -	success				    **/

#include <sli.h>
extern symbol	* find_type ();
extern char	* find_msg ();
extern char	* strrchr();

sli_mandatory ( )
{
  symbol	* sp;

  if ( do_dott )
    {
	/** if the cmd_string wasn't given, then quit **/
      sp  = find_type ( _cmd_string_word );

      if ( ! sp )
	{
	  fprintf ( stderr, "%s\n", find_msg("msg_no_cmd" ) );
	  errors ++;
	}
      else
	errors += check_cmd_syn( sp );

	/** check that all synonyms have a key **/
      _COB_for_list ( spp, list, top_syms, symbol )
	if ( spp->type == _synonym_word )
	  {
	    errors += check_cmd_syn( spp );
	  }
      _COB_end_for_list /* ( spp ) */

	/** check for "product_name" **/
      sp = find_type ( _product_name_word );
      if ( ! sp )
	{
	  fprintf ( stderr, "%s\n", find_msg("msg_prod_name") );
	  errors ++;
	}
    }


  /** if the "class" was not specified, quit **/
  sp = find_type ( _class_word );
  if ( ! sp )
    {
      fprintf ( stderr, "%s\n", find_msg("msg_no_class" ) );
      errors ++;
    }

  return(errors);

} /* sli_mandatory */


/*********************************************************************/
int  check_cmd_syn( sp )
  symbol * sp;
{
  char	  default_key_name[20];
  int found = 0;
  int not_okay = 0;
  char * ch;

  /** if the name is of the form "string", then issue an attention **/
  if ( sp->name[0] == '"'  &&  do_debug /*** JAJ:04-04-88 ***/ )
    {
      if ( sp->type == _cmd_string_word )
	{
	  fprintf ( stderr, find_msg( "msg_cmd_use_msg" ), sp->name );
	}
      else /** it's a synonym **/
	{
	  fprintf ( stderr, find_msg( "msg_syn_use_msg" ), sp->name );
	}
      putc ( '\n', stderr );
    }

  /** if the "key" was not specified, use the name  **/
  /**   of the .sl file w/o the extension.	    **/
  /** "key" is the second modifier string given for **/
  /**   the cmd_string/synonym.			    **/
  if ( sp->strs )		/** NULL => no modifier **/
    if ( sp->strs != sp->strs->list.next )	/** => >1 modifier **/
	found = 1;

  if ( ! found )
    {
      cur_sym = sp;
      if ( ! sp->strs ) sli_modifier ("");

      strcpy ( default_key_name, file_name );

      ch = strrchr ( default_key_name, '.' );
      if ( ch && *ch )  /** get rid of .sl extension, if any **/
        * ch = '\0';

      if ( sp->type == _cmd_string_word )
	{
          if ( do_print )	/*** JAJ:04-04-88 ***/
	    {
              fprintf ( stderr, find_msg("msg_def_cmd_key"),
						    default_key_name );
              putc ( '\n', stderr );
	    }
	}
      else
	{ /*** tag on the type to the default synonym key filename **/
	  strcat ( default_key_name, sp->strs->str );

          if ( do_print )	/*** JAJ:04-04-88 ***/
	    {
              fprintf ( stderr, find_msg("msg_def_syn_key"),
						    default_key_name );
              putc ( '\n', stderr );
	    }
	}

	/** insert the missing args into the record **/
      sli_modifier ( default_key_name );
    }

  if ( found  ||  ! found && sp->type == _cmd_string_word )
    {
      /** check to see if filename is > 10 chars **/
      if ( strlen ( sp->strs->list.next->str ) > 10 )
        {
          int index; /* to avoid subscript out of range warning */
          sp->strs->list.next->str[index=10] = '\0';
          fprintf ( stderr, find_msg("msg_trunc"), ".T",
		sp->strs->list.next->str, 10 );
          putc ( '\n', stderr );
        }
      /** check to see if filename is null **/
      else if ( ! sp->strs->list.next->str[0] )
        {
	  if ( sp->type == _cmd_string_word )
	    {
              fprintf ( stderr, find_msg( "msg_inv_cmd_key" ),
			"", sp->name );
	    }
	  else /** it's a synonym **/
	    {
              fprintf ( stderr, find_msg( "msg_inv_syn_key" ),
		"", sp->name );
	    }
          putc ( '\n', stderr );
          not_okay++;
        }
    }

  return ( not_okay );
}	/** check_cmd_syn **/
