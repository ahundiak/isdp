#include "odi.h"
#include <stdio.h>
#include "HPdef.h"


#define if_token(x) if (!strcmp (tok_str, x))


/* ------- declaration and arguments ---------------------------------------- */

int get_pairs (num_pairs, token, tok_str, src_file, out_file, line)

  uint32 * num_pairs;	/* number of pairs seen */
  int	 * token;	/* input token */
  char	 * tok_str;	/* token string if more than one char */
  FILE	 * src_file;	/* source file pointer */
  FILE	 * out_file;	/* output file pointer */
  int	 * line;	/* source line number counter */

/* -------

   Outline:
     keywords:
       poles: 2d values, write to output if file given

   History:
     25-May-88	LMB	created.

   ------- local declarations ----------------------------------------------- */
{
  int	  status;		/* return code from called functions */


/* ------- code ------------------------------------------------------------- */

  while (* token != ';' && * token != EOF)
    {
/* ignore word "poles" */
      if_token ("poles")
        {}

/* stop if some other word or ending bracket */
      else if (* token == 'w' ||
               * token == ')' ||
               * token == '}' ||
               * token == ']')
        break;

/* better be a 2d pair, count/write them */
      else
        {
          status = get_doubles (2, NULL, token, tok_str, src_file,
              out_file, line);
          if( status ) return HSplot_error;
          if (num_pairs) ++ * num_pairs;
        }

      * token = get_token (tok_str, src_file, line);
    }

  return HSplot_success;
} /* get_pairs */
