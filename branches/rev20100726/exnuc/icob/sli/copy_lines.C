/* -------------------------copy_lines-----------------------------------*/
#include <sli.h>

void copy_lines ( fyl, sym, which_copy )
  FILE		* fyl;
  symbol	* sym;
  int		  which_copy;
{
  int		  count;
  symbol	* sp;
  char		  ch;
  char		  first = 1;
  char		  not_eol;
  symbol	* find_type ();
  extern FILE	* yyin;

  if ( ! fyl ) goto quit;
  count = fseek ( yyin, sym->begin, 0 );
  if ( count )
    {
      fprintf ( stderr, "seek error %s %d\n", sym->name, sym->begin );
      goto quit;
    }
  _verbose(if(do_debug)
    fprintf(stderr,"copy %s [%d, %d]\n",sym->name,sym->begin,sym->end);)
  count = sym->begin;
  do
    {
      ch = getc ( yyin );
      ++ count;
      if ( which_copy == _sli_instance_data )
        {
          putc ( ch, fyl );
          if ( count >= sym->end ) fputs ( ";\n", fyl );
        }
      else if ( which_copy != _sli_methods )
        {
          putc ( ch, fyl );
        }
      else
        {
          if ( first )
            {
              first = 0;
              do
                {
                  putc ( ch, fyl );
                  not_eol = ch != '\n';
                  ch = getc ( yyin );
                  ++ count;
                }
              while ( isspace ( ch ) && not_eol );
              sp = find_type ( _sli_method_top );
              if ( sp ) put_strs ( sp->strs, fyl );
            }
          if ( count >= sym->end )
            {
              sp = find_type ( _sli_method_bottom );
              if ( sp ) put_strs ( sp->strs, fyl );
            }
          putc ( ch, fyl );
          if ( count >= sym->end ) putc ( '\n', fyl );
        }
    }
  while ( count < sym->end );
  _verbose(if(do_debug)
    fprintf(stderr,"copy %s count %d ch \'%c\'\n",sym->name,count,ch);)
quit:
  return;
} /* copy_lines */
