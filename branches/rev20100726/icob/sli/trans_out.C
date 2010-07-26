/* -----------------------  trans_out  -------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>

trans_out ( response_ptr )
  action_rec	* response_ptr;
{
  action_rec	* next_st_ptr;
  symbol	* nsp;
  char		* sub_str;
  char		  string [80];
  char		* find_msg ();

  _verbose(if(do_debug)
      fprintf(stderr,"trans_out %s\n",response_ptr->str);)
  next_st_ptr = NULL;

  sub_str = NULL;
  if ( response_ptr->list.prev->act == _sli_sub_response )
      sub_str = response_ptr->list.prev->str;

  if ( response_ptr->list.next->act == _sli_next )
      next_st_ptr = response_ptr->list.next;

  if ( next_st_ptr )
    {
      if ( ! strcmp ( next_st_ptr->str, "." )) nsp = cur_sym;
      else if ( ! strcmp ( next_st_ptr->str, "-" )) nsp = prev_sp;
      else nsp = (symbol *) lookup ( next_st_ptr->str, STATE );
      if ( nsp )
        {
          if ( ! sub_str ) sub_str = "";
          _verbose(if(do_debug)
              fprintf(stderr,"%s trans %s.%s to %s\n",cur_sym->name,
                  response_ptr->str,sub_str,nsp->name);)
          sprintf ( string, state_name_sp->strs->str, nsp->name );

          /*fprintf ( tblf, "%st(%s,%s,%s,%d)\n", level,  */
          /*  response_ptr->str, sub_str, string, response_ptr->type);*/

          fprintf ( tblf, "%st(%s,%s,%d,%s", level,
              string, response_ptr->str, response_ptr->type, sub_str);

	  _COB_for_list( t_or_ptr, list, response_ptr->trans_or_list,\
							 action_rec )

	    if ( t_or_ptr->act == _sli_response )
	      {
	        if ( t_or_ptr->list.prev->act == _sli_sub_response )
		    sub_str = t_or_ptr->list.prev->str;
	        else
		    sub_str = "";

                fprintf ( tblf, ",%s,%d,%s",
		    t_or_ptr->str, t_or_ptr->type, sub_str);
	      }

	  _COB_end_for_list /* ( t_or_ptr ) */

          fprintf ( tblf, ")\n" );
        }
      else
        {
          sprintf ( string, find_msg ( "msg_undef_state" ), next_st_ptr->str );
          yyerror ( string );
        }
      if ( response_ptr->owner )
        {
          fprintf ( tblf, "%s  {\n", level );
          strcat ( level, "    " );
          _COB_for_list (act_ptr, list, response_ptr->owner, action_rec)
            if ( act_ptr->act == _sli_response ) trans_out ( act_ptr );
            else act_out ( act_ptr );
          _COB_end_for_list /* ( act_ptr ) */
          level [ strlen ( level ) - 4 ] = NULL;
          fprintf ( tblf, "%s  }\n", level );
        }
    }
} /* trans_out */
