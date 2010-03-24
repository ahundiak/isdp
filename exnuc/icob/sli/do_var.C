/* ---------------------  sli_do_var  --------------------------------*/
#include <ode_export.h>
#include <sli.h>

sli_do_var ( act, arg )
  char		* act;
  char		* arg;
{
  action_rec	* act_ptr;
  symbol	* act_sp;
  symbol	* sp;
  int		  type = 0;
  char		  string [_max_data_union_str + 100 ];
  char		  orig_act[_max_data_union_str];
  symbol	* lookup ();
  char		* find_msg ();
  char		  is_prompt = 0;
  extern   char * calloc( );

  push_stack ( sym_stack, cur_syms );
  cur_syms = & var_words;
  act_sp = lookup ( act, 0 );
  if ( act_sp )
    {
      strcpy ( orig_act, act );  /* save it, in case arg is too long */
      act = act_sp->args;
    }
  else
    {
      sprintf ( string, find_msg ( "msg_unk_word" ), act );
      yyerror ( string );
    }
  if ( ! strcmp ( act, "_execute" ))
    {
      act = arg;
      arg = NULL;
      type = 1;
    }
  else
    {
      sp = lookup ( arg, 0 );
      if ( sp ) arg = sp->args;

/* 7-23-87 -- "do prompt" and "do prompt_key" => output do_prompt act */
      if ( stack_depth ( act_stack ) )
        {
          if ( ! strcmp ( act, "_prompt" ) ) is_prompt = 1;
          else if ( ! strcmp ( act, "_prompt_key" ) ) is_prompt = 1;
        }
    }
  if ( arg && * arg == '"' )
    if ( act_sp->offset )	/** if the arg doesn't need quotes **/
      {
	strcpy ( arg, strip_quotes ( arg ));
      }
    else /** check to make sure the string supplied isn't too long **/
      {	 /**   for COB's run-time buffers			   **/
        if ( !strcmp ( act, "_prompt" ) || !strcmp ( act, "_status") || 
	     !strcmp ( act, "_msg" ) )
	  {
	      if ( strlen(arg) >= _max_key )
		{
		  sprintf ( string, find_msg ( "msg_long_str" ),
				orig_act, arg, _max_key - 3  );
			/* - 3 for 2 "'s and the '\0' character */
		  yyerror ( string );
		}
	  }
	else
	  {
	      if ( strlen(arg) >= _max_data_union_str )
		{
		  sprintf ( string, find_msg ( "msg_long_str" ),
				orig_act, arg, _max_data_union_str - 3);
			/* - 3 for 2 "'s and the '\0' character */
		  yyerror ( string );
		}
	  }
      }

  cur_syms = (symbol **) pop_stack ( sym_stack );
  act_ptr = (action_rec *) calloc ( 1, sizeof ( action_rec ));
  if ( ! act_ptr )
    {
      fprintf(stderr,
	"slic: sli_do_var() -- No dynamic memory available 1\n\n");
      exit(1);
    }
  act_ptr->act = _sli_do_act;
  act_ptr->type = type;
  act_ptr->str = act;
  act_ptr->args = arg;
  _COB_append_to_list ( act_ptr, list, * cur_act_list );

/* 7-23-87 -- output do_prompt act if do_prompt or do_prompt_key */
  if ( is_prompt )
    {
      act_ptr = (action_rec *) calloc ( 1, sizeof ( action_rec ));
      if ( ! act_ptr )
        {
          fprintf(stderr,
	    "slic: sli_do_var() -- No dynamic memory available 2\n\n");
          exit(1);
        }
      act_ptr->act = _sli_do_act;
      act_ptr->type = 0;
      act_ptr->str = "_do_prompt";
      /*** act_ptr->args = NULL;  BAD- this causes "luther" in .T ***/
      /*** act_ptr->args = "";  WORSE- this causes core dump for  ***/
			   /*** CEO_LOCATE subclasses at runtime  ***/
      act_ptr->args = "0";			/*** JAJ:08-17-88 ***/
      _COB_append_to_list ( act_ptr, list, * cur_act_list );
    }
}
