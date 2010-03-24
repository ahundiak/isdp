/* -------------------------sli_put----------------------------------------*/
#include <sli.h>

void sli_put ( chr )
  int		  chr;
{
  char		  string [2];

  if ( flush && ! ignore )
    {
      string [0] = chr;
      string [1] = NULL;
      if ( cur_sym )
        if ( chr == '\n' )
          {
            sli_modifier ( big_str );
            big_str [0] = NULL;
          }
        else strcat ( big_str, string );
    }
  else if ( outf ) putc ( chr, outf );

  return;
} /* sli_put */
