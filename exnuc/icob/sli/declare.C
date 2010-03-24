/*-----------------  sli_declare  ------------------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>


sli_declare ( str, type )
  char	* str;
  int	  type;
{

  list_rec	* lp;
  char		  decl_it = 1;
  extern   char * calloc( );

  clear_stack ( sym_stack );
  clear_stack ( act_stack );
  switch ( type )
    {
      case ACTION:
        cur_syms = & class_sp->actions;
        strcpy ( str, strip_quotes ( str ));
        break;
      case _options_word:
        decl_it = 0;
        cur_sym = NULL;
        options ( strip_quotes ( str ), NULL );
        break;
      default:
        cur_syms = & top_syms;
        break;
    }
  if ( decl_it )
    cur_sym = (symbol *) insert_sym ( str, type, 1, "duplicate symbol");
  switch ( type )
    {
      case SPECIFICATION:
        dot_s_sp = cur_sym;
        break;
      case IMPLEMENTATION:
        dot_i_sp = cur_sym;
        break;
      case STATE_TABLE:
        dot_t_sp = cur_sym;
        break;
      case STATE:
        strcpy ( cur_sym->name, strip_quotes ( str ));
        cur_act_list = & cur_sym->acts;
        if ( ! strcmp ( cur_sym->name, "all states" ))
          {
            cur_sym->offset = -990;
            all_sp = cur_sym;
          }
        else if ( ! strcmp ( cur_sym->name, "at init" ))
		cur_sym->offset = -991;
        else if ( ! strcmp ( cur_sym->name, "at wakeup"))
		cur_sym->offset = -992;
        else if ( ! strcmp ( cur_sym->name, "at sleep" ))
		cur_sym->offset = -993;
        else if ( ! strcmp ( cur_sym->name, "at delete" ))
		cur_sym->offset = -994;
        else if ( ! strcmp ( cur_sym->name, "at error" ))
		cur_sym->offset = -995;
        break;
      case ACTION:
        strcpy ( cur_sym->name, strip_quotes ( str ));
        cur_sym->owner = class_sp;
        cur_syms = & top_syms;
        break;
      case _super_word:
        super_sp = cur_sym;
        strcpy ( cur_sym->name, strip_quotes ( str ));
        if ( class_sp )
          {

            lp = (list_rec *) calloc ( 1, sizeof ( list_rec ));
	    if ( ! lp )
	      {
		fprintf(stderr,
		  "slic: sli_declare() -- No dynamic memory available 1\n\n");
		exit(1);
	      }
            lp->val = (char *) cur_sym;
            _COB_insert_head_ansi ( lp, list, (list_rec *) class_sp->owner, 
             class_sp->owner, (struct symbol *));
          }
        break;
      case _class_word:
        class_sp = cur_sym;
        strcpy ( cur_sym->name, strip_quotes ( str ));
        if ( super_sp )
          _COB_for_list ( spp, list, top_syms, symbol )
            if ( spp->type == _super_word )
              {

                lp = (list_rec *) calloc ( 1, sizeof ( list_rec ));
	        if ( ! lp )
	          {
		    fprintf(stderr,
			"slic: sli_declare() -- No dynamic memory available 2\n\n");
		    exit(1);
	          }
                lp->val = (char *) spp;
                _COB_insert_head_ansi ( lp, list, (list_rec *) class_sp->owner,
                 class_sp->owner, (struct symbol *));
              }
          _COB_end_for_list
        break;
      case _version_word:
        strcpy ( cur_sym->name, strip_quotes ( str ));
        break;
/****
      case _construct_word:
        strcpy ( cur_sym->name, strip_quotes ( str ));
        break;
****/
      case _start_word:
        start_sp = cur_sym;
        strcpy ( cur_sym->name, strip_quotes ( str ));
        break;
      case _path_word:
        path_sp = cur_sym;
        break;
      case _spath_word:
        spath_sp = cur_sym;
        break;
      case _ipath_word:
        ipath_sp = cur_sym;
        break;
      case _command_table_word:
        command_table_sp = cur_sym;
        break;
    }
}
