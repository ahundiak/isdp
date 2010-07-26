/* ---------------------  define_states  -----------------------------*/
#include "../sli/y.tab.h"
#include <sli.h>
#include <ode_export.h>

define_states ()
{
  int	  i = 1;
  char	  string [180];
  char	  found_start = 0;

  _verbose(if(do_debug)fprintf(stderr,"define_states\n");)
  if ( ! state_name_sp )
    state_name_sp = (symbol *) find_type ( _sli_state_name );
  _COB_for_list ( spp, list, top_syms, symbol )
    if ( spp->type == STATE )
      {
        if ( spp->offset == 0 )
          {
            if ( ! start_sp )
              {
                start_sp = spp;
                found_start = 1;
              }
            else if ( strcmp ( spp->name, start_sp->name ))
              spp->offset = i ++ ;
            else found_start = 1;
          }
        else
          { if ( start_sp && ! strcmp ( spp->name, start_sp->name )) found_start = 1;
            if ( spp->offset == _previous_state ) prev_sp = spp;
          }
        if ( spp->offset >= 0 && state_name_sp )
          {
            sprintf ( string, state_name_sp->strs->str, spp->name );
            if ( do_debug )
              fprintf ( stderr, "define state %s %d as %s\n",
                  spp->name, spp->offset, string );
            if ( outf ) fprintf ( outf, "#define %s %d\n", string, spp->offset);
            if ( tblf ) fprintf ( tblf, "#define %s %d\n", string, spp->offset);
          }
      }
  _COB_end_for_list /* ( spp ) */
  if ( ! found_start )
    yyerror ( (char *) find_msg ( "msg_undef_start" ));
} /* define_states */
