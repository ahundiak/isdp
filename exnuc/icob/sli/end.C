/* -------------------------sli_end----------------------------------------*/
#include <sli.h>

extern  FILE	*  yyin;

sli_end ()
{
  if ( cur_sym )
    {
      cur_sym->end = ftell ( yyin );
/****   THIS IS TOO DARN VERBOSE  !!!! ***********
      _verbose(if(do_debug)fprintf(stderr,"end %d\n",cur_sym->end);)
*/
    }
}
