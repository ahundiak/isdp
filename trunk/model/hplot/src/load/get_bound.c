#include "odi.h"
#include <stdio.h>
#include "HPdef.h"


/* ------- declaration and arguments ---------------------------------------- */

int get_boundaries (num_boundaries, token, token_str, src_file, out_file, line)

  uint16	* num_boundaries;	/* boundary count */
  int		* token;		/* input token */
  char		* token_str;		/* token string if more than one char */
  FILE		* src_file;		/* source file pointer */
  FILE		* out_file;		/* output file pointer */
  int		* line;			/* source line number counter */

/* -------

   Outline:
     get boundary curves of the form: { curve } { curve } ...
     first token is given as argument
     get num boundaries
       write values to output file if file pointer given
       else return count

   History:
     25-May-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;	/* return code from called functions */
  int	  j;		/* bracket counter */


/* ------- code ------------------------------------------------------------- */

  for (;;)
    {
      if (* token != '{') break;

/* write out boundary if file given, else count */
      if (out_file)
        {
          status = curve_element (src_file, out_file, line, '}');
          if( status ) return HSplot_error;;
        }
      else
        {
          ++ * num_boundaries;
          * token = get_token (token_str, src_file, line);
          for (j = 0;;)
            {
              if (* token == '{') ++ j;
              else if (* token == '}')
                {
                  if (j) -- j;
                  else break;
                }
              * token = get_token (token_str, src_file, line);
            }
        }
      * token = get_token (token_str, src_file, line);
    }

  return HSplot_success;
} /* get_boundaries */
