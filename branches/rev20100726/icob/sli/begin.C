/* -------------------------sli_begin----------------------------------------*/
#include <sli.h>

extern  FILE	*  yyin;

sli_begin ()
{
  if ( cur_sym )
    {
      cur_sym->begin = ftell ( yyin ) - 1;
/****   THIS IS TOO DARN VERBOSE  !!!! ***********
      _verbose(if(do_debug)
          fprintf(stderr,"begin %d\n",cur_sym->begin);)
*/
    }
}
